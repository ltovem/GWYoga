import UIKit
import GWYogaKit

class YogDemoViewController: DemoPageViewController {
    override var demoDescription: String { "yog() proxy chains UIKit + Yoga property configuration on any UIView" }
    override var codeSnippet: String { "UILabel().yog().text(\"Hello\").font(.boldSystemFont(ofSize: 16)).width(200).margin(.all, 8)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "UILabel().yog().text(\"Hello\").font(.boldSystemFont(ofSize: 16)).width(200).margin(.all, 8)"
        contentView.addSubview(info)
    }
}
