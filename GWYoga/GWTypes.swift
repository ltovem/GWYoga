import Foundation

// MARK: - GWSize

public struct GWSize: Equatable, Sendable {
    public var width: Float
    public var height: Float

    public static let zero = GWSize(width: 0, height: 0)

    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
}

// MARK: - GWInsets

public struct GWInsets: Equatable, Sendable {
    public var left: Float
    public var top: Float
    public var right: Float
    public var bottom: Float
    public var start: Float
    public var end: Float

    public static let zero = GWInsets(
        left: 0, top: 0, right: 0, bottom: 0,
        start: 0, end: 0
    )

    public init(left: Float = 0, top: Float = 0, right: Float = 0, bottom: Float = 0,
                start: Float = 0, end: Float = 0) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
        self.start = start
        self.end = end
    }
}

// MARK: - GWValue

/// Represents a CSS dimension value with unit (points, percent, auto, etc.)
public struct GWValue: Equatable, Hashable, Sendable {
    public var value: Float
    public var unit: GWUnit

    public init(value: Float, unit: GWUnit) {
        self.value = value
        self.unit = unit
    }

    // MARK: Static constructors

    public static func points(_ value: Float) -> GWValue {
        GWValue(value: value, unit: .point)
    }

    public static func percent(_ value: Float) -> GWValue {
        GWValue(value: value, unit: .percent)
    }

    public static let auto = GWValue(value: 0, unit: .auto)
    public static let undefined = GWValue(value: 0, unit: .undefined)
    public static let zero = GWValue(value: 0, unit: .point)

    public static func maxContent() -> GWValue {
        GWValue(value: 0, unit: .maxContent)
    }

    public static func fitContent() -> GWValue {
        GWValue(value: 0, unit: .fitContent)
    }

    public static func stretch() -> GWValue {
        GWValue(value: 0, unit: .stretch)
    }
}

// MARK: - GWStyleLength (internal)

/// Internal length representation with unit.
public struct GWStyleLength: Equatable, Sendable {
    public var value: GWFloatOptional
    public var unit: GWUnit

    public static func points(_ v: Float) -> GWStyleLength {
        GWStyleLength(value: GWFloatOptional(value: v), unit: .point)
    }

    public static func percent(_ v: Float) -> GWStyleLength {
        GWStyleLength(value: GWFloatOptional(value: v), unit: .percent)
    }

    public static let auto = GWStyleLength(value: .undefined, unit: .auto)
    public static let undefined = GWStyleLength(value: .undefined, unit: .undefined)
    public static let maxContent = GWStyleLength(value: .undefined, unit: .maxContent)
    public static let fitContent = GWStyleLength(value: .undefined, unit: .fitContent)
    public static let stretch = GWStyleLength(value: .undefined, unit: .stretch)

    public var isDefined: Bool { unit != .undefined }
    public var isAuto: Bool { unit == .auto }
    public var isPoints: Bool { unit == .point && value.isDefined }
    public var isPercent: Bool { unit == .percent }

    /// Resolves this length against a reference length.
    /// For points: returns the value directly.
    /// For percent: returns value/100 * referenceLength.
    /// For auto/undefined: returns undefined.
    public func resolve(referenceLength: Float) -> GWFloatOptional {
        switch unit {
        case .point:
            return value
        case .percent:
            if value.isUndefined { return .undefined }
            return GWFloatOptional(value: value.unwrap() * referenceLength * 0.01)
        default:
            return .undefined
        }
    }
}

// MARK: - GWStyleSizeLength (internal)

/// Extended length that also supports max-content, fit-content, and stretch keywords.
public struct GWStyleSizeLength: Equatable, Sendable {
    public var value: GWFloatOptional
    public var unit: GWUnit

    public static func points(_ v: Float) -> GWStyleSizeLength {
        GWStyleSizeLength(value: GWFloatOptional(value: v), unit: .point)
    }

    public static func percent(_ v: Float) -> GWStyleSizeLength {
        GWStyleSizeLength(value: GWFloatOptional(value: v), unit: .percent)
    }

    public static let auto = GWStyleSizeLength(value: .undefined, unit: .auto)
    public static let undefined = GWStyleSizeLength(value: .undefined, unit: .undefined)
    public static let maxContent = GWStyleSizeLength(value: .undefined, unit: .maxContent)
    public static let fitContent = GWStyleSizeLength(value: .undefined, unit: .fitContent)
    public static let stretch = GWStyleSizeLength(value: .undefined, unit: .stretch)
    public static func stretch(_ value: Float) -> GWStyleSizeLength {
        GWStyleSizeLength(value: GWFloatOptional(value: value), unit: .stretch)
    }

    public var isDefined: Bool { unit != .undefined }
    public var isAuto: Bool { unit == .auto }
    public var isPoints: Bool { unit == .point && value.isDefined }
    public var isPercent: Bool { unit == .percent }
    public var isMaxContent: Bool { unit == .maxContent }
    public var isFitContent: Bool { unit == .fitContent }
    public var isStretch: Bool { unit == .stretch }

