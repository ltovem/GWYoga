import UIKit
import GWYogaKit
import Combine

class CombineDemoViewController: DemoPageViewController {
    override var demoDescription: String { "Publisher.bind(to:keyPath:) and bind(to:update:) for Combine integration" }
    override var codeSnippet: String { "publisher.bind(to: view.style, keyPath: \\.width)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "publisher.bind(to: view.style, keyPath: \\.width)\npublisher.bind(to: view.style) { s, v in s.width = v }"
        contentView.addSubview(info)
    }
}
