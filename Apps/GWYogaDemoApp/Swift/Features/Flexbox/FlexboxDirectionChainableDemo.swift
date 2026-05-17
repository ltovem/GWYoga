import UIKit
import GWYoga
import GWYogaKit

class FlexboxDirectionChainableDemo: UIViewController {

    let thisview = UIView()
    let subView = UIView()
    let infoLabel = UILabel()

    // 文本变化测试
    private let plainLabel = UILabel()
    private let richLabel = UILabel()
    private let tapButton = UIButton(type: .system)
    private let longText = "Yoga 布局引擎自动适应文本内容尺寸变化，无需手动调整 frame。"
    private let shortText = "自适应文本"
    private var isLongText = false
    private var toggleCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // thisview: 100% × 100% 撑满父容器
        thisview.backgroundColor = UIColor.red
        thisview.style.width(100%).height(100%)
        view.addChild(thisview)

        // subView: 50% × 50% 居中
        subView.backgroundColor = UIColor.yellow
        subView.style.width(50%).height(50%)
        thisview.addChild(subView)

        // 信息标签
        infoLabel.textColor = .white
        infoLabel.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.style.alignSelf(.center).top(20)
        thisview.addChild(infoLabel)

        // ── 文本变化测试 ──

        // 普通文本
        plainLabel.text = shortText
        plainLabel.font = .systemFont(ofSize: 18)
        plainLabel.numberOfLines = 0
        plainLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        plainLabel.layer.cornerRadius = 8
        plainLabel.clipsToBounds = true
        plainLabel.yoga.isIntrinsic = true
        plainLabel.style.padding(.all, 8).flexShrink(1)
        subView.addSubview(plainLabel)

        // 富文本
        richLabel.numberOfLines = 0
        richLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        richLabel.layer.cornerRadius = 8
        richLabel.clipsToBounds = true
        richLabel.yoga.isIntrinsic = true
        richLabel.style.padding(.all, 8).flexShrink(1)
        updateAttributedText()
        subView.addSubview(richLabel)

        // 触发按钮
        tapButton.setTitle("切换文本", for: .normal)
        tapButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        tapButton.backgroundColor = .systemBlue
        tapButton.setTitleColor(.white, for: .normal)
        tapButton.layer.cornerRadius = 12
        tapButton.style.padding(.horizontal, 16).padding(.vertical, 10).alignSelf(.center).marginTop(12)
        tapButton.addTarget(self, action: #selector(didTapToggle), for: .touchUpInside)
        subView.addSubview(tapButton)
    }

    private func updateAttributedText() {
        let text = isLongText ? longText : shortText
        let attr = NSMutableAttributedString(string: text)
        attr.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 18), range: NSRange(location: 0, length: attr.length))
        attr.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSRange(location: 0, length: attr.length))

        if isLongText {
            let highlightRange = (text as NSString).range(of: "Yoga")
            attr.addAttribute(.backgroundColor, value: UIColor.systemYellow.withAlphaComponent(0.4), range: highlightRange)
            attr.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: highlightRange)
        }
        richLabel.attributedText = attr
    }

    @objc private func didTapToggle() {
        isLongText.toggle()
        toggleCount += 1

        plainLabel.text = isLongText ? longText : shortText
        updateAttributedText()
        infoLabel.text = "已切换 \(toggleCount) 次"

        // 通知 yoga 内容已变化，需重新测量
        plainLabel.style.markDirty()
        richLabel.style.markDirty()
        view.performYogaLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tf = thisview.frame
        let sf = subView.frame
        infoLabel.text = "thisview: \(Int(tf.width))×\(Int(tf.height))\nsubView: \(Int(sf.width))×\(Int(sf.height)) @ (\(Int(sf.minX)),\(Int(sf.minY)))"
        print("thisview.frame=\(tf) subView.frame=\(sf)")
    }
}
