import UIKit
import GWYoga
import GWYogaKit

class FlexboxDirectionDemoViewController: DemoPageViewController {
    override var demoDescription: String { "flexDirection: .row / .column / .rowReverse / .columnReverse" }
    override var codeSnippet: String { "container.style.flexDirection = .row\ncontainer.style.alignItems = .center" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "flexDirection: .row") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(60)); r.style.flexDirection = .row
                    for _ in 0..<4 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(30)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "flexDirection: .column") {
                    let r = GWYogaNode(); r.style.setWidth(.points(120)); r.style.setHeight(.points(250)); r.style.flexDirection = .column
                    for _ in 0..<4 { let c = GWYogaNode(); c.style.setWidth(.points(80)); c.style.setHeight(.points(40)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec2 = makeSection(title: "flexDirection: .rowReverse") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(60)); r.style.flexDirection = .rowReverse
                    for _ in 0..<4 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(30)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec3 = makeSection(title: "flexDirection: .columnReverse") {
                    let r = GWYogaNode(); r.style.setWidth(.points(120)); r.style.setHeight(.points(250)); r.style.flexDirection = .columnReverse
                    for _ in 0..<4 { let c = GWYogaNode(); c.style.setWidth(.points(80)); c.style.setHeight(.points(40)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                contentView.addSubview(sec0); contentView.addSubview(sec1); contentView.addSubview(sec2); contentView.addSubview(sec3)
            
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