import UIKit
import GWYogaKit

class AddChildDemoViewController: DemoPageViewController {
    override var demoDescription: String { "addChild(_:) / addChild(_:at:) / removeFromParent() for Yoga tree management" }
    override var codeSnippet: String { "container.addChild(child)\ncontainer.addChild(child, at: 0)\nchild.removeFromParent()" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "container.addChild(child)\ncontainer.addChild(child, at: 0)\nchild.removeFromParent()"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(260)
        demo.yoga.height = .points(60)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemGray6
        demo.layer.borderWidth = 1
        demo.layer.borderColor = UIColor.systemGray4.cgColor
        demo.layer.cornerRadius = 4
        contentView.addSubview(demo)

        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen]
        for i in 0..<3 {
            let child = UIView()
            child.backgroundColor = colors[i].withAlphaComponent(0.3)
            child.yoga.width = .points(60)
            child.yoga.height = .points(30)
            child.layer.cornerRadius = 4
            demo.addSubview(child)
        }
    }
}
