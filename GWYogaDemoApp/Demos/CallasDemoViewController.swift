import UIKit
import GWYogaKit

class CallasDemoViewController: DemoPageViewController {
    override var demoDescription: String { "view.style { props in } closure-based configuration via callAsFunction" }
    override var codeSnippet: String { "view.style { s in\n    s.width = 200\n    s.height = 100\n    s.margin = [.all: 12]\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style { s in\n    s.width = 200\n    s.height = 100\n    s.margin = [.all: 12]\n}"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(200)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemOrange.withAlphaComponent(0.3)
        demo.layer.cornerRadius = 8
        contentView.addSubview(demo)
    }
}
