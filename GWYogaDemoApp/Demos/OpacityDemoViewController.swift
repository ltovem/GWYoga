import UIKit
import GWYogaKit

class OpacityDemoViewController: DemoPageViewController {
    override var demoDescription: String { "opacity + clipsToBounds + isHidden / hidden() control" }
    override var codeSnippet: String { "view.style.opacity(0.5)\nview.style.clipsToBounds(true)\nview.style.hidden(false)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.opacity(0.5)\nview.style.clipsToBounds(true)\nview.style.hidden(false)"
        contentView.addSubview(info)

        let full = YogaLayoutView()
        full.yoga.width = .points(80)
        full.yoga.height = .points(80)
        full.yoga.marginTop(16)
        full.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        contentView.addSubview(full)
        let l1 = UILabel()
        l1.text = "opacity 1"
        l1.font = .systemFont(ofSize: 11)
        l1.textAlignment = .center
        full.addSubview(l1)

        let half = YogaLayoutView()
        half.yoga.width = .points(80)
        half.yoga.height = .points(80)
        half.yoga.marginTop(16)
        half.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        half.alpha = 0.5
        contentView.addSubview(half)
        let l2 = UILabel()
        l2.text = "opacity 0.5"
        l2.font = .systemFont(ofSize: 11)
        l2.textAlignment = .center
        half.addSubview(l2)
    }
}
