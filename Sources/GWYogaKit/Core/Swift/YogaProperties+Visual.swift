import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit

extension CACornerMask: Hashable {}

// MARK: - 视觉样式核心结构

/// 背景样式枚举
public enum YogaBackground {
    case color(UIColor)
    case linearGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1))
    case image(UIImage, contentMode: UIView.ContentMode = .scaleAspectFill)
}

/// 阴影样式
public struct YogaShadow {
    public var color: UIColor
    public var opacity: Float
    public var radius: CGFloat
    public var offset: CGSize

    public init(color: UIColor = .black, opacity: Float = 0.3, radius: CGFloat = 4, offset: CGSize = CGSize(width: 0, height: 2)) {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }
}

// MARK: - 圆角配置

/// 圆角配置，支持指定角
public struct YogaCornerRadii {
    public var topLeft: CGFloat
    public var topRight: CGFloat
    public var bottomLeft: CGFloat
    public var bottomRight: CGFloat

    public static let zero = YogaCornerRadii(topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0)

    public init(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    public init(all value: CGFloat) {
        self.init(topLeft: value, topRight: value, bottomLeft: value, bottomRight: value)
    }

    public init(_ dict: [CACornerMask: CGFloat]) {
        self = .zero
        for (key, value) in dict {
            switch key {
            case .layerMinXMinYCorner: topLeft = value
            case .layerMaxXMinYCorner: topRight = value
            case .layerMinXMaxYCorner: bottomLeft = value
            case .layerMaxXMaxYCorner: bottomRight = value
            default: break
            }
        }
    }
}

// MARK: - YogaProperties 视觉样式扩展

extension YogaProperties {

    // MARK: 背景色

    /// 背景色（直接设置 UIView.backgroundColor）
    @discardableResult
    public func backgroundColor(_ color: UIColor?) -> Self {
        view?.backgroundColor = color
        return self
    }

    // MARK: 背景样式（渐变 / 图片）

    /// 背景样式（颜色 / 渐变色 / 图片）
    @discardableResult
    public func background(_ background: YogaBackground) -> Self {
        guard let v = view else { return self }
        // 移除已有背景图层
        removeBackgroundLayers(from: v)

        switch background {
        case .color(let color):
            v.backgroundColor = color

        case .linearGradient(let colors, let startPoint, let endPoint):
            v.backgroundColor = .clear
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors.map { $0.cgColor }
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            gradientLayer.frame = v.bounds
            gradientLayer.name = "gw_yoga_gradient"
            v.layer.insertSublayer(gradientLayer, at: 0)

        case .image(let image, let contentMode):
            v.backgroundColor = .clear
            let imageLayer = CALayer()
            imageLayer.contents = image.cgImage
            imageLayer.contentsGravity = contentMode.toCAGravity
            imageLayer.frame = v.bounds
            imageLayer.name = "gw_yoga_bgimage"
            v.layer.insertSublayer(imageLayer, at: 0)
        }
        return self
    }

    private func removeBackgroundLayers(from view: UIView) {
        view.layer.sublayers?.removeAll { layer in
            layer.name == "gw_yoga_gradient" || layer.name == "gw_yoga_bgimage"
        }
    }

    // MARK: 圆角

    /// 统一设置所有角的圆角半径
    @discardableResult
    public func cornerRadius(_ radius: CGFloat) -> Self {
        guard let v = view else { return self }
        v.layer.cornerRadius = radius
        v.layer.masksToBounds = radius > 0
        return self
    }

    /// 按角分别设置圆角半径
    /// ```
    /// view.style.cornerRadius([.topLeft: 12, .topRight: 12])
    /// ```
    @discardableResult
    public func cornerRadius(_ radii: YogaCornerRadii) -> Self {
        guard let v = view else { return self }
        // 取最大值作为 layer.cornerRadius
        let maxR = max(radii.topLeft, radii.topRight, radii.bottomLeft, radii.bottomRight)
        v.layer.cornerRadius = maxR
        v.layer.masksToBounds = maxR > 0

        // 使用 CACornerMask 控制具体角的圆角
        var maskedCorners: CACornerMask = []
        if radii.topLeft > 0 { maskedCorners.insert(.layerMinXMinYCorner) }
        if radii.topRight > 0 { maskedCorners.insert(.layerMaxXMinYCorner) }
        if radii.bottomLeft > 0 { maskedCorners.insert(.layerMinXMaxYCorner) }
        if radii.bottomRight > 0 { maskedCorners.insert(.layerMaxXMaxYCorner) }
        v.layer.maskedCorners = maskedCorners
        return self
    }

    /// 用字典方式设置指定角圆角
    /// ```
    /// view.style.cornerRadius([.topLeft: 12, .topRight: 12])
    /// ```
    @discardableResult
    public func cornerRadius(_ dict: [CACornerMask: CGFloat]) -> Self {
        return cornerRadius(YogaCornerRadii(dict))
    }

    // MARK: 阴影

    @discardableResult
    public func shadow(color: UIColor = .black, opacity: Float = 0.3, radius: CGFloat = 4, offset: CGSize = CGSize(width: 0, height: 2)) -> Self {
        guard let v = view else { return self }
        v.layer.shadowColor = color.cgColor
        v.layer.shadowOpacity = opacity
        v.layer.shadowRadius = radius
        v.layer.shadowOffset = offset
        return self
    }

    @discardableResult
    public func shadow(_ shadow: YogaShadow) -> Self {
        return self.shadow(color: shadow.color, opacity: shadow.opacity, radius: shadow.radius, offset: shadow.offset)
    }

    // MARK: 边框

    @discardableResult
    public func borderWidth(_ width: CGFloat) -> Self {
        view?.layer.borderWidth = width
        return self
    }

    @discardableResult
    public func borderColor(_ color: UIColor?) -> Self {
        view?.layer.borderColor = color?.cgColor
        return self
    }

    @discardableResult
    public func borderTopWidth(_ width: CGFloat) -> Self {
        // 使用常规 border，暂不支持单边（需要自定义 CALayer）
        view?.layer.borderWidth = width
        return self
    }

    @discardableResult
    public func borderBottomColor(_ color: UIColor?) -> Self {
        view?.layer.borderColor = color?.cgColor
        return self
    }

    // MARK: 透明度

    @discardableResult
    public func opacity(_ value: CGFloat) -> Self {
        view?.alpha = value
        return self
    }

    @discardableResult
    public func clipsToBounds(_ value: Bool) -> Self {
        view?.clipsToBounds = value
        return self
    }

    @discardableResult
    public func hidden(_ value: Bool) -> Self {
        view?.isHidden = value
        return self
    }
}

// MARK: - 工具扩展

extension UIView.ContentMode {
    fileprivate var toCAGravity: CALayerContentsGravity {
        switch self {
        case .scaleToFill: return .resize
        case .scaleAspectFit: return .resizeAspect
        case .scaleAspectFill: return .resizeAspectFill
        case .center: return .center
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .left
        case .right: return .right
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomLeft: return .bottomLeft
        case .bottomRight: return .bottomRight
        case .redraw: return .resize
        @unknown default: return .resize
        }
    }
}
#endif
