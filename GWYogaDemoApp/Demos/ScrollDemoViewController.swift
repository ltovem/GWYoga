import UIKit
import GWYogaKit
import GWYogaKitDSL

class ScrollDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaScrollView for scrollable Yoga content (vertical / horizontal)" }
    override var codeSnippet: String { "YogaScrollView(axis: .vertical) {\n    YogaText(\"Content\")\n}" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaScrollView(axis: .vertical) {\n    YogaText(\"Content\")\n}"
        contentView.addSubview(info)

        let scroll = YogaScrollView(axis: .vertical) {
            for i in 0..<20 {
                YogaText("Row \(i + 1) — scrollable content")
                    .yog()
                    .height(44)
                    .padding(.all, 8)
                    .backgroundColor(i % 2 == 0 ? .systemGray5 : .systemGray6)
                    .view
            }
        }
        scroll.yog().height(200).marginTop(12)
        scroll.layer.borderWidth = 1
        scroll.layer.borderColor = UIColor.systemBlue.cgColor
        scroll.layer.cornerRadius = 6
        contentView.addSubview(scroll)

        let hScroll = YogaScrollView(axis: .horizontal) {
            for i in 0..<10 {
                YogaText("Item \(i + 1)")
                    .yog()
                    .width(100)
                    .height(60)
                    .padding(.all, 8)
                    .backgroundColor(.systemTeal.withAlphaComponent(0.3))
                    .view
            }
        }
        hScroll.yog().height(80).marginTop(16)
        hScroll.layer.borderWidth = 1
        hScroll.layer.borderColor = UIColor.systemGreen.cgColor
        hScroll.layer.cornerRadius = 6
        contentView.addSubview(hScroll)
    }
}
