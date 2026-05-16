import UIKit
import GWYoga
import GWYogaKit

class FlexBasisDemoViewController: DemoPageViewController {
    override var demoDescription: String { "flexBasis sets initial main-axis size before grow/shrink" }
    override var codeSnippet: String { "child.style.flexBasis = 100" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "flexBasis: 100 on child 2") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(60)); r.style.flexDirection = .row
                    for i in 0..<3 { let c = GWYogaNode(); c.style.setHeight(.points(30)); if i == 1 { c.style.flexBasis = .points(100) }; r.insertChild(c, at: i) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "flex: 1 on all") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(50)); r.style.flexDirection = .row
                    for _ in 0..<3 { let c = GWYogaNode(); c.style.setHeight(.points(30)); c.flexGrow = 1; r.insertChild(c, at: r.children.count) }
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