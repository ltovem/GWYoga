import UIKit
import GWYoga
import GWYogaKit

class GapDemoViewController: DemoPageViewController {
    override var demoDescription: String { "rowGap + columnGap" }
    override var codeSnippet: String { "container.style.rowGap = 10\ncontainer.style.columnGap = 20" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "columnGap=20 (row)") {
                    let r = GWYogaNode(); r.style.setWidth(.points(350)); r.style.setHeight(.points(60)); r.style.flexDirection = .row; r.style.setGap(for: .column, .points(20))
                    for _ in 0..<4 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(30)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "column=10, row=15 + wrap") {
                    let r = GWYogaNode(); r.style.setWidth(.points(140)); r.style.setHeight(.points(200)); r.style.flexDirection = .row; r.style.flexWrap = .wrap
                    r.style.setGap(for: .column, .points(10)); r.style.setGap(for: .row, .points(15))
                    for _ in 0..<6 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(40)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                contentView.addSubview(sec0); contentView.addSubview(sec1)
            
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