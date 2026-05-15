import Foundation

// MARK: - GWStyle

/// All CSS flexbox/grid style properties for a node.
/// This is a value type (struct) for efficient copying.
public struct GWStyle: Equatable, Sendable {
    // MARK: Flex Direction & Direction
    public var direction: GWDirection = .inherit
    public var flexDirection: GWFlexDirection = .column

    // MARK: Justify
    public var justifyContent: GWJustify = .flexStart
    public var justifyItems: GWJustify = .stretch
    public var justifySelf: GWJustify = .auto

    // MARK: Align
    public var alignContent: GWAlign = .flexStart
    public var alignItems: GWAlign = .stretch
    public var alignSelf: GWAlign = .auto

    // MARK: Layout
    public var positionType: GWPositionType = .relative
    public var flexWrap: GWWrap = .noWrap
    public var overflow: GWOverflow = .visible
    public var display: GWDisplay = .flex
    public var boxSizing: GWBoxSizing = .borderBox

    // MARK: Flex
    public var flex: GWFloatOptional = .undefined
    public var flexGrow: GWFloatOptional = .undefined
    public var flexShrink: GWFloatOptional = .undefined
    public var flexBasis: GWStyleSizeLength = .auto

    // MARK: Aspect Ratio
    public var aspectRatio: GWFloatOptional = .undefined

    // MARK: Dimensions
    public var dimensions: [GWStyleSizeLength] = [.auto, .auto]
    public var minDimensions: [GWStyleSizeLength] = [.undefined, .undefined]
    public var maxDimensions: [GWStyleSizeLength] = [.undefined, .undefined]

    // MARK: Edge properties (9 edges per property family)
    // Indexed by GWEdge rawValue: left=0, top=1, right=2, bottom=3, start=4, end=5, horizontal=6, vertical=7, all=8
    public var margin: [GWStyleLength] = Array(repeating: .undefined, count: 9)
    public var padding: [GWStyleLength] = Array(repeating: .undefined, count: 9)
    public var position: [GWStyleLength] = Array(repeating: .undefined, count: 9)
    public var border: [Float] = Array(repeating: .nan, count: 9)

    // MARK: Gap
    public var gap: [GWStyleLength] = [.undefined, .undefined, .undefined]

    // MARK: Grid
    public var gridColumnStart: GWGridLine = .default
    public var gridColumnEnd: GWGridLine = .default
    public var gridRowStart: GWGridLine = .default
    public var gridRowEnd: GWGridLine = .default
    public var gridTemplateColumns: GWGridTrackList = []
    public var gridTemplateRows: GWGridTrackList = []
    public var gridAutoColumns: GWGridTrackList = []
    public var gridAutoRows: GWGridTrackList = []

    // MARK: - Defaults

    public static let `default` = GWStyle()

    public init() {}

    /// Applies web defaults: flexDirection = row, alignContent = stretch
    public mutating func useWebDefaults() {
        flexDirection = .row
        alignContent = .stretch
    }

    // MARK: - Convenience Accessors

    public var width: GWStyleSizeLength {
        get { dimensions[0] }
        set { dimensions[0] = newValue }
    }

    public var height: GWStyleSizeLength {
        get { dimensions[1] }
        set { dimensions[1] = newValue }
    }

    public var minWidth: GWStyleSizeLength {
        get { minDimensions[0] }
        set { minDimensions[0] = newValue }
    }

    public var minHeight: GWStyleSizeLength {
        get { minDimensions[1] }
        set { minDimensions[1] = newValue }
    }

    public var maxWidth: GWStyleSizeLength {
        get { maxDimensions[0] }
        set { maxDimensions[0] = newValue }
    }

    public var maxHeight: GWStyleSizeLength {
        get { maxDimensions[1] }
        set { maxDimensions[1] = newValue }
    }

    public var columnGap: GWStyleLength {
        get { gap[GWGutter.column.rawValue] }
        set { gap[GWGutter.column.rawValue] = newValue }
    }

    public var rowGap: GWStyleLength {
        get { gap[GWGutter.row.rawValue] }
        set { gap[GWGutter.row.rawValue] = newValue }
    }

    // MARK: - Edge Resolution (CSS logical property resolution)

