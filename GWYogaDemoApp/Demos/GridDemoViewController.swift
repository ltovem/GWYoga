import UIKit
import GWYoga
import GWYogaKit

class GridDemoViewController: DemoPageViewController {
    override var demoDescription: String { "display: .grid, gridTemplateColumns, fr, minmax" }
    override var codeSnippet: String { "container.style.display = .grid\ncontainer.style.gridTemplateColumns = [.fr(1), .fr(2)]" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "Fixed 2x2") {
                    let r = GWYogaNode(); r.style.display = .grid; r.style.gridTemplateColumns = [.points(100), .points(200)]; r.style.gridTemplateRows = [.points(50), .points(150)]
                    for _ in 0..<4 { r.insertChild(GWYogaNode(), at: r.children.count) }; return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "1fr 2fr 1fr") {
                    let r = GWYogaNode(); r.style.display = .grid; r.style.setWidth(.points(300)); r.style.gridTemplateColumns = [.fr(1), .fr(2), .fr(1)]
                    for _ in 0..<3 { r.insertChild(GWYogaNode(), at: r.children.count) }; return YogaLayoutRenderer.render(node: r)
                }
                let sec2 = makeSection(title: "200pt + 1fr") {
                    let r = GWYogaNode(); r.style.display = .grid; r.style.setWidth(.points(400)); r.style.gridTemplateColumns = [.points(200), .fr(1)]
                    for _ in 0..<2 { r.insertChild(GWYogaNode(), at: r.children.count) }; return YogaLayoutRenderer.render(node: r)
                }
                let sec3 = makeSection(title: "grid-column: 2/4") {
                    let r = GWYogaNode(); r.style.display = .grid; r.style.gridTemplateColumns = [.points(80), .points(80), .points(80)]; r.style.gridTemplateRows = [.points(50), .points(50)]
                    let item = GWYogaNode(); item.style.gridColumnStart = GWGridLine(type: .integer, value: 2); item.style.gridColumnEnd = GWGridLine(type: .integer, value: 4)
                    r.insertChild(item, at: 0); r.insertChild(GWYogaNode(), at: 1); return YogaLayoutRenderer.render(node: r)
                }
                let sec4 = makeSection(title: "minmax + stretch") {
                    let r = GWYogaNode(); r.style.display = .grid; r.style.setWidth(.points(300))
                    r.style.gridTemplateColumns = [.minmax(min: .points(50), max: .points(100)), .minmax(min: .points(50), max: .points(200))]
                    for _ in 0..<2 { r.insertChild(GWYogaNode(), at: r.children.count) }; return YogaLayoutRenderer.render(node: r)
                }
                let sec5 = makeSection(title: "gap 10/20") {
                    let r = GWYogaNode(); r.style.display = .grid; r.style.gridTemplateColumns = [.points(80), .points(80)]; r.style.gridTemplateRows = [.points(40), .points(40)]
                    r.style.setGap(for: .column, .points(10)); r.style.setGap(for: .row, .points(20))
                    for _ in 0..<4 { r.insertChild(GWYogaNode(), at: r.children.count) }; return YogaLayoutRenderer.render(node: r)
                }
                let sec6 = makeSection(title: "padding: 10") {
                    let r = GWYogaNode(); r.style.display = .grid; r.style.gridTemplateColumns = [.points(100), .points(100)]; r.style.gridTemplateRows = [.points(50)]
                    r.style.setPadding(for: .all, .points(10))
                    for _ in 0..<2 { r.insertChild(GWYogaNode(), at: r.children.count) }; return YogaLayoutRenderer.render(node: r)
                }
                for i in 0...6 { contentView.addSubview([sec0, sec1, sec2, sec3, sec4, sec5, sec6][i]) }
            
    }

    private func makeChild(_ w: Float, _ h: Float?) -> GWYogaNode {
        let c = GWYogaNode()
        c.style.setWidth(.points(w))
        if let h = h { c.style.setHeight(.points(h)) }
        return c
    }

    private func makeSection(title: String, build: () -> UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        let view = build()
        let section = YogaLayoutView()
        section.style.marginTop(16)
        section.addSubview(label)
        section.addSubview(view)
        return section
    }
}