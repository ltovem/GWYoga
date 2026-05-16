import Foundation

// MARK: - 数值比较工具（对应 C++ yoga/numeric/Comparison.h）

/// 检查浮点值是否为 NaN（undefined）
internal func isUndefined(_ value: Float) -> Bool {
    value.isNaN
}

/// 检查浮点值是否已定义（非 NaN）
internal func isDefined(_ value: Float) -> Bool {
    !value.isNaN
}

/// 返回两个值中的较大者，处理 NaN：如果一方为 NaN 则返回另一方
internal func maxOrDefined(_ a: Float, _ b: Float) -> Float {
    if isDefined(a) && isDefined(b) { return max(a, b) }
    return isUndefined(a) ? b : a
}

/// 返回两个值中的较小者，处理 NaN：如果一方为 NaN 则返回另一方
internal func minOrDefined(_ a: Float, _ b: Float) -> Float {
    if isDefined(a) && isDefined(b) { return min(a, b) }
    return isUndefined(a) ? b : a
}

/// 浮点值近似相等（epsilon = 0.0001），双方都为 NaN 时也算相等
internal func inexactEquals(_ a: Float, _ b: Float) -> Bool {
    if isDefined(a) && isDefined(b) {
        return abs(a - b) < 0.0001
    }
    return isUndefined(a) && isUndefined(b)
}

/// 浮点值近似相等（double 精度）
internal func inexactEquals(_ a: Double, _ b: Double) -> Bool {
    if isDefined(Float(a)) && isDefined(Float(b)) {
        return abs(a - b) < 0.0001
    }
    return isUndefined(Float(a)) && isUndefined(Float(b))
}
