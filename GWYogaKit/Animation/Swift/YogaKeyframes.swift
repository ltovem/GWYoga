import Foundation
import GWYoga

// MARK: - YogaKeyframeStyle

/// 单个关键帧的样式值快照。
/// 包含可动画的布局属性和平台变换属性。
public class YogaKeyframeStyle {

    // MARK: Layout animatable properties
    public var width: GWValue = .undefined
    public var height: GWValue = .undefined
    public var minWidth: GWValue = .undefined
    public var maxWidth: GWValue = .undefined
    public var minHeight: GWValue = .undefined
    public var maxHeight: GWValue = .undefined
    public var margin: [GWEdge: GWValue] = [:]
    public var padding: [GWEdge: GWValue] = [:]
    public var border: [GWEdge: Float] = [:]
    public var position: [GWEdge: GWValue] = [:]
    public var rowGap: GWValue = .undefined
    public var columnGap: GWValue = .undefined
    public var flexGrow: Float = .nan
    public var flexShrink: Float = .nan
    public var flexBasis: GWValue = .undefined
    public var aspectRatio: Float = .nan

    // MARK: Transform / opacity (non-layout, applied via platform layer)
    public var opacity: Float = .nan
    public var translateX: Float = .nan
    public var translateY: Float = .nan
    public var scale: Float = .nan
    public var rotate: Float = .nan

    // MARK: Discrete properties (snap at 0.5)
    public var flexDirection: GWFlexDirection?
    public var display: GWDisplay?
    public var positionType: GWPositionType?
    public var overflow: GWOverflow?
    public var flexWrap: GWWrap?
    public var boxSizing: GWBoxSizing?
    public var justifyContent: GWJustify?
    public var alignItems: GWAlign?
    public var alignContent: GWAlign?
}

// MARK: - YogaKeyframeBuilder

/// 构建单个关键帧的定义。
/// 使用 `at(_:_:)` 注册每个进度位置的关键帧。
public class YogaKeyframesBuilder {
    internal private(set) var keyframes: [(progress: Float, style: YogaKeyframeStyle)] = []

    public init() {}

    /// 定义某个进度位置的关键帧样式
    public func at(_ progress: Float, _ build: (YogaKeyframeStyle) -> Void) {
        let style = YogaKeyframeStyle()
        build(style)
        keyframes.append((clamp(progress), style))
    }

    private func clamp(_ value: Float) -> Float {
        value < 0 ? 0 : (value > 1 ? 1 : value)
    }
}

// MARK: - YogaKeyframes

/// 一组命名的关键帧，可全局注册供动画引用。
public struct YogaKeyframes {
    public let name: String
    internal let keyframes: [(progress: Float, style: YogaKeyframeStyle)]

    public init(_ name: String, build: (YogaKeyframesBuilder) -> Void) {
        self.name = name
        let builder = YogaKeyframesBuilder()
        build(builder)
        self.keyframes = builder.keyframes.sorted { $0.progress < $1.progress }
    }

    /// 全局注册一个命名关键帧动画
    public static func register(_ name: String, build: (YogaKeyframesBuilder) -> Void) {
        let kf = YogaKeyframes(name, build: build)
        registry[name] = kf
    }

    /// 获取已注册的关键帧
    public static func registered(_ name: String) -> YogaKeyframes? {
        registry[name]
    }

    /// 移除全部已注册关键帧
    public static func unregisterAll() {
        registry.removeAll()
    }

    // MARK: - Internal

    /// 在给定 progress 处插值两个最近的关键帧
    internal func evaluate(at progress: Float, into style: YogaKeyframeStyle) {
        guard !keyframes.isEmpty else { return }

        if progress <= keyframes.first!.progress {
            copyAll(from: keyframes.first!.style, to: style)
            return
        }
        if progress >= keyframes.last!.progress {
            copyAll(from: keyframes.last!.style, to: style)
            return
        }

        // 找到前后两个关键帧
        for i in 0..<(keyframes.count - 1) {
            let prev = keyframes[i]
            let next = keyframes[i + 1]
            if progress >= prev.progress && progress <= next.progress {
                let range = next.progress - prev.progress
                let localProgress = range > 0 ? (progress - prev.progress) / range : 0
                interpolateStyle(from: prev.style, to: next.style, progress: localProgress, into: style)
                return
            }
        }
    }

    // MARK: - Private

    private static var registry: [String: YogaKeyframes] = [:]

