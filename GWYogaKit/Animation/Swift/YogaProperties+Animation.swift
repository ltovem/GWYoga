import Foundation
import GWYoga
import GWYogaKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - 关联对象 Key

private var animationNameKey: UInt8 = 0
private var animationDurationKey: UInt8 = 0
private var animationTimingKey: UInt8 = 0
private var animationDelayKey: UInt8 = 0
private var animationIterationKey: UInt8 = 0
private var animationDirectionKey: UInt8 = 0
private var animationFillModeKey: UInt8 = 0
private var animationPausedKey: UInt8 = 0
private var animationDidStartKey: UInt8 = 0
private var animationDidEndKey: UInt8 = 0
private var animationDidRepeatKey: UInt8 = 0
private var transitionKey: UInt8 = 0

// MARK: - YogaProperties 动画扩展

public extension YogaProperties {

    // MARK: Animation Properties

    var animationName: String? {
        get { objc_getAssociatedObject(self, &animationNameKey) as? String }
        set { objc_setAssociatedObject(self, &animationNameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDuration: TimeInterval {
        get { (objc_getAssociatedObject(self, &animationDurationKey) as? TimeInterval) ?? 0.3 }
        set { objc_setAssociatedObject(self, &animationDurationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationTimingFunction: YogaTimingFunction {
        get { (objc_getAssociatedObject(self, &animationTimingKey) as? YogaTimingFunction) ?? .ease }
        set { objc_setAssociatedObject(self, &animationTimingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDelay: TimeInterval {
        get { (objc_getAssociatedObject(self, &animationDelayKey) as? TimeInterval) ?? 0 }
        set { objc_setAssociatedObject(self, &animationDelayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationIterationCount: YogaIterationCount {
        get { (objc_getAssociatedObject(self, &animationIterationKey) as? YogaIterationCount) ?? .finite(1) }
        set { objc_setAssociatedObject(self, &animationIterationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDirection: YogaAnimationDirection {
        get { (objc_getAssociatedObject(self, &animationDirectionKey) as? YogaAnimationDirection) ?? .normal }
        set { objc_setAssociatedObject(self, &animationDirectionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationFillMode: YogaAnimationFillMode {
        get { (objc_getAssociatedObject(self, &animationFillModeKey) as? YogaAnimationFillMode) ?? .none }
        set { objc_setAssociatedObject(self, &animationFillModeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: 合并赋值

    var animation: YogaAnimation? {
        get {
            guard let name = animationName else { return nil }
            return YogaAnimation(name: name, duration: animationDuration,
                                 timingFunction: animationTimingFunction,
                                 delay: animationDelay,
                                 iterationCount: animationIterationCount,
                                 direction: animationDirection,
                                 fillMode: animationFillMode)
        }
        set {
            guard let anim = newValue else {
                YogaAnimationManager.shared.stopAnimation(on: self)
                animationName = nil
                return
            }
            animationName = anim.name
            animationDuration = anim.duration
            animationTimingFunction = anim.timingFunction
            animationDelay = anim.delay
            animationIterationCount = anim.iterationCount
            animationDirection = anim.direction
            animationFillMode = anim.fillMode
            YogaAnimationManager.shared.startAnimation(anim, on: self)
        }
    }

    // MARK: 控制

    var animationPaused: Bool {
        get { (objc_getAssociatedObject(self, &animationPausedKey) as? Bool) ?? false }
        set {
            objc_setAssociatedObject(self, &animationPausedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            YogaAnimationManager.shared.setPaused(newValue, on: self)
        }
    }

    // MARK: 事件回调

    var animationDidStart: ((String) -> Void)? {
        get { objc_getAssociatedObject(self, &animationDidStartKey) as? (String) -> Void }
        set { objc_setAssociatedObject(self, &animationDidStartKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDidEnd: ((String, Bool) -> Void)? {
        get { objc_getAssociatedObject(self, &animationDidEndKey) as? (String, Bool) -> Void }
        set { objc_setAssociatedObject(self, &animationDidEndKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var animationDidRepeat: ((String) -> Void)? {
        get { objc_getAssociatedObject(self, &animationDidRepeatKey) as? (String) -> Void }
        set { objc_setAssociatedObject(self, &animationDidRepeatKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: Transition

    var transition: YogaTransition? {
        get { objc_getAssociatedObject(self, &transitionKey) as? YogaTransition }
        set { objc_setAssociatedObject(self, &transitionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
