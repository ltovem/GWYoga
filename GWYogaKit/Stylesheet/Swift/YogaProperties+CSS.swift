import Foundation
import GWYoga
import GWYogaKit
#if os(iOS) || os(tvOS)
import UIKit
#endif

// MARK: - YogaProperties CSS 字符串解析

extension YogaProperties {

    /// 从 CSS 字符串解析并应用样式属性。
    ///
    /// 仅支持布局相关属性（width, height, margin, padding, flex, 等）。
    /// 视觉样式（background, border-radius, box-shadow）需要通过独立方法设置。
    ///
    /// ```
    /// view.style.css("""
    ///     width: 100%;
    ///     height: 200px;
    ///     margin: 16px;
    ///     padding: 8px 16px;
    ///     display: flex;
    ///     flex-direction: row;
    ///     justify-content: center;
    ///     align-items: center;
    /// """)
    /// ```
    @discardableResult
    public func css(_ string: String) -> Self {
        let lines = string.split(separator: ";", omittingEmptySubsequences: true)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let parts = splitProperty(trimmed)
            if let property = parts.property, let value = parts.value {
                YogaCSSPropertyMapper.apply(property: property, value: value, to: self)
            }
        }
        return self
    }

    // MARK: - 内部

    private func splitProperty(_ string: String) -> (property: String?, value: String?) {
        let parts = string.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return (nil, nil) }
        let prop = String(parts[0]).trimmingCharacters(in: .whitespaces)
        let val = String(parts[1]).trimmingCharacters(in: .whitespaces)
        return (prop, val)
    }
}
