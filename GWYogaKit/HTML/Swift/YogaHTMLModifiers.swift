import Foundation
import GWYogaKit
#if os(iOS)
import UIKit

// MARK: - CSS Attribute Modifiers

extension UIView {

    /// Set the CSS class name(s) for stylesheet matching.
    /// Multiple classes can be separated by spaces.
    @discardableResult
    public func `class`(_ name: String) -> Self {
        cssClasses = name.split(separator: " ")
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return self
    }

    /// Set the CSS ID for stylesheet matching.
    @discardableResult
    public func id(_ name: String) -> Self {
        cssID = name
        return self
    }

    /// Apply inline CSS style declarations.
    /// Accepts CSS property-value pairs separated by semicolons:
    /// `style("margin: 10px; padding: 5px; display: flex")`
    @discardableResult
    public func style(_ cssString: String) -> Self {
        let declarations = cssString
            .split(separator: ";", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        for declaration in declarations {
            guard let colonIndex = declaration.firstIndex(of: ":") else { continue }
            let property = String(declaration[..<colonIndex])
                .trimmingCharacters(in: .whitespaces)
            let value = String(declaration[declaration.index(after: colonIndex)...])
                .trimmingCharacters(in: .whitespaces)
            guard !property.isEmpty, !value.isEmpty else { continue }
            YogaCSSPropertyMapper.apply(property: property, value: value, to: yoga)
        }

        return self
    }

    /// Set the display property for Yoga layout.
    @discardableResult
    public func display(_ value: GWDisplay) -> Self {
        yoga.display = value
        return self
    }

    /// Set corner radius on the view's layer.
    @discardableResult
    public func cornerRadius(_ radius: Float) -> Self {
        layer.cornerRadius = CGFloat(radius)
        return self
    }

    /// Set background color.
    @discardableResult
    public func backgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }

    /// Set opacity / alpha.
    @discardableResult
    public func opacity(_ value: Float) -> Self {
        alpha = CGFloat(value)
        return self
    }
}

#endif
