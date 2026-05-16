import Foundation

// MARK: - YogaSelectorParseError

public enum YogaSelectorParseError: Error, LocalizedError {
    case invalidSyntax(String)

    public var errorDescription: String? {
        switch self {
        case .invalidSyntax(let s): return "Invalid selector syntax: \(s)"
        }
    }
}

// MARK: - YogaSelector

/// CSS 选择器，支持类型、类、ID、复合、后代、子代和伪类选择器。
public enum YogaSelector: Hashable, Sendable {
    case universal
    case type(String)
    case class_(String)
    case id(String)
    case compound([YogaSelector])
    indirect case descendant(YogaSelector, YogaSelector)
    indirect case child(YogaSelector, YogaSelector)
    indirect case pseudoClass(YogaSelector, YogaPseudoClass)

    /// 解析 CSS 选择器字符串
    public static func parse(_ string: String) throws -> YogaSelector {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            throw YogaSelectorParseError.invalidSyntax(string)
        }
        return try Parser.parse(trimmed)
    }

    /// CSS 优先级 (id, class, type)
    public var specificity: (Int, Int, Int) {
        switch self {
        case .universal:
            return (0, 0, 0)
        case .type:
            return (0, 0, 1)
        case .class_:
            return (0, 1, 0)
        case .id:
            return (1, 0, 0)
        case .compound(let parts):
            return parts.reduce((0, 0, 0)) { add($0, $1.specificity) }
        case .descendant(let left, let right),
             .child(let left, let right):
            return add(left.specificity, right.specificity)
        case .pseudoClass(let sel, _):
            return (sel.specificity.0, sel.specificity.1 + 1, sel.specificity.2)
        }
    }

    /// 总 specificity 值（用于比较）
    public var specificityValue: Int {
        let s = specificity
        return s.0 * 1_000_000 + s.1 * 1_000 + s.2
    }

    private func add(_ a: (Int, Int, Int), _ b: (Int, Int, Int)) -> (Int, Int, Int) {
        (a.0 + b.0, a.1 + b.1, a.2 + b.2)
    }

    /// 匹配 tag 名、class 列表和 id
    public func matches(tag: String, classes: [String], id: String?) -> Bool {
        switch self {
        case .universal:
            return true
        case .type(let t):
            return t == tag
        case .class_(let c):
            return classes.contains(c)
        case .id(let i):
            return id == i
        case .compound(let parts):
            return parts.allSatisfy { $0.matches(tag: tag, classes: classes, id: id) }
        case .descendant, .child, .pseudoClass:
            // Complex selectors require tree walk — handled by YogaStyleApplied
            return true
        }
    }

    // MARK: - Parser

    private enum Parser {
        static func parse(_ string: String) throws -> YogaSelector {
            // Check for combinator (space, >)
            if let spaceRange = findCombinator(string) {
                let left = String(string[string.startIndex..<spaceRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                let right = String(string[spaceRange.upperBound...]).trimmingCharacters(in: .whitespaces)

                guard !left.isEmpty, !right.isEmpty else {
                    throw YogaSelectorParseError.invalidSyntax(string)
                }

                let leftSel = try parseSimple(left)
                let rightSel = try parseSimple(right)

                let char = string[spaceRange.lowerBound..<spaceRange.upperBound].trimmingCharacters(in: .whitespaces)
                if char == ">" {
                    return .child(leftSel, rightSel)
                } else {
                    return .descendant(leftSel, rightSel)
                }
            }

            return try parseSimple(string)
        }

        static func parseSimple(_ string: String) throws -> YogaSelector {
            var parts: [YogaSelector] = []

            // Check for pseudo-class at the end
            var baseString = string
            var pseudo: YogaPseudoClass?

            if let pseudoRange = findPseudoClass(baseString) {
                // Skip the leading colon
                let afterColon = baseString.index(after: pseudoRange.lowerBound)
                let pseudoStr = String(baseString[afterColon..<pseudoRange.upperBound])
                pseudo = YogaPseudoClass.parse(pseudoStr)
                baseString = String(baseString[baseString.startIndex..<pseudoRange.lowerBound])
                    .trimmingCharacters(in: .whitespaces)
            }

            var i = baseString.startIndex
            while i < baseString.endIndex {
                let c = baseString[i]

                if c == "*" {
                    parts.append(.universal)
                    i = baseString.index(after: i)
                } else if c == "." {
                    // Class selector
                    let start = baseString.index(after: i)
                    let end = findSelectorEnd(baseString, from: start)
                    parts.append(.class_(String(baseString[start..<end])))
                    i = end
                } else if c == "#" {
                    // ID selector
                    let start = baseString.index(after: i)
                    let end = findSelectorEnd(baseString, from: start)
                    parts.append(.id(String(baseString[start..<end])))
                    i = end
                } else if c.isLetter || c == "-" {
                    // Type selector
                    let end = findSelectorEnd(baseString, from: i)
                    parts.append(.type(String(baseString[i..<end])))
                    i = end
                } else {
                    i = baseString.index(after: i)
                }
            }

            guard !parts.isEmpty else {
                throw YogaSelectorParseError.invalidSyntax(string)
            }

            var result: YogaSelector = parts.count == 1 ? parts[0] : .compound(parts)

            if let p = pseudo {
                result = .pseudoClass(result, p)
            }

            return result
        }

        static func findCombinator(_ string: String) -> Range<String.Index>? {
            var depth = 0
            var i = string.startIndex
            while i < string.endIndex {
                let c = string[i]
                if c == "(" { depth += 1 }
                else if c == ")" { depth -= 1 }
                else if depth == 0, c == ">" || c == " " {
                    let start = i
                    if c == ">" {
                        return start..<string.index(after: start)
                    }
                    // Space combinator — skip consecutive spaces
                    if c == " " {
                        let after = string.index(after: i)
                        // Make sure there's a non-whitespace after
                        let remaining = string[after...].trimmingCharacters(in: .whitespaces)
                        if !remaining.isEmpty && !remaining.hasPrefix(">") && !remaining.hasPrefix(",") {
                            return start..<after
                        }
                    }
                } else if c == "," {
                    // Comma creates multiple selectors — not supported in single parse
                    break
                }
                i = string.index(after: i)
            }
            return nil
        }

        static func findPseudoClass(_ string: String) -> Range<String.Index>? {
            guard let colon = string.lastIndex(of: ":") else { return nil }
            // Check it's not part of something else
            if colon > string.startIndex, string[string.index(before: colon)] == ":" {
                // ::pseudo-element, skip
                return nil
            }
            return colon..<string.endIndex
        }

        static func findSelectorEnd(_ string: String, from start: String.Index) -> String.Index {
            var i = start
            while i < string.endIndex {
                let c = string[i]
                if c == "." || c == "#" || c == ":" || c == ">" || c == " " {
                    return i
                }
                i = string.index(after: i)
            }
            return i
        }
    }
}