    /// Resolves margin value for a given physical edge, with
    /// CSS logical property fallback (start > left, end > right, etc.)
    public func resolvedMargin(for edge: GWEdge, direction: GWDirection) -> GWStyleLength {
        resolvedEdgeValue(from: margin, for: edge, direction: direction)
    }

    /// Resolves padding value for a given physical edge.
    public func resolvedPadding(for edge: GWEdge, direction: GWDirection) -> GWStyleLength {
        resolvedEdgeValue(from: padding, for: edge, direction: direction)
    }

    /// Resolves position (inset) value for a given physical edge.
    public func resolvedPosition(for edge: GWEdge, direction: GWDirection) -> GWStyleLength {
        resolvedEdgeValue(from: position, for: edge, direction: direction)
    }

    /// Resolves border value for a given physical edge.
    public func resolvedBorder(for edge: GWEdge, direction: GWDirection) -> Float {
        // Border doesn't have logical property fallback - simpler lookup
        let idx = edge.rawValue
        if !border[idx].isNaN { return border[idx] }
        if edge == .left || edge == .right || edge == .start || edge == .end {
            if edge == .left || edge == .start {
                if !border[GWEdge.horizontal.rawValue].isNaN { return border[GWEdge.horizontal.rawValue] }
            }
            if !border[GWEdge.all.rawValue].isNaN { return border[GWEdge.all.rawValue] }
        }
        if edge == .top || edge == .bottom {
            if !border[GWEdge.vertical.rawValue].isNaN { return border[GWEdge.vertical.rawValue] }
            if !border[GWEdge.all.rawValue].isNaN { return border[GWEdge.all.rawValue] }
        }
        return 0
    }

    /// CSS-compliant edge resolution: tries specific edge, then logical alternatives,
    /// then shorthand (horizontal/vertical), then all.
    internal func resolvedEdgeValue(from values: [GWStyleLength], for edge: GWEdge, direction: GWDirection) -> GWStyleLength {
        let idx = edge.rawValue
        if values[idx].isDefined { return values[idx] }

        switch edge {
        case .left:
            if direction == .ltr {
                if values[GWEdge.start.rawValue].isDefined { return values[GWEdge.start.rawValue] }
                if values[GWEdge.horizontal.rawValue].isDefined { return values[GWEdge.horizontal.rawValue] }
            } else {
                if values[GWEdge.end.rawValue].isDefined { return values[GWEdge.end.rawValue] }
                if values[GWEdge.horizontal.rawValue].isDefined { return values[GWEdge.horizontal.rawValue] }
            }
            if values[GWEdge.all.rawValue].isDefined { return values[GWEdge.all.rawValue] }
            return values[idx]

        case .right:
            if direction == .ltr {
                if values[GWEdge.end.rawValue].isDefined { return values[GWEdge.end.rawValue] }
                if values[GWEdge.horizontal.rawValue].isDefined { return values[GWEdge.horizontal.rawValue] }
            } else {
                if values[GWEdge.start.rawValue].isDefined { return values[GWEdge.start.rawValue] }
                if values[GWEdge.horizontal.rawValue].isDefined { return values[GWEdge.horizontal.rawValue] }
            }
            if values[GWEdge.all.rawValue].isDefined { return values[GWEdge.all.rawValue] }
            return values[idx]

        case .top:
            if values[GWEdge.vertical.rawValue].isDefined { return values[GWEdge.vertical.rawValue] }
            if values[GWEdge.all.rawValue].isDefined { return values[GWEdge.all.rawValue] }
            return values[idx]

        case .bottom:
            if values[GWEdge.vertical.rawValue].isDefined { return values[GWEdge.vertical.rawValue] }
            if values[GWEdge.all.rawValue].isDefined { return values[GWEdge.all.rawValue] }
            return values[idx]

        case .start:
            if values[GWEdge.all.rawValue].isDefined { return values[GWEdge.all.rawValue] }
            return values[idx]

        case .end:
            if values[GWEdge.all.rawValue].isDefined { return values[GWEdge.all.rawValue] }
            return values[idx]

        case .horizontal, .vertical, .all:
            if values[GWEdge.all.rawValue].isDefined { return values[GWEdge.all.rawValue] }
            return values[idx]
        }
    }

    // MARK: - 位置/边距/边框/内边距计算（对应 C++ Style.h compute* 方法）

    /// 获取指定边的 position 值（未解析）
    internal func computePosition(_ edge: GWEdge, _ direction: GWDirection) -> GWStyleLength {
        resolvedPosition(for: edge, direction: direction)
    }

