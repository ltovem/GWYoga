import UIKit
import GWYoga
import GWYogaKit

class PositionDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("混合")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        // Relative positioning section
        let sectionLabel = UILabel()
        sectionLabel.text = "Relative + Absolute"
        sectionLabel.font = .boldSystemFont(ofSize: 14)
        sectionLabel.style.marginBottom(8)
        container.addSubview(sectionLabel)

        let relative = YogaLayoutView()
        relative.backgroundColor = UIColor.systemGray6
        relative.layer.cornerRadius = 8
        relative.style.width(100%).height(200).marginBottom(16)
        container.addSubview(relative)

        // Normal flow child
        let normal = UIView()
        normal.backgroundColor = .systemBlue
        normal.style.width(80).height(80).margin(.all, 12)
        relative.addSubview(normal)

        // Absolute positioned
        let absView = UIView()
        absView.backgroundColor = .systemRed
        absView.layer.cornerRadius = 8
        absView.style.position(.absolute).top(10).right(10).width(60).height(60)
        relative.addSubview(absView)

        // Bottom-right absolute
        let brView = UIView()
        brView.backgroundColor = .systemGreen
        brView.layer.cornerRadius  = 8
        brView.style.position(.absolute).bottom(10).right(10).width(50).height(50)
        relative.addSubview(brView)

        // Inset example
        let insetLabel = UILabel()
        insetLabel.text = "Absolute with inset (all: 10)"
        insetLabel.font = .boldSystemFont(ofSize: 14)
        insetLabel.style.marginTop(8).marginBottom(8)
        container.addSubview(insetLabel)

        let outer = UIView()
        outer.backgroundColor = UIColor.systemGray6
        outer.layer.cornerRadius = 8
        outer.style.width(100%).height(120)
        container.addSubview(outer)

        let inner = UIView()
        inner.backgroundColor = UIColor.systemPurple
        inner.layer.cornerRadius = 6
        inner.style.position(.absolute).inset(10)
        outer.addSubview(inner)
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
