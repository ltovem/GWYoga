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
            .width(100%)
            .height(200%)
            .backgroundColor(.systemGray6)
        view.addChild(scrollView)
        addStyleBadge("链式")

//        view.performYogaLayout()
        scrollView.frame = view.bounds;
        
//        view.appl
        container.style
            .flexDirection(.column)
            .rowGap(12)
            .padding(.all, 16)
        scrollView.addSubview(container)

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

        let top = view.safeAreaInsets.top
        let bottom = view.safeAreaInsets.bottom
        

        // container: 宽度撑满 scrollView，高度由 Yoga 自动计算
        container.frame = CGRect(
            x: 0, y: 0,
            width: scrollView.bounds.width - 32,
            height: 0
        )
        container.performYogaLayout()

        let contentHeight = container.yoga.frame.height
        container.frame = CGRect(
            x: 16, y: 0,
            width: scrollView.bounds.width - 32,
            height: contentHeight
        )
        container.performYogaLayout()
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: contentHeight + 16)
    }
}
