import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - YogaConfigProxy

/// 代理链式配置器，统一 UIKit 属性 + Yoga 布局属性的链式调用。
///
/// ```
/// UILabel()
///     .yog()
///     .text("Hello")
///     .font(.boldSystemFont(ofSize: 18))
///     .color(.darkText)
///     .alignment(.center)
///     .numberOfLines(0)
///     .width(.auto)
///     .height(44)
///     .margin(16)
///     .backgroundColor(.white)
///     .cornerRadius(8)
/// ```
public struct YogaConfigProxy<T: YKLView> {
    public let view: T

    public init(view: T) {
        self.view = view
    }

    /// Yoga 样式属性代理
    public var style: YogaProperties { view.yoga }

    // MARK: UIKit 属性

    @discardableResult
    public func text(_ value: String?) -> Self {
        #if os(iOS) || os(tvOS)
        if let label = view as? UILabel { label.text = value }
        if let button = view as? UIButton { button.setTitle(value, for: .normal) }
        #elseif os(macOS)
        if let textField = view as? NSTextField { textField.stringValue = value ?? "" }
        if let button = view as? NSButton { button.title = value ?? "" }
        #endif
        return self
    }

    @discardableResult
    public func font(_ value: PlatformFont?) -> Self {
        #if os(iOS) || os(tvOS)
        if let label = view as? UILabel { label.font = value ?? .systemFont(ofSize: 17) }
        if let button = view as? UIButton { button.titleLabel?.font = value ?? .systemFont(ofSize: 17) }
        #elseif os(macOS)
        if let textField = view as? NSTextField { textField.font = value ?? .systemFont(ofSize: 13) }
        if let button = view as? NSButton { button.font = value ?? .systemFont(ofSize: 13) }
        #endif
        return self
    }

    @discardableResult
    public func color(_ value: PlatformColor?) -> Self {
        #if os(iOS) || os(tvOS)
        if let label = view as? UILabel { label.textColor = value ?? .darkText }
        #elseif os(macOS)
        if let textField = view as? NSTextField { textField.textColor = value ?? .labelColor }
        #endif
        return self
    }

    @discardableResult
    public func alignment(_ value: PlatformTextAlignment) -> Self {
        #if os(iOS) || os(tvOS)
        if let label = view as? UILabel { label.textAlignment = value }
        #elseif os(macOS)
        if let textField = view as? NSTextField { textField.alignment = value }
        #endif
        return self
    }

    @discardableResult
    public func numberOfLines(_ value: Int) -> Self {
        #if os(iOS) || os(tvOS)
        if let label = view as? UILabel { label.numberOfLines = value }
        #endif
        return self
    }

    @discardableResult
    public func image(_ value: PlatformImage?) -> Self {
        #if os(iOS) || os(tvOS)
        if let imageView = view as? UIImageView { imageView.image = value }
        if let button = view as? UIButton { button.setImage(value, for: .normal) }
        #elseif os(macOS)
        if let imageView = view as? NSImageView { imageView.image = value }
        if let button = view as? NSButton { button.image = value }
        #endif
        return self
    }

    #if os(iOS) || os(tvOS)
    @discardableResult
    public func contentMode(_ value: UIView.ContentMode) -> Self {
        if let imageView = view as? UIImageView { imageView.contentMode = value }
        return self
    }
    #endif

    #if os(iOS) || os(tvOS)
    @discardableResult
    public func title(_ value: String?, for state: UIControl.State = .normal) -> Self {
        if let button = view as? UIButton { button.setTitle(value, for: state) }
        return self
    }
    #endif

    // MARK: Yoga 布局属性 — 常用方法

    @discardableResult public func width(_ value: GWValue) -> Self { style.width = value; return self }
    @discardableResult public func height(_ value: GWValue) -> Self { style.height = value; return self }
    @discardableResult public func minWidth(_ value: GWValue) -> Self { style.minWidth = value; return self }
    @discardableResult public func maxWidth(_ value: GWValue) -> Self { style.maxWidth = value; return self }
    @discardableResult public func minHeight(_ value: GWValue) -> Self { style.minHeight = value; return self }
    @discardableResult public func maxHeight(_ value: GWValue) -> Self { style.maxHeight = value; return self }

    @discardableResult public func flexDirection(_ value: GWFlexDirection) -> Self { style.flexDirection = value; return self }
    @discardableResult public func justifyContent(_ value: GWJustify) -> Self { style.justifyContent = value; return self }
    @discardableResult public func alignItems(_ value: GWAlign) -> Self { style.alignItems = value; return self }
    @discardableResult public func alignSelf(_ value: GWAlign) -> Self { style.alignSelf = value; return self }
    @discardableResult public func alignContent(_ value: GWAlign) -> Self { style.alignContent = value; return self }

    @discardableResult public func flexGrow(_ value: Float) -> Self { style.flexGrow = value; return self }
    @discardableResult public func flexShrink(_ value: Float) -> Self { style.flexShrink = value; return self }
    @discardableResult public func flexBasis(_ value: GWValue) -> Self { style.flexBasis = value; return self }
    @discardableResult public func flex(_ value: Float) -> Self { style.flex = value; return self }
    @discardableResult public func flexWrap(_ value: GWWrap) -> Self { style.flexWrap = value; return self }

