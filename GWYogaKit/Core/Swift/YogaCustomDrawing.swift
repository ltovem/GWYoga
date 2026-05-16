import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - YogaCustomDrawing Protocol

/// 自绘制控件协议。
///
/// 实现此协议的视图可以报告其内容尺寸，Yoga 在布局时会自动调用
/// `yogaContentSize(maxWidth:maxHeight:)` 来确定控件尺寸。
///
/// ```
/// class MyCustomView: UIView, YogaCustomDrawing {
///     override func draw(_ rect: CGRect) {
///         // 自定义绘制
///     }
///
///     func yogaContentSize(maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
///         return CGSize(width: min(200, maxWidth), height: 44)
///     }
/// }
///
/// // 注册（自动使用协议实现）
/// YogaMeasureRegistry.register(MyCustomView.self)
///
/// let view = MyCustomView()
/// view.yoga.isIntrinsic = true  // 启用自动测量
/// ```
public protocol YogaCustomDrawing: YKLView {

    /// 返回控件在给定约束下的内容尺寸。
    ///
    /// - Parameters:
    ///   - maxWidth: 最大可用宽度（.greatestFiniteMagnitude 表示无限制）
    ///   - maxHeight: 最大可用高度（.greatestFiniteMagnitude 表示无限制）
    /// - Returns: 控件期望的内容尺寸
    func yogaContentSize(maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize
}

// MARK: - YogaMeasureRegistry

/// 自绘制控件测量注册表。
///
/// 为自定义视图类型注册 measurement handler，当 YogaProperties 启用
/// `isIntrinsic` 时自动创建对应的 measureFunction。
public final class YogaMeasureRegistry {

    private static var handlers: [ObjectIdentifier: (YKLView, CGFloat, CGFloat) -> CGSize] = [:]

    private init() {}

    /// 注册实现了 `YogaCustomDrawing` 协议的类型，自动使用协议方法测量。
    public static func register<T: YogaCustomDrawing>(_ type: T.Type) {
        let id = ObjectIdentifier(type)
        handlers[id] = { view, maxWidth, maxHeight in
            guard let typed = view as? T else { return .zero }
            return typed.yogaContentSize(maxWidth: maxWidth, maxHeight: maxHeight)
        }
    }

    /// 注册任意视图类型 + 自定义测量闭包。
    public static func register<T: YKLView>(
        _ type: T.Type,
        handler: @escaping (T, CGFloat, CGFloat) -> CGSize
    ) {
        let id = ObjectIdentifier(type)
        handlers[id] = { view, maxWidth, maxHeight in
            guard let typed = view as? T else { return .zero }
            return handler(typed, maxWidth, maxHeight)
        }
    }

    /// 为指定视图创建 Yoga measure function（供 YogaProperties 内部使用）。
    internal static func createMeasureFunction(for view: YKLView) -> ((GWYogaNode, Float, GWMeasureMode, Float, GWMeasureMode) -> GWSize)? {
        let type = type(of: view)
        let id = ObjectIdentifier(type)
        guard let handler = handlers[id] else { return nil }
        return { _, w, wm, h, hm in
            let ywMode = YogaMeasurementMode.fromGW(wm)
            let yhMode = YogaMeasurementMode.fromGW(hm)
            let maxW = ywMode == .maxContent ? .greatestFiniteMagnitude : CGFloat(w)
            let maxH = yhMode == .maxContent ? .greatestFiniteMagnitude : CGFloat(h)
            let size = handler(view, maxW, maxH)
            return GWSize(width: Float(ceil(size.width)), height: Float(ceil(size.height)))
        }
    }
}

// MARK: - YogaCustomDrawing 便捷注册

extension YogaMeasureRegistry {
    /// 注册实现了 `YogaCustomDrawing` 协议的类型，使用默认协议方法。
    /// 等同于 `register(_:handler:)`，语法更简洁。
    @discardableResult
    public static func registerCustomDrawing<T: YogaCustomDrawing>(_ type: T.Type) -> T.Type {
        register(type)
        return type
    }
}
