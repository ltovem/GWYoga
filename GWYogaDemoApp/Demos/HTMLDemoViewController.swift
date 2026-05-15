import UIKit
import GWYoga
import GWYogaKit
import GWYogaKitDSL
import GWYogaKitHTML

class HTMLDemoViewController: BaseDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HTML Tags"

        let views: [UIView] = [
            createSection(title: "div { h1, p }") {
                let container = div {
                    h1("Page Title")
                        .padding(.all, value: .points(8))
                    p("This is a paragraph of text.")
                        .padding(.horizontal, value: .points(8))
                }
                container.yoga.width = .points(300)
                container.backgroundColor = .systemGray6
                container.layer.borderWidth = 1
                container.layer.borderColor = UIColor.systemBlue.cgColor
                container.layer.cornerRadius = 4
                return container
            },
            createSection(title: "section { row { ... } }") {
                let container = section {
                    h2("Section Title")
                    row {
                        YogaText("Col 1")
                        YogaText("Col 2")
                        YogaText("Col 3")
                    }
                }
                container.yoga.width = .points(300)
                container.backgroundColor = .systemGray6
                container.layer.borderWidth = 1
                container.layer.borderColor = UIColor.systemBlue.cgColor
                container.layer.cornerRadius = 4
                return container
            },
            createSection(title: "header + footer") {
                let container = div {
                    header {
                        h3("Header Logo")
                    }
                    p("Main content area")
                    footer {
                        p("Copyright 2026")
                    }
                }
                container.yoga.width = .points(300)
                container.backgroundColor = .systemGray6
                container.layer.borderWidth = 1
                container.layer.borderColor = UIColor.systemBlue.cgColor
                container.layer.cornerRadius = 4
                return container
            },
            createSection(title: "html { head, body }") {
                let container = html {
                    h1("Document Title")
                    p("Document body text here.")
                }
                container.yoga.width = .points(300)
                container.backgroundColor = .systemGray6
                container.layer.borderWidth = 1
                container.layer.borderColor = UIColor.systemBlue.cgColor
                container.layer.cornerRadius = 4
                return container
            },
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

    private func createSection(title: String, build: () -> UIView) -> UIView {
        let section = UIView()
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 14)

        let preview = build()
        preview.translatesAutoresizingMaskIntoConstraints = false

        [label, preview].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            section.addSubview($0)
        }
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: section.topAnchor),
            label.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            preview.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            preview.leadingAnchor.constraint(equalTo: section.leadingAnchor),
            preview.bottomAnchor.constraint(equalTo: section.bottomAnchor),
        ])
        return section
    }
}
