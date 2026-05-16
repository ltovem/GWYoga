import UIKit
import GWYogaKit
import Combine

class CoalesceDemoViewController: DemoPageViewController {
    override var demoDescription: String { "coalesceLayout() and scheduleDirty() for batch layout updates" }
    override var codeSnippet: String { "YogaBinding.coalesceLayout {\n    // multiple style changes, one layout pass\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaBinding.coalesceLayout {\n    // multiple style changes, one layout pass\n}"
        contentView.addSubview(info)
    }
}
