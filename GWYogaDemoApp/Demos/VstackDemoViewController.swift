import UIKit
import GWYogaKit
import GWYogaKitDSL

class VstackDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaVStack / YogaHStack / YogaZStack for declarative stack layout" }
    override var codeSnippet: String { "YogaVStack(spacing: 8, alignment: .center) {\n    YogaText(\"A\")\n    YogaText(\"B\")\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaVStack(spacing: 8, alignment: .center) {\n    YogaText(\"A\")\n    YogaText(\"B\")\n}"
        contentView.addSubview(info)

        let stack = YogaVStack(spacing: 8, alignment: .center)
        stack.yoga.width = .points(200)
        stack.yoga.height = .points(160)
        stack.yoga.marginTop(16)
        stack.backgroundColor = .systemGray6
        stack.layer.borderWidth = 1
        stack.layer.borderColor = UIColor.systemGray4.cgColor
        stack.layer.cornerRadius = 8
        contentView.addSubview(stack)

        let items = ["A", "B", "C", "D"]
        for item in items {
            let v = UIView()
            v.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
            v.layer.cornerRadius = 4
            v.yoga.width = .points(60)
            v.yoga.height = .points(24)
            stack.addSubview(v)

            let lbl = UILabel()
            lbl.text = item
            lbl.font = .systemFont(ofSize: 12, weight: .medium)
            lbl.textAlignment = .center
            v.addSubview(lbl)
        }
    }
}
