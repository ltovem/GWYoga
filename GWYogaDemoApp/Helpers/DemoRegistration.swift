import UIKit
import GWYogaKit

/// Registers all demo view controllers with DemoRegistry.
/// Called once at app launch. All classes are in the same module, so no imports needed.
extension DemoRegistry {
    static func registerAll() {
        let r = DemoRegistry.shared
        // Basic Layout (16)
        r.register(route: "basic-flexDirection", vcClass: FlexboxDirectionDemoViewController.self)
        r.register(route: "basic-justifyContent", vcClass: JustifyContentDemoViewController.self)
        r.register(route: "basic-alignItems", vcClass: AlignItemsDemoViewController.self)
        r.register(route: "basic-flexWrap", vcClass: FlexWrapGrowDemoViewController.self)
        r.register(route: "basic-alignSelf", vcClass: AlignSelfDemoViewController.self)
        r.register(route: "basic-alignContent", vcClass: AlignContentDemoViewController.self)
        r.register(route: "basic-flexBasis", vcClass: FlexBasisDemoViewController.self)
        r.register(route: "basic-display", vcClass: DisplayDemoViewController.self)

        // Sizing & Spacing (6)
        r.register(route: "sizing-wh", vcClass: WidthHeightDemoViewController.self)
        r.register(route: "sizing-margin", vcClass: MarginDemoViewController.self)
        r.register(route: "sizing-padding", vcClass: PaddingDemoViewController.self)
        r.register(route: "sizing-gap", vcClass: GapDemoViewController.self)
        r.register(route: "sizing-position", vcClass: PositionDemoViewController.self)
        r.register(route: "sizing-aspectRatio", vcClass: AspectRatioDemoViewController.self)

        // Advanced Layout (9)
        r.register(route: "advanced-grid", vcClass: GridDemoViewController.self)
        r.register(route: "advanced-composite", vcClass: CompositeDemoViewController.self)
        r.register(route: "advanced-addChild", vcClass: AddChildDemoViewController.self)
        r.register(route: "advanced-yogaLayoutView", vcClass: YogaLayoutViewDemoViewController.self)
        r.register(route: "advanced-intrinsic", vcClass: IntrinsicDemoViewController.self)
        r.register(route: "advanced-layoutResult", vcClass: LayoutResultDemoViewController.self)
        r.register(route: "advanced-value", vcClass: ValueDemoViewController.self)
        r.register(route: "advanced-chainable", vcClass: ChainableDemoViewController.self)
        r.register(route: "advanced-callas", vcClass: CallasDemoViewController.self)

        // DSL & HTML (5)
        r.register(route: "dsl-stack", vcClass: VstackDemoViewController.self)
        r.register(route: "dsl-scroll", vcClass: ScrollDemoViewController.self)
        r.register(route: "dsl-controls", vcClass: ControlsDemoViewController.self)
        r.register(route: "dsl-modifiers", vcClass: ModifierDemoViewController.self)
        r.register(route: "dsl-html", vcClass: HtmlDemoViewController.self)

        // Visual Style (6)
        r.register(route: "visual-cornerRadius", vcClass: CornerRadiusDemoViewController.self)
        r.register(route: "visual-shadow", vcClass: ShadowDemoViewController.self)
        r.register(route: "visual-border", vcClass: BorderDemoViewController.self)
        r.register(route: "visual-opacity", vcClass: OpacityDemoViewController.self)
        r.register(route: "visual-gradient", vcClass: GradientDemoViewController.self)
        r.register(route: "visual-image", vcClass: BgimageDemoViewController.self)

        // CSS Stylesheet (5)
        r.register(route: "css-parse", vcClass: CssParseDemoViewController.self)
        r.register(route: "css-inline", vcClass: CssInlineDemoViewController.self)
        r.register(route: "css-file", vcClass: CssFileDemoViewController.self)
        r.register(route: "css-merge", vcClass: CssMergeDemoViewController.self)
        r.register(route: "css-selector", vcClass: SelectorDemoViewController.self)

        // Animation (5)
        r.register(route: "animation-config", vcClass: AnimConfigDemoViewController.self)
        r.register(route: "animation-transition", vcClass: TransitionDemoViewController.self)
        r.register(route: "animation-animate", vcClass: AnimateDemoViewController.self)
        r.register(route: "animation-spring", vcClass: SpringDemoViewController.self)
        r.register(route: "animation-keyframe", vcClass: KeyframeDemoViewController.self)

        // Rich Text (3)
        r.register(route: "richtext-attributed", vcClass: AttributedDemoViewController.self)
        r.register(route: "richtext-builder", vcClass: AttributedBuilderDemoViewController.self)
        r.register(route: "richtext-lines", vcClass: NumberOfLinesDemoViewController.self)

        // Data Binding (4)
        r.register(route: "binding-state", vcClass: YogaStateDemoViewController.self)
        r.register(route: "binding-yogabinding", vcClass: BindingDemoViewController.self)
        r.register(route: "binding-combine", vcClass: CombineDemoViewController.self)
        r.register(route: "binding-coalesce", vcClass: CoalesceDemoViewController.self)

        // Responsive (1)
        r.register(route: "responsive-trait", vcClass: TraitDemoViewController.self)

        // Debug & Config (4)
        r.register(route: "debug-print", vcClass: DebugPrintDemoViewController.self)
        r.register(route: "debug-border", vcClass: DebugBorderDemoViewController.self)
        r.register(route: "debug-size", vcClass: SystemLayoutSizeDemoViewController.self)
        r.register(route: "debug-yog", vcClass: YogDemoViewController.self)

        // Protocols (2)
        r.register(route: "protocol-conformance", vcClass: ProtocolDemoViewController.self)
        r.register(route: "protocol-registry", vcClass: RegistryDemoViewController.self)

        // Measurement (1)
        r.register(route: "measurement-cache", vcClass: CacheDemoViewController.self)
    }
}
