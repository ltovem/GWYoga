import UIKit
import GWYogaKit

class ChainableDemoViewController: DemoPageViewController {
    override var demoDescription: String { "All @discardableResult chainable methods for fluent Yoga property configuration" }
    override var codeSnippet: String { "view.style.width(100).height(200).flexDirection(.row).margin(.all, 12)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.width(100).height(200).flexDirection(.row).margin(.all, 12)"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(200)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        demo.layer.cornerRadius = 8
        contentView.addSubview(demo)
    }
}
