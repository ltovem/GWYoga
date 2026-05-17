import UIKit
import GWYoga
import GWYogaKit

class GapDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("链式")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        // Row gap
        let rowLabel = UILabel()
        rowLabel.text = "Row gap: 12"
        rowLabel.font = .boldSystemFont(ofSize: 14)
        rowLabel.style.marginBottom(4)
        container.addSubview(rowLabel)

        let rowContainer = YogaLayoutView()
        rowContainer.style.flexDirection(.row).gap(12).padding(.all, 12).width(100%)
        rowContainer.backgroundColor = UIColor.systemGray6
        rowContainer.layer.cornerRadius = 8
        container.addSubview(rowContainer)

        for color in [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue, UIColor.systemOrange] {
            let box = UIView()
            box.backgroundColor = color
            box.layer.cornerRadius = 4
            box.style.width(50).height(50)
            rowContainer.addSubview(box)
        }

        // Column gap
        let colLabel = UILabel()
        colLabel.text = "Column gap: 8"
        colLabel.font = .boldSystemFont(ofSize: 14)
        colLabel.style.marginTop(24).marginBottom(4)
        container.addSubview(colLabel)

        let colContainer = YogaLayoutView()
        colContainer.style.flexDirection(.column).gap(8).padding(.all, 12).width(100%)
        colContainer.backgroundColor = UIColor.systemGray6
        colContainer.layer.cornerRadius = 8
        container.addSubview(colContainer)

        for color in [UIColor.systemPurple, UIColor.systemIndigo, UIColor.systemTeal] {
            let box = UIView()
            box.backgroundColor = color
            box.layer.cornerRadius = 4
            box.style.width(100%).height(30)
            colContainer.addSubview(box)
        }

        // Both gap
        let bothLabel = UILabel()
        bothLabel.text = "Row + Column gap: 6"
        bothLabel.font = .boldSystemFont(ofSize: 14)
        bothLabel.style.marginTop(24).marginBottom(4)
        container.addSubview(bothLabel)

        let grid = YogaLayoutView()
        grid.style.flexDirection(.row).flexWrap(.wrap).rowGap(6).columnGap(6).padding(.all, 12)
        grid.backgroundColor = UIColor.systemGray6
        grid.layer.cornerRadius = 8
        container.addSubview(grid)

        for i in 0..<6 {
            let box = UIView()
            box.backgroundColor = UIColor(hue: CGFloat(i) / 6, saturation: 0.7, brightness: 0.9, alpha: 1)
            box.layer.cornerRadius = 4
            box.style.width(80).height(40)
            grid.addSubview(box)
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
