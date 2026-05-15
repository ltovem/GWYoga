import UIKit
import GWYogaKit
import GWYoga

class GapDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gap"

        setupDemoScrollView(scrollView, sections: [
            makeDemoSection(title: "columnGap=20 (Flexbox)") {
                let r = GWYogaNode(); r.style.setWidth(.points(350)); r.style.setHeight(.points(60)); r.style.flexDirection = .row; r.style.setGap(for: .column, .points(20))
                for _ in 0..<4 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(30)); r.insertChild(c, at: r.children.count) }
                return (r, 350, 60)
            },
            makeDemoSection(title: "column=10, row=15 + flexWrap") {
                let r = GWYogaNode(); r.style.setWidth(.points(140)); r.style.setHeight(.points(200)); r.style.flexDirection = .row; r.style.flexWrap = .wrap
                r.style.setGap(for: .column, .points(10)); r.style.setGap(for: .row, .points(15))
                for _ in 0..<6 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(40)); r.insertChild(c, at: r.children.count) }
                return (r, 140, 200)
            },
            makeDemoSection(title: "Grid: columnGap=10, rowGap=20") {
                let r = GWYogaNode(); r.style.display = .grid
                r.style.gridTemplateColumns = [.points(80), .points(80)]; r.style.gridTemplateRows = [.points(40), .points(40)]
                r.style.setGap(for: .column, .points(10)); r.style.setGap(for: .row, .points(20))
                for _ in 0..<4 { r.insertChild(GWYogaNode(), at: r.children.count) }
                return (r, .nan, .nan)
            },
        ])
    }
}
