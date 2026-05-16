import Foundation
import GWYoga
import GWYogaKit

#if os(iOS) || os(tvOS)
import UIKit

// MARK: - YogaVStack

/// 垂直堆栈容器（等效于 flexDirection: .column）
open class YogaVStack: YogaLayoutView {

    public init(
        spacing: Float = 0,
        alignment: GWAlign = .stretch,
        @YogaDSLBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        yoga.flexDirection = .column
        yoga.alignItems = alignment
        if spacing > 0 { yoga.rowGap = .points(spacing) }
        let views = content()
        for v in views {
            addSubview(v)
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YogaHStack

/// 水平堆栈容器（等效于 flexDirection: .row）
open class YogaHStack: YogaLayoutView {

    public init(
        spacing: Float = 0,
        alignment: GWAlign = .center,
        @YogaDSLBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        yoga.flexDirection = .row
        yoga.alignItems = alignment
        if spacing > 0 { yoga.columnGap = .points(spacing) }
        let views = content()
        for v in views {
            addSubview(v)
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YogaZStack

/// 层叠容器（子视图全部绝对定位，以 alignment 对齐）
open class YogaZStack: YogaLayoutView {

    public init(
        alignment: GWAlign = .center,
        @YogaDSLBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        yoga.positionType = .relative
        let views = content()
        for v in views {
            v.yoga.positionType = .absolute
            addSubview(v)
        }
        if let first = views.first {
            first.yoga.positionType = .relative
            first.yoga.alignSelf = alignment
        }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - YogaScrollView

/// 可滚动容器（使用 Yoga 布局计算 contentSize）
open class YogaScrollView: YogaLayoutView {

    public var axis: NSLayoutConstraint.Axis = .vertical {
        didSet { updateContentAxis() }
    }

    private let contentView = YogaLayoutView()

    public init(
        axis: NSLayoutConstraint.Axis = .vertical,
        @YogaDSLBuilder content: () -> [UIView] = { [] }
    ) {
        super.init(frame: .zero)
        self.axis = axis
        contentView.yoga.flexDirection = axis == .vertical ? .column : .row
        let views = content()
        for v in views {
            contentView.addSubview(v)
        }
        addSubview(contentView)
        updateContentAxis()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func updateContentAxis() {
        if axis == .vertical {
            contentView.yoga.flexDirection = .column
        } else {
            contentView.yoga.flexDirection = .row
        }
    }
}

#endif
