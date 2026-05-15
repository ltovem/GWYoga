import UIKit
import GWYoga
import GWYogaKit
import GWYogaKitStylesheet

class StylesheetDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stylesheet"

        let views: [UIView] = [
            createParseSection(),
            createMergeSection(),
            createSelectorSection(),
            createMapperSection(),
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

    private func createParseSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "CSS 解析"
        label.font = .boldSystemFont(ofSize: 14)

        let css = """
        .container {
          display: flex;
          flex-direction: row;
          padding: 16px;
        }
        """
        let sheet = try? YogaStylesheet.parse(css)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        输入 CSS:
        \(css)
        规则数: \(sheet?.rules.count ?? 0)
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

    private func createMergeSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "Stylesheet 合并"
        label.font = .boldSystemFont(ofSize: 14)

        let sheet1 = (try? YogaStylesheet.parse(".box { width: 100px; }")) ?? YogaStylesheet(rules: [])
        let sheet2 = (try? YogaStylesheet.parse(".box { height: 50px; }")) ?? YogaStylesheet(rules: [])
        let merged = YogaStylesheet.merge(sheet1, sheet2)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        Sheet1: .box { width: 100px; }
        Sheet2: .box { height: 50px; }
        合并后规则数: \(merged.rules.count)
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

    private func createSelectorSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "CSS 选择器特异性"
        label.font = .boldSystemFont(ofSize: 14)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        .container — class: specificity=1000
        #header — id: specificity=1000000
        div.container — type+class: specificity=1001
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

    private func createMapperSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "CSS 属性映射"
        label.font = .boldSystemFont(ofSize: 14)

        let preview = YogaLayoutView(frame: .zero)
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.yoga.width = .points(200)
        preview.yoga.height = .points(40)
        preview.yoga.flexDirection = .row
        preview.backgroundColor = .systemGray6
        preview.layer.borderWidth = 1
        preview.layer.borderColor = UIColor.systemBlue.cgColor

        YogaCSSPropertyMapper.apply(property: "width", value: "100px", to: preview.yoga)
        YogaCSSPropertyMapper.apply(property: "background-color", value: "red", to: preview.yoga)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        通过 YogaCSSPropertyMapper 将 CSS 属性映射到 YogaProperties:
        apply(property: "width", value: "100px")
        apply(property: "background-color", value: "red")
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
            info.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 4),
            info.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: section.trailingAnchor),
            info.bottomAnchor.constraint(equalTo: section.bottomAnchor),
        ])
        return section
    }
}
