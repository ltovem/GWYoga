import UIKit
import GWYoga
import GWYogaKit

class SystemLayoutSizeDemoViewController: DemoPageViewController {
    override var demoDescription: String { "systemLayoutSize(width:height:) Yoga-calculated fitting size" }
    override var codeSnippet: String { "let size = view.style.systemLayoutSize(width: 200, height: 300)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "let size = view.style.systemLayoutSize(width: 200, height: 300)"
        contentView.addSubview(info)

        let r = GWYogaNode()
        r.style.flexDirection = .row
        r.style.setWidth(.points(200))
        r.style.setHeight(.points(60))
        for _ in 0..<4 {
            let c = GWYogaNode()
            c.style.setWidth(.points(40))
            c.style.setHeight(.points(30))
            r.insertChild(c, at: r.children.count)
        }
        r.calculateLayout(width: .nan, height: .nan, direction: .ltr)
        let result = r.layoutResult
        let view = YogaLayoutRenderer.render(node: r)
        view.yoga.marginTop(16)
        contentView.addSubview(view)

        let size = UILabel()
        size.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        size.textColor = .secondaryLabel
        size.yoga.marginTop(8)
        size.text = "result: \(Int(result.width))×\(Int(result.height))"
        contentView.addSubview(size)
    }
}
