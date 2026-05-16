import UIKit
import GWYogaKit

class CornerRadiusDemoViewController: DemoPageViewController {
    override var demoDescription: String { "cornerRadius with 3 overloads: CGFloat, YogaCornerRadii, [CACornerMask: CGFloat]" }
    override var codeSnippet: String { "view.style.cornerRadius(12)" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.cornerRadius(12)\n// 3 overloads: CGFloat, YogaCornerRadii, [CACornerMask: CGFloat]"
        contentView.addSubview(info)

        let all = YogaLayoutView()
        all.yoga.width = .points(80)
        all.yoga.height = .points(80)
        all.yoga.marginTop(16)
        all.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        all.layer.cornerRadius = 16
        all.layer.masksToBounds = true
        contentView.addSubview(all)
        let l1 = UILabel()
        l1.text = "all 16"
        l1.font = .systemFont(ofSize: 11)
        l1.textAlignment = .center
        all.addSubview(l1)

        let top = YogaLayoutView()
        top.yoga.width = .points(80)
        top.yoga.height = .points(80)
        top.yoga.marginTop(16)
        top.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        top.layer.cornerRadius = 20
        top.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        top.layer.masksToBounds = true
        contentView.addSubview(top)
        let l2 = UILabel()
        l2.text = "top 20"
        l2.font = .systemFont(ofSize: 11)
        l2.textAlignment = .center
        top.addSubview(l2)
    }
}
