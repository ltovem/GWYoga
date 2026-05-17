import UIKit
import GWYoga
import GWYogaKit

class FlexboxDirectionCSSDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("CSS")

        let container = YogaLayoutView()
        container.style.css("""
            width: 100%;
            padding: 16px;
            flex-direction: row;
            justify-content: center;
            align-items: center;
            background-color: #f0f0f0;
        """)
        view.addSubview(container)

        for i in 1...4 {
            let child = UIView()
            child.style.css("width: 60; height: 60; margin: 8;")
            child.backgroundColor = UIColor(red: 0, green: 0.48 + Double(i) * 0.1, blue: 1, alpha: 1)
            container.addSubview(child)
        }

        // Column CSS example
        let colLabel = UILabel()
        colLabel.text = "Column CSS:"
        colLabel.font = .systemFont(ofSize: 12)
        colLabel.textColor = .secondaryLabel
        colLabel.style.marginTop(20).marginLeft(16)
        view.addSubview(colLabel)

        let colContainer = YogaLayoutView()
        colContainer.style.css("""
            width: 90%;
            margin-left: 16;
            margin-right: 16;
            margin-top: 4;
            padding: 12;
            flex-direction: column;
            align-items: center;
            background-color: #f0f0f0;
        """)
        view.addSubview(colContainer)

        for color in ["#AF52DE", "#5856D6", "#30B0C7"] {
            let child = UIView()
            if let uiColor = UIColor.hex(color) {
                child.backgroundColor = uiColor
            } else {
                child.backgroundColor = .systemPurple
            }
            child.style.css("width: 80; height: 30; margin: 4;")
            colContainer.addSubview(child)
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

extension UIColor {
    static func hex(_ hex: String) -> UIColor? {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        guard str.count == 6, let val = Int(str, radix: 16) else { return nil }
        return UIColor(red: CGFloat((val >> 16) & 0xFF)/255, green: CGFloat((val >> 8) & 0xFF)/255, blue: CGFloat(val & 0xFF)/255, alpha: 1)
    }
}
