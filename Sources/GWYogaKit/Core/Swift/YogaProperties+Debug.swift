import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - YogaProperties 调试工具

extension YogaProperties {

    /// 打印布局树：从当前视图开始递归输出所有子节点的类名、frame 和 cssID。
    ///
    /// ```
    /// view.style.debugPrint()
    /// // YogaLayoutView (300×600 @0,0)
    /// //   ├─ UILabel   (300×44  @0,0)   "title"
    /// //   └─ UIButton  (300×40  @0,560)
    /// ```
    public func debugPrint() {
        print(buildTreeString(view: view, indent: ""))
    }

    /// 为当前视图添加调试边框（便于在布局阶段观察视图位置和大小）。
    ///
    /// - Parameters:
    ///   - color: 边框颜色（默认红色）
    ///   - width: 边框宽度（默认 1）
    @discardableResult
    public func debugBorder(color: PlatformColor = .red, width: CGFloat = 1) -> Self {
        #if os(iOS) || os(tvOS)
        view?.layer.borderColor = color.cgColor
        view?.layer.borderWidth = width
        #elseif os(macOS)
        view?.layer?.borderColor = color.cgColor
        view?.layer?.borderWidth = width
        #endif
        return self
    }

    /// 使用 Yoga 引擎计算当前节点的布局尺寸。
    ///
    /// - Parameters:
    ///   - width: 可用宽度（默认 undefined）
    ///   - height: 可用高度（默认 undefined）
    /// - Returns: 计算后的尺寸
    public func systemLayoutSize(width: Float = .nan, height: Float = .nan) -> CGSize {
        node.calculateLayout(width: width, height: height)
        let r = node.layoutResult
        return CGSize(width: CGFloat(r.width), height: CGFloat(r.height))
    }

    // MARK: - 内部

    private func buildTreeString(view: YKLView?, indent: String, isLast: Bool = true) -> String {
        guard let v = view else { return "" }

        let className = "\(type(of: v))"
        let frame = v.frame
        let size = "\(Int(frame.width))×\(Int(frame.height)) @\(Int(frame.origin.x)),\(Int(frame.origin.y))"

        var label = ""
        let cssId = v.yoga.cssID
        if let cssId = cssId {
            label = "   \"\(cssId)\""
        }

        let line = "\(indent)\(isLast ? "└─ " : "├─ ")\(className) (\(size))\(label)"

        let children = v.subviews
        var result = line
        for (index, child) in children.enumerated() {
            let childIsLast = index == children.count - 1
            let childIndent = indent + (isLast ? "    " : "   │")
            result += "\n" + buildTreeString(view: child, indent: childIndent, isLast: childIsLast)
        }
        return result
    }
}
