import Foundation
import CoreGraphics
import GWYoga
import GWYogaKit
import GWYogaKitLayoutCache
import GWYogaKitObjCCore
#if os(iOS)
import UIKit
#endif

// MARK: - YGKPreLayout

/// ObjC-compatible pre-layout measurement tool.
/// Measures views without triggering actual layout.
@objc(YGKPreLayout)
public class YGKPreLayout: NSObject {
    private let swift: YogaPreLayout

    internal init(swift: YogaPreLayout) {
        self.swift = swift
    }

    /// Measure the view at a given width (unconstrained height).
    @objc public func measure(width: CGFloat) -> CGSize {
        swift.measure(width: Float(width))
    }

    /// Measure the view at given width and height.
    @objc public func measure(width: CGFloat, height: CGFloat) -> CGSize {
        swift.measure(width: Float(width), height: Float(height))
    }

    /// Invalidate cached measurement for this view.
    @objc public func invalidateCache() {
        swift.invalidateCache()
    }
}

// MARK: - YogaProperties extension access

extension YogaProperties {
    /// ObjC-accessible pre-layout measurement.
    @objc public var preLayout: YGKPreLayout {
        YGKPreLayout(swift: measurement)
    }
}

// MARK: - YGKLayoutProperties extension

extension YGKLayoutProperties {
    /// Pre-layout measurement.
    @objc public var preLayout: YGKPreLayout {
        yoga.preLayout
    }
}
