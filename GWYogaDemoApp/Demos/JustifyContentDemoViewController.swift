import UIKit
import GWYoga
import GWYogaKit

class JustifyContentDemoViewController: DemoPageViewController {
    override var demoDescription: String { "justifyContent distribution: .flexStart, .center, .spaceBetween, etc." }
    override var codeSnippet: String { "container.style.justifyContent = .spaceBetween" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let vals: [(String, GWJustify)] = [("flexStart", .flexStart), ("center", .center), ("flexEnd", .flexEnd), ("spaceBetween", .spaceBetween), ("spaceAround", .spaceAround), ("spaceEvenly", .spaceEvenly)]
                for (_, (name, val)) in vals.enumerated() {
                    let sec = makeSection(title: "· \(name)") {
                        let r = GWYogaNode(); r.style.setWidth(.points(280)); r.style.setHeight(.points(50)); r.style.flexDirection = .row; r.style.justifyContent = val
                        for _ in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(55)); c.style.setHeight(.points(25)); r.insertChild(c, at: r.children.count) }
                        return YogaLayoutRenderer.render(node: r)
                    }
                    contentView.addSubview(sec)
                }
            
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