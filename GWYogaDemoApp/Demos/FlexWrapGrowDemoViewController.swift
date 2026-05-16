import UIKit
import GWYoga
import GWYogaKit

class FlexWrapGrowDemoViewController: DemoPageViewController {
    override var demoDescription: String { "flexWrap + flexGrow + flexShrink" }
    override var codeSnippet: String { "container.style.flexWrap = .wrap\nchild.style.flexGrow = 1" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "flexWrap: .wrap") {
                    let r = GWYogaNode(); r.style.setWidth(.points(180)); r.style.setHeight(.points(160)); r.style.flexDirection = .row; r.style.flexWrap = .wrap; r.style.setGap(for: .row, .points(8))
                    for _ in 0..<6 { let c = GWYogaNode(); c.style.setWidth(.points(80)); c.style.setHeight(.points(50)); r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "flexGrow: 1:2:1") {
                    let r = GWYogaNode(); r.style.setWidth(.points(350)); r.style.setHeight(.points(50)); r.style.flexDirection = .row
                    for v in [1 as Float,2,1] { let c = GWYogaNode(); c.style.setHeight(.points(30)); c.flexGrow = v; r.insertChild(c, at: r.children.count) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec2 = makeSection(title: "flexShrink") {
                    let r = GWYogaNode(); r.style.setWidth(.points(200)); r.style.setHeight(.points(50)); r.style.flexDirection = .row
                    for v in [0 as Float,1,0] { let c = GWYogaNode(); c.style.setWidth(.points(120)); c.style.setHeight(.points(30)); c.flexShrink = v; r.insertChild(c, at: r.children.count) }
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