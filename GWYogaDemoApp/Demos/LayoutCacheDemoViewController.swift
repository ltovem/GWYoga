import UIKit
import GWYoga
import GWYogaKit
import GWYogaKitLayoutCache

class LayoutCacheDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Layout Cache"

        let views: [UIView] = [
            createPreMeasureSection(),
            createCacheInvalidationSection(),
            createBatchMeasureSection(),
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

    private func createPreMeasureSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "预测量 (PreLayout)"
        label.font = .boldSystemFont(ofSize: 14)

        let testLabel = UILabel()
        testLabel.text = "Hello Layout Cache"
        testLabel.font = .systemFont(ofSize: 16)

        let pre = testLabel.yoga.measurement
        let size = pre.measure(width: 200)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        UILabel 测量 (width=200):
        width = \(size.width)
        height = \(size.height)
        通过 testLabel.yoga.measurement.measure(width:) 获取
        不触发实际布局，结果被缓存
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

    private func createCacheInvalidationSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "缓存失效 (invalidateCache)"
        label.font = .boldSystemFont(ofSize: 14)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        当视图内容变化时（如文本变更），调用:
        view.yoga.measurement.invalidateCache()
        下次 measure 将重新计算而非使用缓存结果。
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

    private func createBatchMeasureSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "批量测量 (measureAll)"
        label.font = .boldSystemFont(ofSize: 14)

        let label1 = UILabel()
        label1.text = "Short"

        let label2 = UILabel()
        label2.text = "A longer text"

        let sizes = YogaPreLayout.measureAll([label1, label2], width: 150)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        批量测量两个 UILabel (width=150):
        "Short" → w=\(sizes[0].width) h=\(sizes[0].height)
        "A longer text" → w=\(sizes[1].width) h=\(sizes[1].height)
        通过 YogaPreLayout.measureAll([views], width:) 一次测量
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
}
