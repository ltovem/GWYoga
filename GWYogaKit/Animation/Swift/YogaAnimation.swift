import Foundation
import GWYoga
import GWYogaKit

// MARK: - YogaIterationCount

public enum YogaIterationCount: Sendable {
    case finite(Int)
    case infinite
}

// MARK: - YogaAnimationDirection

public enum YogaAnimationDirection: Sendable {
    case normal
    case reverse
    case alternate
    case alternateReverse
}

// MARK: - YogaAnimationFillMode

public enum YogaAnimationFillMode: Sendable {
    case none
    case forwards
    case backwards
    case both
}

// MARK: - YogaAnimation

/// 描述一个 CSS 动画的配置。
/// 等同于 CSS `animation` 简写属性的值。
public struct YogaAnimation: Sendable {
    public var name: String
    public var duration: TimeInterval
    public var timingFunction: YogaTimingFunction
    public var delay: TimeInterval
    public var iterationCount: YogaIterationCount
    public var direction: YogaAnimationDirection
    public var fillMode: YogaAnimationFillMode

    public init(
        name: String,
        duration: TimeInterval,
        timingFunction: YogaTimingFunction = .ease,
        delay: TimeInterval = 0,
        iterationCount: YogaIterationCount = .finite(1),
        direction: YogaAnimationDirection = .normal,
        fillMode: YogaAnimationFillMode = .none
    ) {
        self.name = name
        self.duration = duration
        self.timingFunction = timingFunction
        self.delay = delay
        self.iterationCount = iterationCount
        self.direction = direction
        self.fillMode = fillMode
    }

    /// 直接引用 keyframes 对象创建动画
    public init(
        keyframes: YogaKeyframes,
        duration: TimeInterval,
        timingFunction: YogaTimingFunction = .ease,
        delay: TimeInterval = 0,
        iterationCount: YogaIterationCount = .finite(1),
        direction: YogaAnimationDirection = .normal,
        fillMode: YogaAnimationFillMode = .none
    ) {
        self.init(name: keyframes.name, duration: duration,
                  timingFunction: timingFunction, delay: delay,
                  iterationCount: iterationCount, direction: direction,
                  fillMode: fillMode)
    }
}

// MARK: - CSS 简写解析

extension YogaAnimation: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = YogaAnimationParser.parse(string: value)
    }
}

// MARK: - Animation State (internal)

/// 运行时动画状态，由 YogaAnimationManager 驱动
internal final class YogaAnimationState {
    let animation: YogaAnimation
    let target: YogaProperties
    let keyframes: YogaKeyframes

    var elapsed: TimeInterval = 0
    var iteration: Int = 0
    var isReversed: Bool = false
    var isFinished: Bool = false
    var isPaused: Bool = false

    init(animation: YogaAnimation, target: YogaProperties, keyframes: YogaKeyframes) {
        self.animation = animation
        self.target = target
        self.keyframes = keyframes
    }

    /// 当前迭代的有效 progress [0, 1]
    var currentProgress: Float {
        guard animation.duration > 0 else { return 1 }
        let p = Float(elapsed / animation.duration)
        let clamped = min(max(p, 0), 1)
        let mapped = animation.timingFunction.map(clamped)
        return isReversed ? (1 - mapped) : mapped
    }

    /// 是否已完成延迟阶段
    var isPastDelay: Bool {
        elapsed >= animation.delay
    }

    /// 总迭代次数（考虑 infinite）
    var totalIterations: Int {
        switch animation.iterationCount {
        case .finite(let n): return n
        case .infinite: return .max
        }
    }
}

// MARK: - YogaAnimationParser

internal enum YogaAnimationParser {
    /// 解析 CSS animation 简写字符串
    /// 格式: "name duration timing-function delay iteration-count direction fill-mode"
    static func parse(string: String) -> YogaAnimation {
        let parts = string.split(separator: " ").map(String.init)
        var name = ""
        var duration: TimeInterval = 0
        var timingFunction: YogaTimingFunction = .ease
        var delay: TimeInterval = 0
        var iterationCount: YogaIterationCount = .finite(1)
        var direction: YogaAnimationDirection = .normal
        var fillMode: YogaAnimationFillMode = .none

        for part in parts {
            if let tf = parseTimingFunction(part) { timingFunction = tf }
            else if let dur = parseTime(part, isDelay: false) { duration = dur }
            else if let del = parseTime(part, isDelay: true) { delay = del }
            else if let ic = parseIterationCount(part) { iterationCount = ic }
            else if let dir = parseDirection(part) { direction = dir }
            else if let fm = parseFillMode(part) { fillMode = fm }
            else { name = part }
        }

        return YogaAnimation(name: name, duration: duration,
                             timingFunction: timingFunction, delay: delay,
                             iterationCount: iterationCount, direction: direction,
                             fillMode: fillMode)
    }

    private static func parseTime(_ s: String, isDelay: Bool) -> TimeInterval? {
        if s.hasSuffix("ms") {
            if let v = Double(s.dropLast(2)) { return v / 1000 }
        }
        if s.hasSuffix("s") {
            if let v = Double(s.dropLast()) { return v }
        }
        // bare number only counts as duration (first time-like value)
        if !isDelay, let v = Double(s) { return v }
        return nil
    }

    private static func parseTimingFunction(_ s: String) -> YogaTimingFunction? {
        switch s {
        case "linear": return .linear
        case "ease": return .ease
        case "ease-in": return .easeIn
        case "ease-out": return .easeOut
        case "ease-in-out": return .easeInOut
        case let c where c.hasPrefix("cubic-bezier"):
            return parseCubicBezier(c)
        case let st where st.hasPrefix("steps"):
            return parseSteps(st)
        default: return nil
        }
    }

    private static func parseCubicBezier(_ s: String) -> YogaTimingFunction? {
        let inner = s.dropFirst("cubic-bezier(".count).dropLast()
        let nums = inner.split(separator: ",").compactMap { Float($0.trimmingCharacters(in: .whitespaces)) }
        if nums.count == 4 { return .cubicBezier(nums[0], nums[1], nums[2], nums[3]) }
        return nil
    }

    private static func parseSteps(_ s: String) -> YogaTimingFunction? {
        let inner = s.dropFirst("steps(".count).dropLast()
        let parts = inner.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count >= 1, let count = Int(parts[0]) else { return nil }
        let pos: YogaStepPosition = parts.count > 1 && parts[1] == "start" ? .start : .end
        return .steps(count, stepPosition: pos)
    }

    private static func parseIterationCount(_ s: String) -> YogaIterationCount? {
        if s == "infinite" { return .infinite }
        if let n = Int(s), n > 0 { return .finite(n) }
        return nil
    }

    private static func parseDirection(_ s: String) -> YogaAnimationDirection? {
        switch s {
        case "normal": return .normal
        case "reverse": return .reverse
        case "alternate": return .alternate
        case "alternate-reverse": return .alternateReverse
        default: return nil
        }
    }

    private static func parseFillMode(_ s: String) -> YogaAnimationFillMode? {
        switch s {
        case "none": return YogaAnimationFillMode.none
        case "forwards": return .forwards
        case "backwards": return .backwards
        case "both": return .both
        default: return nil
        }
    }
}
