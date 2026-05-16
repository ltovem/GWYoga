import UIKit
import GWYoga
import GWYogaKit

class DisplayDemoViewController: DemoPageViewController {
    override var demoDescription: String { "display: .flex / .grid / .none, overflow, boxSizing" }
    override var codeSnippet: String { "container.style.display = .grid" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "display: .flex") {
                    let r = GWYogaNode(); r.style.display = .flex; r.style.flexDirection = .row; r.style.setWidth(.points(200)); r.style.setHeight(.points(80))
                    for _ in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(50)); c.style.setHeight(.points(30)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "display: .grid 2x2") {
                    let r = GWYogaNode(); r.style.display = .grid; r.style.gridTemplateColumns = [.points(80), .points(80)]; r.style.gridTemplateRows = [.points(40), .points(40)]
                    for _ in 0..<4 { r.insertChild(GWYogaNode(), at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec2 = makeSection(title: "display: .none (hidden)") {
                    let r = GWYogaNode(); r.style.display = .flex; r.style.flexDirection = .row; r.style.setWidth(.points(200)); r.style.setHeight(.points(80))
                    for _ in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(50)); c.style.setHeight(.points(30)); r.insertChild(c, at: r.children.count) }
                    r.children[1].style.display = .none
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