    /// 获取指定边的 margin 值（未解析）
    internal func computeMargin(_ edge: GWEdge, _ direction: GWDirection) -> GWStyleLength {
        resolvedMargin(for: edge, direction: direction)
    }

    /// 获取指定边的 padding 值（未解析）
    internal func computePadding(_ edge: GWEdge, _ direction: GWDirection) -> GWStyleLength {
        resolvedPadding(for: edge, direction: direction)
    }

    /// 获取指定边的 border 值（未解析）
    internal func computeBorder(_ edge: GWEdge, _ direction: GWDirection) -> GWStyleLength {
        let val = resolvedBorder(for: edge, direction: direction)
        if val.isNaN { return .undefined }
        return .points(val)
    }

    /// CSS inline-start position
    internal func computeInlineStartPosition(_ axis: GWFlexDirection, _ direction: GWDirection, _ axisSize: Float) -> Float {
        resolveLength(computePosition(inlineStartEdge(axis, direction), direction), axisSize).unwrap(orDefault: 0)
    }

    /// CSS inline-end position
    internal func computeInlineEndPosition(_ axis: GWFlexDirection, _ direction: GWDirection, _ axisSize: Float) -> Float {
        resolveLength(computePosition(inlineEndEdge(axis, direction), direction), axisSize).unwrap(orDefault: 0)
    }

    /// CSS flex-start position
    internal func computeFlexStartPosition(_ axis: GWFlexDirection, _ direction: GWDirection, _ axisSize: Float) -> Float {
        resolveLength(computePosition(flexStartEdge(axis), direction), axisSize).unwrap(orDefault: 0)
    }

    /// CSS flex-end position
    internal func computeFlexEndPosition(_ axis: GWFlexDirection, _ direction: GWDirection, _ axisSize: Float) -> Float {
        resolveLength(computePosition(flexEndEdge(axis), direction), axisSize).unwrap(orDefault: 0)
    }

    /// CSS inline-start margin
    internal func computeInlineStartMargin(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        resolveLength(computeMargin(inlineStartEdge(axis, direction), direction), widthSize).unwrap(orDefault: 0)
    }

    /// CSS inline-end margin
    internal func computeInlineEndMargin(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        resolveLength(computeMargin(inlineEndEdge(axis, direction), direction), widthSize).unwrap(orDefault: 0)
    }

    /// CSS flex-start margin
    internal func computeFlexStartMargin(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        resolveLength(computeMargin(flexStartEdge(axis), direction), widthSize).unwrap(orDefault: 0)
    }

    /// CSS flex-end margin
    internal func computeFlexEndMargin(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        resolveLength(computeMargin(flexEndEdge(axis), direction), widthSize).unwrap(orDefault: 0)
    }

    /// CSS inline-start border
    internal func computeInlineStartBorder(_ axis: GWFlexDirection, _ direction: GWDirection) -> Float {
        maxOrDefined(resolveLength(computeBorder(inlineStartEdge(axis, direction), direction), 0).unwrap(orDefault: 0), 0)
    }

    /// CSS inline-end border
    internal func computeInlineEndBorder(_ axis: GWFlexDirection, _ direction: GWDirection) -> Float {
        maxOrDefined(resolveLength(computeBorder(inlineEndEdge(axis, direction), direction), 0).unwrap(orDefault: 0), 0)
    }

    /// CSS flex-start border
    internal func computeFlexStartBorder(_ axis: GWFlexDirection, _ direction: GWDirection) -> Float {
        maxOrDefined(resolveLength(computeBorder(flexStartEdge(axis), direction), 0).unwrap(orDefault: 0), 0)
    }

    /// CSS flex-end border
    internal func computeFlexEndBorder(_ axis: GWFlexDirection, _ direction: GWDirection) -> Float {
        maxOrDefined(resolveLength(computeBorder(flexEndEdge(axis), direction), 0).unwrap(orDefault: 0), 0)
    }

    /// CSS flex-start padding
    internal func computeFlexStartPadding(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        maxOrDefined(resolveLength(computePadding(flexStartEdge(axis), direction), widthSize).unwrap(orDefault: 0), 0)
    }

