import Foundation

/// A node in the Yoga layout tree.
///
/// GWYogaNode is a reference type (class) because nodes have tree identity:
/// a node can only have one parent (owner) and maintains a list of children.
/// The style and layout results are value types (structs) for efficient access.
public final class GWYogaNode {
    // MARK: - Properties

    /// The style properties for this node
    public var style: GWStyle = .default

    /// Internal layout data (computed by calculateLayout)
    internal var layout: GWInternalLayout = .init()

    /// Layout cache for measurement reuse
    internal var cache: GWLayoutCache = .init()

    /// Children nodes (strong references)
    public private(set) var children: [GWYogaNode] = []

    /// Owner (parent) node — weak to avoid retain cycles
    public private(set) weak var owner: GWYogaNode?

    /// Configuration for this node
    public var config: GWYogaConfig

    /// Whether this node has new layout results since last calculation
    public var hasNewLayout: Bool = true

    /// Whether this node is dirty (needs layout recalculation)
    public internal(set) var isDirty: Bool = true

    /// Whether this node is the reference baseline among siblings
    public var isReferenceBaseline: Bool = false

    /// Whether this node always forms a containing block for absolute descendants
    public var alwaysFormsContainingBlock: Bool = false

    /// Node type (default or text)
    public var nodeType: GWNodeType = .default

    /// User-defined context object
    public var context: Any?

    /// Resolve direction from owner direction (handles inherit case)
    internal func resolveDirection(_ ownerDirection: GWDirection) -> GWDirection {
        switch style.direction {
        case .inherit: return ownerDirection == .inherit ? .ltr : ownerDirection
        case .ltr: return .ltr
        case .rtl: return .rtl
        }
    }

    /// Line index within a flex container (populated during layout)
    internal var lineIndex: Int = 0

    /// Number of display:contents children
    internal var contentsChildrenCount: Int = 0

    // MARK: - Callbacks

    /// Measure function for leaf nodes (e.g., text measurement).
    /// Signature: `(node, width, widthMode, height, heightMode) -> GWSize`
    public var measureFunction: ((GWYogaNode, Float, GWMeasureMode, Float, GWMeasureMode) -> GWSize)?

    /// Baseline function for baseline alignment
    public var baselineFunction: ((GWYogaNode, Float, Float) -> Float)?

    /// Called when the node is dirtied
    public var dirtiedHandler: ((GWYogaNode) -> Void)?

    // MARK: - Lifecycle

    public init(config: GWYogaConfig? = nil) {
        self.config = config ?? {
            let c = GWYogaConfig()
            c.useWebDefaults = false
            return c
        }()
        if self.config.useWebDefaults {
            style.useWebDefaults()
        }
    }

    /// Reset this node to its initial state
    public func reset() {
        style = .default
        layout = .init()
        cache = .init()
        children.removeAll()
        owner = nil
        hasNewLayout = true
        isDirty = true
        isReferenceBaseline = false
        alwaysFormsContainingBlock = false
        nodeType = .default
        context = nil
        measureFunction = nil
        baselineFunction = nil
        dirtiedHandler = nil
        contentsChildrenCount = 0
        if config.useWebDefaults {
            style.useWebDefaults()
        }
    }

    // MARK: - Tree Management

    /// Insert a child node at the given index.
    /// The child is removed from its previous owner if it had one.
    public func insertChild(_ child: GWYogaNode, at index: Int) {
        // Remove from previous owner
        child.removeFromOwner()
        child.owner = self
        children.insert(child, at: index)
        markDirty()
    }

    /// Remove a child node from this node's children.
    public func removeChild(_ child: GWYogaNode) {
        guard let index = children.firstIndex(where: { $0 === child }) else { return }
        child.owner = nil
        children.remove(at: index)
        markDirty()
    }

    /// Remove all children from this node.
    public func removeAllChildren() {
        for child in children {
            child.owner = nil
        }
        children.removeAll()
        markDirty()
    }

    /// Replace the child at the given index with a new child.
    public func replaceChild(at index: Int, with newChild: GWYogaNode) {
        guard index < children.count else { return }
        let oldChild = children[index]
        oldChild.owner = nil
        newChild.removeFromOwner()
        newChild.owner = self
        children[index] = newChild
        markDirty()
    }

    /// Replace a specific child node with another node.
    public func replaceChild(_ oldChild: GWYogaNode, with newChild: GWYogaNode) {
        guard let index = children.firstIndex(where: { $0 === oldChild }) else { return }
        replaceChild(at: index, with: newChild)
    }

