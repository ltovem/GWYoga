import UIKit
import GWYoga
import GWYogaKit

class CompositeDemoViewController: DemoPageViewController {
    override var demoDescription: String { "Complex Header+Grid+Footer layout" }
    override var codeSnippet: String { "let page = UIView()\npage.style.flexDirection = .column" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
                let sec0 = makeSection(title: "Header+Grid+Footer") {
                    let page = GWYogaNode(); page.style.flexDirection = .column; page.style.setWidth(.points(375)); page.style.setHeight(.points(450)); page.style.setPadding(for: .all, .points(12))
                    let h = GWYogaNode(); h.style.flexDirection = .row; h.style.justifyContent = .spaceBetween; h.style.alignItems = .center; h.style.setHeight(.points(44))
                    h.insertChild(makeChild(60, 32), at: 0); h.insertChild(makeChild(120, 20), at: 1); h.insertChild(makeChild(32, 32), at: 2); page.insertChild(h, at: 0)
                    let g = GWYogaNode(); g.style.flexDirection = .row; g.style.flexWrap = .wrap; g.style.setGap(for: .column, .points(10)); g.style.setGap(for: .row, .points(10)); g.flexGrow = 1
                    for _ in 0..<6 { let c = GWYogaNode(); c.style.setWidth(.points((375-24-10)/2)); c.style.setHeight(.points(80)); g.insertChild(c, at: g.children.count) }
                    page.insertChild(g, at: 1)
                    let f = GWYogaNode(); f.style.flexDirection = .row; f.style.justifyContent = .spaceAround; f.style.setHeight(.points(44))
                    for _ in 0..<4 { f.insertChild(makeChild(36, 36), at: f.children.count) }
                    page.insertChild(f, at: 2); return YogaLayoutRenderer.render(node: page)
                }
                let sec1 = makeSection(title: "Grid 3列") {
                    let r = GWYogaNode(); r.style.display = .grid; r.style.setWidth(.points(350)); r.style.gridTemplateColumns = [.fr(1), .fr(1), .fr(1)]; r.style.setGap(for: .column, .points(8))
                    for _ in 0..<6 { let c = GWYogaNode(); c.style.setHeight(.points(50)); r.insertChild(c, at: r.children.count) }; return YogaLayoutRenderer.render(node: r)
                }
                let sec2 = makeSection(title: "居中: justify+align center") {
                    let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(150)); r.style.justifyContent = .center; r.style.alignItems = .center
                    let box = GWYogaNode(); box.style.setWidth(.points(120)); box.style.setHeight(.points(80))
                    let inner = GWYogaNode(); inner.style.setWidth(.points(60)); inner.style.setHeight(.points(30))
                    box.insertChild(inner, at: 0); r.insertChild(box, at: 0); return YogaLayoutRenderer.render(node: r)
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