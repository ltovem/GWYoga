import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - 关联对象 Key

private var yogaPropertiesKey: UInt8 = 0
private var yogaIsIntrinsicKey: UInt8 = 0

// MARK: - YogaProperties

/// 通过 `.yoga` 访问的样式属性代理。
/// 每个 UIView/NSView 通过关联对象持有一个 YogaProperties 实例，
/// 内部管理一个 GWYogaNode，所有属性读写直接映射到 node.style。
public final class YogaProperties {

    // MARK: - 节点

    /// 底层 Yoga 节点
    public let node: GWYogaNode

    /// 关联的视图（弱引用，避免循环）
    public private(set) weak var view: YKLView?

    // MARK: - 初始化

    internal init(view: YKLView) {
        self.view = view
        self.node = GWYogaNode()
        #if os(iOS) || os(tvOS)
        setupAutoIntrinsic(for: view)
        #endif
    }

    /// 文本/图片控件默认启用自动内容测量
    private func setupAutoIntrinsic(for view: YKLView) {
        #if os(iOS) || os(tvOS)
        switch view {
        case is UILabel, is UIButton:
            self.isIntrinsic = true
        default:
            break
        }
        #endif
    }

    // MARK: - 脏标记合并（供 YogaBinding 批量使用）

    /// 是否临时抑制 dirty 标记。当 YogaBinding 启用 layout 合并时，
    /// 批量设置样式属性时暂不触发 node.markDirty()，
    /// 由合并器在 RunLoop 末尾统一标记。
    internal static var _suppressDirtyMarking = false

    // MARK: - 内容测量

