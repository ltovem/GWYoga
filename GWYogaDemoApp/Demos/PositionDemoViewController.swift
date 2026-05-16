import UIKit
import GWYoga
import GWYogaKit

class PositionDemoViewController: DemoPageViewController {
    override var demoDescription: String { "positionType: .relative / .absolute" }
    override var codeSnippet: String { "child.style.positionType = .absolute\nchild.style.position = [.top: 20, .left: 200]" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "Relative: child2 offset top=15") {
                    let r = GWYogaNode(); r.style.setWidth(.points(350)); r.style.setHeight(.points(70)); r.style.flexDirection = .row
                    for i in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(80)); c.style.setHeight(.points(40)); if i == 1 { c.style.setPosition(for: .top, .points(15)); c.style.setPosition(for: .left, .points(10)) }; r.insertChild(c, at: i) }
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec1 = makeSection(title: "Absolute: top=20, left=200") {
                    let r = GWYogaNode(); r.style.setWidth(.points(350)); r.style.setHeight(.points(120)); r.style.setPadding(for: .all, .points(10))
                    r.insertChild(makeChild(100, 40), at: 0)
                    let a = GWYogaNode(); a.style.positionType = .absolute; a.style.setWidth(.points(80)); a.style.setHeight(.points(60))
                    a.style.setPosition(for: .top, .points(20)); a.style.setPosition(for: .left, .points(200))
                    r.insertChild(a, at: 1)
                    return YogaLayoutRenderer.render(node: r)
                }
                let sec2 = makeSection(title: "Absolute: bottom=10") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(150))
                    let a = GWYogaNode(); a.style.positionType = .absolute; a.style.setWidth(.points(80)); a.style.setHeight(.points(40))
                    a.style.setPosition(for: .bottom, .points(10)); a.style.setPosition(for: .end, .points(10))
                    r.insertChild(a, at: 0)
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