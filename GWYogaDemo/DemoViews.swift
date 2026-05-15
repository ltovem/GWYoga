import SwiftUI

@available(macOS 11.0, *)
struct FlexboxDemo: View {
    var body: some View { DemoText(title: "Flexbox", items: ["flexDirection", "justifyContent", "alignItems", "flexGrow", "flexWrap", "alignSelf"]) }
}

@available(macOS 11.0, *)
struct GridDemo: View {
    var body: some View { DemoText(title: "Grid", items: ["Fixed tracks", "fr units", "Gaps", "Placement", "MinMax", "Auto"]) }
}

@available(macOS 11.0, *)
struct MarginPaddingDemo: View {
    var body: some View { DemoText(title: "Margin & Padding", items: ["Margin all/left", "Padding container", "Border", "Combined"]) }
}

@available(macOS 11.0, *)
struct PositionDemo: View {
    var body: some View { DemoText(title: "Position", items: ["Relative offset", "Absolute top/left", "Absolute bottom/end"]) }
}

@available(macOS 11.0, *)
struct GapDemo: View {
    var body: some View { DemoText(title: "Gap", items: ["Column gap", "Row gap", "Grid gaps"]) }
}

@available(macOS 11.0, *)
struct AspectRatioDemo: View {
    var body: some View { DemoText(title: "Aspect Ratio", items: ["Width->Height", "Height->Width", "Square items"]) }
}

@available(macOS 11.0, *)
struct CompositeDemo: View {
    var body: some View { DemoText(title: "Composite Layout", items: ["Header+Grid+Footer", "Grid 3 columns", "Center layout"]) }
}

@available(macOS 11.0, *)
struct DemoText: View {
    let title: String
    let items: [String]
    var body: some View {
        List(items, id: \.self) { item in
            Text("• \(item)")
        }
        .navigationTitle(title)
    }
}
