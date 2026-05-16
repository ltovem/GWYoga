import Foundation
import GWYoga
import GWYogaKit
#if os(iOS) || os(tvOS)
import UIKit

private var ygkPropertiesKey: UInt8 = 0

/// Objective-C 友好的 Yoga 布局属性访问分类。
/// 任何 UIView 都可以通过 `.gwstyle` 访问布局属性。
extension UIView {
    /// ObjC-accessible yoga layout properties for this view.
    @objc public var gwstyle: YGKLayoutProperties {
        if let existing = objc_getAssociatedObject(self, &ygkPropertiesKey) as? YGKLayoutProperties {
            return existing
        }
        let props = YGKLayoutProperties(yoga: self.yoga)
        objc_setAssociatedObject(self, &ygkPropertiesKey, props, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return props
    }

    /// 添加子视图并同步到 Yoga 节点树。
    /// YogaLayoutView 重写了 didAddSubview 自动维护节点树，
    /// 用此方法语义更准确。
    @objc(addChild:)
    @discardableResult
    public func gw_addChild(_ view: UIView) -> UIView {
        addSubview(view)
        return view
    }
}
#endif
