import Foundation
import GWYoga
import GWYogaKit
import GWYogaKitStylesheet
#if os(iOS)
import UIKit

// MARK: - YGKStylesheet

/// ObjC-compatible CSS stylesheet.
@objc(YGKStylesheet)
public class YGKStylesheet: NSObject {
    private let swift: YogaStylesheet

    internal init(swift: YogaStylesheet) {
        self.swift = swift
    }

    /// Parse a CSS string into a stylesheet.
    @objc public static func parse(_ css: String) throws -> YGKStylesheet {
        YGKStylesheet(swift: try YogaStylesheet.parse(css))
    }

    /// Load a CSS file from the main bundle.
    @objc public static func load(named name: String) throws -> YGKStylesheet {
        YGKStylesheet(swift: try YogaStylesheet.load(named: name))
    }

    /// Load a CSS file from a specific bundle.
    @objc public static func load(named name: String, bundle: Bundle) throws -> YGKStylesheet {
        YGKStylesheet(swift: try YogaStylesheet.load(named: name, bundle: bundle))
    }

    /// Apply this stylesheet to a view.
    @objc public func apply(to view: UIView) {
        for rule in swift.rules {
            for decl in rule.declarations {
                YogaCSSPropertyMapper.apply(property: decl.property, value: decl.value, to: view.yoga)
            }
        }
    }
}
#endif
