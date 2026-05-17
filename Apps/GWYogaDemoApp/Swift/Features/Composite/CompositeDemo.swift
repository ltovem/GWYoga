import UIKit
import GWYoga
import GWYogaKit

class CompositeDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("混合")

        let scrollView = UIScrollView()
        scrollView.frame = view.bounds
        view.addSubview(scrollView)

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        scrollView.addSubview(container)

        // Section 1: Chainable
        let s1Title = UILabel()
        s1Title.text = "链式 (Chainable)"
        s1Title.font = .boldSystemFont(ofSize: 15)
        s1Title.textColor = .systemBlue
        s1Title.style.marginBottom(8)
        container.addSubview(s1Title)

        let s1 = UIView()
        s1.backgroundColor = .systemRed
        s1.style.width(80).height(80).cornerRadius(12)
        container.addSubview(s1)

        // Section 2: Closure
        let s2Title = UILabel()
        s2Title.text = "闭包 (Closure)"
        s2Title.font = .boldSystemFont(ofSize: 15)
        s2Title.textColor = .systemGreen
        s2Title.style.marginTop(20).marginBottom(8)
        container.addSubview(s2Title)

        let s2 = UIView()
        s2.style { $0.width = 80; $0.height = 80 }
        s2.backgroundColor = .systemGreen
        s2.layer.cornerRadius = 12
        container.addSubview(s2)

        // Section 3: CSS
        let s3Title = UILabel()
        s3Title.text = "CSS"
        s3Title.font = .boldSystemFont(ofSize: 15)
        s3Title.textColor = .systemOrange
        s3Title.style.marginTop(20).marginBottom(8)
        container.addSubview(s3Title)

        let s3 = UIView()
        s3.style.css("width: 80; height: 80;")
        s3.backgroundColor = .systemOrange
        s3.layer.cornerRadius = 12
        container.addSubview(s3)

        // Flex row using chainable
        let row = YogaLayoutView()
        row.style.flexDirection(.row).justifyContent(.spaceEvenly).padding(.all, 12).marginTop(20).width(100%)
        row.backgroundColor = UIColor.systemGray6
        row.layer.cornerRadius = 8
        container.addSubview(row)

        for color in [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue] {
            let box = UIView()
            box.backgroundColor = color
            box.layer.cornerRadius = 8
            box.style.width(60).height(60)
            row.addSubview(box)
        }

        // Using .yog() proxy
        let yogLabel = UILabel().yog()
            .text(".yog() chain example")
            .font(.italicSystemFont(ofSize: 12))
            .color(.secondaryLabel)
            .alignment(.center)
            .marginTop(16)
            .view
        container.addSubview(yogLabel)

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
