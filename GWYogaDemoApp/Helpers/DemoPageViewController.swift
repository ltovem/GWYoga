import UIKit
import GWYogaKit

/// Base class for all demo pages — uses YogaLayoutView for layout, no Auto Layout.
@objc(DemoPageViewController)
open class DemoPageViewController: UIViewController {

    /// Subclasses place their demo views here.
    public let contentView = YogaLayoutView()
    private let codeButton = UIButton(type: .system)
    private let descriptionLabel = UILabel()
    private let scrollView = YogaLayoutView()

    /// Override to provide source code shown in the preview.
    open var codeSnippet: String { "" }

    /// Override to provide a description of the demonstrated API.
    open var demoDescription: String { "" }

    open override func loadView() {
        let root = YogaLayoutView()
        root.backgroundColor = .systemBackground
        root.yoga.flexDirection = .column
        view = root
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = title ?? "Demo"

        guard let root = view as? YogaLayoutView else { return }

        // Scroll wrapper
        scrollView.yoga.flexGrow = 1
        root.addSubview(scrollView)

        // Content area
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.yoga.minHeight = .points(200)
        contentView.yoga.margin = [.all: .points(16)]
        scrollView.addSubview(contentView)

        // Code button
        codeButton.setTitle("📋 查看代码", for: .normal)
        codeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        codeButton.backgroundColor = .systemBlue
        codeButton.setTitleColor(.white, for: .normal)
        codeButton.layer.cornerRadius = 10
        codeButton.addTarget(self, action: #selector(showCode), for: .touchUpInside)
        codeButton.yoga.width = 160
        codeButton.yoga.height = 44
        codeButton.yoga.alignSelf = .center
        codeButton.yoga.marginTop(16)
        scrollView.addSubview(codeButton)

        // Description
        descriptionLabel.text = demoDescription
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.yoga.margin = [.horizontal: .points(16), .top: .points(16)]
        scrollView.addSubview(descriptionLabel)
    }

    @objc private func showCode() {
        let pc = CodePreviewViewController(code: codeSnippet, language: "swift")
        present(pc, animated: true)
    }
}
