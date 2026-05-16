import UIKit
import GWYogaKit
import GWYogaKitStylesheet

class CssFileDemoViewController: DemoPageViewController {
    override var demoDescription: String { "loadStylesheet(_:bundle:) for file loading + YogaCSSConfig.registerDefault()" }
    override var codeSnippet: String { "view.style.loadStylesheet(\"style.css\")\nYogaCSSConfig.registerDefault(sheet)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.loadStylesheet(\"style.css\")\nYogaCSSConfig.registerDefault(sheet)"
        contentView.addSubview(info)
    }
}
