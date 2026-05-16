import UIKit
import GWYogaKit

class ShadowDemoViewController: DemoPageViewController {
    override var demoDescription: String { "shadow(color:opacity:radius:offset:) and YogaShadow struct" }
    override var codeSnippet: String { "view.style.shadow(color: .black, opacity: 0.3, radius: 4, offset: CGSize(width: 0, height: 2))" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.shadow(color: .black, opacity: 0.3, radius: 4, offset: CGSize(width: 0, height: 2))"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(120)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .white
        demo.layer.shadowColor = UIColor.black.cgColor
        demo.layer.shadowOpacity = 0.3
        demo.layer.shadowRadius = 8
        demo.layer.shadowOffset = CGSize(width: 2, height: 4)
        demo.layer.cornerRadius = 8
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "shadow"
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        demo.addSubview(label)
    }
}
