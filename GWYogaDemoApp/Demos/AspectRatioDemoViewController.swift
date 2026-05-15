import UIKit
import GWYogaKit
import GWYoga

class AspectRatioDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Aspect"

        setupDemoScrollView(scrollView, sections: [
            makeDemoSection(title: "aspectRatio=2, height=80 → width=160") {
                let r = GWYogaNode(); r.style.setWidth(.points(250)); r.style.setHeight(.points(150))
                let c = GWYogaNode(); c.style.setHeight(.points(80)); c.style.aspectRatio = .init(value: 2)
                r.insertChild(c, at: 0)
                return (r, 250, 150)
            },
            makeDemoSection(title: "aspectRatio=1.5, width=120 → height=80") {
                let r = GWYogaNode(); r.style.setWidth(.points(250)); r.style.setHeight(.points(150))
                let c = GWYogaNode(); c.style.setWidth(.points(120)); c.style.aspectRatio = .init(value: 1.5)
                r.insertChild(c, at: 0)
                return (r, 250, 150)
            },
            makeDemoSection(title: "aspectRatio=1 (正方形 60×60)") {
                let r = GWYogaNode(); r.style.setWidth(.points(300)); r.style.setHeight(.points(80)); r.style.flexDirection = .row
                for _ in 0..<4 { let c = GWYogaNode(); c.style.setHeight(.points(60)); c.style.aspectRatio = .init(value: 1); r.insertChild(c, at: r.children.count) }
                return (r, 300, 80)
            },
        ])
    }
}
