import Foundation

// MARK: - YogaPropertyFilter

public enum YogaPropertyFilter: Sendable {
    case all
    case properties(Set<String>)
    case layout
    case transform
    case opacity
}

// MARK: - YogaTransition

/// 描述过渡动画（CSS `transition` 的等价物）。
/// 当属性变化时自动触发补间动画。
public struct YogaTransition: Sendable {
    public var duration: TimeInterval
    public var timingFunction: YogaTimingFunction
    public var delay: TimeInterval
    public var propertyFilter: YogaPropertyFilter

    public init(
        duration: TimeInterval,
        timingFunction: YogaTimingFunction = .ease,
        delay: TimeInterval = 0,
        propertyFilter: YogaPropertyFilter = .all
    ) {
        self.duration = duration
        self.timingFunction = timingFunction
        self.delay = delay
        self.propertyFilter = propertyFilter
    }
}
