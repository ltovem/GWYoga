import UIKit
import GWYoga
import GWYogaKit

class ShadowDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("链式")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        // Default shadow
        let defLabel = UILabel()
        defLabel.text = "default shadow"
        defLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        defLabel.textColor = .secondaryLabel
        defLabel.style.marginBottom(4)
        container.addSubview(defLabel)

        let def = UIView()
        def.backgroundColor = .white
        def.style.width(120).height(60).shadow().marginBottom(20).cornerRadius(8)
        container.addSubview(def)

        // Custom shadow
        let cusLabel = UILabel()
        cusLabel.text = "shadow(color: .red, radius: 8, offset: (0,4))"
        cusLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        cusLabel.textColor = .secondaryLabel
        cusLabel.style.marginBottom(4)
        container.addSubview(cusLabel)

        let cus = UIView()
        cus.backgroundColor = .white
        cus.style.width(120).height(60).shadow(color: .red, opacity: 0.4, radius: 8, offset: CGSize(width: 0, height: 4)).marginBottom(20).cornerRadius(8)
        container.addSubview(cus)

        // YogaShadow struct
        let ysLabel = UILabel()
        ysLabel.text = "YogaShadow { color: .blue, radius: 6 }"
        ysLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        ysLabel.textColor = .secondaryLabel
        ysLabel.style.marginBottom(4)
        container.addSubview(ysLabel)

        let ys = UIView()
        ys.backgroundColor = .white
        let shadow = YogaShadow(color: .blue, opacity: 0.5, radius: 6, offset: CGSize(width: 2, height: 2))
        ys.style.width(120).height(60).shadow(shadow).cornerRadius(8)
        container.addSubview(ys)
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
