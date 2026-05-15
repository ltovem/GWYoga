import Foundation
import GWYoga
import GWYogaKit
#if os(iOS)
import UIKit

// MARK: - YGKText

/// Yoga layout text label.
@objc(YGKText)
open class YGKText: UILabel {
    @objc public init(text: String?) {
        super.init(frame: .zero)
        self.text = text
        yoga.isIntrinsic = true
    }

    @objc public init(text: String?, fontSize: CGFloat, color: UIColor?) {
        super.init(frame: .zero)
        self.text = text
        self.font = UIFont.systemFont(ofSize: fontSize)
        if let c = color { self.textColor = c }
        yoga.isIntrinsic = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YGKImage

/// Yoga layout image view.
@objc(YGKImage)
open class YGKImage: UIImageView {
    @objc public init(image: UIImage?) {
        super.init(frame: .zero)
        self.image = image
        self.contentMode = .scaleAspectFit
        yoga.isIntrinsic = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YGKButton

/// Yoga layout button.
@objc(YGKButton)
open class YGKButton: UIButton {
    @objc public init(title: String?) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        yoga.isIntrinsic = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YGKSpacer

/// Flexible spacer (flexGrow: 1).
@objc(YGKSpacer)
open class YGKSpacer: UIView {
    @objc public init(minLength: CGFloat) {
        super.init(frame: .zero)
        yogaProperties.flexGrow = 1
        if minLength > 0 {
            yogaProperties.minWidth = minLength
            yogaProperties.minHeight = minLength
        }
    }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YGKDivider

/// Horizontal divider line.
@objc(YGKDivider)
open class YGKDivider: UIView {
    @objc public init(color: UIColor, thickness: CGFloat) {
        super.init(frame: .zero)
        backgroundColor = color
        yogaProperties.height = thickness
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#endif
