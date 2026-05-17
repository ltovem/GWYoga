import UIKit
import GWYoga
import GWYogaKit

class DebugPrintDemo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addStyleBadge("混合")

        let container = YogaLayoutView()
        container.style.width(100%).padding(.all, 16).flexDirection(.column)
        view.addSubview(container)

        let label = UILabel()
        label.text = "Node Tree Debug"
        label.font = .boldSystemFont(ofSize: 14)
        label.style.marginBottom(12)
        container.addSubview(label)

        // Build a tree
        let root = YogaLayoutView()
        root.style.flexDirection(.row).justifyContent(.center).padding(.all, 12).width(100%)
        root.backgroundColor = UIColor.systemGray6
        root.layer.cornerRadius = 8
        container.addSubview(root)

        let left = YogaLayoutView()
        left.style.width(80).height(80).marginRight(12)
        left.backgroundColor = .systemRed
        left.layer.cornerRadius = 6
        root.addSubview(left)

        let right = YogaLayoutView()
        right.style.flexDirection(.column).flex(1).height(80)
        right.backgroundColor = .systemBlue
        right.layer.cornerRadius = 6
        root.addSubview(right)

        let top = YogaLayoutView()
        top.style.flex(1)
        top.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        right.addSubview(top)

        let bottom = YogaLayoutView()
        bottom.style.flex(1)
        bottom.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        right.addSubview(bottom)

        // Debug output
        let debugBtn = UIButton(type: .system)
        debugBtn.setTitle("打印节点树 (查看控制台)", for: .normal)
        debugBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        debugBtn.backgroundColor = .systemBlue
        debugBtn.setTitleColor(.white, for: .normal)
        debugBtn.layer.cornerRadius = 8
        debugBtn.style.width(240).height(40).alignSelf(.center).marginTop(20)
        debugBtn.addTarget(self, action: #selector(didTapDebug), for: .touchUpInside)
        container.addSubview(debugBtn)

        let infoLabel = UILabel()
        infoLabel.text = "点击按钮，在 Xcode 控制台查看\nYoga 节点树的 debug 输出"
        infoLabel.font = .systemFont(ofSize: 12)
        infoLabel.textColor = .secondaryLabel
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.style.alignSelf(.center).marginTop(8)
        container.addSubview(infoLabel)
    }

    @objc func didTapDebug() {
        // Force layout then print
        self.view.subviews.compactMap { $0 as? YogaLayoutView }.forEach { $0.performYogaLayout() }
        if let firstChild = self.view.subviews.first as? YogaLayoutView {
            print("\n=== GWYoga Node Tree ===")
            firstChild.yoga.debugPrint()
            print("=======================\n")
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