    @discardableResult public func position(_ type: GWPositionType) -> Self { style.positionType = type; return self }
    @discardableResult public func display(_ value: GWDisplay) -> Self { style.display = value; return self }
    @discardableResult public func overflow(_ value: GWOverflow) -> Self { style.overflow = value; return self }
    @discardableResult public func boxSizing(_ value: GWBoxSizing) -> Self { style.boxSizing = value; return self }
    @discardableResult public func aspectRatio(_ value: Float) -> Self { style.aspectRatio = value; return self }

    @discardableResult public func rowGap(_ value: GWValue) -> Self { style.rowGap = value; return self }
    @discardableResult public func columnGap(_ value: GWValue) -> Self { style.columnGap = value; return self }
    @discardableResult public func gap(_ value: GWValue) -> Self { style.rowGap = value; style.columnGap = value; return self }

    @discardableResult public func margin(_ edge: GWEdge = .all, _ value: GWValue) -> Self { style.setMargin(edge, value); return self }
    @discardableResult public func marginTop(_ value: GWValue) -> Self { style.setMargin(.top, value); return self }
    @discardableResult public func marginLeft(_ value: GWValue) -> Self { style.setMargin(.left, value); return self }
    @discardableResult public func marginBottom(_ value: GWValue) -> Self { style.setMargin(.bottom, value); return self }
    @discardableResult public func marginRight(_ value: GWValue) -> Self { style.setMargin(.right, value); return self }
    @discardableResult public func marginHorizontal(_ value: GWValue) -> Self { style.setMargin(.horizontal, value); return self }
    @discardableResult public func marginVertical(_ value: GWValue) -> Self { style.setMargin(.vertical, value); return self }

    @discardableResult public func padding(_ edge: GWEdge = .all, _ value: GWValue) -> Self { style.setPadding(edge, value); return self }
    @discardableResult public func paddingTop(_ value: GWValue) -> Self { style.setPadding(.top, value); return self }
    @discardableResult public func paddingLeft(_ value: GWValue) -> Self { style.setPadding(.left, value); return self }
    @discardableResult public func paddingBottom(_ value: GWValue) -> Self { style.setPadding(.bottom, value); return self }
    @discardableResult public func paddingRight(_ value: GWValue) -> Self { style.setPadding(.right, value); return self }
    @discardableResult public func paddingHorizontal(_ value: GWValue) -> Self { style.setPadding(.horizontal, value); return self }
    @discardableResult public func paddingVertical(_ value: GWValue) -> Self { style.setPadding(.vertical, value); return self }

    @discardableResult public func inset(_ value: GWValue) -> Self { style.setPosition(.all, value); return self }
    @discardableResult public func top(_ value: GWValue) -> Self { style.setPosition(.top, value); return self }
    @discardableResult public func left(_ value: GWValue) -> Self { style.setPosition(.left, value); return self }
    @discardableResult public func bottom(_ value: GWValue) -> Self { style.setPosition(.bottom, value); return self }
    @discardableResult public func right(_ value: GWValue) -> Self { style.setPosition(.right, value); return self }

    // MARK: 视觉样式

    #if os(iOS) || os(tvOS)
    @discardableResult public func backgroundColor(_ color: UIColor?) -> Self { view.backgroundColor = color; return self }
    @discardableResult public func cornerRadius(_ radius: CGFloat) -> Self { view.layer.cornerRadius = radius; view.layer.masksToBounds = radius > 0; return self }
    @discardableResult public func shadow(color: UIColor = .black, opacity: Float = 0.3, radius: CGFloat = 4, offset: CGSize = CGSize(width: 0, height: 2)) -> Self {
        view.layer.shadowColor = color.cgColor; view.layer.shadowOpacity = opacity; view.layer.shadowRadius = radius; view.layer.shadowOffset = offset; return self
    }
    @discardableResult public func borderWidth(_ width: CGFloat) -> Self { view.layer.borderWidth = width; return self }
    @discardableResult public func borderColor(_ color: UIColor?) -> Self { view.layer.borderColor = color?.cgColor; return self }
    @discardableResult public func opacity(_ value: CGFloat) -> Self { view.alpha = value; return self }
    @discardableResult public func clipsToBounds(_ value: Bool) -> Self { view.clipsToBounds = value; return self }
    @discardableResult public func hidden(_ value: Bool) -> Self { view.isHidden = value; return self }
    #endif
}

// MARK: - UIView yog() extension

#if os(iOS) || os(tvOS)
extension UIView {
    /// 创建代理链式配置器。
    /// 使用泛型保留具体类型以便提供 UIKit 属性链式方法。
    public func yog<T: UIView>() -> YogaConfigProxy<T> {
        YogaConfigProxy(view: self as! T)
    }
}
#elseif os(macOS)
extension NSView {
    public func yog<T: NSView>() -> YogaConfigProxy<T> {
        YogaConfigProxy(view: self as! T)
    }
}
#endif
