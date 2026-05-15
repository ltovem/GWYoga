import Foundation
import GWYoga
import GWYogaKit

#if os(iOS)
import UIKit

// MARK: - YogaDSLModifiable 默认实现

extension YogaDSLModifiable {

    // MARK: 尺寸

    @discardableResult
    public func width(_ value: GWValue) -> Self {
        yoga.width = value; return self
    }

    @discardableResult
    public func height(_ value: GWValue) -> Self {
        yoga.height = value; return self
    }

    @discardableResult
    public func size(_ w: GWValue, _ h: GWValue) -> Self {
        yoga.width = w; yoga.height = h; return self
    }

    @discardableResult
    public func minWidth(_ value: GWValue) -> Self {
        yoga.minWidth = value; return self
    }

    @discardableResult
    public func maxWidth(_ value: GWValue) -> Self {
        yoga.maxWidth = value; return self
    }

    @discardableResult
    public func minHeight(_ value: GWValue) -> Self {
        yoga.minHeight = value; return self
    }

    @discardableResult
    public func maxHeight(_ value: GWValue) -> Self {
        yoga.maxHeight = value; return self
    }

    // MARK: 布局

    @discardableResult
    public func flexDirection(_ value: GWFlexDirection) -> Self {
        yoga.flexDirection = value; return self
    }

    @discardableResult
    public func justifyContent(_ value: GWJustify) -> Self {
        yoga.justifyContent = value; return self
    }

    @discardableResult
    public func alignItems(_ value: GWAlign) -> Self {
        yoga.alignItems = value; return self
    }

    @discardableResult
    public func alignSelf(_ value: GWAlign) -> Self {
        yoga.alignSelf = value; return self
    }

    // MARK: 弹性

    @discardableResult
    public func flexGrow(_ value: Float) -> Self {
        yoga.flexGrow = value; return self
    }

    @discardableResult
    public func flexShrink(_ value: Float) -> Self {
        yoga.flexShrink = value; return self
    }

    @discardableResult
    public func flexBasis(_ value: GWValue) -> Self {
        yoga.flexBasis = value; return self
    }

    // MARK: 边距

    @discardableResult
    public func margin(_ edges: GWEdge..., value: GWValue) -> Self {
        for edge in edges { yoga.setMargin(edge, value) }
        return self
    }

    @discardableResult
    public func margin(_ values: [GWEdge: GWValue]) -> Self {
        for (edge, value) in values { yoga.setMargin(edge, value) }
        return self
    }

    @discardableResult
    public func padding(_ edges: GWEdge..., value: GWValue) -> Self {
        for edge in edges { yoga.setPadding(edge, value) }
        return self
    }

    @discardableResult
    public func padding(_ values: [GWEdge: GWValue]) -> Self {
        for (edge, value) in values { yoga.setPadding(edge, value) }
        return self
    }

    @discardableResult
    public func border(_ edges: GWEdge..., value: Float) -> Self {
        for edge in edges { yoga.setBorder(edge, value) }
        return self
    }

    @discardableResult
    public func border(_ values: [GWEdge: Float]) -> Self {
        for (edge, value) in values { yoga.setBorder(edge, value) }
        return self
    }

    // MARK: 定位

    @discardableResult
    public func position(type: GWPositionType) -> Self {
        yoga.positionType = type; return self
    }

    @discardableResult
    public func position(_ edges: [GWEdge: GWValue]) -> Self {
        for (edge, value) in edges { yoga.setPosition(edge, value) }
        return self
    }

    // MARK: 间距

    @discardableResult
    public func gap(_ value: GWValue) -> Self {
        yoga.rowGap = value; yoga.columnGap = value; return self
    }

    // MARK: 显示

    @discardableResult
    public func display(_ value: GWDisplay) -> Self {
        yoga.display = value; return self
    }

    @discardableResult
    public func hidden(_ hidden: Bool) -> Self {
        yoga.display = hidden ? .none : .flex; return self
    }

    // MARK: 宽高比

    @discardableResult
    public func aspectRatio(_ ratio: Float) -> Self {
        yoga.aspectRatio = ratio; return self
    }

    // MARK: 外观

    @discardableResult
    public func backgroundColor(_ color: UIColor) -> Self {
        if let view = self as? UIView { view.backgroundColor = color }
        return self
    }

    @discardableResult
    public func cornerRadius(_ radius: Float) -> Self {
        if let view = self as? UIView { view.layer.cornerRadius = CGFloat(radius) }
        return self
    }

    @discardableResult
    public func opacity(_ value: Float) -> Self {
        if let view = self as? UIView { view.alpha = CGFloat(value) }
        return self
    }

    @discardableResult
    public func shadow(color: UIColor, radius: Float, offset: CGSize) -> Self {
        if let view = self as? UIView {
            view.layer.shadowColor = color.cgColor
            view.layer.shadowRadius = CGFloat(radius)
            view.layer.shadowOffset = offset
            view.layer.shadowOpacity = 1
        }
        return self
    }

    @discardableResult
    public func borderColor(_ color: UIColor) -> Self {
        if let view = self as? UIView { view.layer.borderColor = color.cgColor }
        return self
    }
}

// MARK: - UIView 默认遵守协议

extension UIView: YogaDSLModifiable {}

#endif