    /// The number of children.
    public var childCount: Int {
        children.count
    }

    private func removeFromOwner() {
        owner?.children.removeAll { $0 === self }
        owner = nil
    }

    // MARK: - 节点能力查询（对应 C++ Node.h 方法）

    /// 检查节点是否有弹性（flexGrow > 0 或 flexShrink > 0）
    internal var isNodeFlexible: Bool {
        resolveFlexGrow() > 0 || resolveFlexShrink() > 0
    }

    /// 解析弹性增长系数（匹配 C++ Node::resolveFlexGrow）
    /// 根节点（无 owner）始终返回 0；优先 flexGrow 属性，再回退到 flex 简写
    internal func resolveFlexGrow() -> Float {
        guard owner != nil else { return 0 }
        if style.flexGrow.isDefined {
            return style.flexGrow.unwrap()
        }
        if style.flex.isDefined && style.flex.unwrap() > 0 {
            return style.flex.unwrap()
        }
        return 0
    }

    /// 解析弹性收缩系数（匹配 C++ Node::resolveFlexShrink）
    /// 根节点返回 0；优先 flexShrink 属性，再处理 flex < 0（非 web 默认），最后返回默认值
    internal func resolveFlexShrink() -> Float {
        guard owner != nil else { return 0 }
        if style.flexShrink.isDefined {
            return style.flexShrink.unwrap()
        }
        if !config.useWebDefaults && style.flex.isDefined && style.flex.unwrap() < 0 {
            return -style.flex.unwrap()
        }
        return config.useWebDefaults ? 1.0 : 0.0
    }

    /// 检查指定维度是否有明确尺寸
    internal func hasDefiniteLength(_ dimension: GWDimension, _ widthSize: Float) -> Bool {
        let dim = dimension == .width ? style.width : style.height
        let value = resolveStyleSizeLength(dim, widthSize)
        return value.isDefined && value.unwrap() >= 0
    }

    /// 获取解析后的维度值（含 boxSizing 调整）
    internal func getResolvedDimension(_ direction: GWDirection, _ dim: GWDimension,
                                       _ referenceLength: Float, _ ownerWidth: Float) -> GWFloatOptional {
        let styleDim = dim == .width ? style.width : style.height
        let value = resolveStyleSizeLength(styleDim, referenceLength)
        if style.boxSizing == .contentBox && value.isDefined {
            let paddingAndBorder = style.computePaddingAndBorderForDimension(direction, dim, ownerWidth)
            return GWFloatOptional(value: value.unwrap() + paddingAndBorder)
        }
        return value
    }

    /// 是否具有指定的 errata
    internal func hasErrata(_ errata: GWErrata) -> Bool {
        config.errata.contains(errata)
    }

    /// 布局维度是否已定义
    internal func isLayoutDimensionDefined(_ axis: GWFlexDirection) -> Bool {
        let dim = axis.dimension
        return isDefined(layout.dimension(dim))
    }

    /// 指定轴的尺寸 + margin
    internal func dimensionWithMargin(_ axis: GWFlexDirection, _ widthSize: Float) -> Float {
        layout.dimension(axis.dimension) + style.computeMarginForAxis(axis, widthSize)
    }

    /// 计算相对位置偏移（匹配 C++ Node::relativePosition）
    /// 忽略 static 定位节点；优先 inline-start，否则用 inline-end 的负值
    internal func relativePosition(_ axis: GWFlexDirection, _ direction: GWDirection, _ axisSize: Float) -> Float {
        guard style.positionType != .static else { return 0 }
        if style.isInlineStartPositionDefined(axis, direction) &&
            !style.isInlineStartPositionAuto(axis, direction) {
            return style.computeInlineStartPosition(axis, direction, axisSize)
        }
        return -style.computeInlineEndPosition(axis, direction, axisSize)
    }

