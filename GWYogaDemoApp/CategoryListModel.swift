import UIKit

/// Describes a single demo entry.
@objc(DemoItem)
public class DemoItem: NSObject {
    @objc public let title: String
    @objc public let desc: String
    @objc public let route: String
    public let viewControllerClass: UIViewController.Type?

    @objc public init(title: String, desc: String, route: String, vcClass: AnyClass?) {
        self.title = title
        self.desc = desc
        self.route = route
        self.viewControllerClass = vcClass as? UIViewController.Type
        super.init()
    }
}

/// Describes a category section in the demo list.
@objc(DemoCategory)
public class DemoCategory: NSObject {
    @objc public let name: String
    @objc public let items: [DemoItem]

    @objc public init(name: String, items: [DemoItem]) {
        self.name = name
        self.items = items
        super.init()
    }
}

// MARK: - ViewController Factory

/// Registry that maps route strings to view controller classes.
@objc(DemoRegistry)
public class DemoRegistry: NSObject {
    @objc public static let shared = DemoRegistry()
    private var map: [String: UIViewController.Type] = [:]

    public override init() { super.init() }

    @objc public func register(route: String, vcClass: AnyClass) {
        if let cls = vcClass as? UIViewController.Type {
            map[route] = cls
        }
    }

    @objc public func viewController(for route: String) -> UIViewController? {
        map[route]?.init()
    }

    public func allCategories() -> [DemoCategory] {
        DemoCategories.all
    }
}

// MARK: - Demo Categories Definition

public enum DemoCategories {
    public static var all: [DemoCategory] { generateCategories() }

    private static func generateCategories() -> [DemoCategory] {
        let items = DemoCategoryBuilder.allItems
        var grouped: [String: [DemoItem]] = [:]
        for item in items {
            let cat = String(item.route.split(separator: "-").first ?? "other")
            grouped[cat, default: []].append(item)
        }

        let order = ["basic", "sizing", "advanced", "dsl", "visual", "css", "animation", "richtext", "binding", "responsive", "debug", "protocol", "measurement", "other"]

        let catNames: [String: String] = [
            "basic": "Basic Layout",
            "sizing": "Sizing & Spacing",
            "advanced": "Advanced Layout",
            "dsl": "DSL & HTML",
            "visual": "Visual Style",
            "css": "CSS Stylesheet",
            "animation": "Animation",
            "richtext": "Rich Text",
            "binding": "Data Binding",
            "responsive": "Responsive",
            "debug": "Debug & Config",
            "protocol": "Protocols",
            "measurement": "Measurement",
            "other": "Other",
        ]

        return order.compactMap { key in
            guard let items = grouped[key], !items.isEmpty else { return nil }
            return DemoCategory(name: catNames[key] ?? key, items: items)
        }
    }
}

