import UIKit
import GWYogaKit
import Combine

class BindingDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaBinding.bind(_:to:keyPath:) and bind(_:update:) for style-property binding" }
    override var codeSnippet: String { "YogaBinding.bind(state, to: view.style, keyPath: \\.width)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaBinding.bind(state, to: view.style, keyPath: \\.width)\nYogaBinding.bind(state) { s, v in view.width = v }"
        contentView.addSubview(info)
    }
}
