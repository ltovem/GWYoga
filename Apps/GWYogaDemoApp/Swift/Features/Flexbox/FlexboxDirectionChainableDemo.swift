import UIKit
import GWYoga
import GWYogaKit

class FlexboxDirectionChainableDemo: UIViewController {

    let thisview = UIView()
    let subView = UIView()
    let infoLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // thisview: 100% × 100% 撑满父容器
        thisview.backgroundColor = UIColor.red
        thisview.style.width(100%).height(100%)
        view.addChild(thisview)

        // subView: 50% × 50% 居中
        subView.backgroundColor = UIColor.yellow
        subView.style.width(50%).height(50%)
        thisview.addChild(subView)

        // 信息标签
        infoLabel.textColor = .white
        infoLabel.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.style.alignSelf(.center).top(20)
        thisview.addChild(infoLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tf = thisview.frame
        let sf = subView.frame
        infoLabel.text = "thisview: \(Int(tf.width))×\(Int(tf.height))\nsubView: \(Int(sf.width))×\(Int(sf.height)) @ (\(Int(sf.minX)),\(Int(sf.minY)))"
        print("thisview.frame=\(tf) subView.frame=\(sf)")
    }
}
