import Foundation
import GWYoga
import GWYogaKit

// MARK: - YogaKeyframeStyle

/// 单个关键帧的样式值快照。
/// 包含可动画的布局属性和平台变换属性。
public class YogaKeyframeStyle {

    /// 从 YogaProperties 快照当前样式创建关键帧。
    internal convenience init(snapshot properties: YogaProperties) {
        self.init()
        let style = properties.node.style

        self.width = GWValue(value: style.width.value.unwrap(orDefault: 0), unit: style.width.unit)
        self.height = GWValue(value: style.height.value.unwrap(orDefault: 0), unit: style.height.unit)
        self.minWidth = GWValue(value: style.minWidth.value.unwrap(orDefault: 0), unit: style.minWidth.unit)
        self.maxWidth = GWValue(value: style.maxWidth.value.unwrap(orDefault: 0), unit: style.maxWidth.unit)
        self.minHeight = GWValue(value: style.minHeight.value.unwrap(orDefault: 0), unit: style.minHeight.unit)
        self.maxHeight = GWValue(value: style.maxHeight.value.unwrap(orDefault: 0), unit: style.maxHeight.unit)

        for edge in GWEdge.allCases {
            let idx = edge.rawValue
            if style.margin[idx].isDefined {
                self.margin[edge] = GWValue(value: style.margin[idx].value.unwrap(orDefault: 0), unit: style.margin[idx].unit)
            }
            if style.padding[idx].isDefined {
                self.padding[edge] = GWValue(value: style.padding[idx].value.unwrap(orDefault: 0), unit: style.padding[idx].unit)
            }
            if style.position[idx].isDefined {
                self.position[edge] = GWValue(value: style.position[idx].value.unwrap(orDefault: 0), unit: style.position[idx].unit)
            }
            if !style.border[idx].isNaN {
                self.border[edge] = style.border[idx]
            }
        }

        self.flexGrow = style.flexGrow.unwrap(orDefault: .nan)
        self.flexShrink = style.flexShrink.unwrap(orDefault: .nan)
        self.flexBasis = GWValue(value: style.flexBasis.value.unwrap(orDefault: 0), unit: style.flexBasis.unit)
        self.aspectRatio = style.aspectRatio.unwrap(orDefault: .nan)
        self.rowGap = GWValue(value: style.rowGap.value.unwrap(orDefault: 0), unit: style.rowGap.unit)
        self.columnGap = GWValue(value: style.columnGap.value.unwrap(orDefault: 0), unit: style.columnGap.unit)

        self.flexDirection = style.flexDirection
        self.justifyContent = style.justifyContent
        self.alignItems = style.alignItems
        self.alignContent = style.alignContent
        self.display = style.display
        self.overflow = style.overflow
        self.positionType = style.positionType
        self.flexWrap = style.flexWrap
        self.boxSizing = style.boxSizing
    }

    /// 从另一个关键帧拷贝所有样式值。
    public func copyAll(from other: YogaKeyframeStyle) {
        self.width = other.width
        self.height = other.height
        self.minWidth = other.minWidth
        self.maxWidth = other.maxWidth
        self.minHeight = other.minHeight
        self.maxHeight = other.maxHeight
        self.margin = other.margin
        self.padding = other.padding
        self.border = other.border
        self.position = other.position
        self.rowGap = other.rowGap
        self.columnGap = other.columnGap
        self.flexGrow = other.flexGrow
        self.flexShrink = other.flexShrink
        self.flexBasis = other.flexBasis
        self.aspectRatio = other.aspectRatio
        self.opacity = other.opacity
        self.translateX = other.translateX
        self.translateY = other.translateY
        self.scale = other.scale
        self.rotate = other.rotate
        self.flexDirection = other.flexDirection
        self.display = other.display
        self.positionType = other.positionType
        self.overflow = other.overflow
        self.flexWrap = other.flexWrap
        self.boxSizing = other.boxSizing
        self.justifyContent = other.justifyContent
        self.alignItems = other.alignItems
        self.alignContent = other.alignContent
    }

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

    @discardableResult
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

    /// 移除指定名称的已注册关键帧
    public static func unregister(_ name: String) {
        registry.removeValue(forKey: name)
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
            Self.copyAll(from: keyframes.first!.style, to: style)
            return
        }
        if progress >= keyframes.last!.progress {
            Self.copyAll(from: keyframes.last!.style, to: style)
            return
        }

        // 找到前后两个关键帧
        for i in 0..<(keyframes.count - 1) {
            let prev = keyframes[i]
            let next = keyframes[i + 1]
            if progress >= prev.progress && progress <= next.progress {
                let range = next.progress - prev.progress
                let localProgress = range > 0 ? (progress - prev.progress) / range : 0
                Self.interpolateStyle(from: prev.style, to: next.style, progress: localProgress, into: style)
                return
            }
        }
    }

    /// 在两个关键帧样式之间插值。
    internal static func interpolateStyle(from: YogaKeyframeStyle, to: YogaKeyframeStyle, progress: Float, into result: YogaKeyframeStyle) {
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

    /// 从一个关键帧样式拷贝所有值到另一个。
    internal static func copyAll(from: YogaKeyframeStyle, to: YogaKeyframeStyle) {
        to.copyAll(from: from)
    }

    // MARK: - Private

    private static var registry: [String: YogaKeyframes] = [:]
}
