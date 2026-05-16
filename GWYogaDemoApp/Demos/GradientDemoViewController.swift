import UIKit
import GWYogaKit

class GradientDemoViewController: DemoPageViewController {
    override var demoDescription: String { ".background(.linearGradient(...)) for gradient backgrounds" }
    override var codeSnippet: String { "view.style.background(.linearGradient(colors: [.red, .blue], start: .zero, end: .init(x: 1, y: 0)))" }

    override func viewDidLoad() {
        super.viewDidLoad()
        let info = UILabel()
        info.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        info.numberOfLines = 0
        info.text = "view.style.background(.linearGradient(colors: [.red, .blue], start: .zero, end: .init(x: 1, y: 0)))"
        contentView.addSubview(info)

        let demo = YogaLayoutView()
        demo.yoga.width = .points(200)
        demo.yoga.height = .points(100)
        demo.yoga.marginTop(16)
        contentView.addSubview(demo)

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemRed.cgColor, UIColor.systemBlue.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        gradient.cornerRadius = 8
        demo.layer.insertSublayer(gradient, at: 0)
        demo.layer.cornerRadius = 8
        demo.clipsToBounds = true
    }
}
