import UIKit
import GWYogaKit
import GWYogaKitDSL

class ModifierDemoViewController: DemoPageViewController {
    override var demoDescription: String { "Chainable DSL modifiers: .padding(), .flexGrow(), .backgroundColor(), .cornerRadius()" }
    override var codeSnippet: String { "YogaText(\"Hi\").padding(.all, 12).flexGrow(1).backgroundColor(.lightGray)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaText(\"Hi\").padding(.all, 12).flexGrow(1).backgroundColor(.lightGray)"
        contentView.addSubview(info)
    }
}
