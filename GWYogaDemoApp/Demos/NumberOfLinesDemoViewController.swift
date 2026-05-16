import UIKit
import GWYogaKit

class NumberOfLinesDemoViewController: DemoPageViewController {
    override var demoDescription: String { "numberOfLines + lineBreakMode for multi-line text truncation" }
    override var codeSnippet: String { "view.style.numberOfLines = 2\nview.style.lineBreakMode = .byTruncatingTail" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.numberOfLines = 2\nview.style.lineBreakMode = .byTruncatingTail"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(200)
        demo.yoga.marginTop(16)
        demo.backgroundColor = .systemGray6
        demo.layer.cornerRadius = 4
        contentView.addSubview(demo)

        let label = UILabel()
        label.text = "This is a long text that should be truncated after two lines to demonstrate numberOfLines behavior"
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.yoga.width = .points(180)
        demo.addSubview(label)
    }
}
