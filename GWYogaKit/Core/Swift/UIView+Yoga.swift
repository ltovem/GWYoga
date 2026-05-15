import GWYoga

#if os(iOS)
import UIKit

private var yogaPropertiesKey: UInt8 = 0

extension UIView {
    /// 访问此视图的 Yoga 样式属性。
    /// 首次访问时自动创建关联的 GWYogaNode。
    public var yoga: YogaProperties {
        if let existing = objc_getAssociatedObject(self, &yogaPropertiesKey) as? YogaProperties {
            return existing
        }
        let props = YogaProperties(view: self)
        objc_setAssociatedObject(self, &yogaPropertiesKey, props, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return props
    }
}
#endif
