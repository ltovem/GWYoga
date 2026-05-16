import UIKit
import GWYogaKit
import GWYogaKitAnimation

class KeyframeDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaKeyframes registration and application for multi-step animation" }
    override var codeSnippet: String { "YogaKeyframes {\n    YogaKeyframeStyle(percent: 0) { $0.width = 50 }\n    YogaKeyframeStyle(percent: 100) { $0.width = 200 }\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaKeyframes {\n    YogaKeyframeStyle(percent: 0) { $0.width = 50 }\n    YogaKeyframeStyle(percent: 100) { $0.width = 200 }\n}"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(120)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemPurple.withAlphaComponent(0.3)
        demo.layer.cornerRadius = 8
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "keyframes"
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        demo.addSubview(label)
    }
}
