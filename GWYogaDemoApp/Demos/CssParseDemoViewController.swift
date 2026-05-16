import UIKit
import GWYogaKit
import GWYogaKitStylesheet

class CssParseDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaStylesheet.parse() to parse CSS strings into rules" }
    override var codeSnippet: String { "let sheet = try YogaStylesheet.parse(\".box { width: 100px; }\")" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "let sheet = try YogaStylesheet.parse(\".box { width: 100px; }\")"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(200)
        demo.yoga.height = .points(80)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemGray6
        demo.layer.borderWidth = 1
        demo.layer.borderColor = UIColor.systemBlue.cgColor
        demo.layer.cornerRadius = 4
        contentView.addSubview(demo)

        let cssLabel = UILabel()
        cssLabel.text = ".box { width: 100px; }"
        cssLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        cssLabel.textAlignment = .center
        demo.addSubview(cssLabel)
    }
}
