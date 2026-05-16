import UIKit
import GWYogaKit

class IntrinsicDemoViewController: DemoPageViewController {
    override var demoDescription: String { "isIntrinsic = true lets Yoga measure content automatically via intrinsicContentSize" }
    override var codeSnippet: String { "label.style.isIntrinsic = true\nlabel.style.markDirty() // when content changes" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "label.style.isIntrinsic = true\nlabel.style.markDirty() // when content changes"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(200)
        demo.yoga.height = .points(60)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemGray6
        demo.layer.cornerRadius = 4
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "Auto-sized label"
        label.font = .systemFont(ofSize: 14)
        label.yoga.isIntrinsic = true
        demo.addSubview(label)
    }
}
