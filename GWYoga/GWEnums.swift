import Foundation

// MARK: - Core Enums

public enum GWDirection: Int, CaseIterable, Sendable {
    case inherit = 0
    case ltr = 1
    case rtl = 2
}

public enum GWUnit: Int, CaseIterable, Sendable {
    case undefined = 0
    case point = 1
    case percent = 2
    case auto = 3
    case maxContent = 4
    case fitContent = 5
    case stretch = 6
}

public enum GWFlexDirection: Int, CaseIterable, Sendable {
    case column = 0
    case columnReverse = 1
    case row = 2
    case rowReverse = 3
}

public enum GWJustify: Int, CaseIterable, Sendable {
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
}

public enum GWAlign: Int, CaseIterable, Sendable {
    case auto = 0
    case flexStart = 1
    case center = 2
    case flexEnd = 3
    case stretch = 4
    case baseline = 5
    case spaceBetween = 6
    case spaceAround = 7
    case spaceEvenly = 8
    case start = 9
    case end = 10
}

public enum GWOverflow: Int, CaseIterable, Sendable {
    case visible = 0
    case hidden = 1
    case scroll = 2
}

public enum GWDisplay: Int, CaseIterable, Sendable {
    case flex = 0
    case none = 1
    case contents = 2
    case grid = 3
}

public enum GWPositionType: Int, CaseIterable, Sendable {
    case `static` = 0
    case relative = 1
    case absolute = 2
}

public enum GWWrap: Int, CaseIterable, Sendable {
    case noWrap = 0
    case wrap = 1
    case wrapReverse = 2
}

public enum GWBoxSizing: Int, CaseIterable, Sendable {
    case borderBox = 0
    case contentBox = 1
}

public enum GWEdge: Int, CaseIterable, Sendable {
    case left = 0
    case top = 1
    case right = 2
    case bottom = 3
    case start = 4
    case end = 5
    case horizontal = 6
    case vertical = 7
    case all = 8
}

public enum GWMeasureMode: Int, CaseIterable, Sendable {
    case undefined = 0
    case exactly = 1
    case atMost = 2
}

public enum GWGutter: Int, CaseIterable, Sendable {
    case column = 0
    case row = 1
    case all = 2
}

public enum GWExperimentalFeature: Int, CaseIterable, Sendable {
    case webFlexBasis = 0
    case fixFlexBasisFitContent = 1
}

public enum GWNodeType: Int, CaseIterable, Sendable {
    case `default` = 0
    case text = 1
}

public enum GWLogLevel: Int, CaseIterable, Sendable {
    case error = 0
    case warn = 1
    case info = 2
    case debug = 3
    case verbose = 4
    case fatal = 5
}

public enum GWDimension: Int, CaseIterable, Sendable {
    case width = 0
    case height = 1
}

public enum GWGridTrackType: Int, CaseIterable, Sendable {
    case auto = 0
    case points = 1
    case percent = 2
    case fr = 3
    case minmax = 4
}

// MARK: - Physical Edge

/// Maps logical edges to physical positions in the layout results arrays.
/// Left=0, Top=1, Right=2, Bottom=3
public enum GWPhysicalEdge: Int, CaseIterable, Sendable {
    case left = 0
    case top = 1
    case right = 2
    case bottom = 3
}

/// 将 GWEdge 转换为对应的 GWPhysicalEdge（仅对具体物理边有效）
internal extension GWPhysicalEdge {
    init?(from edge: GWEdge) {
        switch edge {
        case .left: self = .left
        case .top: self = .top
        case .right: self = .right
        case .bottom: self = .bottom
        default: return nil
        }
    }
}

// MARK: - Sizing Mode (internal)

/// Internal sizing mode used by the layout algorithm.
/// Maps to CSS sizing concepts.
public enum GWSizingMode: Int, Sendable {
    /// Exact size known — "stretch to fill"
    case stretchFit = 0
    /// No constraint — "measure content freely"
    case maxContent = 1
    /// At most constraint — "measure but don't exceed"
    case fitContent = 2
}

// MARK: - Errata (OptionSet)

