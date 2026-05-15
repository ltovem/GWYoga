import UIKit
import GWYogaKit
import GWYoga

class GridDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grid"

        setupDemoScrollView(scrollView, sections: [
            makeDemoSection(title: "固定 2×2: [100,200]×[50,150]") {
                let r = GWYogaNode(); r.style.display = .grid
                r.style.gridTemplateColumns = [.points(100), .points(200)]
                r.style.gridTemplateRows = [.points(50), .points(150)]
                for _ in 0..<4 { r.insertChild(GWYogaNode(), at: r.children.count) }
                return (r, .nan, .nan)
            },
            makeDemoSection(title: "1fr 2fr 1fr (容器 300pt)") {
                let r = GWYogaNode(); r.style.display = .grid
                r.style.setWidth(.points(300))
                r.style.gridTemplateColumns = [.fr(1), .fr(2), .fr(1)]
                for _ in 0..<3 { r.insertChild(GWYogaNode(), at: r.children.count) }
                return (r, 300, .nan)
            },
            makeDemoSection(title: "200pt + 1fr (容器 400pt)") {
                let r = GWYogaNode(); r.style.display = .grid
                r.style.setWidth(.points(400))
                r.style.gridTemplateColumns = [.points(200), .fr(1)]
                for _ in 0..<2 { r.insertChild(GWYogaNode(), at: r.children.count) }
                return (r, 400, .nan)
            },
            makeDemoSection(title: "grid-column: 2/4") {
                let r = GWYogaNode(); r.style.display = .grid
                r.style.gridTemplateColumns = [.points(80), .points(80), .points(80)]
                r.style.gridTemplateRows = [.points(50), .points(50)]
                let item = GWYogaNode()
                item.style.gridColumnStart = GWGridLine(type: .integer, value: 2)
                item.style.gridColumnEnd = GWGridLine(type: .integer, value: 4)
                r.insertChild(item, at: 0); r.insertChild(GWYogaNode(), at: 1)
                return (r, .nan, .nan)
            },
            makeDemoSection(title: "minmax(50,100)+stretch") {
                let r = GWYogaNode(); r.style.display = .grid
                r.style.setWidth(.points(300))
                r.style.gridTemplateColumns = [.minmax(min: .points(50), max: .points(100)), .minmax(min: .points(50), max: .points(200))]
                r.style.justifyContent = .stretch
                for _ in 0..<2 { r.insertChild(GWYogaNode(), at: r.children.count) }
                return (r, 300, .nan)
            },
            makeDemoSection(title: "columnGap=10, rowGap=20") {
                let r = GWYogaNode(); r.style.display = .grid
                r.style.gridTemplateColumns = [.points(80), .points(80)]
                r.style.gridTemplateRows = [.points(40), .points(40)]
                r.style.setGap(for: .column, .points(10)); r.style.setGap(for: .row, .points(20))
                for _ in 0..<4 { r.insertChild(GWYogaNode(), at: r.children.count) }
                return (r, .nan, .nan)
            },
            makeDemoSection(title: "grid-row: 1/3") {
                let r = GWYogaNode(); r.style.display = .grid
                r.style.gridTemplateColumns = [.points(100)]
                r.style.gridTemplateRows = [.points(40), .points(40), .points(40)]
                let s = GWYogaNode()
                s.style.gridRowStart = GWGridLine(type: .integer, value: 1)
                s.style.gridRowEnd = GWGridLine(type: .integer, value: 3)
                r.insertChild(s, at: 0)
                return (r, .nan, .nan)
            },
            makeDemoSection(title: "Grid + padding:10") {
                let r = GWYogaNode(); r.style.display = .grid
                r.style.gridTemplateColumns = [.points(100), .points(100)]
                r.style.gridTemplateRows = [.points(50)]
                r.style.setPadding(for: .all, .points(10))
                for _ in 0..<2 { r.insertChild(GWYogaNode(), at: r.children.count) }
                return (r, .nan, .nan)
            },
        ])
    }
}
