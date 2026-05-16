import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit

// MARK: - YogaProperties 富文本支持

extension YogaProperties {

    /// 设置 NSAttributedString，自动配置 measureFunction 以便 Yoga 正确计算尺寸。
    ///
    /// 设置后 `isIntrinsic` 自动变为 true，Yoga 布局时会根据文本内容计算宽高。
    ///
    /// ```
    /// let attrText = NSAttributedString(
    ///     string: "Hello World",
    ///     attributes: [.font: UIFont.boldSystemFont(ofSize: 18)]
    /// )
    /// label.style.attributedText = attrText
    /// label.style.numberOfLines = 2
    /// ```
    public var attributedText: NSAttributedString? {
        get {
            (view as? UILabel)?.attributedText
        }
        set {
            guard let label = view as? UILabel else { return }
            label.attributedText = newValue
            if newValue != nil {
                isIntrinsic = true
            }
            markDirty()
        }
    }

    /// 行数控制（UILabel.numberOfLines）
    public var numberOfLines: Int {
        get { (view as? UILabel)?.numberOfLines ?? 1 }
        set {
            guard let label = view as? UILabel else { return }
            label.numberOfLines = newValue
            markDirty()
        }
    }

    /// 便捷构造 attributedText 并设置到 label。
    ///
    /// ```
    /// label.style.attributedText { builder in
    ///     builder.text("Hello ", font: .systemFont(ofSize: 16), color: .gray)
    ///     builder.text("World", font: .boldSystemFont(ofSize: 16), color: .blue)
    /// }
    /// ```
    @discardableResult
    public func attributedText(_ configure: (YogaAttributedTextBuilder) -> Void) -> Self {
        let builder = YogaAttributedTextBuilder()
        configure(builder)
        self.attributedText = builder.result
        return self
    }

    /// 链式设置 numberOfLines
    @discardableResult
    public func numberOfLines(_ value: Int) -> Self {
        self.numberOfLines = value
        return self
    }
}

// MARK: - YogaAttributedTextBuilder

/// 便捷构建 NSAttributedString。
///
/// ```
/// let builder = YogaAttributedTextBuilder()
/// builder.text("Hello ", font: .systemFont(ofSize: 16), color: .gray)
/// builder.text("World", font: .boldSystemFont(ofSize: 16), color: .blue)
/// label.attributedText = builder.result
/// ```
public final class YogaAttributedTextBuilder {

    private let string = NSMutableAttributedString()

    public init() {}

    /// 追加一段文本
    @discardableResult
    public func text(_ text: String, font: UIFont, color: UIColor? = nil, alignment: NSTextAlignment? = nil) -> Self {
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
        if let color = color {
            attributes[.foregroundColor] = color
        }
        let paraStyle = NSMutableParagraphStyle()
        if let alignment = alignment {
            paraStyle.alignment = alignment
        }
        if alignment != nil || !paraStyle.isEqual(NSMutableParagraphStyle()) {
            attributes[.paragraphStyle] = paraStyle
        }
        string.append(NSAttributedString(string: text, attributes: attributes))
        return self
    }

    /// 追加带完整自定义属性的文本
    @discardableResult
    public func text(_ text: String, attributes: [NSAttributedString.Key: Any]) -> Self {
        string.append(NSAttributedString(string: text, attributes: attributes))
        return self
    }

    /// 构建完成的 NSAttributedString
    public var result: NSAttributedString {
        string.copy() as? NSAttributedString ?? string
    }
}
#endif
