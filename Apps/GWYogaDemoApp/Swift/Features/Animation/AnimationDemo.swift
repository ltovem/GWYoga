import UIKit
import GWYoga
import GWYogaKit

class AnimationDemo: UIViewController {
    var isExpanded = false
    let animatedView = YogaLayoutView()
    let toggleButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("链式")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        let label = UILabel()
        label.text = "Animate Yoga properties"
        label.font = .boldSystemFont(ofSize: 14)
        label.style.marginBottom(16)
        container.addSubview(label)

        animatedView.backgroundColor = UIColor.systemGray6
        animatedView.layer.cornerRadius = 12
        animatedView.style.width(100%).flexDirection(.row).justifyContent(.center).alignItems(.center).padding(.all, 12)
        container.addSubview(animatedView)

        for color in [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue] {
            let box = UIView()
            box.backgroundColor = color
            box.layer.cornerRadius = 6
            box.style.width(40).height(40).margin(.horizontal, 4)
            animatedView.addSubview(box)
        }

        toggleButton.setTitle("展开 (flexDirection: column)", for: .normal)
        toggleButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        toggleButton.backgroundColor = .systemBlue
        toggleButton.setTitleColor(.white, for: .normal)
        toggleButton.layer.cornerRadius = 10
        toggleButton.style.width(200).height(44).alignSelf(.center).marginTop(20)
        toggleButton.addTarget(self, action: #selector(didTapToggle), for: .touchUpInside)
        container.addSubview(toggleButton)
    }

    @objc func didTapToggle() {
        isExpanded.toggle()
        if isExpanded {
            animatedView.style.flexDirection(.column).alignItems(.center)
            toggleButton.setTitle("折叠 (flexDirection: row)", for: .normal)
        } else {
            animatedView.style.flexDirection(.row).justifyContent(.center).alignItems(.center)
            toggleButton.setTitle("展开 (flexDirection: column)", for: .normal)
        }
        UIView.animate(withDuration: 0.3) {
            self.animatedView.superview?.layoutIfNeeded()
        }
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
