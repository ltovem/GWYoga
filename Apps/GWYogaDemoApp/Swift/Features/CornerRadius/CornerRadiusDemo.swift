import UIKit
import GWYoga
import GWYogaKit

class CornerRadiusDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("链式")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        // All corners
        let allLabel = UILabel()
        allLabel.text = "cornerRadius(all: 16)"
        allLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        allLabel.textColor = .secondaryLabel
        allLabel.style.marginBottom(4)
        container.addSubview(allLabel)

        let all = UIView()
        all.backgroundColor = .systemBlue
        all.style.width(100).height(60).cornerRadius(16).marginBottom(16)
        container.addSubview(all)

        // Top corners only
        let topLabel = UILabel()
        topLabel.text = "cornerRadius(topLeft: 16, topRight: 16)"
        topLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        topLabel.textColor = .secondaryLabel
        topLabel.style.marginBottom(4)
        container.addSubview(topLabel)

        let top = UIView()
        top.backgroundColor = .systemGreen
        top.style.width(100).height(60).cornerRadius(topLeft: 16, topRight: 16).marginBottom(16)
        container.addSubview(top)

        // Bottom corners only
        let bottomLabel = UILabel()
        bottomLabel.text = "cornerRadius(bottomLeft: 16, bottomRight: 16)"
        bottomLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        bottomLabel.textColor = .secondaryLabel
        bottomLabel.style.marginBottom(4)
        container.addSubview(bottomLabel)

        let bottom = UIView()
        bottom.backgroundColor = .systemOrange
        bottom.style.width(100).height(60).cornerRadius(bottomLeft: 16, bottomRight: 16).marginBottom(16)
        container.addSubview(bottom)

        // Different corners
        let diffLabel = UILabel()
        diffLabel.text = "cornerRadius(topLeft: 24, bottomRight: 24)"
        diffLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        diffLabel.textColor = .secondaryLabel
        diffLabel.style.marginBottom(4)
        container.addSubview(diffLabel)

        let diff = UIView()
        diff.backgroundColor = .systemPurple
        diff.style.width(100).height(60).cornerRadius(topLeft: 24, bottomRight: 24)
        container.addSubview(diff)
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
