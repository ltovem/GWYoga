import GWYoga

#if os(macOS)
import AppKit

extension NSTextField {
    /// 便捷设置文本并标记 Yoga 节点为脏
    public func setYogaText(_ text: String?) {
        self.stringValue = text ?? ""
        yoga.markDirty()
    }
}

extension NSImageView {
    /// 便捷设置图片并标记 Yoga 节点为脏
    public func setYogaImage(_ image: NSImage?) {
        self.image = image
        yoga.markDirty()
    }
}

extension NSButton {
    /// 便捷设置标题并标记 Yoga 节点为脏
    public func setYogaTitle(_ title: String) {
        self.title = title
        yoga.markDirty()
    }
}
#endif
