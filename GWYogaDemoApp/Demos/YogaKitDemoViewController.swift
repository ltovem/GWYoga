import UIKit
import GWYoga
import GWYogaKit

class YogaKitDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "YogaKit"

        setupDemoScrollView(scrollView, sections: [
            createPropertiesSection(),
            createLayoutViewSection(),
            createIntrinsicSection(),
            createComplexSection(),
        ])
    }

    private func createPropertiesSection() -> UIView {
        makeDemoSection(title: "YogaProperties 属性") {
            let r = GWYogaNode()
            r.style.setWidth(.points(300))
            r.style.setHeight(.points(80))
            r.style.flexDirection = .row
            r.style.justifyContent = .spaceEvenly
            r.style.alignItems = .center
            for i in 0..<4 {
                let c = GWYogaNode()
                c.style.setWidth(.points(50))
                c.style.setHeight(.points(30))
                r.insertChild(c, at: i)
            }
            return (r, 300, 80)
        }
    }

    private func createLayoutViewSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "YogaLayoutView (Auto Layout)"
        label.font = .boldSystemFont(ofSize: 14)

        let container = YogaLayoutView(frame: .init(x: 0, y: 0, width: 300, height: 80))
        container.yoga.flexDirection = .row
        container.yoga.justifyContent = .spaceBetween
        container.yoga.alignItems = .center
        container.backgroundColor = .systemGray6
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemBlue.cgColor
        container.layer.cornerRadius = 4

        for i in 0..<3 {
            let child = UIView()
            child.backgroundColor = UIColor.systemColors[i % UIColor.systemColors.count].withAlphaComponent(0.3)
            child.layer.borderWidth = 1
            child.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.4).cgColor
            child.layer.cornerRadius = 2
            child.yoga.width = .points(70)
            child.yoga.height = .points(40)
            container.addSubview(child)
        }
        container.performYogaLayout()

        container.translatesAutoresizingMaskIntoConstraints = false

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        info.numberOfLines = 0
        info.text = YogaLayoutRenderer.describe(node: container.yoga.node)

        [label, container, info].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            section.addSubview($0)
        }
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: section.topAnchor),
            label.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            container.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            container.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            info.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 4),
            info.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            info.bottomAnchor.constraint(equalTo: section.bottomAnchor),
        ])
        return section
    }

    private func createIntrinsicSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "Intrinsic 内容尺寸"
        label.font = .boldSystemFont(ofSize: 14)

        let textLabel = UILabel()
        textLabel.text = "Intrinsic Text"
        textLabel.yoga.isIntrinsic = true
        textLabel.yoga.margin = [.right: .points(8)]

        let button = UIButton(type: .system)
        button.setTitle("Button", for: .normal)
        button.yoga.isIntrinsic = true

        let container = YogaLayoutView(frame: .init(x: 0, y: 0, width: 300, height: 50))
        container.yoga.flexDirection = .row
        container.yoga.alignItems = .center
        container.backgroundColor = .systemGray6
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemBlue.cgColor
        container.layer.cornerRadius = 4
        container.addSubview(textLabel)
        container.addSubview(button)
        container.performYogaLayout()

        container.translatesAutoresizingMaskIntoConstraints = false

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        UILabel / UIButton 设置 isIntrinsic = true 后，
        自动根据内容计算尺寸。
        """

        [label, container, info].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            section.addSubview($0)
        }
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: section.topAnchor),
            label.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            container.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            container.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            info.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 4),
            info.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            info.bottomAnchor.constraint(equalTo: section.bottomAnchor),
        ])
        return section
    }

    private func createComplexSection() -> UIView {
        makeDemoSection(title: "YogaLayoutView: flex + gap + padding") {
            let r = GWYogaNode()
            r.style.setWidth(.points(300))
            r.style.setHeight(.points(120))
            r.style.flexDirection = .row
            r.style.flexWrap = .wrap
            r.style.setPadding(for: .all, .points(8))
            r.style.setGap(for: .row, .points(8))
            r.style.setGap(for: .column, .points(8))
            for _ in 0..<6 {
                let c = GWYogaNode()
                c.style.setWidth(.points(80))
                c.style.setHeight(.points(40))
                r.insertChild(c, at: r.children.count)
            }
            return (r, 300, 120)
        }
    }
}

extension UIColor {
    static var systemColors: [UIColor] {
        [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemTeal, .systemPink, .systemIndigo]
    }
}
