import Foundation

/// An optional float value where `.nan` represents "undefined".
/// Used throughout the layout engine to represent unset or indefinite sizes.
public struct GWFloatOptional: Equatable, Sendable {
    public var value: Float

    public static let undefined = GWFloatOptional(value: .nan)
    public static let zero = GWFloatOptional(value: 0)

    public init(value: Float) {
        self.value = value
    }

    public var isDefined: Bool {
        !value.isNaN
    }

    public var isUndefined: Bool {
        value.isNaN
    }

    public func unwrap() -> Float {
        value
    }

    public func unwrap(orDefault defaultVal: Float) -> Float {
        isDefined ? value : defaultVal
    }
}

// MARK: - Arithmetic

extension GWFloatOptional {
    public static func + (lhs: GWFloatOptional, rhs: GWFloatOptional) -> GWFloatOptional {
        if lhs.isUndefined || rhs.isUndefined { return .undefined }
        return GWFloatOptional(value: lhs.value + rhs.value)
    }

    public static func - (lhs: GWFloatOptional, rhs: GWFloatOptional) -> GWFloatOptional {
        if lhs.isUndefined || rhs.isUndefined { return .undefined }
        return GWFloatOptional(value: lhs.value - rhs.value)
    }

    public static func * (lhs: GWFloatOptional, rhs: GWFloatOptional) -> GWFloatOptional {
        if lhs.isUndefined || rhs.isUndefined { return .undefined }
        return GWFloatOptional(value: lhs.value * rhs.value)
    }

    public static func + (lhs: GWFloatOptional, rhs: Float) -> GWFloatOptional {
        if lhs.isUndefined { return .undefined }
        return GWFloatOptional(value: lhs.value + rhs)
    }

    public static func - (lhs: GWFloatOptional, rhs: Float) -> GWFloatOptional {
        if lhs.isUndefined { return .undefined }
        return GWFloatOptional(value: lhs.value - rhs)
    }

    public static func += (lhs: inout GWFloatOptional, rhs: GWFloatOptional) {
        lhs = lhs + rhs
    }

    public static func > (lhs: GWFloatOptional, rhs: GWFloatOptional) -> Bool {
        if lhs.isUndefined || rhs.isUndefined { return false }
        return lhs.value > rhs.value
    }

    public static func < (lhs: GWFloatOptional, rhs: GWFloatOptional) -> Bool {
        if lhs.isUndefined || rhs.isUndefined { return false }
        return lhs.value < rhs.value
    }

    public static func >= (lhs: GWFloatOptional, rhs: GWFloatOptional) -> Bool {
        if lhs.isUndefined || rhs.isUndefined { return false }
        return lhs.value >= rhs.value
    }

    public static func <= (lhs: GWFloatOptional, rhs: GWFloatOptional) -> Bool {
        if lhs.isUndefined || rhs.isUndefined { return false }
        return lhs.value <= rhs.value
    }
}

/// Returns the maximum of two FloatOptional values.
/// If either is undefined, returns the defined one. If both undefined, returns undefined.
public func maxOrDefined(_ a: GWFloatOptional, _ b: GWFloatOptional) -> GWFloatOptional {
    if a.isUndefined { return b }
    if b.isUndefined { return a }
    return GWFloatOptional(value: max(a.value, b.value))
}

/// Returns the minimum of two FloatOptional values.
public func minOrDefined(_ a: GWFloatOptional, _ b: GWFloatOptional) -> GWFloatOptional {
    if a.isUndefined { return b }
    if b.isUndefined { return a }
    return GWFloatOptional(value: min(a.value, b.value))
}
