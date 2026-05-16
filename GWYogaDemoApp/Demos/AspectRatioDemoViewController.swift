import UIKit
import GWYoga
import GWYogaKit

class AspectRatioDemoViewController: DemoPageViewController {
    override var demoDescription: String { "aspectRatio sizes one dimension from the other" }
    override var codeSnippet: String { "view.style.aspectRatio = 1.5" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "aspectRatio=2, h=80 -> w=160") {
                    let r = GWYogaNode(); r.style.setWidth(.points(250)); r.style.setHeight(.points(150))
                    let c = GWYogaNode(); c.style.setHeight(.points(80)); c.style.aspectRatio = .init(value: 2); r.insertChild(c, at: 0)
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "aspectRatio=1.5, w=120 -> h=80") {
                    let r = GWYogaNode(); r.style.setWidth(.points(250)); r.style.setHeight(.points(150))
                    let c = GWYogaNode(); c.style.setWidth(.points(120)); c.style.aspectRatio = .init(value: 1.5); r.insertChild(c, at: 0)
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec2 = makeSection(title: "aspectRatio=1 (square)") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(80)); r.style.flexDirection = .row
                    for _ in 0..<4 { let c = GWYogaNode(); c.style.setHeight(.points(60)); c.style.aspectRatio = .init(value: 1); r.insertChild(c, at: r.children.count) }
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