import GWYoga

#if os(iOS) || os(tvOS)
import UIKit

private var yogaPropertiesKey: UInt8 = 0

extension UIView {
    /// 访问此视图的 Yoga 样式属性。
    /// 首次访问时自动创建关联的 GWYogaNode。
    public var yoga: YogaProperties {
        // 首次访问 yoga 时自动注册 layoutSubviews swizzle
        _yogaAutoLayoutSwizzleOnce()
        if let existing = objc_getAssociatedObject(self, &yogaPropertiesKey) as? YogaProperties {
            return existing
        }
        let props = YogaProperties(view: self)
        objc_setAssociatedObject(self, &yogaPropertiesKey, props, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return props
    }

    /// 访问 Yoga 样式属性的简洁别名。
    /// 等价于 `self.yoga`，支持属性赋值和闭包配置。
    ///
    /// ```
    /// view.style.width = 100
    /// view.style { $0.width = 100 }
    /// ```
    public var style: YogaProperties {
        get { self.yoga }
        set { /* YogaProperties 是引用类型，无需 setter 实现 */ }
    }

    // MARK: - 层级构建

    /// 添加子视图并自动同步到 Yoga 节点树。
    /// 等价于 addSubview + appendChild(yoga.node)。
    /// 如果父视图是 YogaLayoutView，didAddSubview 已同步节点树，无需重复插入。
    @discardableResult
    public func addChild(_ view: UIView) -> UIView {
        addSubview(view)
        if !(self is YogaLayoutView) {
            self.yoga.node.insertChild(view.yoga.node, at: self.yoga.node.childCount)
            _yogaAutoLayoutEnabled = true
        }
        return view
    }

    /// 在指定位置插入子视图并同步 Yoga 节点树。
    /// 如果父视图是 YogaLayoutView，didAddSubview 已同步节点树，无需重复插入。
    @discardableResult
    public func addChild(_ view: UIView, at index: Int) -> UIView {
        insertSubview(view, at: index)
        if !(self is YogaLayoutView) {
            self.yoga.node.insertChild(view.yoga.node, at: index)
            _yogaAutoLayoutEnabled = true
        }
        return view
    }

    /// 从父视图移除并同步 Yoga 节点树。
    @discardableResult
    public func removeFromParent() -> UIView {
        if let owner = self.yoga.node.owner {
            owner.removeChild(self.yoga.node)
        }
        removeFromSuperview()
        return self
    }
}
#endif
