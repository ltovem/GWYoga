import UIKit
import GWYoga
import GWYogaKit

class YogProxyDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("链式")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        let label = UILabel()
        label.text = ".yog() proxy — UIKit + Yoga chain"
        label.font = .boldSystemFont(ofSize: 14)
        label.style.marginBottom(12)
        container.addSubview(label)

        // Demo 1: UILabel with .yog()
        let demo1 = UILabel().yog()
            .text("Hello Yoga!")
            .font(.boldSystemFont(ofSize: 22))
            .color(.systemBlue)
            .alignment(.center)
            .width(200).height(44)
            .backgroundColor(.systemGray6)
            .cornerRadius(8)
            .margin(.all, 0)
            .view
        container.addSubview(demo1)

        // Demo 2: UIButton with .yog()
        let demo2 = UIButton(type: .system).yog()
            .title("Tap me")
            .font(.systemFont(ofSize: 16, weight: .semibold))
            .backgroundColor(.systemBlue)
            .cornerRadius(10)
            .width(160).height(44)
            .marginTop(12)
            .view
        (demo2 as! UIButton).setTitleColor(.white, for: .normal)
        container.addSubview(demo2)

        // Demo 3: Plain UIView with .yog()
        let demo3Label = UILabel()
        demo3Label.text = "Plain UIView + Yoga:"
        demo3Label.font = .systemFont(ofSize: 12)
        demo3Label.textColor = .secondaryLabel
        demo3Label.style.marginTop(16).marginBottom(4)
        container.addSubview(demo3Label)

        let demo3 = UIView().yog()
            .backgroundColor(.systemPurple)
            .cornerRadius(8)
            .width(120).height(80)
            .marginTop(4)
            .shadow(color: .purple, opacity: 0.3, radius: 6, offset: CGSize(width: 0, height: 4))
            .view
        container.addSubview(demo3)
    }

    func addStyleBadge(_ text: String) {
        let badge = UILabel()
        badge.text = "  \(text)  "
        badge.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        badge.textColor = .systemBlue
        badge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        badge.layer.cornerRadius = 4
        badge.clipsToBounds = true
        badge.tag = 999
        view.addSubview(badge)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let badge = view.viewWithTag(999) as? UILabel {
            badge.sizeToFit()
            badge.frame = CGRect(x: view.bounds.width - badge.frame.width - 16, y: view.safeAreaLayoutGuide.layoutFrame.minY + 8, width: badge.frame.width, height: badge.frame.height)
        }
        view.subviews.compactMap { $0 as? YogaLayoutView }.forEach { $0.performYogaLayout() }
    }
}
