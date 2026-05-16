import Foundation

// MARK: - YogaPseudoClass

public enum YogaPseudoClass: Hashable, Sendable {
    case hover
    case active
    case focus
    case firstChild
    case lastChild
    case nthChild(Int)

    public static func parse(_ string: String) -> YogaPseudoClass? {
        switch string {
        case "hover": return .hover
        case "active": return .active
        case "focus": return .focus
        case "first-child": return .firstChild
        case "last-child": return .lastChild
        default:
            if string.hasPrefix("nth-child(") {
                let inner = string.dropFirst("nth-child(".count).dropLast()
                if let n = Int(inner) { return .nthChild(n) }
            }
            return nil
        }
    }
}
