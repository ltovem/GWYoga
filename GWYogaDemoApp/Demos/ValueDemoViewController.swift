import UIKit
import GWYogaKit

class ValueDemoViewController: DemoPageViewController {
    override var demoDescription: String { "GWValue creation: ExpressibleByFloatLiteral, % operator, .auto, .maxContent(), .fitContent()" }
    override var codeSnippet: String { "let v: GWValue = 100\nlet pct: GWValue = 50%\nview.style.width = 200" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "let v: GWValue = 100\nlet pct: GWValue = 50%\nview.style.width = 200"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .percent(50)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemOrange.withAlphaComponent(0.3)
        demo.layer.cornerRadius = 8
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "50% width"
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        demo.addSubview(label)
    }
}