    private func interpolateStyle(from: YogaKeyframeStyle, to: YogaKeyframeStyle, progress: Float, into result: YogaKeyframeStyle) {
        result.width = YogaInterpolation.interpolate(from.width, to.width, progress: progress)
        result.height = YogaInterpolation.interpolate(from.height, to.height, progress: progress)
        result.minWidth = YogaInterpolation.interpolate(from.minWidth, to.minWidth, progress: progress)
        result.maxWidth = YogaInterpolation.interpolate(from.maxWidth, to.maxWidth, progress: progress)
        result.minHeight = YogaInterpolation.interpolate(from.minHeight, to.minHeight, progress: progress)
        result.maxHeight = YogaInterpolation.interpolate(from.maxHeight, to.maxHeight, progress: progress)
        result.margin = YogaInterpolation.interpolate(from.margin, to.margin, progress: progress)
        result.padding = YogaInterpolation.interpolate(from.padding, to.padding, progress: progress)
        result.border = YogaInterpolation.interpolate(from.border, to.border, progress: progress)
        result.position = YogaInterpolation.interpolate(from.position, to.position, progress: progress)
        result.rowGap = YogaInterpolation.interpolate(from.rowGap, to.rowGap, progress: progress)
        result.columnGap = YogaInterpolation.interpolate(from.columnGap, to.columnGap, progress: progress)
        result.flexGrow = YogaInterpolation.interpolate(from.flexGrow, to.flexGrow, progress: progress)
        result.flexShrink = YogaInterpolation.interpolate(from.flexShrink, to.flexShrink, progress: progress)
        result.flexBasis = YogaInterpolation.interpolate(from.flexBasis, to.flexBasis, progress: progress)
        result.aspectRatio = YogaInterpolation.interpolate(from.aspectRatio, to.aspectRatio, progress: progress)
        result.opacity = YogaInterpolation.interpolate(from.opacity, to.opacity, progress: progress)
        result.translateX = YogaInterpolation.interpolate(from.translateX, to.translateX, progress: progress)
        result.translateY = YogaInterpolation.interpolate(from.translateY, to.translateY, progress: progress)
        result.scale = YogaInterpolation.interpolate(from.scale, to.scale, progress: progress)
        result.rotate = YogaInterpolation.interpolate(from.rotate, to.rotate, progress: progress)
        // Discrete properties
        result.flexDirection = YogaInterpolation.discrete(from.flexDirection, to.flexDirection, progress: progress)
        result.display = YogaInterpolation.discrete(from.display, to.display, progress: progress)
        result.positionType = YogaInterpolation.discrete(from.positionType, to.positionType, progress: progress)
        result.overflow = YogaInterpolation.discrete(from.overflow, to.overflow, progress: progress)
        result.flexWrap = YogaInterpolation.discrete(from.flexWrap, to.flexWrap, progress: progress)
        result.boxSizing = YogaInterpolation.discrete(from.boxSizing, to.boxSizing, progress: progress)
        result.justifyContent = YogaInterpolation.discrete(from.justifyContent, to.justifyContent, progress: progress)
        result.alignItems = YogaInterpolation.discrete(from.alignItems, to.alignItems, progress: progress)
        result.alignContent = YogaInterpolation.discrete(from.alignContent, to.alignContent, progress: progress)
    }

    private func copyAll(from: YogaKeyframeStyle, to: YogaKeyframeStyle) {
        to.width = from.width
        to.height = from.height
        to.minWidth = from.minWidth
        to.maxWidth = from.maxWidth
        to.minHeight = from.minHeight
        to.maxHeight = from.maxHeight
        to.margin = from.margin
        to.padding = from.padding
        to.border = from.border
        to.position = from.position
        to.rowGap = from.rowGap
        to.columnGap = from.columnGap
        to.flexGrow = from.flexGrow
        to.flexShrink = from.flexShrink
        to.flexBasis = from.flexBasis
        to.aspectRatio = from.aspectRatio
        to.opacity = from.opacity
        to.translateX = from.translateX
        to.translateY = from.translateY
        to.scale = from.scale
        to.rotate = from.rotate
        to.flexDirection = from.flexDirection
        to.display = from.display
        to.positionType = from.positionType
        to.overflow = from.overflow
        to.flexWrap = from.flexWrap
        to.boxSizing = from.boxSizing
        to.justifyContent = from.justifyContent
        to.alignItems = from.alignItems
        to.alignContent = from.alignContent
    }
}
