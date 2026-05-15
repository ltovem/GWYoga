import Foundation

#if os(iOS)
import UIKit

// MARK: - YogaText

/// Yoga 布局的文本控件
open class YogaText: UILabel {
    public init(_ text: String? = nil, font: UIFont? = nil, color: UIColor? = nil) {
        super.init(frame: .zero)
        self.text = text
        yoga.isIntrinsic = true
        if let f = font { self.font = f }
        if let c = color { self.textColor = c }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YogaImage

/// Yoga 布局的图片控件
open class YogaImage: UIImageView {
    public init(_ image: UIImage? = nil, contentMode: UIView.ContentMode = .scaleAspectFit) {
        super.init(frame: .zero)
        self.image = image
        self.contentMode = contentMode
        yoga.isIntrinsic = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YogaButton

/// Yoga 布局的按钮控件
open class YogaButton: UIButton {
    public init(_ title: String? = nil, action: (() -> Void)? = nil) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        yoga.isIntrinsic = true
        if let a = action {
            self.actionHandler = a
            addTarget(self, action: #selector(didTap), for: .touchUpInside)
        }
    }

    public convenience init(icon: UIImage?, action: (() -> Void)? = nil) {
        self.init(nil, action: action)
        setImage(icon, for: .normal)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private var actionHandler: (() -> Void)?

    @objc private func didTap() {
        actionHandler?()
    }
}

// MARK: - YogaSpacer

/// 弹性空白（flexGrow = 1，撑满剩余空间）
open class YogaSpacer: UIView {
    public init(minLength: Float = 0) {
        super.init(frame: .zero)
        yoga.flexGrow = 1
        if minLength > 0 {
            yoga.minWidth = .points(minLength)
            yoga.minHeight = .points(minLength)
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YogaDivider

/// 分割线控件
open class YogaDivider: UIView {
    public init(color: UIColor = .lightGray, thickness: Float = 1) {
        super.init(frame: .zero)
        backgroundColor = color
        yoga.height = .points(thickness)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#endif
