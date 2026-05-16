import UIKit
import GWYoga
import GWYogaKit

class WidthHeightDemoViewController: DemoPageViewController {
    override var demoDescription: String { "width/height, min/max, percentages" }
    override var codeSnippet: String { "view.style.width = 200\nview.style.height = 100" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "Fixed 100x50") {
                    let r = GWYogaNode(); r.style.setWidth(.points(100)); r.style.setHeight(.points(50)); return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "Width 50%, Height 30") {
                    let r = GWYogaNode(); r.style.setWidth(.percent(50)); r.style.setHeight(.points(30)); return YogaLayoutRenderer.render(node: r)
                }
                let sec2 = makeSection(title: "Min/Max") {
                    let r = GWYogaNode(); r.style.flexDirection = .row; r.style.setWidth(.points(300)); r.style.setHeight(.points(60))
                    for _ in 0..<3 { let c = GWYogaNode(); c.style.setHeight(.points(30)); c.style.minWidth = .points(60); c.style.maxWidth = .points(120); r.insertChild(c, at: r.children.count) }
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