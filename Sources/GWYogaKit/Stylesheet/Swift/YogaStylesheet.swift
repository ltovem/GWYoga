import Foundation

// MARK: - YogaStylesheet

/// Represents a parsed CSS stylesheet containing style rules.
public struct YogaStylesheet: Hashable, Sendable {
    /// The parsed style rules, sorted by specificity.
    public private(set) var rules: [YogaStyleRule]

    public init(rules: [YogaStyleRule]) {
        self.rules = rules
    }

    /// Parse a CSS string into a stylesheet.
    public static func parse(_ css: String) throws -> YogaStylesheet {
        let rules = try YogaCSSParser.parse(css)
        return YogaStylesheet(rules: rules)
    }

    /// Load and parse a CSS file from a bundle.
    /// - Parameters:
    ///   - name: The file name (with or without .css extension).
    ///   - bundle: The bundle to load from. Defaults to `.main`.
    public static func load(named name: String, bundle: Bundle = .main) throws -> YogaStylesheet {
        let fileName = name.hasSuffix(".css") ? name : "\(name).css"
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
            throw YogaStylesheetError.fileNotFound(name)
        }
        let css = try String(contentsOf: url, encoding: .utf8)
        return try parse(css)
    }

    /// Merge multiple stylesheets into one. Later rules override earlier ones
    /// when specificity is equal.
    public static func merge(_ stylesheets: YogaStylesheet...) -> YogaStylesheet {
        let allRules = stylesheets.flatMap { $0.rules }
        return YogaStylesheet(rules: allRules)
    }
}

// MARK: - YogaStylesheetError

public enum YogaStylesheetError: Error, LocalizedError {
    case fileNotFound(String)
    case parseFailed(String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Stylesheet file not found: \(name)"
        case .parseFailed(let detail):
            return "Stylesheet parse failed: \(detail)"
        }
    }
}
