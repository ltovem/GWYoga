import UIKit
import GWYogaKit

class YogaLayoutViewDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaLayoutView auto-manages subview Yoga nodes and calculates layout" }
    override var codeSnippet: String { "let c = YogaLayoutView()\nc.yoga.flexDirection = .row\nc.addSubview(v)\nc.performYogaLayout()" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "let c = YogaLayoutView()\nc.yoga.flexDirection = .row\nc.addSubview(v)\nc.performYogaLayout()"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(260)
        demo.yoga.height = .points(60)
        demo.yoga.marginTop(16)
        demo.yoga.flexDirection = .row
        demo.backgroundColor = .systemGray6
        demo.layer.borderWidth = 1
        demo.layer.borderColor = UIColor.systemBlue.cgColor
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
