import UIKit
import GWYoga
import GWYogaKit

class AlignSelfDemoViewController: DemoPageViewController {
    override var demoDescription: String { "alignSelf overrides alignItems on individual items" }
    override var codeSnippet: String { "child.style.alignSelf = .flexEnd" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "alignSelf: .flexEnd on child 2") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(70)); r.style.flexDirection = .row; r.style.alignItems = .flexStart
                    for i in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(35)); if i == 1 { c.style.alignSelf = .flexEnd }; r.insertChild(c, at: i) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "alignSelf: .center on child 1") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(70)); r.style.flexDirection = .row; r.style.alignItems = .flexStart
                    for i in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(35)); if i == 0 { c.style.alignSelf = .center }; r.insertChild(c, at: i) }
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