    /// CSS flex-end padding
    internal func computeFlexEndPadding(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        maxOrDefined(resolveLength(computePadding(flexEndEdge(axis), direction), widthSize).unwrap(orDefault: 0), 0)
    }

    /// CSS inline-start padding
    internal func computeInlineStartPadding(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        maxOrDefined(resolveLength(computePadding(inlineStartEdge(axis, direction), direction), widthSize).unwrap(orDefault: 0), 0)
    }

    /// CSS inline-end padding
    internal func computeInlineEndPadding(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        maxOrDefined(resolveLength(computePadding(inlineEndEdge(axis, direction), direction), widthSize).unwrap(orDefault: 0), 0)
    }

    /// CSS inline-start padding + border
    internal func computeInlineStartPaddingAndBorder(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        computeInlineStartPadding(axis, direction, widthSize) + computeInlineStartBorder(axis, direction)
    }

    /// CSS inline-end padding + border
    internal func computeInlineEndPaddingAndBorder(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        computeInlineEndPadding(axis, direction, widthSize) + computeInlineEndBorder(axis, direction)
    }

    /// CSS flex-start padding + border
    internal func computeFlexStartPaddingAndBorder(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        computeFlexStartPadding(axis, direction, widthSize) + computeFlexStartBorder(axis, direction)
    }

    /// CSS flex-end padding + border
    internal func computeFlexEndPaddingAndBorder(_ axis: GWFlexDirection, _ direction: GWDirection, _ widthSize: Float) -> Float {
        computeFlexEndPadding(axis, direction, widthSize) + computeFlexEndBorder(axis, direction)
    }

    /// 指定 dimension 的 padding + border 总和
    internal func computePaddingAndBorderForDimension(_ direction: GWDirection, _ dim: GWDimension, _ widthSize: Float) -> Float {
        let axis: GWFlexDirection = dim == .width ? .row : .column
        return computeFlexStartPaddingAndBorder(axis, direction, widthSize) + computeFlexEndPaddingAndBorder(axis, direction, widthSize)
    }

    /// 指定轴的 border 总和（简化：用 LTR 方向）
    internal func computeBorderForAxis(_ axis: GWFlexDirection) -> Float {
        computeInlineStartBorder(axis, .ltr) + computeInlineEndBorder(axis, .ltr)
    }

    /// 指定轴的 margin 总和
    internal func computeMarginForAxis(_ axis: GWFlexDirection, _ widthSize: Float) -> Float {
        computeInlineStartMargin(axis, .ltr, widthSize) + computeInlineEndMargin(axis, .ltr, widthSize)
    }

    /// 指定轴的 gap 值
    internal func computeGapForAxis(_ axis: GWFlexDirection, _ ownerSize: Float) -> Float {
        let gap = axis.isRow ? columnGap : rowGap
        return maxOrDefined(resolveLength(gap, ownerSize).unwrap(orDefault: 0), 0)
    }

    // MARK: - 边距是否为 auto

    internal func flexStartMarginIsAuto(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computeMargin(flexStartEdge(axis), direction).isAuto
    }

    internal func flexEndMarginIsAuto(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computeMargin(flexEndEdge(axis), direction).isAuto
    }

    internal func inlineStartMarginIsAuto(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computeMargin(inlineStartEdge(axis, direction), direction).isAuto
    }

    internal func inlineEndMarginIsAuto(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computeMargin(inlineEndEdge(axis, direction), direction).isAuto
    }

    // MARK: - 内嵌值定义判断

    internal func isFlexStartPositionDefined(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computePosition(flexStartEdge(axis), direction).isDefined
    }

    internal func isFlexStartPositionAuto(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computePosition(flexStartEdge(axis), direction).isAuto
    }

    internal func isInlineStartPositionDefined(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computePosition(inlineStartEdge(axis, direction), direction).isDefined
    }

    internal func isInlineStartPositionAuto(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computePosition(inlineStartEdge(axis, direction), direction).isAuto
    }

    internal func isFlexEndPositionDefined(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computePosition(flexEndEdge(axis), direction).isDefined
    }

    internal func isFlexEndPositionAuto(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computePosition(flexEndEdge(axis), direction).isAuto
    }

    internal func isInlineEndPositionDefined(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computePosition(inlineEndEdge(axis, direction), direction).isDefined
    }

    internal func isInlineEndPositionAuto(_ axis: GWFlexDirection, _ direction: GWDirection) -> Bool {
        computePosition(inlineEndEdge(axis, direction), direction).isAuto
    }

