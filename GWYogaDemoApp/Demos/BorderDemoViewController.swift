import UIKit
import GWYogaKit

class BorderDemoViewController: DemoPageViewController {
    override var demoDescription: String { "borderWidth + borderColor for edge borders" }
    override var codeSnippet: String { "view.style.borderWidth(2)\nview.style.borderColor(.red)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.borderWidth(2)\nview.style.borderColor(.red)"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(120)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemYellow.withAlphaComponent(0.3)
        demo.layer.borderWidth = 2
        demo.layer.borderColor = UIColor.systemRed.cgColor
        demo.layer.cornerRadius = 4
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "2px red border"
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        demo.addSubview(label)
    }
}
