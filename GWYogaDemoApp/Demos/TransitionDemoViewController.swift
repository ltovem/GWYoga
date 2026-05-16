import UIKit
import GWYogaKit
import GWYogaKitAnimation

class TransitionDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaTransition with duration, timing function, delay, and propertyFilter" }
    override var codeSnippet: String { "YogaTransition(duration: 0.25, timingFunction: .ease, propertyFilter: .layout)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaTransition(duration: 0.25, timingFunction: .ease, propertyFilter: .layout)"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(120)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemPink.withAlphaComponent(0.3)
        demo.layer.cornerRadius = 8
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "transition"
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        demo.addSubview(label)
    }
}
