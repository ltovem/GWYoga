import UIKit
import GWYogaKit
import GWYogaKitDSL

class ControlsDemoViewController: DemoPageViewController {
    override var demoDescription: String { "YogaText, YogaImage, YogaButton, YogaSpacer, YogaDivider DSL controls" }
    override var codeSnippet: String { "YogaText(\"Hello\")\nYogaImage(image)\nYogaButton(\"Tap\")\nYogaSpacer(minLength: 10)\nYogaDivider()" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "YogaText(\"Hello\")\nYogaImage(image)\nYogaButton(\"Tap\")\nYogaSpacer(minLength: 10)\nYogaDivider()"
        contentView.addSubview(info)
    }
}
