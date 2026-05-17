import UIKit
import GWYoga
import GWYogaKit

class JustifyContentDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("闭包")

        let scrollView = UIScrollView()
        scrollView.frame = view.bounds
        view.addSubview(scrollView)

        let container = YogaLayoutView()
        container.style { $0.padding = [.all: 16]; $0.width = 100%; $0.flexDirection = .column }
        scrollView.addSubview(container)

        let values: [(title: String, justify: GWJustify)] = [
            ("flexStart", .flexStart), ("center", .center), ("flexEnd", .flexEnd),
            ("spaceBetween", .spaceBetween), ("spaceAround", .spaceAround), ("spaceEvenly", .spaceEvenly),
        ]

        for v in values {
            let section = UIView()
            section.backgroundColor = .systemGray6
            section.layer.cornerRadius = 8
            section.style { $0.margin = [.bottom: 12]; $0.padding = [.all: 8] }
            container.addSubview(section)

            let label = UILabel()
            label.text = v.title
            label.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
            label.textColor = .secondaryLabel
            section.addSubview(label)

            let row = YogaLayoutView()
            row.style { $0.flexDirection = .row; $0.justifyContent = v.justify; $0.margin = [.top: 4]; $0.padding = [.all: 4] }
            row.backgroundColor = UIColor.systemGray5
            row.layer.cornerRadius = 4
            section.addSubview(row)

            for color in [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue] {
                let box = UIView()
                box.backgroundColor = color
                box.layer.cornerRadius = 4
                box.style { $0.width = 40; $0.height = 40; $0.margin = [.horizontal: 2] }
                row.addSubview(box)
            }
        }

        DispatchQueue.main.async {
            container.performYogaLayout()
            scrollView.contentSize = container.frame.size
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
    }
}
