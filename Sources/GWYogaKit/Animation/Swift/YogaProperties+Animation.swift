import Foundation
import GWYoga
import GWYogaKit
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - 关联对象 Key

private var animationNameKey: UInt8 = 0
private var animationDurationKey: UInt8 = 0
private var animationTimingKey: UInt8 = 0
private var animationDelayKey: UInt8 = 0
private var animationIterationKey: UInt8 = 0
private var animationDirectionKey: UInt8 = 0
private var animationFillModeKey: UInt8 = 0
private var animationPausedKey: UInt8 = 0
private var animationDidStartKey: UInt8 = 0
private var animationDidEndKey: UInt8 = 0
private var animationDidRepeatKey: UInt8 = 0
private var transitionKey: UInt8 = 0

// MARK: - YogaProperties 动画扩展

public extension YogaProperties {

    // MARK: Animation Properties

    var animationName: String? {
        get { objc_getAssociatedObject(self, &animationNameKey) as? String }
        set { objc_setAssociatedObject(self, &animationNameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDuration: TimeInterval {
        get { (objc_getAssociatedObject(self, &animationDurationKey) as? TimeInterval) ?? 0.3 }
        set { objc_setAssociatedObject(self, &animationDurationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationTimingFunction: YogaTimingFunction {
        get { (objc_getAssociatedObject(self, &animationTimingKey) as? YogaTimingFunction) ?? .ease }
        set { objc_setAssociatedObject(self, &animationTimingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDelay: TimeInterval {
        get { (objc_getAssociatedObject(self, &animationDelayKey) as? TimeInterval) ?? 0 }
        set { objc_setAssociatedObject(self, &animationDelayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationIterationCount: YogaIterationCount {
        get { (objc_getAssociatedObject(self, &animationIterationKey) as? YogaIterationCount) ?? .finite(1) }
        set { objc_setAssociatedObject(self, &animationIterationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDirection: YogaAnimationDirection {
        get { (objc_getAssociatedObject(self, &animationDirectionKey) as? YogaAnimationDirection) ?? .normal }
        set { objc_setAssociatedObject(self, &animationDirectionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationFillMode: YogaAnimationFillMode {
        get { (objc_getAssociatedObject(self, &animationFillModeKey) as? YogaAnimationFillMode) ?? .none }
        set { objc_setAssociatedObject(self, &animationFillModeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: 合并赋值

    var animation: YogaAnimation? {
        get {
            guard let name = animationName else { return nil }
            return YogaAnimation(name: name, duration: animationDuration,
                                 timingFunction: animationTimingFunction,
                                 delay: animationDelay,
                                 iterationCount: animationIterationCount,
                                 direction: animationDirection,
                                 fillMode: animationFillMode)
        }
        set {
            guard let anim = newValue else {
                YogaAnimationManager.shared.stopAnimation(on: self)
                animationName = nil
                return
            }
            animationName = anim.name
            animationDuration = anim.duration
            animationTimingFunction = anim.timingFunction
            animationDelay = anim.delay
            animationIterationCount = anim.iterationCount
            animationDirection = anim.direction
            animationFillMode = anim.fillMode
            YogaAnimationManager.shared.startAnimation(anim, on: self)
        }
    }

    // MARK: 控制

    var animationPaused: Bool {
        get { (objc_getAssociatedObject(self, &animationPausedKey) as? Bool) ?? false }
        set {
            objc_setAssociatedObject(self, &animationPausedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            YogaAnimationManager.shared.setPaused(newValue, on: self)
        }
    }

    // MARK: 事件回调

    var animationDidStart: ((String) -> Void)? {
        get { objc_getAssociatedObject(self, &animationDidStartKey) as? (String) -> Void }
        set { objc_setAssociatedObject(self, &animationDidStartKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDidEnd: ((String, Bool) -> Void)? {
        get { objc_getAssociatedObject(self, &animationDidEndKey) as? (String, Bool) -> Void }
        set { objc_setAssociatedObject(self, &animationDidEndKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDidRepeat: ((String) -> Void)? {
        get { objc_getAssociatedObject(self, &animationDidRepeatKey) as? (String) -> Void }
        set { objc_setAssociatedObject(self, &animationDidRepeatKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: Transition

    var transition: YogaTransition? {
        get { objc_getAssociatedObject(self, &transitionKey) as? YogaTransition }
        set { objc_setAssociatedObject(self, &transitionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: - 便捷动画

    /// 便捷动画：在当前值基础上执行过渡动画。
    ///
    /// 用法：
    /// ```swift
    /// view.style.animate(duration: 0.3) {
    ///     $0.width = 200
    ///     $0.height = 300
    /// }
    /// ```
    /// - Parameters:
    ///   - duration: 动画时长（秒）
    ///   - delay: 延迟（秒）
    ///   - timingFunction: 计时函数（默认 .ease）
    ///   - changes: 设置目标样式的闭包
    /// - Returns: 动画名称（可用于停止动画）
    @discardableResult
    func animate(
        duration: TimeInterval,
        delay: TimeInterval = 0,
        timingFunction: YogaTimingFunction = .ease,
        changes: (YogaProperties) -> Void
    ) -> String {
        let animName = UUID().uuidString
        let fromStyle = YogaKeyframeStyle(snapshot: self)
        changes(self)
        let toStyle = YogaKeyframeStyle(snapshot: self)

        YogaKeyframes(animName) { builder in
            builder.at(0) { $0.copyAll(from: fromStyle) }
            builder.at(1) { $0.copyAll(from: toStyle) }
        }

        let anim = YogaAnimation(
            name: animName,
            duration: duration,
            timingFunction: timingFunction,
            delay: delay,
            fillMode: .forwards
        )
        YogaAnimationManager.shared.startAnimation(anim, on: self)

        // 动画结束后自动清理注册的关键帧
        animationDidEnd = { [weak self] name, _ in
            guard name == animName else { return }
            YogaKeyframes.unregister(animName)
            self?.animationDidEnd = nil
        }

        return animName
    }

    /// 弹簧动画便捷方法。
    ///
    /// 用法：
    /// ```swift
    /// view.style.animate(duration: 0.5, dampingRatio: 0.6) {
    ///     $0.width = 200
    /// }
    /// ```
    /// - Parameters:
    ///   - duration: 动画时长（秒）
    ///   - delay: 延迟（秒）
    ///   - dampingRatio: 阻尼比（0=无阻尼振荡, 1=临界阻尼）
    ///   - initialVelocity: 初始速度（相对单位）
    ///   - changes: 设置目标样式的闭包
    /// - Returns: 动画名称（可用于停止动画）
    @discardableResult
    func animate(
        duration: TimeInterval,
        delay: TimeInterval = 0,
        dampingRatio: CGFloat,
        initialVelocity: CGFloat = 0,
        changes: (YogaProperties) -> Void
    ) -> String {
        let animName = UUID().uuidString
        let fromStyle = YogaKeyframeStyle(snapshot: self)
        changes(self)
        let toStyle = YogaKeyframeStyle(snapshot: self)

        let keyframeCount = 60
        let dt = duration / Double(keyframeCount - 1)

        YogaKeyframes(animName) { builder in
            for i in 0..<keyframeCount {
                let t = Double(i) * dt
                let progress = self.springProgress(
                    at: t,
                    duration: duration,
                    dampingRatio: dampingRatio,
                    initialVelocity: initialVelocity
                )
                let clamped = min(max(progress, 0), 1)
                let style = YogaKeyframeStyle()
                YogaKeyframes.interpolateStyle(from: fromStyle, to: toStyle, progress: clamped, into: style)
                builder.at(Float(i) / Float(keyframeCount - 1)) { target in
                    target.copyAll(from: style)
                }
            }
        }

        let anim = YogaAnimation(
            name: animName,
            duration: duration,
            delay: delay,
            fillMode: .forwards
        )
        YogaAnimationManager.shared.startAnimation(anim, on: self)

        animationDidEnd = { [weak self] name, _ in
            guard name == animName else { return }
            YogaKeyframes.unregister(animName)
            self?.animationDidEnd = nil
        }

        return animName
    }

    // MARK: - 内部

    /// 计算弹簧动画在给定时间点的进度值 [0, 1]（可能 >1 表示 overshoot）。
    private func springProgress(
        at time: TimeInterval,
        duration: TimeInterval,
        dampingRatio: CGFloat,
        initialVelocity: CGFloat
    ) -> Float {
        guard duration > 0 else { return 1 }
        guard dampingRatio < 1 else { return min(Float(time / duration), 1) }

        let t = Float(time)
        let dur = Float(duration)
        // 估算自然频率：使弹簧在给定持续时间内大致完成一次振荡
        let omega_n: Float = 2 * Float.pi * 1.5 / dur
        let zeta = Float(dampingRatio)
        let omega_d = omega_n * sqrt(1 - zeta * zeta)
        let v0 = Float(initialVelocity)

        let decay = exp(-zeta * omega_n * t)
        let A: Float = 1
        let B = (zeta / sqrt(1 - zeta * zeta) + v0 / omega_d)
        let displacement: Float = A - decay * (cos(omega_d * t) + B * sin(omega_d * t))

        return displacement
    }
}

// MARK: - YogaSpringConfig

/// 弹簧动画配置。
public struct YogaSpringConfig: Sendable {
    /// 阻尼比（0 = 无阻尼振荡, 1 = 临界阻尼）
    public var dampingRatio: CGFloat
    /// 初始速度（相对单位/秒）
    public var initialVelocity: CGFloat

    public init(dampingRatio: CGFloat, initialVelocity: CGFloat = 0) {
        self.dampingRatio = dampingRatio
        self.initialVelocity = initialVelocity
    }

    public static let `default` = YogaSpringConfig(dampingRatio: 0.5)
}
