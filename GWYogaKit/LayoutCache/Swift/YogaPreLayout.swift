import Foundation
import GWYoga
import GWYogaKit
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - 关联对象 Key

private var measurementPreLayoutKey: UInt8 = 0

// MARK: - YogaPreLayout

/// 预测量工具：在不触发实际布局的情况下计算视图尺寸。
///
/// 适用于 TableView/CollectionView 动态高度预计算、动画前尺寸预取等场景。
/// 内部使用缓存避免重复计算。
public final class YogaPreLayout {

    private weak var view: YKLView?

    internal init(view: YKLView?) {
        self.view = view
    }

    /// 测量视图在指定约束下的尺寸。
    ///
    /// 使用临时节点树计算，不影响实际布局。结果会被缓存，相同约束重复调用零开销。
    ///
    /// - Parameters:
    ///   - width: 宽度约束
    ///   - height: 高度约束（默认 .nan = 不限制）
    ///   - widthMode: 宽度测量模式（默认 .exactly）
    ///   - heightMode: 高度测量模式（默认 .undefined）
    /// - Returns: 计算后的尺寸
    public func measure(
        width: Float,
        height: Float = .nan,
        widthMode: GWMeasureMode = .exactly,
        heightMode: GWMeasureMode = .undefined
    ) -> CGSize {
        guard let v = view else { return .zero }
        let node = v.yoga.node

        let key = YogaCacheKey(
            node: node,
            width: width,
            widthMode: widthMode,
            height: height,
            heightMode: heightMode
        )

        if let cached = YogaLayoutCache.shared.getCachedSize(for: key) {
            return cached
        }

        let size = computeSize(node: node, width: width, height: height,
                               widthMode: widthMode, heightMode: heightMode)

        YogaLayoutCache.shared.setCachedSize(size, for: key)
        return size
    }

    /// 批量测量多个视图在相同宽度下的尺寸（共享缓存）。
    ///
    /// - Parameters:
    ///   - views: 需要测量的视图数组
    ///   - width: 统一的宽度约束
    /// - Returns: 每个视图对应的测量尺寸（顺序与输入一致）
    public static func measureAll(_ views: [YKLView], width: Float) -> [CGSize] {
        views.map { $0.yoga.measurement.measure(width: width) }
    }

    /// 清除此视图的测量缓存。
    /// 当视图内容变化（如文本、图片变更）后调用。
    public func invalidateCache() {
        guard let v = view else { return }
        YogaLayoutCache.shared.invalidate(for: v.yoga.node)
    }

    // MARK: - 私有方法

    /// 创建临时节点树并计算尺寸
    private func computeSize(
        node: GWYogaNode,
        width: Float,
        height: Float,
        widthMode: GWMeasureMode,
        heightMode: GWMeasureMode
    ) -> CGSize {
        let tempNode = cloneNode(node)
        let effectiveWidth = widthMode == .undefined ? .nan : width
        let effectiveHeight = heightMode == .undefined ? .nan : height
        tempNode.calculateLayout(width: effectiveWidth, height: effectiveHeight, direction: .ltr)
        let result = tempNode.layoutResult
        return CGSize(width: CGFloat(result.width), height: CGFloat(result.height))
    }

    /// 递归克隆节点树（仅复制样式和 measureFunction，不关联视图）
    private func cloneNode(_ node: GWYogaNode) -> GWYogaNode {
        let cloned = GWYogaNode()
        cloned.style = node.style
        cloned.nodeType = node.nodeType
        cloned.measureFunction = node.measureFunction
        for child in node.children {
            let clonedChild = cloneNode(child)
            cloned.insertChild(clonedChild, at: cloned.children.count)
        }
        return cloned
    }
}

// MARK: - YogaProperties 扩展

public extension YogaProperties {

    /// 预测量工具
    var measurement: YogaPreLayout {
        if let existing = objc_getAssociatedObject(self, &measurementPreLayoutKey) as? YogaPreLayout {
            return existing
        }
        guard let v = view else {
            return YogaPreLayout(view: nil)
        }
        let preLayout = YogaPreLayout(view: v)
        objc_setAssociatedObject(self, &measurementPreLayoutKey, preLayout, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return preLayout
    }

    /// 缓存是否有效
    var isMeasurementValid: Bool {
        !isDirty
    }
}
