import UIKit
import GWYoga
import GWYogaKit

class PaddingDemoViewController: DemoPageViewController {
    override var demoDescription: String { "padding for all edges" }
    override var codeSnippet: String { "view.style.padding = [.all: 12]" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "padding: all=20") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(120)); r.style.setPadding(for: .all, .points(20)); r.style.flexDirection = .row
                    for _ in 0..<2 { let c = GWYogaNode(); c.style.setWidth(.points(80)); c.style.setHeight(.points(40)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "padding: horizontal=16") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(80)); r.style.setPadding(for: .horizontal, .points(16)); r.style.flexDirection = .row
                    for _ in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(30)); r.insertChild(c, at: r.children.count) }
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