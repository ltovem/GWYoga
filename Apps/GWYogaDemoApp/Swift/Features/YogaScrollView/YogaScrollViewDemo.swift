import UIKit
import GWYoga
import GWYogaKit

class YogaScrollViewDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("链式")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16)
        view.addSubview(container)

        let label = UILabel()
        label.text = "ScrollView with Yoga content"
        label.font = .boldSystemFont(ofSize: 14)
        label.style.marginBottom(12)
        container.addSubview(label)

        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.systemGray6
        scrollView.layer.cornerRadius = 8
        scrollView.style.width(100%).height(300)
        container.addSubview(scrollView)

        let content = YogaLayoutView()
        content.style.width(100%).flexDirection(.column).padding(.all, 12)
        scrollView.addSubview(content)

        for i in 0..<10 {
            let row = UIView()
            row.backgroundColor = UIColor(hue: CGFloat(i) / 10, saturation: 0.5, brightness: 0.9, alpha: 1)
            row.layer.cornerRadius = 6
            row.style.width(100%).height(50).marginBottom(8)
            content.addSubview(row)

            let rowLabel = UILabel()
            rowLabel.text = "Item \(i + 1)"
            rowLabel.textColor = .white
            rowLabel.font = .boldSystemFont(ofSize: 16)
            rowLabel.style.marginLeft(12).alignSelf(.center)
            row.addSubview(rowLabel)
        }

        DispatchQueue.main.async {
            content.performYogaLayout()
            scrollView.contentSize = content.frame.size
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
