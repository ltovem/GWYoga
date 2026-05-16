import UIKit
import GWYogaKit

class BgimageDemoViewController: DemoPageViewController {
    override var demoDescription: String { ".background(.image(...)) with contentMode support" }
    override var codeSnippet: String { "view.style.background(.image(UIImage(named: \"photo\")!))" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.background(.image(UIImage(named: \"photo\")!))"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(200)
        demo.yoga.height = .points(120)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemGray6
        demo.layer.cornerRadius = 8
        demo.clipsToBounds = true
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "Background Image Demo"
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        demo.addSubview(label)
    }
}
