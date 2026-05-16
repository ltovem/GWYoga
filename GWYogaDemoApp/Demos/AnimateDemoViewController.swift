import UIKit
import GWYogaKit
import GWYogaKitAnimation

class AnimateDemoViewController: DemoPageViewController {
    override var demoDescription: String { ".animate(duration:timingFunction:delay:changes:) convenience method" }
    override var codeSnippet: String { "view.style.animate(duration: 0.3) { props in\n    props.width = 200\n    props.height = 150\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.animate(duration: 0.3) { props in\n    props.width = 200\n    props.height = 150\n}"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(120)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemOrange.withAlphaComponent(0.3)
        demo.layer.cornerRadius = 8
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "animate"
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        demo.addSubview(label)
    }
}
