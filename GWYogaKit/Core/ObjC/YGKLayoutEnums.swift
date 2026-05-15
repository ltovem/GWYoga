import Foundation
import GWYoga
import GWYogaKit

// MARK: - YGKFlexDirection

/// Objective-C compatible flex direction enum.
@objc public enum YGKFlexDirection: Int {
    case column = 0
    case columnReverse = 1
    case row = 2
    case rowReverse = 3

    internal var swiftValue: GWFlexDirection {
        GWFlexDirection(rawValue: rawValue) ?? .column
    }

    internal static func from(_ value: GWFlexDirection) -> YGKFlexDirection {
        YGKFlexDirection(rawValue: value.rawValue) ?? .column
    }
}

// MARK: - YGKJustify

@objc public enum YGKJustify: Int {
    case auto = 0
    case flexStart = 1
    case center = 2
    case flexEnd = 3
    case spaceBetween = 4
    case spaceAround = 5
    case spaceEvenly = 6
    case stretch = 7
    case start = 8
    case end = 9

    internal var swiftValue: GWJustify {
        GWJustify(rawValue: rawValue) ?? .flexStart
    }

    internal static func from(_ value: GWJustify) -> YGKJustify {
        YGKJustify(rawValue: value.rawValue) ?? .flexStart
    }
}

// MARK: - YGKAlign

@objc public enum YGKAlign: Int {
    case auto = 0
    case flexStart = 1
    case center = 2
    case flexEnd = 3
    case stretch = 4
    case baseline = 5
    case spaceBetween = 6
    case spaceAround = 7
    case spaceEvenly = 8

    internal var swiftValue: GWAlign {
        GWAlign(rawValue: rawValue) ?? .stretch
    }

    internal static func from(_ value: GWAlign) -> YGKAlign {
        YGKAlign(rawValue: value.rawValue) ?? .stretch
    }
}

// MARK: - YGKPositionType

@objc public enum YGKPositionType: Int {
    case `static` = 0
    case relative = 1
    case absolute = 2

    internal var swiftValue: GWPositionType {
        GWPositionType(rawValue: rawValue) ?? .relative
    }

    internal static func from(_ value: GWPositionType) -> YGKPositionType {
        YGKPositionType(rawValue: value.rawValue) ?? .relative
    }
}

// MARK: - YGKDisplay

@objc public enum YGKDisplay: Int {
    case flex = 0
    case none = 1
    case contents = 2
    case grid = 3

    internal var swiftValue: GWDisplay {
        GWDisplay(rawValue: rawValue) ?? .flex
    }

    internal static func from(_ value: GWDisplay) -> YGKDisplay {
        YGKDisplay(rawValue: value.rawValue) ?? .flex
    }
}

// MARK: - YGKOverflow

@objc public enum YGKOverflow: Int {
    case visible = 0
    case hidden = 1
    case scroll = 2

    internal var swiftValue: GWOverflow {
        GWOverflow(rawValue: rawValue) ?? .visible
    }

    internal static func from(_ value: GWOverflow) -> YGKOverflow {
        YGKOverflow(rawValue: value.rawValue) ?? .visible
    }
}

// MARK: - YGKWrap

@objc public enum YGKWrap: Int {
    case noWrap = 0
    case wrap = 1
    case wrapReverse = 2

    internal var swiftValue: GWWrap {
        GWWrap(rawValue: rawValue) ?? .noWrap
    }

    internal static func from(_ value: GWWrap) -> YGKWrap {
        YGKWrap(rawValue: value.rawValue) ?? .noWrap
    }
}

// MARK: - YGKEdge

@objc public enum YGKEdge: Int {
    case left = 0
    case top = 1
    case right = 2
    case bottom = 3
    case start = 4
    case end = 5
    case horizontal = 6
    case vertical = 7
    case all = 8

    internal var swiftValue: GWEdge {
        GWEdge(rawValue: rawValue) ?? .all
    }
}

// MARK: - YGKBoxSizing

@objc public enum YGKBoxSizing: Int {
    case borderBox = 0
    case contentBox = 1

    internal var swiftValue: GWBoxSizing {
        GWBoxSizing(rawValue: rawValue) ?? .borderBox
    }

    internal static func from(_ value: GWBoxSizing) -> YGKBoxSizing {
        YGKBoxSizing(rawValue: value.rawValue) ?? .borderBox
    }
}

// MARK: - YGKUnit

@objc public enum YGKUnit: Int {
    case undefined = 0
    case point = 1
    case percent = 2
    case auto = 3
    case maxContent = 4
    case fitContent = 5
    case stretch = 6

    internal var swiftValue: GWUnit {
        GWUnit(rawValue: rawValue) ?? .undefined
    }

    internal static func from(_ value: GWUnit) -> YGKUnit {
        YGKUnit(rawValue: value.rawValue) ?? .undefined
    }
}

// MARK: - YGKDirection

@objc public enum YGKDirection: Int {
    case inherit = 0
    case ltr = 1
    case rtl = 2

    internal var swiftValue: GWDirection {
        GWDirection(rawValue: rawValue) ?? .inherit
    }

    internal static func from(_ value: GWDirection) -> YGKDirection {
        YGKDirection(rawValue: value.rawValue) ?? .inherit
    }
}

// MARK: - YGKGutter

@objc public enum YGKGutter: Int {
    case column = 0
    case row = 1
    case all = 2

    internal var swiftValue: GWGutter {
        GWGutter(rawValue: rawValue) ?? .row
    }
}

// MARK: - YGKNodeType

@objc public enum YGKNodeType: Int {
    case `default` = 0
    case text = 1

    internal var swiftValue: GWNodeType {
        GWNodeType(rawValue: rawValue) ?? .default
    }

    internal static func from(_ value: GWNodeType) -> YGKNodeType {
        YGKNodeType(rawValue: value.rawValue) ?? .default
    }
}

// MARK: - YGKLayoutMode

/// Layout mode for YGKLayoutView.
@objc public enum YGKLayoutMode: Int {
    case auto = 0
    case forced = 1
    case manual = 2
}

// MARK: - YGKGridLineType

@objc public enum YGKGridLineType: Int {
    case auto = 0
    case integer = 1
    case span = 2

    internal var swiftValue: GWGridLineType {
        GWGridLineType(rawValue: rawValue) ?? .auto
    }

    internal static func from(_ value: GWGridLineType) -> YGKGridLineType {
        YGKGridLineType(rawValue: value.rawValue) ?? .auto
    }
}

// MARK: - YGKDimension

@objc public enum YGKDimension: Int {
    case width = 0
    case height = 1
}
