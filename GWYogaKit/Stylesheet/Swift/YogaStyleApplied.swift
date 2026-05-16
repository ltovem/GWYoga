import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#endif

// MARK: - YogaStyleApplied

/// Protocol that enables CSS stylesheet support on views.
///
/// Conforming views get `cssID`, `cssClasses`, `cssTagName`, and `stylesheet`
/// properties via associated objects, plus the `applyStylesheet()` method.
public protocol YogaStyleApplied: AnyObject {
    /// CSS ID (`#id` selector matching)
    var cssID: String? { get set }

    /// CSS class list (`.class` selector matching)
    var cssClasses: [String] { get set }

    /// Tag name for type selector matching (e.g., "button", "label").
    /// Defaults to the class name if not set.
    var cssTagName: String { get set }

    /// The stylesheet to apply to this view and its descendants.
    var stylesheet: YogaStylesheet? { get set }

    /// Apply the stylesheet to this view and all subviews.
    func applyStylesheet()
}

// MARK: - Associated Object Keys

private var cssIDKey: UInt8 = 0
private var cssClassesKey: UInt8 = 0
private var cssTagNameKey: UInt8 = 0
private var stylesheetKey: UInt8 = 0

// MARK: - Default Implementation (UIView / NSView)

#if os(iOS) || os(tvOS)
extension YogaStyleApplied where Self: UIView {

    public var cssID: String? {
        get { objc_getAssociatedObject(self, &cssIDKey) as? String }
        set { objc_setAssociatedObject(self, &cssIDKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    public var cssClasses: [String] {
        get { objc_getAssociatedObject(self, &cssClassesKey) as? [String] ?? [] }
        set { objc_setAssociatedObject(self, &cssClassesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    public var cssTagName: String {
        get {
            if let tag = objc_getAssociatedObject(self, &cssTagNameKey) as? String { return tag }
            // Default to the class name lowercased
            return String(describing: type(of: self)).lowercased()
        }
        set { objc_setAssociatedObject(self, &cssTagNameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    public var stylesheet: YogaStylesheet? {
        get { objc_getAssociatedObject(self, &stylesheetKey) as? YogaStylesheet }
        set {
            objc_setAssociatedObject(self, &stylesheetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func applyStylesheet() {
        guard let stylesheet = self.stylesheet else { return }
        applyStylesheetRecursive(stylesheet, to: self)
    }

    // MARK: - Recursive Application

    private func applyStylesheetRecursive(_ stylesheet: YogaStylesheet, to view: UIView) {
        let parent = view.superview
        let matched = matchRules(stylesheet.rules, to: view, parent: parent)
        for (rule, _) in matched {
            for declaration in rule.declarations {
                YogaCSSPropertyMapper.apply(
                    property: declaration.property,
                    value: declaration.value,
                    to: view.yoga
                )
            }
        }
        for subview in view.subviews {
            applyStylesheetRecursive(stylesheet, to: subview)
        }
    }

    // MARK: - Rule Matching

    private func matchRules(_ rules: [YogaStyleRule], to view: UIView, parent: UIView?) -> [(YogaStyleRule, Int)] {
        let tag = view.cssTagName
        let classes = view.cssClasses
        let id = view.cssID
        var matched: [(YogaStyleRule, Int)] = []

        for rule in rules {
            if matches(selector: rule.selector, view: view, tag: tag, classes: classes, id: id, parent: parent) {
                // Check pseudo class if present
                if let pc = rule.pseudoClass {
                    if evaluatePseudoClass(pc, view: view, parent: parent) {
                        matched.append((rule, rule.specificity))
                    }
                } else {
                    matched.append((rule, rule.specificity))
                }
            }
        }

        // Sort by specificity ascending (lower-specificity applied first)
        matched.sort { $0.1 < $1.1 }
        return matched
    }

    private func matches(selector: YogaSelector, view: UIView, tag: String, classes: [String], id: String?, parent: UIView?) -> Bool {
        switch selector {
        case .universal:
            return true
        case .type(let t):
            return t.lowercased() == tag.lowercased()
        case .class_(let c):
            return classes.contains(c)
        case .id(let i):
            return id == i
        case .compound(let parts):
            return parts.allSatisfy { matches(selector: $0, view: view, tag: tag, classes: classes, id: id, parent: parent) }
        case .descendant(let left, let right):
            guard matches(selector: right, view: view, tag: tag, classes: classes, id: id, parent: parent) else { return false }
            return hasAncestor(matching: left, from: parent)
        case .child(let left, let right):
            guard matches(selector: right, view: view, tag: tag, classes: classes, id: id, parent: parent) else { return false }
            guard let p = parent else { return false }
            return matches(selector: left, view: p, tag: p.cssTagName, classes: p.cssClasses, id: p.cssID, parent: p.superview)
        case .pseudoClass(let sel, let pseudo):
            guard matches(selector: sel, view: view, tag: tag, classes: classes, id: id, parent: parent) else { return false }
            return evaluatePseudoClass(pseudo, view: view, parent: parent)
        }
    }

    private func hasAncestor(matching selector: YogaSelector, from view: UIView?) -> Bool {
        var current = view
        while let v = current {
            if matches(selector: selector, view: v, tag: v.cssTagName, classes: v.cssClasses, id: v.cssID, parent: v.superview) {
                return true
            }
            current = v.superview
        }
        return false
    }

    private func evaluatePseudoClass(_ pseudo: YogaPseudoClass, view: UIView, parent: UIView?) -> Bool {
        switch pseudo {
        case .firstChild:
            guard let parent = parent else { return false }
            return parent.subviews.first(where: { !$0.isHidden }) === view
        case .lastChild:
            guard let parent = parent else { return false }
            return parent.subviews.last(where: { !$0.isHidden }) === view
        case .nthChild(let n):
            guard let parent = parent else { return false }
            let visible = parent.subviews.filter { !$0.isHidden }
            let index = visible.firstIndex(of: view)
            return index == n - 1
        case .hover, .active, .focus:
            // Interaction-based pseudo classes require gesture recognizer tracking
            // which should be set up separately. For initial application, skip.
            return false
        }
    }
}
#endif

// MARK: - UIView Conformance

#if os(iOS) || os(tvOS)
extension UIView: YogaStyleApplied {}
#endif
