import GWYoga

#if os(iOS)
import UIKit

extension UILabel {
    /// 便捷设置文本并标记 Yoga 节点为脏
    public func setYogaText(_ text: String?) {
        self.text = text
        yoga.markDirty()
    }
}

extension UIImageView {
    /// 便捷设置图片并标记 Yoga 节点为脏
    public func setYogaImage(_ image: UIImage?) {
        self.image = image
        yoga.markDirty()
    }
}

extension UIButton {
    /// 便捷设置标题并标记 Yoga 节点为脏
    public func setYogaTitle(_ title: String?, for state: UIControl.State = .normal) {
        setTitle(title, for: state)
        yoga.markDirty()
    }
    /// 便捷设置图片并标记 Yoga 节点为脏
    public func setYogaImage(_ image: UIImage?, for state: UIControl.State = .normal) {
        setImage(image, for: state)
        yoga.markDirty()
    }
}
#endif
