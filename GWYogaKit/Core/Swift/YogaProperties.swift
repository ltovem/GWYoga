import Foundation
import GWYoga
#if os(iOS)
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
    }

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
            break
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
            break
        }
        #endif
    }

    // MARK: - 尺寸

    public var width: GWValue {
        get { GWValue(from: node.style.width) }
        set { node.style.setWidth(newValue); node.markDirty() }
    }

    public var height: GWValue {
        get { GWValue(from: node.style.height) }
        set { node.style.setHeight(newValue); node.markDirty() }
    }

    public var minWidth: GWValue {
        get { GWValue(from: node.style.minWidth) }
        set { node.style.setMinWidth(newValue); node.markDirty() }
    }

    public var maxWidth: GWValue {
        get { GWValue(from: node.style.maxWidth) }
        set { node.style.setMaxWidth(newValue); node.markDirty() }
    }

    public var minHeight: GWValue {
        get { GWValue(from: node.style.minHeight) }
        set { node.style.setMinHeight(newValue); node.markDirty() }
    }

    public var maxHeight: GWValue {
        get { GWValue(from: node.style.maxHeight) }
        set { node.style.setMaxHeight(newValue); node.markDirty() }
    }

    // MARK: - 主轴方向

    public var flexDirection: GWFlexDirection {
        get { node.style.flexDirection }
        set { node.style.flexDirection = newValue; node.markDirty() }
    }

    // MARK: - 对齐

    public var justifyContent: GWJustify {
        get { node.style.justifyContent }
        set { node.style.justifyContent = newValue; node.markDirty() }
    }

    public var alignItems: GWAlign {
        get { node.style.alignItems }
        set { node.style.alignItems = newValue; node.markDirty() }
    }

    public var alignSelf: GWAlign {
        get { node.style.alignSelf }
        set { node.style.alignSelf = newValue; node.markDirty() }
    }

    public var alignContent: GWAlign {
        get { node.style.alignContent }
        set { node.style.alignContent = newValue; node.markDirty() }
    }

    // MARK: - 弹性

    public var flexGrow: Float {
        get { node.style.flexGrow.unwrap(orDefault: 0) }
        set { node.style.flexGrow = GWFloatOptional(value: newValue); node.markDirty() }
    }

    public var flexShrink: Float {
        get { node.style.flexShrink.unwrap(orDefault: 0) }
        set { node.style.flexShrink = GWFloatOptional(value: newValue); node.markDirty() }
    }

    public var flexBasis: GWValue {
        get { GWValue(from: node.style.flexBasis) }
        set { node.style.setFlexBasis(newValue); node.markDirty() }
    }

    /// flex 简写：设置 flexGrow, flexShrink, flexBasis
    public var flex: Float {
        get { node.style.flex.unwrap(orDefault: 0) }
        set {
            node.style.flex = GWFloatOptional(value: newValue)
            node.style.flexGrow = GWFloatOptional(value: newValue)
            node.style.flexShrink = GWFloatOptional(value: 1)
            node.style.flexBasis = .points(0)
            node.markDirty()
        }
    }

    // MARK: - 换行

    public var flexWrap: GWWrap {
        get { node.style.flexWrap }
        set { node.style.flexWrap = newValue; node.markDirty() }
    }

    // MARK: - 定位

    public var positionType: GWPositionType {
        get { node.style.positionType }
        set { node.style.positionType = newValue; node.markDirty() }
    }

    // MARK: - 显示

    public var display: GWDisplay {
        get { node.style.display }
        set { node.style.display = newValue; node.markDirty() }
    }

    public var overflow: GWOverflow {
        get { node.style.overflow }
        set { node.style.overflow = newValue; node.markDirty() }
    }

    // MARK: - 盒模型

    public var boxSizing: GWBoxSizing {
        get { node.style.boxSizing }
        set { node.style.boxSizing = newValue; node.markDirty() }
    }

    // MARK: - 宽高比

    public var aspectRatio: Float {
        get { node.style.aspectRatio.unwrap(orDefault: .nan) }
        set { node.style.aspectRatio = GWFloatOptional(value: newValue); node.markDirty() }
    }

    // MARK: - 间距

    public var rowGap: GWValue {
        get { GWValue(from: node.style.rowGap) }
        set { node.style.setGap(for: .row, newValue); node.markDirty() }
    }

    public var columnGap: GWValue {
        get { GWValue(from: node.style.columnGap) }
        set { node.style.setGap(for: .column, newValue); node.markDirty() }
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
                node.style.setMargin(for: edge, newValue)
                node.markDirty()
            }
        }
    }

    public func setMargin(_ edge: GWEdge, _ value: GWValue) {
        node.style.setMargin(for: edge, value)
        node.markDirty()
    }

    public func setPadding(_ edge: GWEdge, _ value: GWValue) {
        node.style.setPadding(for: edge, value)
        node.markDirty()
    }

    public func setBorder(_ edge: GWEdge, _ value: Float) {
        node.style.setBorder(for: edge, value)
        node.markDirty()
    }

    public func setPosition(_ edge: GWEdge, _ value: GWValue) {
        node.style.setPosition(for: edge, value)
        node.markDirty()
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
        set { node.style.gridTemplateColumns = newValue; node.markDirty() }
    }

    public var gridTemplateRows: GWGridTrackList {
        get { node.style.gridTemplateRows }
        set { node.style.gridTemplateRows = newValue; node.markDirty() }
    }

    public var gridAutoColumns: GWGridTrackList {
        get { node.style.gridAutoColumns }
        set { node.style.gridAutoColumns = newValue; node.markDirty() }
    }

    public var gridAutoRows: GWGridTrackList {
        get { node.style.gridAutoRows }
        set { node.style.gridAutoRows = newValue; node.markDirty() }
    }

    public var gridColumnStart: GWGridLine {
        get { node.style.gridColumnStart }
        set { node.style.gridColumnStart = newValue; node.markDirty() }
    }

    public var gridColumnEnd: GWGridLine {
        get { node.style.gridColumnEnd }
        set { node.style.gridColumnEnd = newValue; node.markDirty() }
    }

    public var gridRowStart: GWGridLine {
        get { node.style.gridRowStart }
        set { node.style.gridRowStart = newValue; node.markDirty() }
    }

    public var gridRowEnd: GWGridLine {
        get { node.style.gridRowEnd }
        set { node.style.gridRowEnd = newValue; node.markDirty() }
    }
}

