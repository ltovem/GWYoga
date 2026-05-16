import UIKit
import GWYogaKit
import GWYogaKitStylesheet

class CssMergeDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaStylesheet.merge() and selector specificity rules" }
    override var codeSnippet: String { "YogaStylesheet.merge(sheet1, sheet2)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaStylesheet.merge(sheet1, sheet2)"
        contentView.addSubview(info)
    }
}
