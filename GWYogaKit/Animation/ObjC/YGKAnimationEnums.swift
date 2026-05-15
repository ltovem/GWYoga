import Foundation
import GWYoga
import GWYogaKit

// MARK: - YGKAnimationDirection

@objc public enum YGKAnimationDirection: Int {
    case normal = 0
    case reverse = 1
    case alternate = 2
    case alternateReverse = 3
}

// MARK: - YGKAnimationFillMode

@objc public enum YGKAnimationFillMode: Int {
    case none = 0
    case forwards = 1
    case backwards = 2
    case both = 3
}

// MARK: - YGKStepPosition

@objc public enum YGKStepPosition: Int {
    case start = 0
    case end = 1
}

// MARK: - YGKPropertyFilter

@objc public enum YGKPropertyFilter: Int {
    case all = 0
    case layout = 1
    case transform = 2
    case opacity = 3
}
