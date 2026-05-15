import UIKit
import GWYogaKit
import GWYoga

class MarginPaddingDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Margin"

        setupDemoScrollView(scrollView, sections: [
            makeDemoSection(title: "margin=10 (全部)") {
                let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(70)); r.style.flexDirection = .row
                for i in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(30)); c.style.setMargin(for: .all, .points(10)); r.insertChild(c, at: i) }
                return (r, 300, 70)
            },
            makeDemoSection(title: "marginLeft=20 (child2)") {
                let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(50)); r.style.flexDirection = .row
                for i in 0..<3 {
                    let c = GWYogaNode(); c.style.setWidth(.points(70)); c.style.setHeight(.points(25))
                    if i == 1 { c.style.setMargin(for: .left, .points(20)) }
                    r.insertChild(c, at: i)
                }
                return (r, 300, 50)
            },
            makeDemoSection(title: "padding=20 (容器内边距)") {
                let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(100)); r.style.setPadding(for: .all, .points(20)); r.style.flexDirection = .row
                for i in 0..<2 { let c = GWYogaNode(); c.style.setWidth(.points(80)); c.style.setHeight(.points(40)); r.insertChild(c, at: i) }
                return (r, 300, 100)
            },
            makeDemoSection(title: "border=4") {
                let r = GWYogaNode(); r.style.setWidth(.points(200)); r.style.setHeight(.points(50)); r.style.setBorder(for: .all, 4)
                let c = GWYogaNode(); c.style.setWidth(.points(100)); c.style.setHeight(.points(25)); r.insertChild(c, at: 0)
                return (r, 200, 50)
            },
            makeDemoSection(title: "margin8+padding12+border2") {
                let r = GWYogaNode(); r.style.setWidth(.points(350)); r.style.setHeight(.points(100)); r.style.setPadding(for: .all, .points(12)); r.style.setBorder(for: .all, 2)
                let c = GWYogaNode(); c.style.setWidth(.points(100)); c.style.setHeight(.points(50)); c.style.setMargin(for: .all, .points(8)); c.style.setPadding(for: .all, .points(6)); c.style.setBorder(for: .all, 1)
                let cc = GWYogaNode(); cc.style.setWidth(.points(60)); cc.style.setHeight(.points(20)); c.insertChild(cc, at: 0)
                r.insertChild(c, at: 0)
                return (r, 350, 100)
            },
        ])
    }
}
