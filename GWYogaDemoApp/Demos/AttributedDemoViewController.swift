import UIKit
import GWYogaKit

class AttributedDemoViewController: DemoPageViewController {
    override var demoDescription: String { ".attributedText = NSAttributedString with automatic intrinsic measurement" }
    override var codeSnippet: String { "view.style.attributedText = NSAttributedString(string: \"Hello\")" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.attributedText = NSAttributedString(string: \"Hello\")"
        contentView.addSubview(info)
    }
}
