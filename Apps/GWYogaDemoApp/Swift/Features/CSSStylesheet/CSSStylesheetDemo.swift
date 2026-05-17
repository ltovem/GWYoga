import UIKit
import GWYoga
import GWYogaKit
import GWYogaKitStylesheet

class CSSStylesheetDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("CSS")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        let label = UILabel()
        label.text = "CSS Stylesheet"
        label.font = .boldSystemFont(ofSize: 14)
        label.style.marginBottom(12)
        container.addSubview(label)

        // Apply CSS to multiple views
        let css = """
            width: 160;
            height: 50;
            margin: 6px;
            border-radius: 8px;
        """

        let infoLabel = UILabel()
        infoLabel.text = "Same CSS applied to multiple views:"
        infoLabel.font = .systemFont(ofSize: 11)
        infoLabel.textColor = .secondaryLabel
        infoLabel.style.marginBottom(8)
        container.addSubview(infoLabel)

        for color in [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue] {
            let box = UIView()
            box.backgroundColor = color
            box.style.css(css)
            container.addSubview(box)
        }

        // Grid with CSS
        let gridLabel = UILabel()
        gridLabel.text = "Grid via CSS:"
        gridLabel.font = .systemFont(ofSize: 11)
        gridLabel.textColor = .secondaryLabel
        gridLabel.style.marginTop(16).marginBottom(4)
        container.addSubview(gridLabel)

        let gridCSS = """
            width: 100%;
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 8px;
            padding: 12px;
            background-color: #f0f0f0;
        """

        let grid = YogaLayoutView()
        grid.style.css(gridCSS)
        grid.layer.cornerRadius = 8
        container.addSubview(grid)

        for i in 0..<3 {
            let cell = UIView()
            cell.backgroundColor = UIColor(hue: CGFloat(i) / 3, saturation: 0.6, brightness: 0.9, alpha: 1)
            cell.style.css("height: 60;")
            cell.layer.cornerRadius = 6
            grid.addSubview(cell)
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
