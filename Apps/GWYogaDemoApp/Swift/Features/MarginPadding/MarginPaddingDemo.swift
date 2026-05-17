import UIKit
import GWYoga
import GWYogaKit

class MarginPaddingDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("链式")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        let outer = UIView()
        outer.backgroundColor = UIColor.systemGray5
        outer.layer.cornerRadius = 8
        outer.style.width(200).height(120).alignSelf(.center).marginTop(20)
        container.addSubview(outer)

        let inner = UIView()
        inner.backgroundColor = .systemBlue
        inner.layer.cornerRadius = 6
        inner.style.width(60).height(60).margin(.all, 16).padding(.all, 8)
        outer.addSubview(inner)

        let label1 = UILabel()
        label1.text = "outer: margin=16, inner: margin=16"
        label1.font = .systemFont(ofSize: 11)
        label1.textColor = .secondaryLabel
        label1.style.alignSelf(.center).marginTop(4)
        container.addSubview(label1)

        // Horizontal margin example
        let hRow = YogaLayoutView()
        hRow.style.flexDirection(.row).justifyContent(.center).marginTop(24).width(100%)
        container.addSubview(hRow)

        for color in [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue] {
            let box = UIView()
            box.backgroundColor = color
            box.layer.cornerRadius = 4
            box.style.width(50).height(50).margin(.horizontal, 6)
            hRow.addSubview(box)
        }

        let label2 = UILabel()
        label2.text = "margin(.horizontal, 6) on each"
        label2.font = .systemFont(ofSize: 11)
        label2.textColor = .secondaryLabel
        label2.style.alignSelf(.center).marginTop(4)
        container.addSubview(label2)

        // Padding example
        let padded = UIView()
        padded.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
        padded.style.width(200).height(60).alignSelf(.center).marginTop(20).padding(.all, 12)
        container.addSubview(padded)

        let innerText = UILabel()
        innerText.text = "padding: 12"
        innerText.font = .systemFont(ofSize: 13)
        innerText.textAlignment = .center
        innerText.backgroundColor = .systemOrange
        innerText.textColor = .white
        innerText.layer.cornerRadius = 4
        innerText.clipsToBounds = true
        padded.addSubview(innerText)
        innerText.style.alignSelf(.center).width(80).height(36)
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
