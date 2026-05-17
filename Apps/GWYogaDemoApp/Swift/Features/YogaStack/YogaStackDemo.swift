import UIKit
import GWYoga
import GWYogaKit

class YogaStackDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("闭包")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        // VStack
        let vLabel = UILabel()
        vLabel.text = "VStack"
        vLabel.font = .boldSystemFont(ofSize: 14)
        vLabel.style.marginBottom(4)
        container.addSubview(vLabel)

        let vStack = YogaLayoutView()
        vStack.style { $0.flexDirection = .column; $0.alignItems = .center; $0.rowGap = 8; $0.columnGap = 8; $0.padding = [.all: 12] }
        vStack.backgroundColor = UIColor.systemGray6
        vStack.layer.cornerRadius = 8
        vStack.style.marginBottom(24)
        container.addSubview(vStack)

        for color in [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue] {
            let box = UIView()
            box.backgroundColor = color
            box.layer.cornerRadius = 4
            box.style { $0.width = 200; $0.height = 30 }
            vStack.addSubview(box)
        }

        // HStack
        let hLabel = UILabel()
        hLabel.text = "HStack"
        hLabel.font = .boldSystemFont(ofSize: 14)
        hLabel.style.marginBottom(4)
        container.addSubview(hLabel)

        let hStack = YogaLayoutView()
        hStack.style { $0.flexDirection = .row; $0.justifyContent = .spaceEvenly; $0.alignItems = .center; $0.padding = [.all: 12] }
        hStack.backgroundColor = UIColor.systemGray6
        hStack.layer.cornerRadius = 8
        container.addSubview(hStack)

        for (i, color) in [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue, UIColor.systemOrange].enumerated() {
            let box = UIView()
            box.backgroundColor = color
            box.layer.cornerRadius = 4
            box.style { $0.width = 50; $0.height = GWValue.points(Float(30 + i * 10)) }
            hStack.addSubview(box)
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
