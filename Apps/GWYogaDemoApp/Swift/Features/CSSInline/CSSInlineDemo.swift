import UIKit
import GWYoga
import GWYogaKit
import GWYogaKitStylesheet

class CSSInlineDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("CSS")

        let container = YogaLayoutView()
        container.style.css("""
            width: 100%;
            padding: 16px;
            flex-direction: column;
        """)
        view.addSubview(container)

        let label = UILabel()
        label.text = "CSS 内联样式"
        label.font = .boldSystemFont(ofSize: 14)
        label.style.marginBottom(12)
        container.addSubview(label)

        // Box with CSS
        let boxLabel = UILabel()
        boxLabel.text = "style.css(\"width: 200; height: 80; margin: 8; border-radius: 8; background-color: #007AFF;\")"
        boxLabel.font = .monospacedSystemFont(ofSize: 10, weight: .medium)
        boxLabel.textColor = .secondaryLabel
        boxLabel.numberOfLines = 0
        boxLabel.style.marginBottom(4)
        container.addSubview(boxLabel)

        let box = UIView()
        box.style.css("width: 200; height: 80; margin: 8;")
        box.backgroundColor = UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)
        box.layer.cornerRadius = 8
        container.addSubview(box)

        // Flex row with CSS
        let rowLabel = UILabel()
        rowLabel.text = "Flex row via CSS"
        rowLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        rowLabel.textColor = .secondaryLabel
        rowLabel.style.marginTop(16).marginBottom(4)
        container.addSubview(rowLabel)

        let row = YogaLayoutView()
        row.style.css("""
            width: 100%;
            padding: 12px;
            flex-direction: row;
            justify-content: center;
            gap: 8px;
            background-color: #f0f0f0;
        """)
        row.layer.cornerRadius = 8
        container.addSubview(row)

        for i in 1...3 {
            let child = UIView()
            child.style.css("width: 60; height: 60;")
            child.backgroundColor = UIColor(hue: CGFloat(i) / 4, saturation: 0.6, brightness: 0.9, alpha: 1)
            child.layer.cornerRadius = 6
            row.addSubview(child)
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
