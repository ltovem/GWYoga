import Foundation
import GWYoga
#if os(iOS)
import UIKit
#endif

// MARK: - YGKTimingFunction

/// ObjC-compatible timing function.
@objc(YGKTimingFunction)
public class YGKTimingFunction: NSObject {
    @objc public var name: String
    @objc public var controlPoints: [Float]

    @objc public init(name: String, controlPoints: [Float] = []) {
        self.name = name
        self.controlPoints = controlPoints
    }

    @objc public static func linear() -> YGKTimingFunction {
        YGKTimingFunction(name: "linear")
    }

    @objc public static func ease() -> YGKTimingFunction {
        YGKTimingFunction(name: "ease")
    }

    @objc public static func easeIn() -> YGKTimingFunction {
        YGKTimingFunction(name: "ease-in")
    }

    @objc public static func easeOut() -> YGKTimingFunction {
        YGKTimingFunction(name: "ease-out")
    }

    @objc public static func easeInOut() -> YGKTimingFunction {
        YGKTimingFunction(name: "ease-in-out")
    }

    @objc public static func cubicBezier(_ x1: Float, _ y1: Float, _ x2: Float, _ y2: Float) -> YGKTimingFunction {
        YGKTimingFunction(name: "cubic-bezier", controlPoints: [x1, y1, x2, y2])
    }

    @objc public static func steps(_ count: Int, position: YGKStepPosition) -> YGKTimingFunction {
        YGKTimingFunction(name: "steps", controlPoints: [Float(count), Float(position.rawValue)])
    }
}

// MARK: - YGKAnimation

/// ObjC-compatible animation configuration.
@objc(YGKAnimation)
public class YGKAnimation: NSObject {
    @objc public var name: String
    @objc public var duration: TimeInterval
    @objc public var timingFunction: YGKTimingFunction
    @objc public var delay: TimeInterval
    @objc public var direction: YGKAnimationDirection
    @objc public var fillMode: YGKAnimationFillMode

    @objc public init(
        name: String,
        duration: TimeInterval,
        timingFunction: YGKTimingFunction?,
        delay: TimeInterval,
        direction: YGKAnimationDirection,
        fillMode: YGKAnimationFillMode
    ) {
        self.name = name
        self.duration = duration
        self.timingFunction = timingFunction ?? .ease()
        self.delay = delay
        self.direction = direction
        self.fillMode = fillMode
    }

    @objc public convenience init(name: String, duration: TimeInterval) {
        self.init(name: name, duration: duration,
                  timingFunction: nil, delay: 0,
                  direction: .normal, fillMode: .none)
    }
}

// MARK: - YGKTransition

/// ObjC-compatible transition configuration.
@objc(YGKTransition)
public class YGKTransition: NSObject {
    @objc public var duration: TimeInterval
    @objc public var timingFunction: YGKTimingFunction
    @objc public var delay: TimeInterval
    @objc public var propertyFilter: YGKPropertyFilter

    @objc public init(
        duration: TimeInterval,
        timingFunction: YGKTimingFunction?,
        delay: TimeInterval,
        propertyFilter: YGKPropertyFilter
    ) {
        self.duration = duration
        self.timingFunction = timingFunction ?? .ease()
        self.delay = delay
        self.propertyFilter = propertyFilter
    }

    @objc public convenience init(duration: TimeInterval) {
        self.init(duration: duration, timingFunction: nil, delay: 0, propertyFilter: .all)
    }
}
