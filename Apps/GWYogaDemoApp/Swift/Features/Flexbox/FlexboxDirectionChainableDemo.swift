import UIKit
import GWYoga
import GWYogaKit

class FlexboxDirectionChainableDemo: UIViewController {

    let container = YogaLayoutView()
    let scrollView = UIScrollView()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        scrollView.yog()
            .backgroundColor(.systemGray6)
        view.addChild(scrollView)
        addStyleBadge("链式")
        scrollView.performYogaLayout()
        for _ in 1...3 {
            let label = UILabel()
            label.text = "this is label"
            label.style{
                $0.width(100%)
            }
            scrollView.addChild(label)
        }
        

        container.style
            .flexDirection(.column)
            .rowGap(12)
            .padding(.all, 16)
        scrollView.addChild(container)

        let directions: [(GWFlexDirection, String)] = [
            (.row, "row"),
            (.column, "column"),
            (.rowReverse, "rowReverse"),
            (.columnReverse, "columnReverse"),
        ]

        for (dir, name) in directions {
            let label = UILabel()
            label.text = "flexDirection: .\(name)"
            label.font = .monospacedSystemFont(ofSize: 12, weight: .regular)

            let row = YogaLayoutView()
            row.style
                .flexDirection(dir)
                .padding(.all, 8)
                .cornerRadius(6)
            row.backgroundColor = UIColor.yellow

            for color in [UIColor.systemRed, .systemGreen, .systemBlue, .systemOrange] {
                let box = UIView()
                box.style
                    .width(50).height(40)
                    .margin(.all, 4)
                    .backgroundColor(color)
                    .cornerRadius(4)
                row.addSubview(box)
            }

            container.addSubview(label)
            container.addSubview(row)
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
            badge.frame = CGRect(
                x: view.bounds.width - badge.frame.width - 16,
                y: view.safeAreaLayoutGuide.layoutFrame.minY + 8,
                width: badge.frame.width,
                height: badge.frame.height
            )
        }

        // 1. scrollView 占满 safe area
        let insets = view.safeAreaInsets
        scrollView.frame = CGRect(
            x: insets.left,
            y: insets.top,
            width: view.bounds.width - insets.left - insets.right,
            height: view.bounds.height - insets.top - insets.bottom
        )

        // 2. container 宽度撑满，高度由 Yoga 自动计算（style 没设 height → NaN → content sizing）
        container.frame = CGRect(
            x: 0, y: 0,
            width: scrollView.bounds.width,
            height: 0  // 初始值无所谓，NaN 会覆盖
        )
        container.performYogaLayout()

        // 3. 用计算出的内容高度设置 contentSize
        let contentHeight = container.yoga.frame.height
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: contentHeight + 16)
    }
}
