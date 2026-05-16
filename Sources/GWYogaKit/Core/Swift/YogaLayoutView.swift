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
    // 确保节点树与视图树一致
    YogaNodeManager.rebuildNodeTree(for: view)

    // 计算布局
    let rootNode = view.yoga.node
    rootNode.calculateLayout(
        width: Float(view.bounds.width),
        height: Float(view.bounds.height),
        direction: .ltr
    )

    // 应用结果到子视图
    applyYogaFrames(parentView: view, parentNode: rootNode)
}

/// 递归应用布局结果到子视图 frame
internal func applyYogaFrames(parentView: YKLView, parentNode: GWYogaNode) {
    let children = parentNode.children
    let subviewList = parentView.subviews

    for (index, childNode) in children.enumerated() {
        guard index < subviewList.count else { break }
        let subview = subviewList[index]

        let result = childNode.layoutResult
        var frame = CGRect(
            x: CGFloat(result.left),
            y: CGFloat(result.top),
            width: CGFloat(result.width),
            height: CGFloat(result.height)
        )
        // NaN 保护
        if frame.origin.x.isNaN || frame.origin.y.isNaN ||
           frame.size.width.isNaN || frame.size.height.isNaN {
            frame = .zero
        }
        subview.frame = frame

        // 递归应用子视图的子视图
        applyYogaFrames(parentView: subview, parentNode: childNode)
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
