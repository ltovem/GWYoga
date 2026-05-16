import UIKit
import GWYogaKit

class RegistryDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaMeasureRegistry.register(_:) and register(_:handler:) for custom measurement" }
    override var codeSnippet: String { "YogaMeasureRegistry.register(MyView.self)\nYogaMeasureRegistry.register(MyView.self) { view, w, h in CGSize(width: 100, height: 50) }" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaMeasureRegistry.register(MyView.self)\nYogaMeasureRegistry.register(MyView.self) { view, w, h in CGSize(width: 100, height: 50) }"
        contentView.addSubview(info)
    }
}
