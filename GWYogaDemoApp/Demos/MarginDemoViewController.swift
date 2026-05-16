import UIKit
import GWYoga
import GWYogaKit

class MarginDemoViewController: DemoPageViewController {
    override var demoDescription: String { "margin for all edges" }
    override var codeSnippet: String { "view.style.margin = [.all: 10]" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "margin: all=10") {
                    let r = GWYogaNode(); r.style.flexDirection = .row; r.style.setWidth(.points(300)); r.style.setHeight(.points(80))
                    for _ in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(30)); c.style.setMargin(for: .all, .points(10)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "marginLeft=20 (child2)") {
                    let r = GWYogaNode(); r.style.flexDirection = .row; r.style.setWidth(.points(300)); r.style.setHeight(.points(60))
                    for i in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(70)); c.style.setHeight(.points(25)); if i == 1 { c.style.setMargin(for: .left, .points(20)) }; r.insertChild(c, at: i) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec2 = makeSection(title: "margin+padding+border") {
                    let r = GWYogaNode(); r.style.setWidth(.points(350)); r.style.setHeight(.points(100)); r.style.setPadding(for: .all, .points(12)); r.style.setBorder(for: .all, 2)
                    let c = GWYogaNode(); c.style.setWidth(.points(100)); c.style.setHeight(.points(50)); c.style.setMargin(for: .all, .points(8)); c.style.setPadding(for: .all, .points(6)); c.style.setBorder(for: .all, 1)
                    let cc = GWYogaNode(); cc.style.setWidth(.points(60)); cc.style.setHeight(.points(20)); c.insertChild(cc, at: 0)
                    r.insertChild(c, at: 0)
                    return YogaLayoutRenderer.render(node: r)
                }
                contentView.addSubview(sec0); contentView.addSubview(sec1); contentView.addSubview(sec2)
            
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