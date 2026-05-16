import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - YogaBinding — 绑定管理器

/// 管理 `@YogaState` 到视图属性的绑定生命周期。
///
/// `YogaBinding` 负责注册观察者、将状态值映射到 UIKit 属性，
/// 并在不需要时统一解除所有绑定。
///
/// ```
/// class MyViewController: UIViewController {
///     @YogaState var title: String = "Hello"
///     let binding = YogaBinding()
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         binding.bind($title, to: \.text, on: titleLabel)
///         binding.bind($title) { [weak self] in
///             self?.updateLayout($0)
///         }
///     }
///
///     deinit {
///         binding.unbindAll()
///     }
/// }
/// ```
public final class YogaBinding {

    private var cleanups: [() -> Void] = []

    // MARK: - Layout 合并

    private var isCoalescing = false

    /// 静态合并器，收集需要脏标记的 YogaProperties，
    /// 在 RunLoop 末尾统一触发一次 node.markDirty()。
    private static var pending = NSHashTable<YogaProperties>.weakObjects()
    private static var scheduled = false

    public init() {}

    deinit {
        unbindAll()
    }

    /// 启用 layout 合并。
    ///
    /// 启用后，通过 `YogaProperties.bind()` 设置样式属性时，
    /// 同一 RunLoop 内多次变更只会触发一次 `node.markDirty()`。
    @discardableResult
    public func coalesceLayout() -> Self {
        isCoalescing = true
        return self
    }

    /// 当前是否启用 layout 合并。
    internal var isLayoutCoalescing: Bool { isCoalescing }

    /// 安排 YogaProperties 在 RunLoop 末尾统一进行脏标记。
    internal func scheduleDirty(_ props: YogaProperties) {
        Self.pending.add(props)
        if !Self.scheduled {
            Self.scheduled = true
            DispatchQueue.main.async {
                Self.flush()
            }
        }
    }

    private static func flush() {
        for props in pending.allObjects {
            props.node.markDirty()
        }
        pending.removeAllObjects()
        scheduled = false
    }

    /// 绑定状态到视图的 keyPath。
    /// 绑定时会立即将当前值应用到视图，之后在值变化时自动更新。
    ///
    /// - Parameters:
    ///   - state: @YogaState 的 $ 投影
    ///   - keyPath: 目标视图的可写 keyPath
    ///   - view: 目标视图（弱引用持有）
    @discardableResult
    public func bind<Value, View: YKLView>(
        _ state: YogaState<Value>,
        to keyPath: ReferenceWritableKeyPath<View, Value>,
        on view: View
    ) -> Self {
        // 立即应用当前值
        view[keyPath: keyPath] = state.wrappedValue
        let token = state.observe { [weak view] value in
            view?[keyPath: keyPath] = value
        }
        cleanups.append { state.removeObserver(token) }
        return self
    }

    /// 绑定状态到自定义更新闭包。
    /// 绑定时会立即用当前值调用闭包，之后在值变化时自动调用。
    ///
    /// - Parameters:
    ///   - state: @YogaState 的 $ 投影
    ///   - update: 值变化时的回调
    @discardableResult
    public func bind<Value>(
        _ state: YogaState<Value>,
        update: @escaping (Value) -> Void
    ) -> Self {
        // 立即用当前值调用
        update(state.wrappedValue)
        let token = state.observe(update)
        cleanups.append { state.removeObserver(token) }
        return self
    }

    /// 解除所有绑定，清除观察者。
    public func unbindAll() {
        cleanups.forEach { $0() }
        cleanups.removeAll()
    }

    // MARK: - 内部扩展支持

    /// 注册清理闭包（供 YogaProperties 内部绑定使用）。
    internal func _addCleanup(_ cleanup: @escaping () -> Void) {
        cleanups.append(cleanup)
    }
}
