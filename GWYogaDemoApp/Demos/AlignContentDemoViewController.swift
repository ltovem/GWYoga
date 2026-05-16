import UIKit
import GWYoga
import GWYogaKit

class AlignContentDemoViewController: DemoPageViewController {
    override var demoDescription: String { "alignContent controls multi-line cross-axis alignment" }
    override var codeSnippet: String { "container.style.alignContent = .spaceAround" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let vals: [(String, GWAlign)] = [("flexStart", .flexStart), ("center", .center), ("spaceBetween", .spaceBetween), ("spaceAround", .spaceAround), ("stretch", .stretch)]
                for (_, (name, val)) in vals.enumerated() {
                    let sec = makeSection(title: "· \(name)") {
                        let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(160)); r.style.flexDirection = .row; r.style.flexWrap = .wrap; r.style.alignContent = val
                        r.style.setGap(for: .row, .points(6)); r.style.setGap(for: .column, .points(6))
                        for _ in 0..<6 { let c = GWYogaNode(); c.style.setWidth(.points(120)); c.style.setHeight(.points(40)); r.insertChild(c, at: r.children.count) }
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