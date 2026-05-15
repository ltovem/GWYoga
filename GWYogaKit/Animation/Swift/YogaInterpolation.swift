import Foundation
import GWYoga

// MARK: - YogaInterpolation

/// 数值插值工具，用于关键帧之间的补间计算。
internal enum YogaInterpolation {

    /// 在两个 GWValue 之间按 progress [0,1] 插值
    static func interpolate(_ from: GWValue, _ to: GWValue, progress: Float) -> GWValue {
        guard from.unit == to.unit else {
            // 单位不同时，在 progress=0.5 处 snap
            return progress < 0.5 ? from : to
        }
        let p = clamp(progress)
        let v = from.value + (to.value - from.value) * p
        return GWValue(value: v, unit: from.unit)
    }

    /// 在两个 Float 之间按 progress [0,1] 插值
    static func interpolate(_ from: Float, _ to: Float, progress: Float) -> Float {
        from + (to - from) * clamp(progress)
    }

    /// 在两个 [GWEdge: GWValue] 字典之间插值（合并所有 key 的并集）
    static func interpolate(_ from: [GWEdge: GWValue], _ to: [GWEdge: GWValue], progress: Float) -> [GWEdge: GWValue] {
        let allKeys = Set(from.keys).union(to.keys)
        var result: [GWEdge: GWValue] = [:]
        for key in allKeys {
            let f = from[key] ?? GWValue(value: 0, unit: .point)
            let t = to[key] ?? GWValue(value: 0, unit: .point)
            result[key] = interpolate(f, t, progress: progress)
        }
        return result
    }

    /// 在两个 [GWEdge: Float] 字典之间插值
    static func interpolate(_ from: [GWEdge: Float], _ to: [GWEdge: Float], progress: Float) -> [GWEdge: Float] {
        let allKeys = Set(from.keys).union(to.keys)
        var result: [GWEdge: Float] = [:]
        for key in allKeys {
            result[key] = interpolate(from[key] ?? 0, to[key] ?? 0, progress: progress)
        }
        return result
    }

    /// 离散属性：在 progress=0.5 处切换
    static func discrete<T>(_ from: T, _ to: T, progress: Float) -> T {
        progress < 0.5 ? from : to
    }

    private static func clamp(_ value: Float) -> Float {
        value < 0 ? 0 : (value > 1 ? 1 : value)
    }
}
