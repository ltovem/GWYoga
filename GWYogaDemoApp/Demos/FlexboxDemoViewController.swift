import UIKit
import GWYogaKit
import GWYoga

class FlexboxDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flexbox"

        setupDemoScrollView(scrollView, sections: [
            // 1. flexDirection: row
            makeDemoSection(title: "flexDirection: .row") {
                let r = GWYogaNode()
                r.style.setWidth(.points(350)); r.style.setHeight(.points(70))
                r.style.flexDirection = .row
                for i in 0..<4 { let c = GWYogaNode(); c.style.setWidth(.points(70)); c.style.setHeight(.points(40)); r.insertChild(c, at: i) }
                return (r, 350, 70)
            },
            // 2. justifyContent: spaceBetween
            makeDemoSection(title: "justifyContent: .spaceBetween") {
                let r = GWYogaNode()
                r.style.setWidth(.points(350)); r.style.setHeight(.points(60))
                r.style.flexDirection = .row; r.style.justifyContent = .spaceBetween
                for i in 0..<3 { let c = GWYogaNode(); c.style.setWidth(.points(70)); c.style.setHeight(.points(30)); r.insertChild(c, at: i) }
                return (r, 350, 60)
            },
            // 3. alignItems: center
            makeDemoSection(title: "alignItems: .center") {
                let r = GWYogaNode()
                r.style.setWidth(.points(350)); r.style.setHeight(.points(80))
                r.style.flexDirection = .row; r.style.alignItems = .center
                for i in 0..<4 { let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(25 + Float(i)*12)); r.insertChild(c, at: i) }
                return (r, 350, 80)
            },
            // 4. flexGrow
            makeDemoSection(title: "flexGrow: 1:2:1") {
                let r = GWYogaNode()
                r.style.setWidth(.points(350)); r.style.setHeight(.points(50))
                r.style.flexDirection = .row
                for v in [1,2,1] {
                    let c = GWYogaNode(); c.style.setHeight(.points(30)); c.flexGrow = Float(v); r.insertChild(c, at: r.children.count)
                }
                return (r, 350, 50)
            },
            // 5. flexWrap
            makeDemoSection(title: "flexWrap: .wrap") {
                let r = GWYogaNode()
                r.style.setWidth(.points(180)); r.style.setHeight(.points(160))
                r.style.flexDirection = .row; r.style.flexWrap = .wrap; r.style.setGap(for: .row, .points(8))
                for _ in 0..<6 { let c = GWYogaNode(); c.style.setWidth(.points(80)); c.style.setHeight(.points(50)); r.insertChild(c, at: r.children.count) }
                return (r, 180, 160)
            },
            // 6. alignSelf
            makeDemoSection(title: "alignSelf: child2 = .flexEnd") {
                let r = GWYogaNode()
                r.style.setWidth(.points(300)); r.style.setHeight(.points(70))
                r.style.flexDirection = .row; r.style.alignItems = .flexStart
                for i in 0..<3 {
                    let c = GWYogaNode(); c.style.setWidth(.points(60)); c.style.setHeight(.points(35))
                    if i == 1 { c.style.alignSelf = .flexEnd }
                    r.insertChild(c, at: i)
                }
                return (r, 300, 70)
            },
        ])
    }
}
