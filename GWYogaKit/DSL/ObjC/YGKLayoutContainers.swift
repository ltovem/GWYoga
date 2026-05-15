import Foundation
import GWYoga
import GWYogaKit
import GWYogaKitObjCCore
#if os(iOS)
import UIKit

// MARK: - YGKVStack

/// Vertical stack container (flexDirection: column).
@objc(YGKVStack)
open class YGKVStack: YogaLayoutView {
    @objc public init(spacing: CGFloat, alignment: YGKAlign) {
        super.init(frame: .zero)
        yoga.flexDirection = .column
        yoga.alignItems = alignment.swiftValue
        if spacing > 0 { yoga.rowGap = .points(Float(spacing)) }
    }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        yoga.flexDirection = .column
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YGKHStack

/// Horizontal stack container (flexDirection: row).
@objc(YGKHStack)
open class YGKHStack: YogaLayoutView {
    @objc public init(spacing: CGFloat, alignment: YGKAlign) {
        super.init(frame: .zero)
        yoga.flexDirection = .row
        yoga.alignItems = alignment.swiftValue
        if spacing > 0 { yoga.columnGap = .points(Float(spacing)) }
    }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        yoga.flexDirection = .row
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YGKZStack

/// Overlay container (children absolutely positioned).
@objc(YGKZStack)
open class YGKZStack: YogaLayoutView {
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Add a child view positioned with given alignment.
    @objc public func addChild(_ view: UIView, alignment: YGKAlign) {
        view.yogaProperties.positionType = .absolute
        if subviews.isEmpty {
            view.yogaProperties.positionType = .relative
            view.yogaProperties.alignSelf = alignment
        }
        addSubview(view)
    }
}

// MARK: - YGKScrollView

/// Scrollable Yoga container.
@objc(YGKScrollView)
open class YGKScrollView: YogaLayoutView {
    private let content = YogaLayoutView()

    @objc public var axis: Int {
        get { content.yoga.flexDirection == .column ? 0 : 1 }
        set { content.yoga.flexDirection = newValue == 0 ? .column : .row }
    }

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        content.yoga.flexDirection = .column
        addSubview(content)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc public override func addSubview(_ view: UIView) {
        if view !== content {
            content.addSubview(view)
        } else {
            super.addSubview(view)
        }
    }
}

#endif
