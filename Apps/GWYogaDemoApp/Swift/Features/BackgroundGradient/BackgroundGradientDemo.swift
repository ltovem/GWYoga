import UIKit
import GWYoga
import GWYogaKit

class BackgroundGradientDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("链式")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        // Red to blue
        let rbLabel = UILabel()
        rbLabel.text = "Red → Blue"
        rbLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        rbLabel.textColor = .secondaryLabel
        rbLabel.style.marginBottom(4)
        container.addSubview(rbLabel)

        let rb = UIView()
        rb.style.width(200).height(60).marginBottom(16).background(.linearGradient(colors: [.red, .blue], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1)))
        container.addSubview(rb)

        // Multi-color gradient
        let mcLabel = UILabel()
        mcLabel.text = "Multi-color: red → yellow → green"
        mcLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        mcLabel.textColor = .secondaryLabel
        mcLabel.style.marginBottom(4)
        container.addSubview(mcLabel)

        let mc = UIView()
        mc.style.width(200).height(60).marginBottom(16).background(.linearGradient(colors: [.red, .yellow, .green], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 0)))
        container.addSubview(mc)

        // Top to bottom
        let tbLabel = UILabel()
        tbLabel.text = "Top → Bottom (purple → orange)"
        tbLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        tbLabel.textColor = .secondaryLabel
        tbLabel.style.marginBottom(4)
        container.addSubview(tbLabel)

        let tb = UIView()
        tb.style.width(200).height(60).background(.linearGradient(colors: [.purple, .orange], startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 0.5, y: 1)))
        container.addSubview(tb)
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
