import Foundation
import QuartzCore
import GWYoga
import GWYogaKit
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - YogaAnimationManager

/// 动画运行时引擎。
/// 驱动所有活跃的 keyframe 动画和 transition 动画。
internal final class YogaAnimationManager {

    static let shared = YogaAnimationManager()

    private var displayLink: AnyObject? // CADisplayLink on iOS, Timer fallback on macOS
    private var animations: [YogaAnimationState] = []
    private let lock = NSLock()

    private init() {}

    // MARK: - 动画生命周期

    /// 启动一个动画
    func startAnimation(_ animation: YogaAnimation, on target: YogaProperties) {
        guard let keyframes = YogaKeyframes.registered(animation.name) else { return }

        let state = YogaAnimationState(animation: animation, target: target, keyframes: keyframes)
        lock.lock()
        animations.append(state)
        lock.unlock()

        ensureDisplayLinkRunning()
    }

    /// 停止指定视图上的动画
    func stopAnimation(on target: YogaProperties, name: String? = nil) {
        lock.lock()
        if let n = name {
            animations.removeAll { $0.target === target && $0.animation.name == n }
        } else {
            animations.removeAll { $0.target === target }
        }
        lock.unlock()
    }

    /// 暂停/恢复指定视图的动画
    func setPaused(_ paused: Bool, on target: YogaProperties) {
        lock.lock()
        for anim in animations where anim.target === target {
            anim.isPaused = paused
        }
        lock.unlock()
    }

    /// 是否正在播放
    func isAnimating(target: YogaProperties) -> Bool {
        lock.lock()
        let result = animations.contains { $0.target === target && !$0.isFinished }
        lock.unlock()
        return result
    }

    // MARK: - 显示链接

    private func ensureDisplayLinkRunning() {
        guard displayLink == nil else { return }
        #if os(iOS)
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
        #elseif os(macOS)
        let timer = Timer(timeInterval: 1.0 / 60.0, target: self,
                          selector: #selector(tick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        displayLink = timer
        #endif
    }

    @objc private func tick() {
        let dt: TimeInterval = 1.0 / 60.0

        lock.lock()
        var finished: [YogaAnimationState] = []

        for anim in animations {
            guard !anim.isFinished else { continue }
            if anim.isPaused { continue }

            anim.elapsed += dt

            // Handle delay phase
            if !anim.isPastDelay {
                if anim.animation.fillMode == .backwards || anim.animation.fillMode == .both {
                    applyKeyframe(progress: 0, to: anim)
                }
                continue
            }

            let effectiveElapsed = anim.elapsed - anim.animation.delay
            let duration = anim.animation.duration

            if effectiveElapsed >= duration * TimeInterval(anim.iteration + 1) {
                anim.iteration += 1
                if anim.iteration >= anim.totalIterations {
                    if anim.animation.fillMode == .forwards || anim.animation.fillMode == .both {
                        let finalProgress: Float = anim.isReversed ? 0 : 1
                        applyKeyframe(progress: finalProgress, to: anim)
                    }
                    applyLayout(target: anim.target)
                    anim.isFinished = true
                    finished.append(anim)
                    continue
                }
                if anim.animation.direction == .alternate || anim.animation.direction == .alternateReverse {
                    anim.isReversed.toggle()
                }
            }

            applyKeyframe(progress: anim.currentProgress, to: anim)
            applyLayout(target: anim.target)
        }

        for anim in finished {
            anim.target.animationDidEnd?(anim.animation.name, true)
        }

        animations.removeAll { $0.isFinished }
        lock.unlock()

        if animations.isEmpty, let link = displayLink {
            #if os(iOS)
            (link as? CADisplayLink)?.invalidate()
            #elseif os(macOS)
            (link as? Timer)?.invalidate()
            #endif
            displayLink = nil
        }
    }

    // MARK: - Apply Keyframe

    private func applyKeyframe(progress: Float, to state: YogaAnimationState) {
        let style = YogaKeyframeStyle()
        state.keyframes.evaluate(at: progress, into: style)
        applyStyle(style, to: state.target)
    }

    private func applyStyle(_ style: YogaKeyframeStyle, to target: YogaProperties) {
        func isDefined(_ v: GWValue) -> Bool { v.unit != .undefined }

        if isDefined(style.width) { target.node.style.setWidth(style.width) }
        if isDefined(style.height) { target.node.style.setHeight(style.height) }
        if isDefined(style.minWidth) { target.node.style.setMinWidth(style.minWidth) }
        if isDefined(style.maxWidth) { target.node.style.setMaxWidth(style.maxWidth) }
        if isDefined(style.minHeight) { target.node.style.setMinHeight(style.minHeight) }
        if isDefined(style.maxHeight) { target.node.style.setMaxHeight(style.maxHeight) }
        if !style.margin.isEmpty { applyMargin(style.margin, to: &target.node.style) }
        if !style.padding.isEmpty { applyPadding(style.padding, to: &target.node.style) }
        if !style.border.isEmpty { applyBorder(style.border, to: &target.node.style) }
        if !style.position.isEmpty { applyPosition(style.position, to: &target.node.style) }
        if isDefined(style.rowGap) { target.node.style.setGap(for: .row, style.rowGap) }
        if isDefined(style.columnGap) { target.node.style.setGap(for: .column, style.columnGap) }
        if !style.flexGrow.isNaN { target.node.style.flexGrow = GWFloatOptional(value: style.flexGrow) }
        if !style.flexShrink.isNaN { target.node.style.flexShrink = GWFloatOptional(value: style.flexShrink) }
        if isDefined(style.flexBasis) { target.node.style.setFlexBasis(style.flexBasis) }
        if !style.aspectRatio.isNaN { target.node.style.aspectRatio = GWFloatOptional(value: style.aspectRatio) }

        if let v = style.flexDirection { target.node.style.flexDirection = v }
        if let v = style.display { target.node.style.display = v }
        if let v = style.positionType { target.node.style.positionType = v }
        if let v = style.overflow { target.node.style.overflow = v }
        if let v = style.flexWrap { target.node.style.flexWrap = v }
        if let v = style.boxSizing { target.node.style.boxSizing = v }
        if let v = style.justifyContent { target.node.style.justifyContent = v }
        if let v = style.alignItems { target.node.style.alignItems = v }
        if let v = style.alignContent { target.node.style.alignContent = v }

        target.node.markDirty()
    }

    private func applyLayout(target: YogaProperties) {
        guard let view = target.view else { return }
        #if os(iOS)
        view.setNeedsLayout()
        #elseif os(macOS)
        view.needsLayout = true
        #endif
    }

    // MARK: - Helpers (use public setter methods instead of internal GWStyle extensions)

    private func applyMargin(_ dict: [GWEdge: GWValue], to style: inout GWStyle) {
        for (edge, value) in dict { style.setMargin(for: edge, value) }
    }

    private func applyPadding(_ dict: [GWEdge: GWValue], to style: inout GWStyle) {
        for (edge, value) in dict { style.setPadding(for: edge, value) }
    }

    private func applyBorder(_ dict: [GWEdge: Float], to style: inout GWStyle) {
        for (edge, value) in dict { style.setBorder(for: edge, value) }
    }

    private func applyPosition(_ dict: [GWEdge: GWValue], to style: inout GWStyle) {
        for (edge, value) in dict { style.setPosition(for: edge, value) }
    }
}