public struct GWErrata: OptionSet, Sendable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let none: GWErrata = []
    public static let stretchFlexBasis = GWErrata(rawValue: 1 << 0)
    public static let absolutePositionWithoutInsetsExcludesPadding = GWErrata(rawValue: 1 << 1)
    public static let absolutePercentAgainstInnerSize = GWErrata(rawValue: 1 << 2)
    public static let all = GWErrata(rawValue: 0x7FFFFFFF)
    public static let classic = GWErrata(rawValue: 0x7FFFFFFF & ~(1 << 0))
}

// MARK: - Flex Direction Helpers

internal extension GWFlexDirection {
    /// Returns true if this flex direction is a row (Row or RowReverse)
    var isRow: Bool {
        self == .row || self == .rowReverse
    }

    /// Returns true if this flex direction is a column (Column or ColumnReverse)
    var isColumn: Bool {
        self == .column || self == .columnReverse
    }

    /// Resolves flex direction considering RTL direction.
    /// In RTL, Row becomes RowReverse and vice versa.
    func resolved(for direction: GWDirection) -> GWFlexDirection {
        if direction == .rtl {
            if self == .row { return .rowReverse }
            if self == .rowReverse { return .row }
        }
        return self
    }

    /// Returns the cross axis direction (perpendicular to this direction)
    var cross: GWFlexDirection {
        switch self {
        case .row, .rowReverse: return .column
        case .column, .columnReverse: return .row
        }
    }

    /// Returns the flex-start physical edge for this direction
    var flexStartEdge: GWEdge {
        switch self {
        case .row: return .left
        case .rowReverse: return .right
        case .column: return .top
        case .columnReverse: return .bottom
        }
    }

    /// Returns the flex-end physical edge for this direction
    var flexEndEdge: GWEdge {
        switch self {
        case .row: return .right
        case .rowReverse: return .left
        case .column: return .bottom
        case .columnReverse: return .top
        }
    }

    /// Returns the dimension (width/height) associated with this direction
    var dimension: GWDimension {
        switch self {
        case .row, .rowReverse: return .width
        case .column, .columnReverse: return .height
        }
    }

    /// Returns the inline start edge considering LTR/RTL
    static func inlineStartEdge(for direction: GWFlexDirection, layoutDirection: GWDirection) -> GWEdge {
        if direction.isRow {
            return layoutDirection == .rtl ? .right : .left
        }
        return .top
    }

    /// Returns the inline end edge considering LTR/RTL
    static func inlineEndEdge(for direction: GWFlexDirection, layoutDirection: GWDirection) -> GWEdge {
        if direction.isRow {
            return layoutDirection == .rtl ? .left : .right
        }
        return .bottom
    }
}

// MARK: - Align Helpers

internal func resolveChildAlignment(parent: GWStyle, child: GWStyle) -> GWAlign {
    if child.alignSelf != .auto {
        return child.alignSelf
    }
    let align = parent.alignItems

    // Baseline 在 column 方向退化到 flex-start
    if parent.display == .flex && align == .baseline && parent.flexDirection.isColumn {
        return .flexStart
    }

    return align
}

internal func fallbackAlignment(_ align: GWAlign) -> GWAlign {
    switch align {
    case .spaceBetween, .stretch: return .flexStart
    case .spaceAround, .spaceEvenly: return .flexStart
    default: return align
    }
}

// MARK: - Justify Helpers

internal func resolveChildJustification(parent: GWStyle, child: GWStyle) -> GWJustify {
    if child.justifySelf != .auto {
        return child.justifySelf
    }
    return parent.justifyItems
}

internal func fallbackAlignment(_ justify: GWJustify) -> GWJustify {
    switch justify {
    case .spaceBetween, .stretch: return .flexStart
    case .spaceAround, .spaceEvenly: return .flexStart
    default: return justify
    }
}

internal func fallbackJustify(_ justify: GWJustify) -> GWJustify {
    switch justify {
    case .spaceBetween, .stretch: return .flexStart
    case .spaceAround, .spaceEvenly: return .flexStart
    default: return justify
    }
}
