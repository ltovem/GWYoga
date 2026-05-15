import UIKit
import GWYogaKit
import GWYoga

class PositionDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Position"

        setupDemoScrollView(scrollView, sections: [
            makeDemoSection(title: "Relative: child2 offset top=15,left=10") {
                let r = GWYogaNode(); r.style.setWidth(.points(350)); r.style.setHeight(.points(70)); r.style.flexDirection = .row
                for i in 0..<3 {
                    let c = GWYogaNode(); c.style.setWidth(.points(80)); c.style.setHeight(.points(40))
                    if i == 1 { c.style.setPosition(for: .top, .points(15)); c.style.setPosition(for: .left, .points(10)) }
                    r.insertChild(c, at: i)
                }
                return (r, 350, 70)
            },
            makeDemoSection(title: "Absolute: top=20, left=200") {
                let r = GWYogaNode(); r.style.setWidth(.points(350)); r.style.setHeight(.points(120)); r.style.setPadding(for: .all, .points(10))
                let n = GWYogaNode(); n.style.setWidth(.points(100)); n.style.setHeight(.points(40)); r.insertChild(n, at: 0)
                let a = GWYogaNode(); a.style.positionType = .absolute; a.style.setWidth(.points(80)); a.style.setHeight(.points(60))
                a.style.setPosition(for: .top, .points(20)); a.style.setPosition(for: .left, .points(200))
                r.insertChild(a, at: 1)
                return (r, 350, 120)
            },
            makeDemoSection(title: "Absolute: bottom=10, end=10") {
                let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(150))
                let a = GWYogaNode(); a.style.positionType = .absolute; a.style.setWidth(.points(80)); a.style.setHeight(.points(40))
                a.style.setPosition(for: .bottom, .points(10)); a.style.setPosition(for: .end, .points(10))
                r.insertChild(a, at: 0)
                return (r, 300, 150)
            },
        ])
    }
}