    /// 设定节点位置（匹配 C++ Node::setPosition）
    /// 设置 margin 和相对定位偏移到 layout 的四个物理边
    internal func setPosition(_ direction: GWDirection, _ ownerWidth: Float, _ ownerHeight: Float) {
        let directionRespectingRoot = owner != nil ? direction : .ltr
        let mainAxis = style.flexDirection.resolved(for: directionRespectingRoot)
        let crossAxis = mainAxis.isColumn ? GWFlexDirection.row.resolved(for: directionRespectingRoot) : .column

        let relativePositionMain = relativePosition(mainAxis, directionRespectingRoot, mainAxis.isRow ? ownerWidth : ownerHeight)
        let relativePositionCross = relativePosition(crossAxis, directionRespectingRoot, mainAxis.isRow ? ownerHeight : ownerWidth)

        let mainAxisLeadingEdge = inlineStartEdge(mainAxis, direction)
        let mainAxisTrailingEdge = inlineEndEdge(mainAxis, direction)
        let crossAxisLeadingEdge = inlineStartEdge(crossAxis, direction)
        let crossAxisTrailingEdge = inlineEndEdge(crossAxis, direction)

        layout.setPosition(asPhysical(mainAxisLeadingEdge),
            style.computeInlineStartMargin(mainAxis, direction, ownerWidth) + relativePositionMain)
        layout.setPosition(asPhysical(mainAxisTrailingEdge),
            style.computeInlineEndMargin(mainAxis, direction, ownerWidth) + relativePositionMain)
        layout.setPosition(asPhysical(crossAxisLeadingEdge),
            style.computeInlineStartMargin(crossAxis, direction, ownerWidth) + relativePositionCross)
        layout.setPosition(asPhysical(crossAxisTrailingEdge),
            style.computeInlineEndMargin(crossAxis, direction, ownerWidth) + relativePositionCross)
    }

    // MARK: - Dirty / Layout Management

    /// Mark this node and its ancestors as dirty.
    public func markDirty() {
        if isDirty { return }
        isDirty = true
        hasNewLayout = true
        owner?.markDirty()
        dirtiedHandler?(self)
    }

    // MARK: - Layout Calculation

    /// Calculate the layout for this node and its descendants.
    /// - Parameters:
    ///   - width: Available width (YGUndefined / NaN for undefined)
    ///   - height: Available height
    ///   - direction: The direction (LTR/RTL)
    public func calculateLayout(
        width: Float = .nan,
        height: Float = .nan,
        direction: GWDirection = .ltr
    ) {
        GWLayoutEngine.calculateLayout(
            node: self,
            ownerWidth: width,
            ownerHeight: height,
            ownerDirection: direction
        )
    }

    // MARK: - Layout Results

    /// Get the computed layout result after calculation.
    public var layoutResult: GWLayoutResult {
        layout.toPublicLayoutResult()
    }

    /// Computed margin for a given edge after layout
    public func computedMargin(for edge: GWEdge) -> Float {
        switch edge {
        case .left: return layout.margin(.left)
        case .top: return layout.margin(.top)
        case .right: return layout.margin(.right)
        case .bottom: return layout.margin(.bottom)
        case .start: return layout.margin(.left) // Approximate for LTR
        case .end: return layout.margin(.right)
        case .horizontal: return layout.margin(.left) + layout.margin(.right)
        case .vertical: return layout.margin(.top) + layout.margin(.bottom)
        case .all: return layout.margin(.left) + layout.margin(.top) + layout.margin(.right) + layout.margin(.bottom)
        }
    }

    /// Computed border for a given edge after layout
    public func computedBorder(for edge: GWEdge) -> Float {
        switch edge {
        case .left: return layout.border(.left)
        case .top: return layout.border(.top)
        case .right: return layout.border(.right)
        case .bottom: return layout.border(.bottom)
        case .start: return layout.border(.left)
        case .end: return layout.border(.right)
        case .horizontal: return layout.border(.left) + layout.border(.right)
        case .vertical: return layout.border(.top) + layout.border(.bottom)
        case .all: return layout.border(.left) + layout.border(.top) + layout.border(.right) + layout.border(.bottom)
        }
    }

    /// Computed padding for a given edge after layout
    public func computedPadding(for edge: GWEdge) -> Float {
        switch edge {
        case .left: return layout.padding(.left)
        case .top: return layout.padding(.top)
        case .right: return layout.padding(.right)
        case .bottom: return layout.padding(.bottom)
        case .start: return layout.padding(.left)
        case .end: return layout.padding(.right)
        case .horizontal: return layout.padding(.left) + layout.padding(.right)
        case .vertical: return layout.padding(.top) + layout.padding(.bottom)
        case .all: return layout.padding(.left) + layout.padding(.top) + layout.padding(.right) + layout.padding(.bottom)
        }
    }
}

// MARK: - GWStyle convenience setters on GWYogaNode

