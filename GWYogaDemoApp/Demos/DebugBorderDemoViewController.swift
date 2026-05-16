import UIKit
import GWYogaKit

class DebugBorderDemoViewController: DemoPageViewController {
    override var demoDescription: String { "debugBorder(color:width:) visual debugging border" }
    override var codeSnippet: String { "view.style.debugBorder()\nview.style.debugBorder(color: .red, width: 2)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.debugBorder()\nview.style.debugBorder(color: .red, width: 2)"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(200)
        demo.yoga.height = .points(100)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemGray6
        contentView.addSubview(demo)

        let child1 = UIView()
        child1.backgroundColor = .systemRed.withAlphaComponent(0.3)
        child1.yoga.width = .points(60)
        child1.yoga.height = .points(40)
        child1.layer.borderWidth = 2
        child1.layer.borderColor = UIColor.systemRed.cgColor
        demo.addSubview(child1)

        let child2 = UIView()
        child2.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        child2.yoga.width = .points(60)
        child2.yoga.height = .points(40)
        child2.layer.borderWidth = 1
        child2.layer.borderColor = UIColor.systemBlue.cgColor
        demo.addSubview(child2)

        let child3 = UIView()
        child3.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        child3.yoga.width = .points(60)
        child3.yoga.height = .points(40)
        child3.layer.borderWidth = 1
        child3.layer.borderColor = UIColor.systemGreen.cgColor
        demo.addSubview(child3)
    }
}