/// Provides the flat list of all demo items.
@objc(DemoCategoryBuilder)
public class DemoCategoryBuilder: NSObject {
    @objc public static let allItems: [DemoItem] = {
        let r = DemoRegistry.shared

        // Basic Layout
        let items: [DemoItem] = [
            DemoItem(title: "Flexbox Direction", desc: "flexDirection: row / column / rowReverse / columnReverse", route: "basic-flexDirection", vcClass: nil),
            DemoItem(title: "Justify Content", desc: "justifyContent: .center, .spaceBetween, etc.", route: "basic-justifyContent", vcClass: nil),
            DemoItem(title: "Align Items", desc: "alignItems: .center, .stretch, .baseline", route: "basic-alignItems", vcClass: nil),
            DemoItem(title: "Flex Wrap & Grow", desc: "flexWrap + flexGrow + flexShrink", route: "basic-flexWrap", vcClass: nil),
            DemoItem(title: "Align Self", desc: "alignSelf overrides alignItems for single items", route: "basic-alignSelf", vcClass: nil),
            DemoItem(title: "Align Content", desc: "alignContent for multi-line containers", route: "basic-alignContent", vcClass: nil),
            DemoItem(title: "Flex Basis", desc: "flexBasis + flex shorthand", route: "basic-flexBasis", vcClass: nil),
            DemoItem(title: "Display & Overflow", desc: "display(.flex/.grid/.none), overflow, boxSizing", route: "basic-display", vcClass: nil),

            // Sizing & Spacing
            DemoItem(title: "Width & Height", desc: "width, height, min/max constraints", route: "sizing-wh", vcClass: nil),
            DemoItem(title: "Margin", desc: "margin for all edges", route: "sizing-margin", vcClass: nil),
            DemoItem(title: "Padding", desc: "padding for all edges", route: "sizing-padding", vcClass: nil),
            DemoItem(title: "Gap", desc: "rowGap + columnGap", route: "sizing-gap", vcClass: nil),
            DemoItem(title: "Position", desc: "relative / absolute positioning", route: "sizing-position", vcClass: nil),
            DemoItem(title: "Aspect Ratio", desc: "aspectRatio for proportional sizing", route: "sizing-aspectRatio", vcClass: nil),

            // Advanced Layout
            DemoItem(title: "Grid", desc: "display: grid + gridTemplateColumns", route: "advanced-grid", vcClass: nil),
            DemoItem(title: "Composite Layout", desc: "Header + Grid + Footer", route: "advanced-composite", vcClass: nil),
            DemoItem(title: "Add Child", desc: "addChild() / removeFromParent()", route: "advanced-addChild", vcClass: nil),
            DemoItem(title: "YogaLayoutView", desc: "Auto-layout container with Yoga", route: "advanced-yogaLayoutView", vcClass: nil),
            DemoItem(title: "Intrinsic Size", desc: "isIntrinsic for auto-sizing content", route: "advanced-intrinsic", vcClass: nil),
            DemoItem(title: "Layout Result", desc: "Read frame / layoutResult after layout", route: "advanced-layoutResult", vcClass: nil),
            DemoItem(title: "Value System", desc: "GWValue: points, percent, auto, maxContent, fitContent", route: "advanced-value", vcClass: nil),
            DemoItem(title: "Chainable API", desc: "All @discardableResult chained methods", route: "advanced-chainable", vcClass: nil),
            DemoItem(title: "CallAsFunction", desc: "view.style { props in } closure configuration", route: "advanced-callas", vcClass: nil),

            // DSL & HTML
            DemoItem(title: "VStack / HStack / ZStack", desc: "DSL stack containers", route: "dsl-stack", vcClass: nil),
            DemoItem(title: "ScrollView", desc: "YogaScrollView (vertical / horizontal)", route: "dsl-scroll", vcClass: nil),
            DemoItem(title: "Controls", desc: "YogaText, YogaImage, YogaButton, YogaSpacer, YogaDivider", route: "dsl-controls", vcClass: nil),
            DemoItem(title: "DSL Modifiers", desc: "Chainable .padding() .flexGrow() .backgroundColor()", route: "dsl-modifiers", vcClass: nil),
            DemoItem(title: "HTML Tags", desc: "div, h1, p, section, header, footer, row", route: "dsl-html", vcClass: nil),

            // Visual Style
            DemoItem(title: "Corner Radius", desc: "cornerRadius with 3 overloads", route: "visual-cornerRadius", vcClass: nil),
            DemoItem(title: "Shadow", desc: "shadow(color:opacity:radius:offset:)", route: "visual-shadow", vcClass: nil),
            DemoItem(title: "Border", desc: "borderWidth + borderColor", route: "visual-border", vcClass: nil),
            DemoItem(title: "Opacity & Clips", desc: "opacity + clipsToBounds + isHidden", route: "visual-opacity", vcClass: nil),
            DemoItem(title: "Background Gradient", desc: ".background(.linearGradient(...))", route: "visual-gradient", vcClass: nil),
            DemoItem(title: "Background Image", desc: ".background(.image(...))", route: "visual-image", vcClass: nil),

            // CSS Stylesheet
            DemoItem(title: "CSS Parse", desc: "YogaStylesheet.parse() CSS rules", route: "css-parse", vcClass: nil),
            DemoItem(title: "CSS Inline", desc: ".css(\"width:100px;margin:8\")", route: "css-inline", vcClass: nil),
            DemoItem(title: "CSS File", desc: "loadStylesheet() / YogaCSSConfig.registerDefault()", route: "css-file", vcClass: nil),
            DemoItem(title: "Stylesheet Merge", desc: "YogaStylesheet.merge + selector specificity", route: "css-merge", vcClass: nil),
            DemoItem(title: "Selector", desc: "cssID / cssClass / find(byID:) / findAll(byClass:)", route: "css-selector", vcClass: nil),

            // Animation
            DemoItem(title: "Animation Config", desc: "YogaAnimation + TimingFunction types", route: "animation-config", vcClass: nil),
            DemoItem(title: "Transition", desc: "YogaTransition + propertyFilter", route: "animation-transition", vcClass: nil),
            DemoItem(title: "Animate Convenience", desc: ".animate(duration:changes:) shortcut", route: "animation-animate", vcClass: nil),
            DemoItem(title: "Spring Animation", desc: ".animate(duration:dampingRatio:changes:) spring", route: "animation-spring", vcClass: nil),
            DemoItem(title: "Keyframe", desc: "YogaKeyframes keyframe animation", route: "animation-keyframe", vcClass: nil),

            // Rich Text
            DemoItem(title: "Attributed Text", desc: ".attributedText with auto-measurement", route: "richtext-attributed", vcClass: nil),
            DemoItem(title: "Attributed Builder", desc: "attributedText { builder in } convenience", route: "richtext-builder", vcClass: nil),
            DemoItem(title: "Number of Lines", desc: "numberOfLines + lineBreakMode", route: "richtext-lines", vcClass: nil),

            // Data Binding
            DemoItem(title: "YogaState", desc: "@YogaState value container with observers", route: "binding-state", vcClass: nil),
            DemoItem(title: "YogaBinding", desc: "bind(_:to:on:) keyPath binding", route: "binding-yogabinding", vcClass: nil),
            DemoItem(title: "Combine Binding", desc: "Publisher.bind(to:keyPath:)", route: "binding-combine", vcClass: nil),
            DemoItem(title: "Coalesce Layout", desc: "coalesceLayout() + scheduleDirty() batch", route: "binding-coalesce", vcClass: nil),

            // Responsive
            DemoItem(title: "Trait Change", desc: "onTraitChange for orientation / size class", route: "responsive-trait", vcClass: nil),

            // Debug & Config
            DemoItem(title: "Debug Print", desc: "debugPrint() tree output", route: "debug-print", vcClass: nil),
            DemoItem(title: "Debug Border", desc: "debugBorder(color:width:)", route: "debug-border", vcClass: nil),
            DemoItem(title: "System Layout Size", desc: "systemLayoutSize() Yoga-calculated size", route: "debug-size", vcClass: nil),
            DemoItem(title: "Yog Proxy", desc: "yog() chained UIKit + Yoga property proxy", route: "debug-yog", vcClass: nil),

            // Protocols
            DemoItem(title: "Protocol Conformance", desc: "YogaCustomDrawing + YogaStyleApplied full example", route: "protocol-conformance", vcClass: nil),
            DemoItem(title: "Custom Drawing Registry", desc: "YogaMeasureRegistry.register()", route: "protocol-registry", vcClass: nil),

            // Measurement
            DemoItem(title: "Layout Cache", desc: "YogaPreLayout + invalidateCache", route: "measurement-cache", vcClass: nil),
        ]
        return items
    }()
}
