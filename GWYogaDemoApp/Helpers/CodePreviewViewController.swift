import UIKit
import GWYogaKit

/// Modal that displays source code — uses YogaLayoutView, no Auto Layout.
@objc(CodePreviewViewController)
open class CodePreviewViewController: UIViewController {

    private let textView = UITextView()
    private let code: String
    private let language: String

    @objc public init(code: String, language: String = "swift") {
        self.code = code
        self.language = language
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    public required init?(coder: NSCoder) { nil }

    open override func loadView() {
        let root = YogaLayoutView()
        root.backgroundColor = .systemBackground
        root.yoga.flexDirection = .column
        view = root
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        guard let root = view as? YogaLayoutView else { return }

        // Nav bar area with close + copy
        let navBar = UIView()
        navBar.yoga.flexDirection = .row
        navBar.yoga.justifyContent = .spaceBetween
        navBar.yoga.padding = [.horizontal: .points(16), .vertical: .points(8)]
        navBar.yoga.height = 44

        let closeBtn = UIButton(type: .close)
        closeBtn.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        navBar.addSubview(closeBtn)

        let titleLabel = UILabel()
        titleLabel.text = language.uppercased()
        titleLabel.font = .boldSystemFont(ofSize: 16)
        navBar.addSubview(titleLabel)

        let copyBtn = UIButton(type: .system)
        copyBtn.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copyBtn.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
        navBar.addSubview(copyBtn)

        root.addSubview(navBar)

        // Code text view
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.text = code
        textView.isEditable = false
        textView.backgroundColor = .systemGray6
        textView.textColor = .label
        textView.yoga.flexGrow = 1
        textView.yoga.margin = [.horizontal: .points(8)]
        root.addSubview(textView)
    }

    @objc private func dismissSelf() { dismiss(animated: true) }

    @objc private func copyCode() {
        UIPasteboard.general.string = code
        let alert = UIAlertController(title: nil, message: "Copied!", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { alert.dismiss(animated: true) }
    }
}
