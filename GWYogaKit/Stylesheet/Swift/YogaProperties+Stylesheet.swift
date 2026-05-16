import Foundation
import GWYoga
import GWYogaKit
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - YogaProperties 样式表支持

extension YogaProperties {

    /// 从 CSS 文件加载样式并应用到当前视图。
    ///
    /// 使用 CSS 选择器（tag、.class、#id）匹配当前视图后再应用属性。
    ///
    /// ```
    /// view.style.loadStylesheet("style")
    /// view.style.loadStylesheet("custom.css", bundle: .module)
    /// ```
    /// - Parameters:
    ///   - name: CSS 文件名（可含 .css 后缀）
    ///   - bundle: 资源 bundle（默认 `.main`）
    @discardableResult
    public func loadStylesheet(_ name: String, bundle: Bundle = .main) -> Self {
        guard let stylesheet = try? YogaStylesheet.load(named: name, bundle: bundle) else {
            return self
        }
        return apply(stylesheet: stylesheet)
    }

    /// 应用 `YogaStylesheet` 中的规则到当前视图。
    ///
    /// 根据视图的 `cssID`、`cssClass` 和类型名匹配选择器，
    /// 匹配成功后调用 `YogaCSSPropertyMapper` 应用每个声明。
    @discardableResult
    public func apply(stylesheet: YogaStylesheet) -> Self {
        let tag = viewTagName
        let classes = cssClass?.split(separator: " ").map(String.init) ?? []
        let id = cssID

        for rule in stylesheet.rules {
            if rule.selector.matches(tag: tag, classes: classes, id: id) {
                for declaration in rule.declarations {
                    YogaCSSPropertyMapper.apply(
                        property: declaration.property,
                        value: declaration.value,
                        to: self
                    )
                }
            }
        }
        return self
    }

    // MARK: - 内部

    /// 获取视图的标签名（用于类型选择器匹配）
    private var viewTagName: String {
        guard let v = view else { return "view" }
    #if os(iOS) || os(tvOS)
        let applied = v as YogaStyleApplied
        return applied.cssTagName
    #else
        return String(describing: type(of: v)).lowercased()
    #endif
    }
}

// MARK: - YogaCSSConfig

/// 全局 CSS 样式表配置。
///
/// 提供默认样式注册功能，方便在应用启动时设置全局基础样式。
public enum YogaCSSConfig {

    private static var storage: YogaStylesheet?

    /// 注册全局默认样式表。
    ///
    /// 注册的样式表可通过 `registeredDefault` 获取，
    /// 但不会自动应用到已有视图 —— 需手动调用 `applyDefaultStylesheet()`。
    public static func registerDefault(_ stylesheet: YogaStylesheet) {
        storage = stylesheet
    }

    /// 获取已注册的全局默认样式表。
    public static var registeredDefault: YogaStylesheet? {
        storage
    }

    /// 移除已注册的全局默认样式。
    public static func unregisterDefault() {
        storage = nil
    }
}

// MARK: - YogaProperties 默认样式应用

extension YogaProperties {

    /// 将已注册的全局默认样式应用到当前视图。
    ///
    /// 如果未注册默认样式，则无操作。
    @discardableResult
    public func applyDefaultStylesheet() -> Self {
        guard let stylesheet = YogaCSSConfig.registeredDefault else { return self }
        return apply(stylesheet: stylesheet)
    }
}
