import UIKit
import GWYogaKit
import GWYoga

/// 将 GWYogaNode 树渲染为 UIKit 视图
class YogaLayoutRenderer {
    static let colors: [UIColor] = [
        .systemRed.withAlphaComponent(0.3),
        .systemBlue.withAlphaComponent(0.3),
        .systemGreen.withAlphaComponent(0.3),
        .systemOrange.withAlphaComponent(0.3),
        .systemPurple.withAlphaComponent(0.3),
        .systemTeal.withAlphaComponent(0.3),
        .systemPink.withAlphaComponent(0.3),
        .systemIndigo.withAlphaComponent(0.3),
        .systemYellow.withAlphaComponent(0.3),
        .systemBrown.withAlphaComponent(0.3),
    ]

    /// 计算布局后渲染为 UIView
    static func render(node: GWYogaNode, width: Float = .nan, height: Float = .nan) -> UIView {
        node.calculateLayout(width: width, height: height, direction: .ltr)
        let r = node.layoutResult
        let cw = r.width.isNaN ? 0 : CGFloat(r.width)
        let ch = r.height.isNaN ? 0 : CGFloat(r.height)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: cw, height: ch))
        container.backgroundColor = .systemGray6
        container.layer.borderColor = UIColor.systemBlue.cgColor
        container.layer.borderWidth = 1
        container.layer.cornerRadius = 4
        buildViewHierarchy(parent: container, node: node, depth: 0)
        return container
    }

    @discardableResult
    static func buildViewHierarchy(parent: UIView, node: GWYogaNode, depth: Int) -> UIView {
        let r = node.layoutResult
        let vx = r.left.isNaN ? 0 : CGFloat(r.left)
        let vy = r.top.isNaN ? 0 : CGFloat(r.top)
        let vw = r.width.isNaN ? 0 : CGFloat(r.width)
        let vh = r.height.isNaN ? 0 : CGFloat(r.height)
        let v = UIView(frame: CGRect(x: vx, y: vy, width: vw, height: vh))
        v.backgroundColor = colors[depth % colors.count]
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.4).cgColor
        v.layer.cornerRadius = 2

        let label = UILabel()
        label.text = "\(r.width.isNaN ? 0 : Int(r.width))×\(r.height.isNaN ? 0 : Int(r.height))"
        label.font = .monospacedSystemFont(ofSize: 9, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.frame = v.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.addSubview(label)

        parent.addSubview(v)
        for child in node.children {
            buildViewHierarchy(parent: v, node: child, depth: depth + 1)
        }
        return v
    }

    /// 生成布局信息文字
    static func describe(node: GWYogaNode, indent: Int = 0) -> String {
        let r = node.layoutResult
        let pad = String(repeating: "  ", count: indent)
        let dw = r.width.isNaN ? 0 : Int(r.width)
        let dh = r.height.isNaN ? 0 : Int(r.height)
        let dx = r.left.isNaN ? 0 : Int(r.left)
        let dy = r.top.isNaN ? 0 : Int(r.top)
        var s = "\(pad)\(dw)×\(dh) @(\(dx),\(dy))"
        for c in node.children {
            s += "\n" + describe(node: c, indent: indent + 1)
        }
        return s
    }
}
