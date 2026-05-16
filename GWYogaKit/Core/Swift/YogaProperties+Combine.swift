import Foundation
import Combine
import GWYoga

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Publisher → 对象绑定

extension Publisher where Failure == Never {

    /// 将 Publisher 的输出绑定到对象的 keyPath。
    /// 返回的 AnyCancellable 控制生命周期，释放时解除绑定。
    ///
    /// ```
    /// let pub = Just(GWValue.points(100))
    /// let cancel = pub.bind(to: view.style, keyPath: \.width)
    /// ```
    @discardableResult
    public func bind<Root: AnyObject>(
        to target: Root,
        keyPath: ReferenceWritableKeyPath<Root, Output>
    ) -> AnyCancellable {
        sink { [weak target] value in
            target?[keyPath: keyPath] = value
        }
    }

    /// 将 Publisher 的输出通过闭包绑定到 YogaProperties。
    ///
    /// ```
    /// let pub = Just(100 as Float)
    /// let cancel = pub.bind(to: view.style) { $0.flexGrow = $1 }
    /// ```
    @discardableResult
    public func bind(
        to target: YogaProperties,
        update: @escaping (YogaProperties, Output) -> Void
    ) -> AnyCancellable {
        sink { [weak target] value in
            guard let target = target else { return }
            update(target, value)
        }
    }
}