public extension GWYogaNode {
    var width: GWValue {
        get { GWValue(style.width) }
        set { style.setWidth(newValue); markDirty() }
    }

    var height: GWValue {
        get { GWValue(style.height) }
        set { style.setHeight(newValue); markDirty() }
    }

    var minWidth: GWValue {
        get { GWValue(style.minWidth) }
        set { style.setMinWidth(newValue); markDirty() }
    }

    var maxWidth: GWValue {
        get { GWValue(style.maxWidth) }
        set { style.setMaxWidth(newValue); markDirty() }
    }

    var minHeight: GWValue {
        get { GWValue(style.minHeight) }
        set { style.setMinHeight(newValue); markDirty() }
    }

    var maxHeight: GWValue {
        get { GWValue(style.maxHeight) }
        set { style.setMaxHeight(newValue); markDirty() }
    }

    var flexDirection: GWFlexDirection {
        get { style.flexDirection }
        set { style.flexDirection = newValue; markDirty() }
    }

    var justifyContent: GWJustify {
        get { style.justifyContent }
        set { style.justifyContent = newValue; markDirty() }
    }

    var alignItems: GWAlign {
        get { style.alignItems }
        set { style.alignItems = newValue; markDirty() }
    }

    var alignContent: GWAlign {
        get { style.alignContent }
        set { style.alignContent = newValue; markDirty() }
    }

    var alignSelf: GWAlign {
        get { style.alignSelf }
        set { style.alignSelf = newValue; markDirty() }
    }

    var flexGrow: Float {
        get { style.flexGrow.unwrap(orDefault: 0) }
        set { style.flexGrow = GWFloatOptional(value: newValue); markDirty() }
    }

    var flexShrink: Float {
        get { style.flexShrink.unwrap(orDefault: 0) }
        set { style.flexShrink = GWFloatOptional(value: newValue); markDirty() }
    }

    var flexBasis: GWValue {
        get { GWValue(style.flexBasis) }
        set { style.setFlexBasis(newValue); markDirty() }
    }

    var positionType: GWPositionType {
        get { style.positionType }
        set { style.positionType = newValue; markDirty() }
    }

    var flexWrap: GWWrap {
        get { style.flexWrap }
        set { style.flexWrap = newValue; markDirty() }
    }

    var display: GWDisplay {
        get { style.display }
        set { style.display = newValue; markDirty() }
    }

    func setMargin(for edge: GWEdge, _ value: GWValue) {
        style.setMargin(for: edge, value); markDirty()
    }

    func setPadding(for edge: GWEdge, _ value: GWValue) {
        style.setPadding(for: edge, value); markDirty()
    }

    func setPosition(for edge: GWEdge, _ value: GWValue) {
        style.setPosition(for: edge, value); markDirty()
    }

    func setBorder(for edge: GWEdge, _ value: Float) {
        style.setBorder(for: edge, value); markDirty()
    }

    func setGap(for gutter: GWGutter, _ value: GWValue) {
        style.setGap(for: gutter, value); markDirty()
    }

    func copyStyle(from other: GWYogaNode) {
        style = other.style
        markDirty()
    }

    // MARK: Grid properties

    var gridTemplateColumns: GWGridTrackList {
        get { style.gridTemplateColumns }
        set { style.gridTemplateColumns = newValue; markDirty() }
    }

    var gridTemplateRows: GWGridTrackList {
        get { style.gridTemplateRows }
        set { style.gridTemplateRows = newValue; markDirty() }
    }

    var gridAutoColumns: GWGridTrackList {
        get { style.gridAutoColumns }
        set { style.gridAutoColumns = newValue; markDirty() }
    }

    var gridAutoRows: GWGridTrackList {
        get { style.gridAutoRows }
        set { style.gridAutoRows = newValue; markDirty() }
    }

    var gridColumnStart: GWGridLine {
        get { style.gridColumnStart }
        set { style.gridColumnStart = newValue; markDirty() }
    }

    var gridColumnEnd: GWGridLine {
        get { style.gridColumnEnd }
        set { style.gridColumnEnd = newValue; markDirty() }
    }

    var gridRowStart: GWGridLine {
        get { style.gridRowStart }
        set { style.gridRowStart = newValue; markDirty() }
    }

    var gridRowEnd: GWGridLine {
        get { style.gridRowEnd }
        set { style.gridRowEnd = newValue; markDirty() }
    }
}
