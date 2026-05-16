import Foundation

// MARK: - YogaStyleDeclaration

/// 单个 CSS 声明（属性和值对）。
public struct YogaStyleDeclaration: Hashable, Sendable {
    public let property: String
    public let value: String

    public init(property: String, value: String) {
        self.property = property.trimmingCharacters(in: .whitespaces)
        self.value = value.trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - YogaStyleRule

/// 完整的 CSS 规则（选择器 + 声明列表）。
public struct YogaStyleRule: Hashable, Sendable {
    public let selector: YogaSelector
    public let declarations: [YogaStyleDeclaration]
    public let pseudoClass: YogaPseudoClass?

    public init(selector: YogaSelector, declarations: [YogaStyleDeclaration],
                pseudoClass: YogaPseudoClass? = nil) {
        self.selector = selector
        self.declarations = declarations
        self.pseudoClass = pseudoClass
    }

    /// CSS specificity
    public var specificity: Int {
        selector.specificityValue
    }
}
