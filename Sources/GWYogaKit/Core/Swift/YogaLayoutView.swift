import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Yoga 布局容器视图。
///
/// YogaLayoutView 自动管理子视图的 Yoga 节点树，在 layoutSubviews/layout 中
/// 自动运行 Yoga 布局计算并将结果应用到子视图的 frame。
///
/// 使用方式：
/// ```swift
/// let container = YogaLayoutView(frame: .init(x: 0, y: 0, width: 375, height: 667))
/// container.yoga.flexDirection = .column
/// container.yoga.padding = [.all: .points(16)]
///
/// let label = UILabel()
/// label.text = "Hello"
/// label.yoga.isIntrinsic = true
/// container.addSubview(label)
/// // → layout 时自动计算 label 的位置和尺寸
/// ```
open class YogaLayoutView: YKLView {

    // MARK: - 布局策略

    /// Yoga 布局执行策略
    ///
    /// - `.auto`: 仅节点 dirty 时重算（增量模式，默认）
    /// - `.forced`: 每次 layoutSubviews/layout 都重算
    /// - `.manual`: 不自动触发，需手动调用 performYogaLayout()
    open var yogaLayoutMode: YogaLayoutMode = .auto

    /// 是否需要在此次 layout 循环中执行 Yoga 布局
    private var shouldPerformLayout: Bool {
        switch yogaLayoutMode {
        case .forced: return true
        case .manual: return false
        case .auto:   return yoga.isDirty
        }
    }

    // MARK: - 生命周期

    #if os(iOS)
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        guard subview !== self else { return }
        YogaNodeManager.addChild(subview, to: self)
    }

    open override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        guard subview !== self else { return }
        YogaNodeManager.removeChild(subview)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if shouldPerformLayout {
            _applyYogaLayout(to: self)
        }
    }
    #elseif os(macOS)
    open override var isFlipped: Bool { true }

    open override func didAddSubview(_ subview: NSView) {
        super.didAddSubview(subview)
        guard subview !== self else { return }
        YogaNodeManager.addChild(subview, to: self)
    }

    open override func willRemoveSubview(_ subview: NSView) {
        super.willRemoveSubview(subview)
        guard subview !== self else { return }
        YogaNodeManager.removeChild(subview)
    }

    open override func layout() {
        super.layout()
        if shouldPerformLayout {
            _applyYogaLayout(to: self)
        }
    }
    #endif

    // MARK: - 内容尺寸

    #if os(iOS)
    open override var intrinsicContentSize: CGSize {
        if yoga.isDirty {
            _applyYogaLayout(to: self)
        }
        let r = yoga.node.layoutResult
        return CGSize(width: CGFloat(r.width), height: CGFloat(r.height))
    }
    #elseif os(macOS)
    open override var intrinsicContentSize: CGSize {
        if yoga.isDirty {
            _applyYogaLayout(to: self)
        }
        let r = yoga.node.layoutResult
        return CGSize(width: CGFloat(r.width), height: CGFloat(r.height))
    }
    #endif
}

// MARK: - 独立布局函数

/// 对任意视图执行 Yoga 布局计算并应用 frame 到子视图。
internal func _applyYogaLayout(to view: YKLView) {
    // 清除旧 handler，避免 rebuildNodeTree 过程中 markDirty 触发残留回调
    view.yoga.node.dirtiedHandler = nil

    YogaNodeManager.rebuildNodeTree(for: view)
    let rootNode = view.yoga.node

    // 新根节点上设置 dirtied handler → 自动触发 UIKit 布局
    rootNode.dirtiedHandler = { [weak view] _ in
        #if os(iOS) || os(tvOS)
        view?.setNeedsLayout()
        #elseif os(macOS)
        view?.needsLayout = true
        #endif
    }

    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var layoutWidth = view.bounds.width
    var layoutHeight = view.bounds.height

    #if os(iOS) || os(tvOS)
    let mode = view.yoga.safeAreaMode
    let insets = view.safeAreaInsets

    switch mode {
    case .auto:
        offsetX = insets.left
        offsetY = insets.top
        layoutWidth = max(0, view.bounds.width - insets.left - insets.right)
        layoutHeight = max(0, view.bounds.height - insets.top - insets.bottom)
    case .padding:
        let style = view.yoga.node.style
        let savedLeft = GWValue(from: style.padding[GWEdge.left.rawValue])
        let savedRight = GWValue(from: style.padding[GWEdge.right.rawValue])
        let savedTop = GWValue(from: style.padding[GWEdge.top.rawValue])
        let savedBottom = GWValue(from: style.padding[GWEdge.bottom.rawValue])
        let leftVal = savedLeft.unit == .undefined ? 0 : savedLeft.value
        let rightVal = savedRight.unit == .undefined ? 0 : savedRight.value
        let topVal = savedTop.unit == .undefined ? 0 : savedTop.value
        let bottomVal = savedBottom.unit == .undefined ? 0 : savedBottom.value
        view.yoga.setPadding(.left, .points(Float(insets.left) + leftVal))
        view.yoga.setPadding(.right, .points(Float(insets.right) + rightVal))
        view.yoga.setPadding(.top, .points(Float(insets.top) + topVal))
        view.yoga.setPadding(.bottom, .points(Float(insets.bottom) + bottomVal))
        defer {
            view.yoga.setPadding(.left, savedLeft)
            view.yoga.setPadding(.right, savedRight)
            view.yoga.setPadding(.top, savedTop)
            view.yoga.setPadding(.bottom, savedBottom)
        }
    case .manual:
        break
    }
    #endif

    // 如果 style 没有显式设宽/高，传 NaN 让 Yoga 按内容自由计算（类似 CSS height: auto）
    let style = view.yoga.node.style
    if style.width.unit == .undefined || style.width.unit == .auto {
        layoutWidth = CGFloat.nan
    }
    if style.height.unit == .undefined || style.height.unit == .auto {
        layoutHeight = CGFloat.nan
    }

    rootNode.calculateLayout(
        width: Float(layoutWidth),
        height: Float(layoutHeight),
        direction: .ltr
    )

    applyYogaFrames(parentView: view, parentNode: rootNode, offsetX: offsetX, offsetY: offsetY)
}

/// 递归应用布局结果到子视图 frame
internal func applyYogaFrames(parentView: YKLView, parentNode: GWYogaNode,
                              offsetX: CGFloat = 0, offsetY: CGFloat = 0) {
    let children = parentNode.children
    let subviewList = parentView.subviews

    for (index, childNode) in children.enumerated() {
        guard index < subviewList.count else { break }
        let subview = subviewList[index]

        let result = childNode.layoutResult
        var frame = CGRect(
            x: offsetX + CGFloat(result.left),
            y: offsetY + CGFloat(result.top),
            width: CGFloat(result.width),
            height: CGFloat(result.height)
        )
        // NaN 保护
        if frame.origin.x.isNaN || frame.origin.y.isNaN ||
           frame.size.width.isNaN || frame.size.height.isNaN {
            frame = .zero
        }
        subview.frame = frame

        // 递归应用子视图的子视图（子视图 offset 归零，因为已经在 safe area 内部）
        applyYogaFrames(parentView: subview, parentNode: childNode, offsetX: 0, offsetY: 0)
    }
}

// MARK: - YKLView 布局扩展

extension YKLView {
    /// 手动触发 Yoga 布局计算并应用 frame 到子视图。
    /// 任何 UIView 都可以调用此方法，无需继承 YogaLayoutView。
    /// ObjC 调用：`[view performYogaLayout]`
    @objc
    public func performYogaLayout() {
        _applyYogaLayout(to: self)
    }
}
