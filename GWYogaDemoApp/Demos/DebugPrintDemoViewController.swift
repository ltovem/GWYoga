import UIKit
import GWYoga
import GWYogaKit

class DebugPrintDemoViewController: DemoPageViewController {
    override var demoDescription: String { "debugPrint() tree-formatted output of the Yoga layout tree" }
    override var codeSnippet: String { "view.style.debugPrint() // print layout tree" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.debugPrint() // print layout tree"
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

        // Visual rendered preview
        let preview = YogaLayoutRenderer.render(node: r)
        preview.yoga.marginTop(16)
        contentView.addSubview(preview)

        // Text output
        let output = YogaLayoutRenderer.describe(node: r)
        let log = UILabel()
        log.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        log.numberOfLines = 0
        log.textColor = .secondaryLabel
        log.yoga.marginTop(12)
        log.text = "Layout tree:\n" + output
        contentView.addSubview(log)
    }
}
