import UIKit
import GWYogaKit
import GWYoga

class CompositeDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "综合"

        setupDemoScrollView(scrollView, sections: [
            makeDemoSection(title: "Header + Grid(卡片 6) + Footer") {
                let page = GWYogaNode(); page.style.flexDirection = .column; page.style.setWidth(.points(375)); page.style.setHeight(.points(450)); page.style.setPadding(for: .all, .points(12))

                let h = GWYogaNode(); h.style.flexDirection = .row; h.style.justifyContent = .spaceBetween; h.style.alignItems = .center; h.style.setHeight(.points(44)); h.style.setMargin(for: .bottom, .points(12))
                let b = GWYogaNode(); b.style.setWidth(.points(60)); b.style.setHeight(.points(32))
                let t = GWYogaNode(); t.style.setWidth(.points(120)); t.style.setHeight(.points(20))
                let m = GWYogaNode(); m.style.setWidth(.points(32)); m.style.setHeight(.points(32))
                h.insertChild(b, at: 0); h.insertChild(t, at: 1); h.insertChild(m, at: 2)
                page.insertChild(h, at: 0)

                let grid = GWYogaNode(); grid.style.flexDirection = .row; grid.style.flexWrap = .wrap
                grid.style.setGap(for: .column, .points(10)); grid.style.setGap(for: .row, .points(10))
                grid.style.flexGrow = GWFloatOptional(value: 1)
                for _ in 0..<6 {
                    let card = GWYogaNode(); card.style.setWidth(.points((375-24-10)/2)); card.style.setHeight(.points(80)); card.style.setPadding(for: .all, .points(8)); card.style.setBorder(for: .all, 1)
                    let inner = GWYogaNode(); inner.style.setWidth(.percent(100)); inner.style.setHeight(.points(20))
                    card.insertChild(inner, at: 0); grid.insertChild(card, at: grid.children.count)
                }
                page.insertChild(grid, at: 1)

                let footer = GWYogaNode(); footer.style.flexDirection = .row; footer.style.justifyContent = .spaceAround; footer.style.alignItems = .center; footer.style.setHeight(.points(44)); footer.style.setMargin(for: .top, .points(12))
                for _ in 0..<4 { let tab = GWYogaNode(); tab.style.setWidth(.points(36)); tab.style.setHeight(.points(36)); footer.insertChild(tab, at: footer.children.count) }
                page.insertChild(footer, at: 2)
                return (page, 375, 450)
            },
            makeDemoSection(title: "Grid 3列等宽") {
                let r = GWYogaNode(); r.style.display = .grid; r.style.setWidth(.points(350))
                r.style.gridTemplateColumns = [.fr(1), .fr(1), .fr(1)]; r.style.setGap(for: .column, .points(8)); r.style.setGap(for: .row, .points(8))
                for _ in 0..<6 { let card = GWYogaNode(); card.style.setHeight(.points(50)); card.style.setPadding(for: .all, .points(6))
                    let inner = GWYogaNode(); inner.style.setWidth(.percent(100)); inner.style.setHeight(.points(15)); card.insertChild(inner, at: 0)
                    r.insertChild(card, at: r.children.count) }
                return (r, 350, .nan)
            },
            makeDemoSection(title: "居中布局: center + center") {
                let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(150))
                r.style.justifyContent = .center; r.style.alignItems = .center
                let box = GWYogaNode(); box.style.setWidth(.points(120)); box.style.setHeight(.points(80)); box.style.setPadding(for: .all, .points(8))
                let inner = GWYogaNode(); inner.style.setWidth(.points(60)); inner.style.setHeight(.points(30))
                box.insertChild(inner, at: 0); r.insertChild(box, at: 0)
                return (r, 300, 150)
            },
        ])
    }
}
