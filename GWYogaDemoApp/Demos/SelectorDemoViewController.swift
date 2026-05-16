import UIKit
import GWYogaKit
import GWYogaKitStylesheet

class SelectorDemoViewController: DemoPageViewController {
    override var demoDescription: String { "cssID / cssClass / find(byID:) / findAll(byClass:) for element lookup" }
    override var codeSnippet: String { "view.style.cssID = \"header\"\nview.style.cssClass = \"item\"\nview.find(byID: \"header\")" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.cssID = \"header\"\nview.style.cssClass = \"item\"\nview.find(byID: \"header\")"
        contentView.addSubview(info)
    }
}
