import Foundation
import GWYoga

// MARK: - YogaCSSParser

/// Parses CSS text into an array of `YogaStyleRule`.
public enum YogaCSSParser {

    /// Parse a CSS string into style rules.
    public static func parse(_ css: String) throws -> [YogaStyleRule] {
        let cleaned = stripComments(css)
        let blocks = extractRuleBlocks(cleaned)
        var rules: [YogaStyleRule] = []

        for (selectorString, declarationString) in blocks {
            let selectors = splitSelectors(selectorString)
            let declarations = parseDeclarations(declarationString)

            for selStr in selectors {
                let trimmed = selStr.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { continue }

                let selector = try YogaSelector.parse(trimmed)
                let rule = YogaStyleRule(
                    selector: selector,
                    declarations: declarations,
                    pseudoClass: extractPseudoClass(from: trimmed)
                )
                rules.append(rule)
            }
        }

        return rules
    }

    // MARK: - Comment Stripping

    private static func stripComments(_ css: String) -> String {
        var result = ""
        var i = css.startIndex
        while i < css.endIndex {
            if css[i] == "/" && i < css.index(before: css.endIndex) && css[css.index(after: i)] == "*" {
                // Find closing */ — skip past the opening /* first
                i = css.index(i, offsetBy: 2)
                var found = false
                while i < css.index(before: css.endIndex) {
                    if css[i] == "*" && css[css.index(after: i)] == "/" {
                        i = css.index(i, offsetBy: 2) // skip past */
                        found = true
                        break
                    }
                    i = css.index(after: i)
                }
                if !found { continue } // unclosed comment, stop processing
            } else {
                result.append(css[i])
                i = css.index(after: i)
            }
        }
        return result
    }

    // MARK: - Block Extraction

    /// Extract selector → declaration pairs from CSS text.
    /// Returns [(selectorString, declarationString)]
    private static func extractRuleBlocks(_ css: String) -> [(String, String)] {
        var blocks: [(String, String)] = []
        var current = ""
        var braceDepth = 0
        var selectorStart = css.startIndex

        for i in css.indices {
            let c = css[i]
            if c == "{" {
                if braceDepth == 0 {
                    let selStr = css[selectorStart..<i].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !selStr.isEmpty {
                        current = String(selStr)
                    }
                    selectorStart = css.index(after: i)
                }
                braceDepth += 1
            } else if c == "}" {
                braceDepth -= 1
                if braceDepth == 0 {
                    let declStr = css[selectorStart..<i].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !current.isEmpty {
                        blocks.append((current, declStr))
                    }
                    current = ""
                    if i < css.endIndex {
                        selectorStart = css.index(after: i)
                    }
                }
            }
        }

        return blocks
    }

    // MARK: - Selector Splitting

    /// Split comma-separated selectors: ".foo, .bar" → [".foo", ".bar"]
    private static func splitSelectors(_ string: String) -> [String] {
        var parts: [String] = []
        var current = ""
        var depth = 0
        var inParen = false

        for c in string {
            switch c {
            case "(":
                inParen = true
                current.append(c)
            case ")":
                inParen = false
                current.append(c)
            case "[":
                depth += 1
                current.append(c)
            case "]":
                depth -= 1
                current.append(c)
            case ",":
                if depth == 0 && !inParen {
                    parts.append(current.trimmingCharacters(in: .whitespaces))
                    current = ""
                } else {
                    current.append(c)
                }
            default:
                current.append(c)
            }
        }

        let last = current.trimmingCharacters(in: .whitespaces)
        if !last.isEmpty {
            parts.append(last)
        }

        return parts
    }

    // MARK: - Declaration Parsing

    /// Parse declarations from a CSS block body string.
    /// "color: red; margin: 10px" → [YogaStyleDeclaration(...)]
    private static func parseDeclarations(_ string: String) -> [YogaStyleDeclaration] {
        var declarations: [YogaStyleDeclaration] = []
        var current = ""
        var inParen = false

        for c in string {
            if c == "(" { inParen = true; current.append(c) }
            else if c == ")" { inParen = false; current.append(c) }
            else if c == ";" && !inParen {
                if let decl = parseSingleDeclaration(current) {
                    declarations.append(decl)
                }
                current = ""
            } else {
                current.append(c)
            }
        }

        // Last declaration (may not have trailing semicolon)
        let remaining = current.trimmingCharacters(in: .whitespaces)
        if !remaining.isEmpty, let decl = parseSingleDeclaration(remaining) {
            declarations.append(decl)
        }

        return declarations
    }

    /// Parse a single "property: value" string.
    private static func parseSingleDeclaration(_ string: String) -> YogaStyleDeclaration? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let colonIndex = trimmed.firstIndex(of: ":") else { return nil }

        let property = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
        let value = String(trimmed[trimmed.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)

        guard !property.isEmpty, !value.isEmpty else { return nil }
        return YogaStyleDeclaration(property: property, value: value)
    }

    // MARK: - Pseudo Class Extraction

    /// Check if the selector string has a trailing pseudo-class and return it.
    private static func extractPseudoClass(from selectorString: String) -> YogaPseudoClass? {
        // Find the last colon that starts a pseudo-class
        guard let colon = selectorString.lastIndex(of: ":") else { return nil }
        // Check it's not a pseudo-element ::
        if colon > selectorString.startIndex && selectorString[selectorString.index(before: colon)] == ":" {
            return nil
        }

        // Check for functional pseudo-classes like :nth-child(n)
        if let parenStart = selectorString[colon...].firstIndex(of: "("),
           let parenEnd = selectorString[colon...].firstIndex(of: ")") {
            let afterColon = selectorString.index(after: colon)
            let name = String(selectorString[afterColon..<parenStart])
            let args = String(selectorString[selectorString.index(after: parenStart)..<parenEnd])
            if name == "nth-child", let n = Int(args.trimmingCharacters(in: .whitespaces)) {
                return .nthChild(n)
            }
            return nil
        }

        let afterColon = selectorString.index(after: colon)
        let pseudoStr = String(selectorString[afterColon...])
        return YogaPseudoClass.parse(pseudoStr)
    }
}
