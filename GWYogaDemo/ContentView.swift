import SwiftUI
import GWYoga

// ============================================================
// ContentView — 主导航
// ============================================================

struct ContentView: View {
    @State private var selectedDemo: DemoKind = .flexbox

    var body: some View {
        NavigationView {
            List(DemoKind.allCases, id: \.self) { kind in
                NavigationLink(
                    destination: demoView(for: kind),
                    label: { Label(kind.title, systemImage: kind.icon) }
                )
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)

            // 默认选中第一个
            demoView(for: selectedDemo)
        }
        .frame(minWidth: 800, minHeight: 500)
    }

    @ViewBuilder
    private func demoView(for kind: DemoKind) -> some View {
        switch kind {
        case .flexbox:        FlexboxDemo()
        case .grid:           GridDemo()
        case .marginPadding:  MarginPaddingDemo()
        case .position:       PositionDemo()
        case .gap:            GapDemo()
        case .aspectRatio:    AspectRatioDemo()
        case .composite:      CompositeDemo()
        }
    }
}

// ============================================================
// DemoKind — 演示分类
// ============================================================

enum DemoKind: String, CaseIterable {
    case flexbox
    case grid
    case marginPadding
    case position
    case gap
    case aspectRatio
    case composite

    var title: String {
        switch self {
        case .flexbox:       return "Flexbox 弹性盒"
        case .grid:          return "CSS Grid 网格"
        case .marginPadding: return "Margin & Padding"
        case .position:      return "定位 (Relative/Absolute)"
        case .gap:           return "Gap 间距"
        case .aspectRatio:   return "宽高比"
        case .composite:     return "综合页面布局"
        }
    }

    var icon: String {
        switch self {
        case .flexbox:       return "rectangle.3.group"
        case .grid:          return "grid"
        case .marginPadding: return "rectangle.expand.vertical"
        case .position:      return "move.3d"
        case .gap:           return "space"
        case .aspectRatio:   return "aspectratio"
        case .composite:     return "rectangle.stack"
        }
    }
}
