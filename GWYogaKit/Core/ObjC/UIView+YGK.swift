import Foundation
import GWYoga
import GWYogaKit
#if os(iOS)
import UIKit

private var ygkPropertiesKey: UInt8 = 0

/// Objective-C 友好的 Yoga 属性访问分类。
/// 任何 UIView 都可以通过 `.yogaProperties` 访问 Yoga 布局属性。
extension UIView {
    /// ObjC-accessible yoga layout properties for this view.
    @objc public var yogaProperties: YGKLayoutProperties {
        if let existing = objc_getAssociatedObject(self, &ygkPropertiesKey) as? YGKLayoutProperties {
            return existing
        }
        let props = YGKLayoutProperties(yoga: self.yoga)
        objc_setAssociatedObject(self, &ygkPropertiesKey, props, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return props
    }
}
#endif
