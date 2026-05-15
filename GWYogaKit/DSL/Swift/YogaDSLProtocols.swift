import Foundation
import GWYogaKit

#if os(iOS)
import UIKit

// MARK: - YogaDSLModifiable

/// 所有 DSL 组件遵守的协议，提供链式修饰器。
public protocol YogaDSLModifiable: AnyObject {
    var yoga: YogaProperties { get }
}

// MARK: - YogaDSLBuilder

/// SwiftUI 风格的 @resultBuilder，用于 DSL 容器的子视图闭包。
@resultBuilder
public struct YogaDSLBuilder {

    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expr: UIView) -> [UIView] {
        [expr]
    }

    public static func buildOptional(_ component: [UIView]?) -> [UIView] {
        component ?? []
    }

    public static func buildEither(first component: [UIView]) -> [UIView] {
        component
    }

    public static func buildEither(second component: [UIView]) -> [UIView] {
        component
    }

    public static func buildArray(_ components: [[UIView]]) -> [UIView] {
        components.flatMap { $0 }
    }
}

#endif
