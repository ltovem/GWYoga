import UIKit
import GWYoga
import GWYogaKit

class GridDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("链式")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        let label = UILabel()
        label.text = "Grid: gridTemplateColumns = 1fr 1fr 1fr"
        label.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        label.textColor = .secondaryLabel
        label.style.marginBottom(8)
        container.addSubview(label)

        let grid = YogaLayoutView()
        grid.style.display(.grid).gap(8)
        grid.style.gridTemplateColumns = [.fr(1), .fr(1), .fr(1)]
        grid.backgroundColor = UIColor.systemGray6
        grid.layer.cornerRadius = 8
        grid.style.padding(.all, 8)
        container.addSubview(grid)

        for i in 0..<6 {
            let cell = UIView()
            cell.backgroundColor = UIColor(hue: CGFloat(i) / 6, saturation: 0.6, brightness: 0.9, alpha: 1)
            cell.layer.cornerRadius = 4
            cell.style.height(60)
            grid.addSubview(cell)
        }

        let label2 = UILabel()
        label2.text = "Grid: 2 columns"
        label2.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        label2.textColor = .secondaryLabel
        label2.style.marginTop(24).marginBottom(8)
        container.addSubview(label2)

        let grid2 = YogaLayoutView()
        grid2.style.display(.grid).gap(12)
        grid2.style.gridTemplateColumns = [.fr(1), .fr(1)]
        grid2.backgroundColor = UIColor.systemGray6
        grid2.layer.cornerRadius = 8
        grid2.style.padding(.all, 8)
        container.addSubview(grid2)

        for i in 0..<4 {
            let cell = UIView()
            cell.backgroundColor = [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue, UIColor.systemOrange][i]
            cell.layer.cornerRadius = 4
            cell.style.height(80)
            grid2.addSubview(cell)
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
