import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit

// MARK: - YogaProperties 文本属性扩展

extension YogaProperties {

    // MARK: 文本内容

    /// 文本内容（UILabel.text / UIButton.title / UITextField.text）
    public var text: String? {
        get {
            if let label = view as? UILabel { return label.text }
            if let button = view as? UIButton { return button.title(for: .normal) }
            if let field = view as? UITextField { return field.text }
            return nil
        }
        set {
            if let label = view as? UILabel { label.text = newValue }
            if let button = view as? UIButton { button.setTitle(newValue, for: .normal) }
            if let field = view as? UITextField { field.text = newValue }
            if newValue != nil { isIntrinsic = true }
            markDirty()
        }
    }

    // MARK: 字体

    /// 字体（UILabel / UIButton / UITextField）
    public var font: UIFont? {
        get {
            if let label = view as? UILabel { return label.font }
            if let button = view as? UIButton { return button.titleLabel?.font }
            if let field = view as? UITextField { return field.font }
            return nil
        }
        set {
            let f = newValue ?? .systemFont(ofSize: 17)
            if let label = view as? UILabel { label.font = f }
            if let button = view as? UIButton { button.titleLabel?.font = f }
            if let field = view as? UITextField { field.font = f }
            markDirty()
        }
    }

    // MARK: 文字颜色

    /// 文字颜色（UILabel.textColor / UITextField.textColor）
    public var textColor: UIColor? {
        get {
            if let label = view as? UILabel { return label.textColor }
            if let field = view as? UITextField { return field.textColor }
            return nil
        }
        set {
            if let label = view as? UILabel { label.textColor = newValue }
            if let field = view as? UITextField { field.textColor = newValue }
        }
    }

    // MARK: 对齐方式

    /// 文字对齐（UILabel / UITextField）
    public var textAlignment: NSTextAlignment {
        get {
            if let label = view as? UILabel { return label.textAlignment }
            if let field = view as? UITextField { return field.textAlignment }
            return .natural
        }
        set {
            if let label = view as? UILabel { label.textAlignment = newValue }
            if let field = view as? UITextField { field.textAlignment = newValue }
        }
    }

    // MARK: 链式方法

    @discardableResult
    public func text(_ value: String?) -> Self {
        self.text = value
        return self
    }

    @discardableResult
    public func font(_ value: UIFont?) -> Self {
        self.font = value
        return self
    }

    @discardableResult
    public func textColor(_ value: UIColor?) -> Self {
        self.textColor = value
        return self
    }

    @discardableResult
    public func textAlignment(_ value: NSTextAlignment) -> Self {
        self.textAlignment = value
        return self
    }
}

#endif
