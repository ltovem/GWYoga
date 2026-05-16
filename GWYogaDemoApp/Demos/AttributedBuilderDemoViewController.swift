import UIKit
import GWYogaKit

class AttributedBuilderDemoViewController: DemoPageViewController {
    override var demoDescription: String { "attributedText { builder in } convenience builder for attributed strings" }
    override var codeSnippet: String { "view.style.attributedText { b in\n    b.text(\"Hello\").font(.boldSystemFont(ofSize: 16))\n    b.text(\" World\").color(.gray)\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.attributedText { b in\n    b.text(\"Hello\").font(.boldSystemFont(ofSize: 16))\n    b.text(\" World\").color(.gray)\n}"
        contentView.addSubview(info)
    }
}
