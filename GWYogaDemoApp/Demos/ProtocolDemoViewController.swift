import UIKit
import GWYogaKit

class ProtocolDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaCustomDrawing + YogaStyleApplied protocol conformance (custom text view example)" }
    override var codeSnippet: String { "class MyView: UIView, YogaCustomDrawing, YogaStyleApplied {\n    var cssTagName: String?\n    func yogaContentSize(...) -> CGSize { ... }\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "class MyView: UIView, YogaCustomDrawing, YogaStyleApplied {\n    var cssTagName: String?\n    func yogaContentSize(...) -> CGSize { ... }\n}"
        contentView.addSubview(info)
    }
}
