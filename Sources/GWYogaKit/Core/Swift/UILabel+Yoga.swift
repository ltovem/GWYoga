import GWYoga

#if os(iOS) || os(tvOS)
import UIKit

// MARK: - 便捷方法（手动）

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

// MARK: - 自动脏标记（Method Swizzling）

private var labelSwizzled = false
private var buttonSwizzled = false

extension UILabel {
    /// 启用文本变化自动脏标记。框架内部自动调用，无需手动触发。
    static func _yoga_enableAutoMarkDirty() {
        guard !labelSwizzled else { return }
        labelSwizzled = true

        let textSel = #selector(setter: UILabel.text)
        let textSwizzled = #selector(UILabel._yoga_setText(_:))
        _yoga_swizzleMethod(UILabel.self, textSel, textSwizzled)

        let attrSel = #selector(setter: UILabel.attributedText)
        let attrSwizzled = #selector(UILabel._yoga_setAttributedText(_:))
        _yoga_swizzleMethod(UILabel.self, attrSel, attrSwizzled)
    }

    @objc private func _yoga_setText(_ text: String?) {
        let old = self.text
        self._yoga_setText(text)
        if old != text {
            _yoga_markDirtyIfEnabled()
        }
    }

    @objc private func _yoga_setAttributedText(_ text: NSAttributedString?) {
        let old = self.attributedText
        self._yoga_setAttributedText(text)
        if old != text {
            _yoga_markDirtyIfEnabled()
        }
    }

    private func _yoga_markDirtyIfEnabled() {
        if let props = objc_getAssociatedObject(self, &YogaPropertiesAssociatedKey) as? YogaProperties {
            props.node.markDirty()
        }
    }
}

extension UIButton {
    /// 启用标题变化自动脏标记。框架内部自动调用，无需手动触发。
    static func _yoga_enableAutoMarkDirty() {
        guard !buttonSwizzled else { return }
        buttonSwizzled = true

        let titleSel = #selector(UIButton.setTitle(_:for:))
        let titleSwizzled = #selector(UIButton._yoga_setTitle(_:for:))
        _yoga_swizzleMethod(UIButton.self, titleSel, titleSwizzled)
    }

    @objc private func _yoga_setTitle(_ title: String?, for state: UIControl.State) {
        let old = self.title(for: state)
        self._yoga_setTitle(title, for: state)
        if old != title, let props = objc_getAssociatedObject(self, &YogaPropertiesAssociatedKey) as? YogaProperties {
            props.node.markDirty()
        }
    }
}

// MARK: - Swizzle 辅助

private func _yoga_swizzleMethod(_ cls: AnyClass, _ original: Selector, _ swizzled: Selector) {
    if let originalMethod = class_getInstanceMethod(cls, original),
       let swizzledMethod = class_getInstanceMethod(cls, swizzled) {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
#endif
