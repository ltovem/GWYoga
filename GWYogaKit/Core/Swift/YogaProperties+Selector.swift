import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - 关联对象 Key

private var cssIDKey: UInt8 = 0
private var cssClassKey: UInt8 = 0

// MARK: - YogaProperties ID / Class 选择器

extension YogaProperties {

    /// CSS ID 标识（用于 `find(byID:)` 查找）
    public var cssID: String? {
        get { objc_getAssociatedObject(self, &cssIDKey) as? String }
        set { objc_setAssociatedObject(self, &cssIDKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    /// CSS Class 标识（空格分隔，用于 `findAll(byClass:)` 查找）
    public var cssClass: String? {
        get { objc_getAssociatedObject(self, &cssClassKey) as? String }
        set { objc_setAssociatedObject(self, &cssClassKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    /// 递归查找子视图中 cssID 匹配的第一个视图
    @discardableResult
    public func find(byID id: String) -> YKLView? {
        findInSubviews(view: view, id: id)
    }

    /// 递归查找子视图中所有匹配 cssClass 的视图（支持空格分隔的多个 class）
    public func findAll(byClass className: String) -> [YKLView] {
        var results: [YKLView] = []
        findInSubviews(view: view, className: className, results: &results)
        return results
    }

    // MARK: - 私有递归

    private func findInSubviews(view: YKLView?, id: String) -> YKLView? {
        guard let v = view else { return nil }
        if v.yoga.cssID == id { return v }
        for sub in v.subviews {
            if let found = findInSubviews(view: sub, id: id) {
                return found
            }
        }
        return nil
    }

    private func findInSubviews(view: YKLView?, className: String, results: inout [YKLView]) {
        guard let v = view else { return }
        let classes = className.split(separator: " ").map(String.init)
        if let cssClass = v.yoga.cssClass {
            let viewClasses = cssClass.split(separator: " ").map(String.init)
            if classes.contains(where: { viewClasses.contains($0) }) {
                results.append(v)
            }
        }
        for sub in v.subviews {
            findInSubviews(view: sub, className: className, results: &results)
        }
    }
}
