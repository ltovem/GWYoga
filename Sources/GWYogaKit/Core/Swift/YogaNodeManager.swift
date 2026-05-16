import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// 管理视图层级与 Yoga 节点树的同步。
///
/// YogaLayoutView 在 didAddSubview / willRemoveSubview 中调用此类的方法，
/// 自动保持 view 树和 node 树一致。
internal final class YogaNodeManager {

    /// 将子视图的节点添加到父视图的节点下
    internal static func addChild(_ child: YKLView, to parent: YKLView, at index: Int = -1) {
        let childNode = child.yoga.node
        let parentNode = parent.yoga.node

        // 如果已有父节点，先移除
        if childNode.owner != nil {
            childNode.owner?.removeChild(childNode)
        }

        let insertIndex = index < 0 ? parentNode.children.count : index
        parentNode.insertChild(childNode, at: insertIndex)
    }

    /// 从父节点移除子视图的节点
    internal static func removeChild(_ child: YKLView) {
        let childNode = child.yoga.node
        childNode.owner?.removeChild(childNode)
    }

    /// 重建整个节点树（从根视图开始递归）
    internal static func rebuildNodeTree(for rootView: YKLView) {
        let rootNode = rootView.yoga.node
        rootNode.removeAllChildren()
        buildNodeTree(parentView: rootView, parentNode: rootNode)
    }

    /// 递归构建节点树
    @discardableResult
    internal static func buildNodeTree(parentView: YKLView, parentNode: GWYogaNode) -> GWYogaNode {
        // 先清除旧子节点，避免 stale children 导致 insertChild 中 removeFromOwner 破坏数组
        parentNode.removeAllChildren()
        for subview in parentView.subviews {
            let childNode = subview.yoga.node
            childNode.dirtiedHandler = nil
            parentNode.appendChild(childNode)
            buildNodeTree(parentView: subview, parentNode: childNode)
        }
        return parentNode
    }
}
