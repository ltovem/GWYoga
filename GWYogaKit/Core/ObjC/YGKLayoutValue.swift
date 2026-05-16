import Foundation
import CoreGraphics
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#endif

// MARK: - YGKLayoutValue

/// ObjC-compatible layout value with unit (points / percent / auto / etc.).
///
/// Factory methods:
/// ```objc
/// YGKLayoutValue *v = YGKPoints(100);       // 100pt
/// YGKLayoutValue *v = YGKPercent(50);        // 50%
/// YGKLayoutValue *v = YGKAuto;               // auto
/// ```
@objc(YGKLayoutValue)
public class YGKLayoutValue: NSObject {
    @objc public var value: CGFloat
    @objc public var unit: YGKUnit

    @objc public init(value: CGFloat, unit: YGKUnit) {
        self.value = value
        self.unit = unit
    }

    // MARK: Factory methods

    @objc(points:)
    public static func points(_ value: CGFloat) -> YGKLayoutValue {
        YGKLayoutValue(value: value, unit: .point)
    }

    @objc(percent:)
    public static func percent(_ value: CGFloat) -> YGKLayoutValue {
        YGKLayoutValue(value: value, unit: .percent)
    }

    @objc public static var autoValue: YGKLayoutValue {
        YGKLayoutValue(value: 0, unit: .auto)
    }

    @objc public static var undefinedValue: YGKLayoutValue {
        YGKLayoutValue(value: 0, unit: .undefined)
    }

    internal var swiftValue: GWValue {
        switch unit {
        case .undefined: return .undefined
        case .point: return .points(Float(value))
        case .percent: return .percent(Float(value))
        case .auto: return .auto
        case .maxContent: return .maxContent()
        case .fitContent: return .fitContent()
        case .stretch: return .stretch()
        @unknown default: return .points(Float(value))
        }
    }
}

// MARK: - Convenience Functions

/// Create a point value (convenience inline, available in Swift and ObjC).
@objc public class YGKLayout: NSObject {
    @objc(pts:)
    public static func pts(_ value: CGFloat) -> YGKLayoutValue {
        .points(value)
    }

    @objc(pct:)
    public static func pct(_ value: CGFloat) -> YGKLayoutValue {
        .percent(value)
    }

    @objc public static var autoVal: YGKLayoutValue { .autoValue }
}