    /// 是否由内容决定尺寸（文本、图片等）。
    /// 设为 true 后自动根据控件类型设置 measureFunction。
    public var isIntrinsic: Bool {
        get {
            objc_getAssociatedObject(self, &yogaIsIntrinsicKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &yogaIsIntrinsicKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue {
                setupIntrinsicMeasurement()
            } else {
                node.measureFunction = nil
            }
        }
    }

    /// 自定义测量函数
    public typealias YogaMeasureFunction = (GWYogaNode, Float, YogaMeasurementMode, Float, YogaMeasurementMode) -> GWSize

    public var measureFunction: YogaMeasureFunction? {
        get { _measureFunction }
        set {
            _measureFunction = newValue
            if let fn = newValue {
                node.measureFunction = { [fn] node, w, wm, h, hm in
                    let ywMode = YogaMeasurementMode.fromGW(wm)
                    let yhMode = YogaMeasurementMode.fromGW(hm)
                    return fn(node, w, ywMode, h, yhMode)
                }
            } else {
                node.measureFunction = nil
            }
        }
    }
    private var _measureFunction: YogaMeasureFunction?

    /// 标记内容已变化，下次布局重新测量
    public func markDirty() {
        node.markDirty()
    }

    /// 节点是否脏
    public var isDirty: Bool { node.isDirty }

    /// 上次布局的 frame（即时返回，不触发计算）
    public var frame: CGRect {
        let r = node.layoutResult
        return CGRect(x: CGFloat(r.left), y: CGFloat(r.top),
                      width: CGFloat(r.width), height: CGFloat(r.height))
    }

    /// 上次布局结果详情
    public var layoutResult: GWLayoutResult { node.layoutResult }

    // MARK: - Safe Area

    /// Safe area 处理策略，默认 .manual（不自动处理）
    #if os(iOS) || os(tvOS)
    public var safeAreaMode: YogaSafeAreaMode {
        get {
            _safeAreaMode ?? .manual
        }
        set {
            _safeAreaMode = newValue
        }
    }
    private var _safeAreaMode: YogaSafeAreaMode?
    #endif

    // MARK: - 自动测量设置

    private func setupIntrinsicMeasurement() {
        #if os(iOS)
        switch view {
        case let label as UILabel:
            node.nodeType = .text
            node.measureFunction = { [weak label] _, w, wm, h, hm in
                guard let label = label else { return .zero }
                let size = label.sizeThatFits(CGSize(
                    width: wm == .undefined ? .greatestFiniteMagnitude : CGFloat(w),
                    height: hm == .undefined ? .greatestFiniteMagnitude : CGFloat(h)
                ))
                return GWSize(width: Float(ceil(size.width)), height: Float(ceil(size.height)))
            }
        case let imageView as UIImageView:
            node.measureFunction = { [weak imageView] _, w, wm, h, hm in
                guard let iv = imageView else { return .zero }
                let image = iv.image
                let size = image?.size ?? .zero
                return GWSize(width: Float(size.width), height: Float(size.height))
            }
        case let button as UIButton:
            node.measureFunction = { [weak button] _, w, wm, h, hm in
                guard let btn = button else { return .zero }
                let size = btn.sizeThatFits(CGSize(
                    width: wm == .undefined ? .greatestFiniteMagnitude : CGFloat(w),
                    height: hm == .undefined ? .greatestFiniteMagnitude : CGFloat(h)
                ))
                return GWSize(width: Float(ceil(size.width)), height: Float(ceil(size.height)))
            }
        default:
            if let v = view, let fn = YogaMeasureRegistry.createMeasureFunction(for: v) {
                node.nodeType = .text
                node.measureFunction = fn
            }
        }
        #elseif os(macOS)
        switch view {
        case let textField as NSTextField:
            node.nodeType = .text
            node.measureFunction = { [weak textField] _, w, wm, h, hm in
                guard let tf = textField else { return .zero }
                let constrained = CGSize(
                    width: wm == .undefined ? .greatestFiniteMagnitude : CGFloat(w),
                    height: hm == .undefined ? .greatestFiniteMagnitude : CGFloat(h)
                )
                let size = tf.sizeThatFits(constrained)
                return GWSize(width: Float(ceil(size.width)), height: Float(ceil(size.height)))
            }
        case let imageView as NSImageView:
            node.measureFunction = { [weak imageView] _, w, wm, h, hm in
                guard let iv = imageView else { return .zero }
                let size = iv.image?.size ?? .zero
                return GWSize(width: Float(size.width), height: Float(size.height))
            }
        case let button as NSButton:
            node.measureFunction = { [weak button] _, w, wm, h, hm in
                guard let btn = button else { return .zero }
                let size = btn.sizeThatFits(CGSize(
                    width: wm == .undefined ? .greatestFiniteMagnitude : CGFloat(w),
                    height: hm == .undefined ? .greatestFiniteMagnitude : CGFloat(h)
                ))
                return GWSize(width: Float(ceil(size.width)), height: Float(ceil(size.height)))
            }
        default:
            if let v = view, let fn = YogaMeasureRegistry.createMeasureFunction(for: v) {
                node.nodeType = .text
                node.measureFunction = fn
            }
        }
        #endif
    }

    // MARK: - 尺寸

    public var width: GWValue {
        get { GWValue(from: node.style.width) }
        set {
            let old = GWValue(from: node.style.width)
            guard old != newValue else { return }
            node.style.setWidth(newValue)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var height: GWValue {
        get { GWValue(from: node.style.height) }
        set {
            let old = GWValue(from: node.style.height)
            guard old != newValue else { return }
            node.style.setHeight(newValue)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var minWidth: GWValue {
        get { GWValue(from: node.style.minWidth) }
        set {
            let old = GWValue(from: node.style.minWidth)
            guard old != newValue else { return }
            node.style.setMinWidth(newValue)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var maxWidth: GWValue {
        get { GWValue(from: node.style.maxWidth) }
        set {
            let old = GWValue(from: node.style.maxWidth)
            guard old != newValue else { return }
            node.style.setMaxWidth(newValue)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var minHeight: GWValue {
        get { GWValue(from: node.style.minHeight) }
        set {
            let old = GWValue(from: node.style.minHeight)
            guard old != newValue else { return }
            node.style.setMinHeight(newValue)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var maxHeight: GWValue {
        get { GWValue(from: node.style.maxHeight) }
        set {
            let old = GWValue(from: node.style.maxHeight)
            guard old != newValue else { return }
            node.style.setMaxHeight(newValue)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 主轴方向

    public var flexDirection: GWFlexDirection {
        get { node.style.flexDirection }
        set {
            guard node.style.flexDirection != newValue else { return }
            node.style.flexDirection = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 对齐

    public var justifyContent: GWJustify {
        get { node.style.justifyContent }
        set {
            guard node.style.justifyContent != newValue else { return }
            node.style.justifyContent = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var alignItems: GWAlign {
        get { node.style.alignItems }
        set {
            guard node.style.alignItems != newValue else { return }
            node.style.alignItems = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var alignSelf: GWAlign {
        get { node.style.alignSelf }
        set {
            guard node.style.alignSelf != newValue else { return }
            node.style.alignSelf = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var alignContent: GWAlign {
        get { node.style.alignContent }
        set {
            guard node.style.alignContent != newValue else { return }
            node.style.alignContent = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 弹性

    public var flexGrow: Float {
        get { node.style.flexGrow.unwrap(orDefault: 0) }
        set {
            let old = node.style.flexGrow
            let new = GWFloatOptional(value: newValue)
            guard old != new else { return }
            guard !(old.isUndefined && new.isUndefined) else { return }
            node.style.flexGrow = new
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var flexShrink: Float {
        get { node.style.flexShrink.unwrap(orDefault: 0) }
        set {
            let old = node.style.flexShrink
            let new = GWFloatOptional(value: newValue)
            guard old != new else { return }
            guard !(old.isUndefined && new.isUndefined) else { return }
            node.style.flexShrink = new
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var flexBasis: GWValue {
        get { GWValue(from: node.style.flexBasis) }
        set {
            let old = GWValue(from: node.style.flexBasis)
            guard old != newValue else { return }
            node.style.setFlexBasis(newValue)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    /// flex 简写：设置 flexGrow, flexShrink, flexBasis
    public var flex: Float {
        get { node.style.flex.unwrap(orDefault: 0) }
        set {
            let old = node.style.flex
            let new = GWFloatOptional(value: newValue)
            guard old != new else { return }
            guard !(old.isUndefined && new.isUndefined) else { return }
            node.style.flex = new
            node.style.flexGrow = new
            node.style.flexShrink = GWFloatOptional(value: 1)
            node.style.flexBasis = .points(0)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 换行

    public var flexWrap: GWWrap {
        get { node.style.flexWrap }
        set {
            guard node.style.flexWrap != newValue else { return }
            node.style.flexWrap = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 定位

    public var positionType: GWPositionType {
        get { node.style.positionType }
        set {
            guard node.style.positionType != newValue else { return }
            node.style.positionType = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 显示

    public var display: GWDisplay {
        get { node.style.display }
        set {
            guard node.style.display != newValue else { return }
            node.style.display = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var overflow: GWOverflow {
        get { node.style.overflow }
        set {
            guard node.style.overflow != newValue else { return }
            node.style.overflow = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 盒模型

    public var boxSizing: GWBoxSizing {
        get { node.style.boxSizing }
        set {
            guard node.style.boxSizing != newValue else { return }
            node.style.boxSizing = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 宽高比

    public var aspectRatio: Float {
        get { node.style.aspectRatio.unwrap(orDefault: .nan) }
        set {
            let old = node.style.aspectRatio
            let new = GWFloatOptional(value: newValue)
            guard old != new else { return }
            guard !(old.isUndefined && new.isUndefined) else { return }
            node.style.aspectRatio = new
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 间距

    public var rowGap: GWValue {
        get { GWValue(from: node.style.rowGap) }
        set {
            let old = GWValue(from: node.style.rowGap)
            guard old != newValue else { return }
            node.style.setGap(for: .row, newValue)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var columnGap: GWValue {
        get { GWValue(from: node.style.columnGap) }
        set {
            let old = GWValue(from: node.style.columnGap)
            guard old != newValue else { return }
            node.style.setGap(for: .column, newValue)
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - 边距

    public subscript(edge: GWEdge) -> GWValue {
        get {
            switch edge {
            case .left, .top, .right, .bottom, .start, .end, .horizontal, .vertical, .all:
                return GWValue(from: node.style.margin[edge.rawValue])
            }
        }
        set {
            switch edge {
            case .left, .top, .right, .bottom, .start, .end, .horizontal, .vertical, .all:
                let old = GWValue(from: node.style.margin[edge.rawValue])
                guard old != newValue else { return }
                node.style.setMargin(for: edge, newValue)
                if !Self._suppressDirtyMarking { node.markDirty() }
            }
        }
    }

    public func setMargin(_ edge: GWEdge, _ value: GWValue) {
        let old = GWValue(from: node.style.margin[edge.rawValue])
        guard old != value else { return }
        node.style.setMargin(for: edge, value)
        if !Self._suppressDirtyMarking { node.markDirty() }
    }

    public func setPadding(_ edge: GWEdge, _ value: GWValue) {
        let old = GWValue(from: node.style.padding[edge.rawValue])
        guard old != value else { return }
        node.style.setPadding(for: edge, value)
        if !Self._suppressDirtyMarking { node.markDirty() }
    }

    public func setBorder(_ edge: GWEdge, _ value: Float) {
        let old = node.style.border[edge.rawValue]
        guard old != value else { return }
        guard !(old.isNaN && value.isNaN) else { return }
        node.style.setBorder(for: edge, value)
        if !Self._suppressDirtyMarking { node.markDirty() }
    }

    public func setPosition(_ edge: GWEdge, _ value: GWValue) {
        let old = GWValue(from: node.style.position[edge.rawValue])
        guard old != value else { return }
        node.style.setPosition(for: edge, value)
        if !Self._suppressDirtyMarking { node.markDirty() }
    }

    // MARK: - 边距字典赋值

    public var margin: [GWEdge: GWValue] {
        get { [:] } // 写优先，读取用 subscript
        set {
            for (edge, value) in newValue {
                setMargin(edge, value)
            }
        }
    }

    public var padding: [GWEdge: GWValue] {
        get { [:] }
        set {
            for (edge, value) in newValue {
                setPadding(edge, value)
            }
        }
    }

    public var border: [GWEdge: Float] {
        get { [:] }
        set {
            for (edge, value) in newValue {
                setBorder(edge, value)
            }
        }
    }

    public var position: [GWEdge: GWValue] {
        get { [:] }
        set {
            for (edge, value) in newValue {
                setPosition(edge, value)
            }
        }
    }

    // MARK: - Grid

    public var gridTemplateColumns: GWGridTrackList {
        get { node.style.gridTemplateColumns }
        set {
            guard node.style.gridTemplateColumns != newValue else { return }
            node.style.gridTemplateColumns = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var gridTemplateRows: GWGridTrackList {
        get { node.style.gridTemplateRows }
        set {
            guard node.style.gridTemplateRows != newValue else { return }
            node.style.gridTemplateRows = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var gridAutoColumns: GWGridTrackList {
        get { node.style.gridAutoColumns }
        set {
            guard node.style.gridAutoColumns != newValue else { return }
            node.style.gridAutoColumns = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var gridAutoRows: GWGridTrackList {
        get { node.style.gridAutoRows }
        set {
            guard node.style.gridAutoRows != newValue else { return }
            node.style.gridAutoRows = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var gridColumnStart: GWGridLine {
        get { node.style.gridColumnStart }
        set {
            guard node.style.gridColumnStart != newValue else { return }
            node.style.gridColumnStart = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var gridColumnEnd: GWGridLine {
        get { node.style.gridColumnEnd }
        set {
            guard node.style.gridColumnEnd != newValue else { return }
            node.style.gridColumnEnd = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var gridRowStart: GWGridLine {
        get { node.style.gridRowStart }
        set {
            guard node.style.gridRowStart != newValue else { return }
            node.style.gridRowStart = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    public var gridRowEnd: GWGridLine {
        get { node.style.gridRowEnd }
        set {
            guard node.style.gridRowEnd != newValue else { return }
            node.style.gridRowEnd = newValue
            if !Self._suppressDirtyMarking { node.markDirty() }
        }
    }

    // MARK: - callAsFunction（闭包配置）

    /// 闭包批量配置样式
    /// ```
    /// view.style {
    ///     $0.width = 100
    ///     $0.height = 200
    /// }
    /// ```
    @discardableResult
    public func callAsFunction(_ configure: (YogaProperties) -> Void) -> YogaProperties {
        configure(self)
        return self
    }

    // MARK: - 链式方法（全部返回 Self）

    @discardableResult public func width(_ value: GWValue) -> Self { self.width = value; return self }
    @discardableResult public func height(_ value: GWValue) -> Self { self.height = value; return self }
    @discardableResult public func minWidth(_ value: GWValue) -> Self { self.minWidth = value; return self }
    @discardableResult public func maxWidth(_ value: GWValue) -> Self { self.maxWidth = value; return self }
    @discardableResult public func minHeight(_ value: GWValue) -> Self { self.minHeight = value; return self }
    @discardableResult public func maxHeight(_ value: GWValue) -> Self { self.maxHeight = value; return self }

    @discardableResult public func flexDirection(_ value: GWFlexDirection) -> Self { self.flexDirection = value; return self }
    @discardableResult public func justifyContent(_ value: GWJustify) -> Self { self.justifyContent = value; return self }
    @discardableResult public func alignItems(_ value: GWAlign) -> Self { self.alignItems = value; return self }
    @discardableResult public func alignSelf(_ value: GWAlign) -> Self { self.alignSelf = value; return self }
    @discardableResult public func alignContent(_ value: GWAlign) -> Self { self.alignContent = value; return self }

    @discardableResult public func flexGrow(_ value: Float) -> Self { self.flexGrow = value; return self }
    @discardableResult public func flexShrink(_ value: Float) -> Self { self.flexShrink = value; return self }
    @discardableResult public func flexBasis(_ value: GWValue) -> Self { self.flexBasis = value; return self }
    @discardableResult public func flex(_ value: Float) -> Self { self.flex = value; return self }

    @discardableResult public func flexWrap(_ value: GWWrap) -> Self { self.flexWrap = value; return self }

    @discardableResult public func position(_ type: GWPositionType) -> Self { self.positionType = type; return self }
    @discardableResult public func display(_ value: GWDisplay) -> Self { self.display = value; return self }
    @discardableResult public func overflow(_ value: GWOverflow) -> Self { self.overflow = value; return self }

    @discardableResult public func boxSizing(_ value: GWBoxSizing) -> Self { self.boxSizing = value; return self }
    @discardableResult public func aspectRatio(_ value: Float) -> Self { self.aspectRatio = value; return self }

    @discardableResult public func rowGap(_ value: GWValue) -> Self { self.rowGap = value; return self }
    @discardableResult public func columnGap(_ value: GWValue) -> Self { self.columnGap = value; return self }
    @discardableResult public func gap(_ value: GWValue) -> Self { self.rowGap = value; self.columnGap = value; return self }

    // MARK: 边距链式

    @discardableResult public func margin(_ edge: GWEdge = .all, _ value: GWValue) -> Self { setMargin(edge, value); return self }
    @discardableResult public func margin(_ values: [GWEdge: GWValue]) -> Self { for (e, v) in values { setMargin(e, v) }; return self }
    @discardableResult public func marginTop(_ value: GWValue) -> Self { setMargin(.top, value); return self }
    @discardableResult public func marginLeft(_ value: GWValue) -> Self { setMargin(.left, value); return self }
    @discardableResult public func marginBottom(_ value: GWValue) -> Self { setMargin(.bottom, value); return self }
    @discardableResult public func marginRight(_ value: GWValue) -> Self { setMargin(.right, value); return self }
    @discardableResult public func marginHorizontal(_ value: GWValue) -> Self { setMargin(.horizontal, value); return self }
    @discardableResult public func marginVertical(_ value: GWValue) -> Self { setMargin(.vertical, value); return self }

    @discardableResult public func padding(_ edge: GWEdge = .all, _ value: GWValue) -> Self { setPadding(edge, value); return self }
    @discardableResult public func padding(_ values: [GWEdge: GWValue]) -> Self { for (e, v) in values { setPadding(e, v) }; return self }
    @discardableResult public func paddingTop(_ value: GWValue) -> Self { setPadding(.top, value); return self }
    @discardableResult public func paddingLeft(_ value: GWValue) -> Self { setPadding(.left, value); return self }
    @discardableResult public func paddingBottom(_ value: GWValue) -> Self { setPadding(.bottom, value); return self }
    @discardableResult public func paddingRight(_ value: GWValue) -> Self { setPadding(.right, value); return self }
    @discardableResult public func paddingHorizontal(_ value: GWValue) -> Self { setPadding(.horizontal, value); return self }
    @discardableResult public func paddingVertical(_ value: GWValue) -> Self { setPadding(.vertical, value); return self }

    @discardableResult public func border(_ edge: GWEdge = .all, _ value: Float) -> Self { setBorder(edge, value); return self }
    @discardableResult public func borderTop(_ value: Float) -> Self { setBorder(.top, value); return self }
    @discardableResult public func borderLeft(_ value: Float) -> Self { setBorder(.left, value); return self }
    @discardableResult public func borderBottom(_ value: Float) -> Self { setBorder(.bottom, value); return self }
    @discardableResult public func borderRight(_ value: Float) -> Self { setBorder(.right, value); return self }

    // MARK: 位置链式

    @discardableResult public func inset(_ value: GWValue) -> Self { setPosition(.all, value); return self }
    @discardableResult public func top(_ value: GWValue) -> Self { setPosition(.top, value); return self }
    @discardableResult public func left(_ value: GWValue) -> Self { setPosition(.left, value); return self }
    @discardableResult public func bottom(_ value: GWValue) -> Self { setPosition(.bottom, value); return self }
    @discardableResult public func right(_ value: GWValue) -> Self { setPosition(.right, value); return self }
}

