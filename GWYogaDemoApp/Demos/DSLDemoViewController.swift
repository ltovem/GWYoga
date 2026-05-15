import UIKit
import GWYoga
import GWYogaKit
import GWYogaKitDSL

class DSLDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DSL"

        let views: [UIView] = [
            createStackSection(title: "YogaVStack", stack: {
                YogaVStack(spacing: 8, alignment: .center) {
                    YogaText("Item A")
                    YogaText("Item B")
                    YogaText("Item C")
                }
            }()),
            createStackSection(title: "YogaHStack", stack: {
                YogaHStack(spacing: 12, alignment: .center) {
                    YogaText("Left")
                    YogaText("Center")
                    YogaText("Right")
                }
            }()),
            createStackSection(title: "YogaZStack", stack: {
                YogaZStack(alignment: .center) {
                    YogaText("Back")
                    YogaText("Front")
                }
            }()),
            createStackSection(title: "YogaScrollView", stack: {
                let scroll = YogaScrollView(axis: .vertical) {
                    YogaText("Scroll content line 1")
                    YogaText("Scroll content line 2")
                    YogaText("Scroll content line 3")
                }
                scroll.yoga.height = .points(120)
                return scroll
            }()),
            createControlSection(),
            createModifierSection(),
        ]

        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 32
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
        ])
    }

    private func createStackSection(title: String, stack: UIView) -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 14)

        stack.translatesAutoresizingMaskIntoConstraints = false

        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.layer.borderWidth = 1
        border.layer.borderColor = UIColor.systemBlue.cgColor
        border.layer.cornerRadius = 4
        border.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: border.topAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: border.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: border.trailingAnchor, constant: -4),
            stack.bottomAnchor.constraint(equalTo: border.bottomAnchor, constant: -4),
        ])

        [label, border].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            section.addSubview($0)
        }
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: section.topAnchor),
            label.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            border.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            border.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: section.bottomAnchor),
        ])
        return section
    }

    private func createControlSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "DSL Controls"
        label.font = .boldSystemFont(ofSize: 14)

        let spacer = YogaSpacer(minLength: 10)
        spacer.translatesAutoresizingMaskIntoConstraints = false

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        YogaText("Hello") — 文本控件
        YogaImage(nil) — 图片控件
        YogaButton("Tap") — 按钮控件
        YogaSpacer(minLength: 10) — 弹性空白
        YogaDivider() — 分割线
        """

        [label, info].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            section.addSubview($0)
        }
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: section.topAnchor),
            label.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            info.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            info.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            info.bottomAnchor.constraint(equalTo: section.bottomAnchor),
        ])
        return section
    }

    private func createModifierSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "链式 Modifier"
        label.font = .boldSystemFont(ofSize: 14)

        let text = YogaText("Modified Text")
            .padding(.all, value: .points(12))
            .flexGrow(1)
            .backgroundColor(.lightGray)
            .cornerRadius(8)

        let preview = UIView()
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.layer.borderWidth = 1
        preview.layer.borderColor = UIColor.systemBlue.cgColor
        preview.layer.cornerRadius = 4
        text.translatesAutoresizingMaskIntoConstraints = false
        preview.addSubview(text)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        链式 Modifier 示例:
        .padding(.all, .points(12))
        .flexGrow(1)
        .backgroundColor(.lightGray)
        .cornerRadius(8)
        """

        [label, preview, info].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            section.addSubview($0)
        }
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: section.topAnchor),
            label.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            preview.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            preview.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            preview.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            preview.heightAnchor.constraint(equalToConstant: 60),
            info.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 4),
            info.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            info.bottomAnchor.constraint(equalTo: section.bottomAnchor),
        ])
        return section
    }
}
