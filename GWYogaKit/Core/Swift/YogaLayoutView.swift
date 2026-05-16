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

    // MARK: - 生命周期

    #if os(iOS)
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        // 跳过 YogaLayoutView 自身管理
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
        performYogaLayout()
    }
    #elseif os(macOS)
    /// macOS 默认坐标系原点在左下角，Yoga 布局使用左上角原点，
    /// 反转后使 Yoga 计算出的 Y 坐标直接匹配 AppKit 视图坐标系。
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
        performYogaLayout()
    }
    #endif

    // MARK: - Yoga 布局

    /// 手动触发布局计算。通常不需要直接调用，除非 yogaLayoutMode 为 .manual。
    @objc open func performYogaLayout() {
        if yogaLayoutMode == .auto && !yoga.yogaNode.isDirty {
            return
        }

        // 确保节点树与视图树一致
        YogaNodeManager.rebuildNodeTree(for: self)

        // 计算布局
        let rootNode = yoga.yogaNode
        rootNode.calculateLayout(
            width: Float(bounds.width),
            height: Float(bounds.height),
            direction: .ltr
        )

        // 应用结果到子视图
        applyYogaFrames(parentView: self, parentNode: rootNode)
    }

    /// 递归应用布局结果到子视图 frame
    private func applyYogaFrames(parentView: YKLView, parentNode: GWYogaNode) {
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
            #if os(iOS)
            subview.frame = frame
            #elseif os(macOS)
            subview.frame = frame
            #endif

            // 递归应用子视图的子视图
            applyYogaFrames(parentView: subview, parentNode: childNode)
        }
    }

    // MARK: - 内容尺寸

    #if os(iOS)
    open override var intrinsicContentSize: CGSize {
        if yoga.yogaNode.isDirty {
            performYogaLayout()
        }
        let r = yoga.yogaNode.layoutResult
        return CGSize(width: CGFloat(r.width), height: CGFloat(r.height))
    }
    #elseif os(macOS)
    open override var intrinsicContentSize: CGSize {
        if yoga.yogaNode.isDirty {
            performYogaLayout()
        }
        let r = yoga.yogaNode.layoutResult
        return CGSize(width: CGFloat(r.width), height: CGFloat(r.height))
    }
    #endif
}

// MARK: - YogaProperties 补充

internal extension YogaProperties {
    /// 获取关联视图的 yoga 属性对应的 Yoga 节点（YogaLayoutView 使用）
    var yogaNode: GWYogaNode { node }
}
