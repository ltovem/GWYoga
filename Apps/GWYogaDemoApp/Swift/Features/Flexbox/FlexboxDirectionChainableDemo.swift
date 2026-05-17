import UIKit
import GWYoga
import GWYogaKit

class FlexboxDirectionChainableDemo: UIViewController {

    // MARK: - 自动脏标记演示（已有）

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

    // MARK: - 数据绑定演示

    @YogaState private var bindWidth: GWValue = 50%       // subView 宽度百分比
    @YogaState private var bindMargin: CGFloat = 16        // subView margin

    private let binding = YogaBinding()
    private let widthSlider = UISlider()
    private let marginSlider = UISlider()
    private let widthLabel = UILabel()
    private let marginLabel = UILabel()
    private let controlPanel = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupAutoMarkDirtyDemo()
        setupDataBindingDemo()
        applyBindings()
    }

    // MARK: - 自动脏标记演示

    private func setupAutoMarkDirtyDemo() {
        // thisview: 100% × 100% 撑满父容器
        thisview.backgroundColor = UIColor.red
        thisview.style.width(100%).height(100%)
        view.addChild(thisview)

        // subView: 50% 宽，高度由内容决定（自适应）
        subView.backgroundColor = UIColor.yellow
        subView.style.width(50%).margin(.all, 100)
        thisview.addChild(subView)

        // 信息标签
        infoLabel.textColor = .white
        infoLabel.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.style.alignSelf(.center).top(20)
        thisview.addChild(infoLabel)

        // 普通文本
        plainLabel.text = shortText
        plainLabel.font = .systemFont(ofSize: 18)
        plainLabel.numberOfLines = 0
        plainLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        plainLabel.layer.cornerRadius = 8
        plainLabel.clipsToBounds = true
        plainLabel.yoga.isIntrinsic = true
        plainLabel.style.padding(.all, 0).flexShrink(1)
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

    // MARK: - 数据绑定演示

    private func setupDataBindingDemo() {
        // 控制面板 — 放在 thisview 底部（绝对定位）
        controlPanel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.85)
        controlPanel.layer.cornerRadius = 12
        controlPanel.style.position(.absolute).left(12).right(12).bottom(40).padding(.all, 12)
        thisview.addChild(controlPanel)

        let panelTitle = UILabel()
        panelTitle.text = "数据绑定 ( @YogaState → style )"
        panelTitle.font = .boldSystemFont(ofSize: 13)
        panelTitle.textColor = .white
        panelTitle.style.alignSelf(.center).marginBottom(8)
        controlPanel.addSubview(panelTitle)

        // 宽度行
        let widthRow = UIView()
        widthRow.style.flexDirection(.row).alignItems(.center).marginBottom(6)
        controlPanel.addSubview(widthRow)

        widthLabel.text = "width: 50%"
        widthLabel.font = .monospacedSystemFont(ofSize: 12)
        widthLabel.textColor = UIColor.systemOrange
        widthLabel.style.width(90)
        widthRow.addSubview(widthLabel)

        widthSlider.minimumValue = 10
        widthSlider.maximumValue = 100
        widthSlider.value = 50
        widthSlider.tintColor = .systemOrange
        widthSlider.addTarget(self, action: #selector(widthSliderChanged), for: .valueChanged)
        widthRow.addChild(widthSlider)

        // margin 行
        let marginRow = UIView()
        marginRow.style.flexDirection(.row).alignItems(.center)
        controlPanel.addSubview(marginRow)

        marginLabel.text = "margin: 16"
        marginLabel.font = .monospacedSystemFont(ofSize: 12)
        marginLabel.textColor = UIColor.systemGreen
        marginLabel.style.width(90)
        marginRow.addSubview(marginLabel)

        marginSlider.minimumValue = 0
        marginSlider.maximumValue = 80
        marginSlider.value = 16
        marginSlider.tintColor = .systemGreen
        marginSlider.addTarget(self, action: #selector(marginSliderChanged), for: .valueChanged)
        marginRow.addChild(marginSlider)
    }

    private func applyBindings() {
        // @YogaState 绑定到 subView 的样式属性
        // 拖动 slider → @YogaState 变化 → 自动更新 style → 触发 yoga 重排
        binding
            .bind($bindWidth) { [weak self] newWidth in
                self?.subView.style.width = newWidth
                self?.widthLabel.text = "width: \(Int(newWidth.value))%"
            }
            .bind($bindMargin) { [weak self] newMargin in
                self?.subView.style.setMargin(.all, .points(Float(newMargin)))
                self?.marginLabel.text = "margin: \(Int(newMargin))"
            }
    }

    @objc private func widthSliderChanged(_ sender: UISlider) {
        bindWidth = GWValue.percent(Double(round(sender.value)))
    }

    @objc private func marginSliderChanged(_ sender: UISlider) {
        bindMargin = CGFloat(round(sender.value))
    }

    // MARK: - 已有方法

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
        tapButton.setTitle(isLongText ? "切换到短文本" : "切换到长文本", for: .normal)
        infoLabel.text = "已切换 \(toggleCount) 次"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tf = thisview.frame
        let sf = subView.frame
        infoLabel.text = "thisview: \(Int(tf.width))×\(Int(tf.height))\nsubView: \(Int(sf.width))×\(Int(sf.height)) @ (\(Int(sf.minX)),\(Int(sf.minY)))"
        print("thisview.frame=\(tf) subView.frame=\(sf)")
    }
}
