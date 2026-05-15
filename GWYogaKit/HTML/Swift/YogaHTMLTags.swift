import Foundation
import GWYoga
import GWYogaKit
import GWYogaKitDSL
import GWYogaKitStylesheet

#if os(iOS)
import UIKit

// MARK: - YogaHTMLBuilder

/// Result builder for HTML-style layout blocks.
@resultBuilder
public struct YogaHTMLBuilder {

    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expr: UIView) -> [UIView] {
        [expr]
    }

    public static func buildExpression(_ expr: [UIView]) -> [UIView] {
        expr
    }

    public static func buildOptional(_ component: [UIView]?) -> [UIView] {
        component ?? []
    }

    public static func buildEither(first component: [UIView]) -> [UIView] {
        component
    }

    public static func buildEither(second component: [UIView]) -> [UIView] {
        component
    }

    public static func buildArray(_ components: [[UIView]]) -> [UIView] {
        components.flatMap { $0 }
    }
}

// MARK: - HTML Entry Point

/// Root HTML container.
/// Creates a full-width column layout as the root of an HTML-style hierarchy.
@discardableResult
public func html(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let container = YogaLayoutView()
    container.yoga.flexDirection = .column
    container.yoga.alignItems = .stretch
    container.cssTagName = "html"
    for view in content() {
        container.addSubview(view)
    }
    return container
}

// MARK: - Block Containers

/// Generic block-level container (flex-direction: column).
@discardableResult
public func div(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .column
    view.cssTagName = "div"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

/// Section block container.
@discardableResult
public func section(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .column
    view.cssTagName = "section"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

/// Header block container.
@discardableResult
public func header(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .column
    view.cssTagName = "header"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

/// Footer block container.
@discardableResult
public func footer(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .column
    view.cssTagName = "footer"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

/// Main content block container.
@discardableResult
public func main(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .column
    view.cssTagName = "main"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

/// Navigation block container.
@discardableResult
public func nav(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .column
    view.cssTagName = "nav"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

/// Aside block container.
@discardableResult
public func aside(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .column
    view.cssTagName = "aside"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

// MARK: - Row Container

/// Horizontal row container (flex-direction: row, items center-aligned by default).
@discardableResult
public func row(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .row
    view.yoga.alignItems = .center
    view.cssTagName = "row"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

// MARK: - Text Tags

private let headingFontSizes: [Int: Float] = [
    1: 28, 2: 24, 3: 20, 4: 18, 5: 16, 6: 14
]

/// Heading level 1.
@discardableResult
public func h1(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.font = .boldSystemFont(ofSize: CGFloat(headingFontSizes[1] ?? 28))
    label.cssTagName = "h1"
    return label
}

/// Heading level 2.
@discardableResult
public func h2(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.font = .boldSystemFont(ofSize: CGFloat(headingFontSizes[2] ?? 24))
    label.cssTagName = "h2"
    return label
}

/// Heading level 3.
@discardableResult
public func h3(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.font = .boldSystemFont(ofSize: CGFloat(headingFontSizes[3] ?? 20))
    label.cssTagName = "h3"
    return label
}

/// Heading level 4.
@discardableResult
public func h4(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.font = .boldSystemFont(ofSize: CGFloat(headingFontSizes[4] ?? 18))
    label.cssTagName = "h4"
    return label
}

/// Heading level 5.
@discardableResult
public func h5(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.font = .boldSystemFont(ofSize: CGFloat(headingFontSizes[5] ?? 16))
    label.cssTagName = "h5"
    return label
}

/// Heading level 6.
@discardableResult
public func h6(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.font = .boldSystemFont(ofSize: CGFloat(headingFontSizes[5] ?? 14))
    label.cssTagName = "h6"
    return label
}

/// Paragraph text.
@discardableResult
public func p(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.cssTagName = "p"
    return label
}

/// Inline span text.
@discardableResult
public func span(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.cssTagName = "span"
    return label
}

/// Strong / bold text.
@discardableResult
public func strong(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
    label.cssTagName = "strong"
    return label
}

/// Emphasized / italic text.
@discardableResult
public func em(_ text: String) -> YogaText {
    let label = YogaText(text)
    if let descriptor = UIFont.systemFont(ofSize: UIFont.systemFontSize).fontDescriptor.withSymbolicTraits(.traitItalic) {
        label.font = UIFont(descriptor: descriptor, size: 0)
    }
    label.cssTagName = "em"
    return label
}

// MARK: - Media

/// Image tag.
@discardableResult
public func img(_ source: UIImage?, contentMode: UIView.ContentMode = .scaleAspectFit) -> YogaImage {
    let imageView = YogaImage(source, contentMode: contentMode)
    imageView.cssTagName = "img"
    return imageView
}

// MARK: - Interactive

/// Link / anchor tag.
@discardableResult
public func a(_ text: String, href: String? = nil, action: (() -> Void)? = nil) -> YogaButton {
    let button = YogaButton(text, action: action)
    button.cssTagName = "a"
    return button
}

/// Button tag.
@discardableResult
public func button(_ title: String, action: (() -> Void)? = nil) -> YogaButton {
    let btn = YogaButton(title, action: action)
    btn.cssTagName = "button"
    return btn
}

// MARK: - Lists

/// Unordered list container.
@discardableResult
public func ul(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .column
    view.cssTagName = "ul"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

/// Ordered list container.
@discardableResult
public func ol(@YogaHTMLBuilder content: () -> [UIView]) -> YogaLayoutView {
    let view = YogaLayoutView()
    view.yoga.flexDirection = .column
    view.cssTagName = "ol"
    for subview in content() {
        view.addSubview(subview)
    }
    return view
}

/// List item.
@discardableResult
public func li(_ text: String) -> YogaText {
    let label = YogaText(text)
    label.cssTagName = "li"
    return label
}

// MARK: - Utilities

/// Flexible spacer that pushes sibling views apart (flexGrow: 1).
@discardableResult
public func spacer(_ minLength: Float = 0) -> YogaSpacer {
    let s = YogaSpacer(minLength: minLength)
    s.cssTagName = "spacer"
    return s
}

/// Horizontal divider line.
@discardableResult
public func divider(color: UIColor = .lightGray, thickness: Float = 1) -> YogaDivider {
    let d = YogaDivider(color: color, thickness: thickness)
    d.cssTagName = "divider"
    return d
}

#endif
