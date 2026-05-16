import UIKit
import GWYogaKit

class TraitDemoViewController: DemoPageViewController {
    override var demoDescription: String { "onTraitChange(_:) for responsive layout on trait/orientation changes" }
    override var codeSnippet: String { "view.style.onTraitChange { traits, style in\n    if traits.horizontalSizeClass == .compact { ... }\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.onTraitChange { traits, style in\n    if traits.horizontalSizeClass == .compact { ... }\n}"
        contentView.addSubview(info)
    }
}
