import Foundation
import GWYoga
import GWYogaKit
#if os(iOS) || os(tvOS)
import UIKit

/// Objective-C 友好的 UILabel/UIImageView/UIButton 扩展。
extension UILabel {
    /// 设置文本并标记 Yoga 节点为脏。
    @objc public func setYogaText(_ text: String?) {
        self.text = text
        yoga.markDirty()
    }
}

extension UIImageView {
    /// 设置图片并标记 Yoga 节点为脏。
    @objc public func setYogaImage(_ image: UIImage?) {
        self.image = image
        yoga.markDirty()
    }
}

extension UIButton {
    /// 设置标题并标记 Yoga 节点为脏。
    @objc public func setYogaTitle(_ title: String?, forState state: UIControl.State) {
        setTitle(title, for: state)
        yoga.markDirty()
    }

    /// 设置标题（默认 normal state）并标记 Yoga 节点为脏。
    @objc public func setYogaTitle(_ title: String?) {
        setTitle(title, for: .normal)
        yoga.markDirty()
    }

    /// 设置图片并标记 Yoga 节点为脏。
    @objc public func setYogaImage(_ image: UIImage?, forState state: UIControl.State) {
        setImage(image, for: state)
        yoga.markDirty()
    }
}
#endif
