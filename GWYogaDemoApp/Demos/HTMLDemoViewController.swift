import UIKit
import GWYogaKit
import GWYogaKitHTML

class HtmlDemoViewController: DemoPageViewController {
    override var demoDescription: String { "HTML-like tags: div, h1-h3, p, section, header, footer, row, html" }
    override var codeSnippet: String { "div { h1(\"T\"); p(\"C\") }\nsection { h2(\"S\"); row { } }\nheader { h3(\"Logo\") }" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "div { h1(\"T\"); p(\"C\") }\nsection { h2(\"S\"); row { } }\nheader { h3(\"Logo\") }"
        contentView.addSubview(info)
    }
}