    internal var horizontalInsetsDefined: Bool {
        position[GWEdge.left.rawValue].isDefined ||
        position[GWEdge.right.rawValue].isDefined ||
        position[GWEdge.all.rawValue].isDefined ||
        position[GWEdge.horizontal.rawValue].isDefined ||
        position[GWEdge.start.rawValue].isDefined ||
        position[GWEdge.end.rawValue].isDefined
    }

    internal var verticalInsetsDefined: Bool {
        position[GWEdge.top.rawValue].isDefined ||
        position[GWEdge.bottom.rawValue].isDefined ||
        position[GWEdge.all.rawValue].isDefined ||
        position[GWEdge.vertical.rawValue].isDefined
    }

    // MARK: - 解析尺寸

    /// 解析最小尺寸（含 boxSizing 调整）
    internal func resolvedMinDimension(_ direction: GWDirection, _ axis: GWDimension, _ referenceLength: Float, _ ownerWidth: Float) -> GWFloatOptional {
        let dim = axis == .width ? minWidth : minHeight
        guard dim.isDefined else { return .undefined }
        let value = resolveStyleSizeLength(dim, referenceLength)
        if boxSizing == .borderBox || !value.isDefined { return value }
        let dimPaddingAndBorder = GWFloatOptional(value: computePaddingAndBorderForDimension(direction, axis, ownerWidth))
        return value + (dimPaddingAndBorder.isDefined ? dimPaddingAndBorder : GWFloatOptional(value: 0))
    }

    /// 解析最大尺寸（含 boxSizing 调整）
    internal func resolvedMaxDimension(_ direction: GWDirection, _ axis: GWDimension, _ referenceLength: Float, _ ownerWidth: Float) -> GWFloatOptional {
        let dim = axis == .width ? maxWidth : maxHeight
        guard dim.isDefined else { return .undefined }
        let value = resolveStyleSizeLength(dim, referenceLength)
        if boxSizing == .borderBox || !value.isDefined { return value }
        let dimPaddingAndBorder = GWFloatOptional(value: computePaddingAndBorderForDimension(direction, axis, ownerWidth))
        return value + (dimPaddingAndBorder.isDefined ? dimPaddingAndBorder : GWFloatOptional(value: 0))
    }

    /// Resolve gap for a gutter direction. Column gap falls back to All.
    public func resolvedGap(for gutter: GWGutter) -> GWStyleLength {
        if gutter == .column || gutter == .row {
            let specific = gap[gutter.rawValue]
            if specific.isDefined { return specific }
            let all = gap[GWGutter.all.rawValue]
            if all.isDefined { return all }
        }
        return gap[gutter.rawValue]
    }
}

// MARK: - Convenience setters for GWValue

public extension GWStyle {
    mutating func setWidth(_ value: GWValue) {
        width = GWStyleSizeLength(value)
    }

    mutating func setHeight(_ value: GWValue) {
        height = GWStyleSizeLength(value)
    }

    mutating func setMinWidth(_ value: GWValue) {
        minWidth = GWStyleSizeLength(value)
    }

    mutating func setMaxWidth(_ value: GWValue) {
        maxWidth = GWStyleSizeLength(value)
    }

    mutating func setMinHeight(_ value: GWValue) {
        minHeight = GWStyleSizeLength(value)
    }

    mutating func setMaxHeight(_ value: GWValue) {
        maxHeight = GWStyleSizeLength(value)
    }

    mutating func setFlexBasis(_ value: GWValue) {
        flexBasis = GWStyleSizeLength(value)
    }

    mutating func setMargin(for edge: GWEdge, _ value: GWValue) {
        margin[edge.rawValue] = GWStyleLength(value)
    }

    mutating func setPadding(for edge: GWEdge, _ value: GWValue) {
        padding[edge.rawValue] = GWStyleLength(value)
    }

    mutating func setPosition(for edge: GWEdge, _ value: GWValue) {
        position[edge.rawValue] = GWStyleLength(value)
    }

    mutating func setBorder(for edge: GWEdge, _ value: Float) {
        border[edge.rawValue] = value
    }

    mutating func setGap(for gutter: GWGutter, _ value: GWValue) {
        gap[gutter.rawValue] = GWStyleLength(value)
    }
}
