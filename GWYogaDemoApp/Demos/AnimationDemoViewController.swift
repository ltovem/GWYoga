import UIKit
import GWYoga
import GWYogaKit
import GWYogaKitAnimation

class AnimationDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Animation"

        let timingSection = createTimingFunctionSection()
        let animSection = createAnimationConfigSection()
        let transSection = createTransitionSection()

        let stack = UIStackView(arrangedSubviews: [timingSection, animSection, transSection])
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

    private func createTimingFunctionSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "Timing Functions"
        label.font = .boldSystemFont(ofSize: 14)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        • .linear — 匀速
        • .ease — 缓入缓出
        • .easeIn — 缓入
        • .easeOut — 缓出
        • .easeInOut — 缓入缓出
        • .cubicBezier(0.25, 0.1, 0.25, 1.0) — 贝塞尔
        • .steps(4, stepPosition: .end) — 步进
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

    private func createAnimationConfigSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "YogaAnimation 配置"
        label.font = .boldSystemFont(ofSize: 14)

        let anim = YogaAnimation(
            name: "fadeIn",
            duration: 0.3,
            timingFunction: .easeInOut,
            delay: 0.1,
            direction: .normal,
            fillMode: .forwards
        )

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        name: \(anim.name)
        duration: \(anim.duration)s
        delay: \(anim.delay)s
        direction: .normal
        fillMode: .forwards
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

    private func createTransitionSection() -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = "YogaTransition 配置"
        label.font = .boldSystemFont(ofSize: 14)

        let trans = YogaTransition(duration: 0.25, timingFunction: .ease, delay: 0, propertyFilter: .layout)

        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        info.numberOfLines = 0
        info.text = """
        duration: \(trans.duration)s
        delay: \(trans.delay)s
        propertyFilter: .layout
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
