import UIKit
import GWYoga
import GWYogaKit

class LayoutResultDemoViewController: DemoPageViewController {
    override var demoDescription: String { "Read frame / layoutResult after Yoga layout calculation" }
    override var codeSnippet: String { "let r = view.yoga.layoutResult\nprint(r.width, r.height, r.left, r.top)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "let r = view.yoga.layoutResult\nprint(r.width, r.height, r.left, r.top)"
        contentView.addSubview(info)

        let r = GWYogaNode()
        r.style.flexDirection = .row
        r.style.setWidth(.points(260))
        r.style.setHeight(.points(60))
        for _ in 0..<3 {
            let c = GWYogaNode()
            c.style.setWidth(.points(60))
            c.style.setHeight(.points(30))
            r.insertChild(c, at: r.children.count)
        }
        r.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        let view = YogaLayoutRenderer.render(node: r)
        view.yoga.marginTop(16)
        contentView.addSubview(view)

        let result = r.layoutResult
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.yoga.marginTop(8)
        label.text = "result: \(Int(result.width))×\(Int(result.height))"
        contentView.addSubview(label)
    }
}
