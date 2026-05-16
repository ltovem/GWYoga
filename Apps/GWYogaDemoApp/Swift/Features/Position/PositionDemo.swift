import UIKit
import GWYoga
import GWYogaKit

class PositionDemo: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("混合")
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
            badge.frame = CGRect(
                x: view.bounds.width - badge.frame.width - 16,
                y: view.safeAreaLayoutGuide.layoutFrame.minY + 8,
                width: badge.frame.width,
                height: badge.frame.height
            )
        }
    }
}
