import Foundation
import GWYoga
import GWYogaKit
#if os(iOS)
import UIKit

// MARK: - YGKHTMLFactory

/// ObjC-compatible factory for HTML-style layout views.
@objc(YGKHTMLFactory)
public class YGKHTMLFactory: NSObject {

    /// Create a div container.
    @objc public static func makeDiv() -> YogaLayoutView {
        YogaLayoutView(frame: .zero)
    }

    /// Create a section container.
    @objc public static func makeSection() -> YogaLayoutView {
        let v = YogaLayoutView(frame: .zero)
        v.yoga.flexDirection = .column
        return v
    }

    /// Create a row container (flexDirection: row).
    @objc public static func makeRow() -> YogaLayoutView {
        let v = YogaLayoutView(frame: .zero)
        v.yoga.flexDirection = .row
        return v
    }

    /// Create a header container.
    @objc public static func makeHeader() -> YogaLayoutView {
        let v = YogaLayoutView(frame: .zero)
        v.yoga.flexDirection = .row
        v.yoga.alignItems = .center
        return v
    }

    /// Create a heading label (h1-h6 size).
    @objc public static func makeHeading(_ text: String, level: Int) -> UILabel {
        let sizes: [CGFloat] = [28, 24, 20, 18, 16, 14]
        let idx = max(0, min(level - 1, 5))
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: sizes[idx])
        label.yoga.isIntrinsic = true
        return label
    }

    /// Create a paragraph label.
    @objc public static func makeParagraph(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.yoga.isIntrinsic = true
        return label
    }
}

#endif