    /// Resolves this size length against a reference length.
    /// For points: returns the value directly.
    /// For percent: returns value/100 * referenceLength.
    /// For all other units (auto, maxContent, etc.): returns undefined.
    public func resolve(referenceLength: Float) -> GWFloatOptional {
        switch unit {
        case .point:
            return value
        case .percent:
            if value.isUndefined { return .undefined }
            return GWFloatOptional(value: value.unwrap() * referenceLength * 0.01)
        default:
            return .undefined
        }
    }
}

// MARK: - Conversions between GWValue and GWStyleLength/StyleSizeLength

internal extension GWValue {
    init(_ length: GWStyleLength) {
        self.value = length.value.unwrap(orDefault: 0)
        self.unit = length.unit
    }

    init(_ sizeLength: GWStyleSizeLength) {
        self.value = sizeLength.value.unwrap(orDefault: 0)
        self.unit = sizeLength.unit
    }
}

internal extension GWStyleLength {
    init(_ value: GWValue) {
        switch value.unit {
        case .undefined, .auto, .maxContent, .fitContent, .stretch:
            self = GWStyleLength(value: .undefined, unit: value.unit)
        case .point:
            self = GWStyleLength(value: GWFloatOptional(value: value.value), unit: .point)
        case .percent:
            self = GWStyleLength(value: GWFloatOptional(value: value.value), unit: .percent)
        }
    }
}

internal extension GWStyleSizeLength {
    init(_ value: GWValue) {
        switch value.unit {
        case .undefined:
            self = .undefined
        case .auto:
            self = .auto
        case .maxContent:
            self = .maxContent
        case .fitContent:
            self = .fitContent
        case .stretch:
            self = .stretch
        case .point:
            self = .points(value.value)
        case .percent:
            self = .percent(value.value)
        }
    }
}

// MARK: - 全局辅助函数（对应 C++ 中的自由函数）

/// 解析 GWStyleLength，返回 GWFloatOptional
internal func resolveLength(_ length: GWStyleLength, _ referenceLength: Float) -> GWFloatOptional {
    length.resolve(referenceLength: referenceLength)
}

/// 解析 GWStyleSizeLength，返回 GWFloatOptional
internal func resolveStyleSizeLength(_ length: GWStyleSizeLength, _ referenceLength: Float) -> GWFloatOptional {
    length.resolve(referenceLength: referenceLength)
}

/// 将 GWFlexDirection 映射到对应的 GWDimension
internal func dimension(_ axis: GWFlexDirection) -> GWDimension {
    axis.dimension
}

/// 返回 flex-start 方向的物理边
internal func flexStartEdge(_ axis: GWFlexDirection) -> GWEdge {
    axis.flexStartEdge
}

/// 返回 flex-end 方向的物理边
internal func flexEndEdge(_ axis: GWFlexDirection) -> GWEdge {
    axis.flexEndEdge
}

/// 返回 flex-start 方向的物理边（用于 layout API 需要 GWPhysicalEdge 时）
internal func flexStartPhysicalEdge(_ axis: GWFlexDirection) -> GWPhysicalEdge {
    switch axis {
    case .column: return .top
    case .columnReverse: return .bottom
    case .row: return .left
    case .rowReverse: return .right
    }
}

/// 返回 flex-end 方向的物理边（用于 layout API 需要 GWPhysicalEdge 时）
internal func flexEndPhysicalEdge(_ axis: GWFlexDirection) -> GWPhysicalEdge {
    switch axis {
    case .column: return .bottom
    case .columnReverse: return .top
    case .row: return .right
    case .rowReverse: return .left
    }
}

/// 返回 inline-start 方向的物理边（考虑 LTR/RTL）
internal func inlineStartEdge(_ axis: GWFlexDirection, _ direction: GWDirection) -> GWEdge {
    GWFlexDirection.inlineStartEdge(for: axis, layoutDirection: direction)
}

/// 返回 inline-end 方向的物理边（考虑 LTR/RTL）
internal func inlineEndEdge(_ axis: GWFlexDirection, _ direction: GWDirection) -> GWEdge {
    GWFlexDirection.inlineEndEdge(for: axis, layoutDirection: direction)
}

/// 将 GWEdge 转换为 GWPhysicalEdge（仅对具体物理边有效）
internal func physicalEdge(from edge: GWEdge) -> GWPhysicalEdge? {
    GWPhysicalEdge(from: edge)
}

/// 按 rawValue 将 GWEdge 转换为 GWPhysicalEdge（仅对 left=0, top=1, right=2, bottom=3 有效）
internal func asPhysical(_ edge: GWEdge) -> GWPhysicalEdge {
    // 匹配 rawValue（left=0, top=1, right=2, bottom=3）
    GWPhysicalEdge(rawValue: edge.rawValue) ?? .left
}

/// 根据方向确定解析后的 flex direction
internal func resolveDirection(_ flexDirection: GWFlexDirection, _ direction: GWDirection) -> GWFlexDirection {
    flexDirection.resolved(for: direction)
}

/// 解析交叉轴方向
internal func resolveCrossDirection(_ flexDirection: GWFlexDirection, _ direction: GWDirection) -> GWFlexDirection {
    flexDirection.isColumn
        ? resolveDirection(.row, direction)
        : .column
}
