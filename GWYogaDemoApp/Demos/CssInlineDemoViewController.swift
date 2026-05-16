import UIKit
import GWYogaKit
import GWYogaKitStylesheet

class CssInlineDemoViewController: DemoPageViewController {
    override var demoDescription: String { ".css(\"width:100px;margin:8\") inline CSS string on any view" }
    override var codeSnippet: String { "view.style.css(\"width: 100px; margin: 8px\")" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.css(\"width: 100px; margin: 8px\")"
        contentView.addSubview(info)
    }
}
