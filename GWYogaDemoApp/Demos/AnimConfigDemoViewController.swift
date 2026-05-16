import UIKit
import GWYogaKit
import GWYogaKitAnimation

class AnimConfigDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaAnimation initialization with timing functions and direction" }
    override var codeSnippet: String { "YogaAnimation(name: \"fade\", duration: 0.3, timingFunction: .easeInOut)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaAnimation(name: \"fade\", duration: 0.3, timingFunction: .easeInOut)"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(120)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemTeal.withAlphaComponent(0.3)
        demo.layer.cornerRadius = 8
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "animation config"
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        demo.addSubview(label)
    }
}
