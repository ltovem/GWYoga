import UIKit
import GWYogaKit
import Combine

class YogaStateDemoViewController: DemoPageViewController {
    override var demoDescription: String { "@YogaState property wrapper with observe() and forward() for reactive values" }
    override var codeSnippet: String { "@YogaState var count: Int = 0\n$count.observe { newValue in\n    print(newValue)\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "@YogaState var count: Int = 0\n$count.observe { newValue in\n    print(newValue)\n}"
        contentView.addSubview(info)
    }
}
