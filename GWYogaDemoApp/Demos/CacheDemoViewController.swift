import UIKit
import GWYogaKit
import GWYogaKitLayoutCache

class CacheDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaPreLayout.measure() / measureAll() / invalidateCache() for layout caching" }
    override var codeSnippet: String { "let size = view.yoga.measurement.measure(width: 200)\nview.yoga.measurement.invalidateCache()" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "let size = view.yoga.measurement.measure(width: 200)\nview.yoga.measurement.invalidateCache()"
        contentView.addSubview(info)
    }
}
