import Foundation

// MARK: - YogaState Property Wrapper

/// 提供值变化观察的属性包装器，带相等性去重。
///
/// `@YogaState` 包装任意 `Equatable` 值，在值真正变化时通知所有观察者。
/// 常用于视图模型中的可观察属性，配合 `YogaBinding` 驱动布局更新。
///
/// ```
/// class ViewModel {
///     @YogaState var title: String = ""
///     @YogaState var count: Int = 0
/// }
///
/// // 观察变化
/// $title.observe { newTitle in
///     label.text = newTitle
/// }
///
/// // 链式转发
/// $count.forward(to: $title) { "Count: \($0)" }
/// ```
@propertyWrapper
public struct YogaState<Value: Equatable> {

    // MARK: - Internal Box (reference semantics for shareability)

    final class Box {
        var value: Value
        var observers: [UUID: (Value) -> Void] = [:]

        init(_ value: Value) {
            self.value = value
        }
    }

    private var box: Box

    // MARK: - Initialization

    public init(wrappedValue: Value) {
        self.box = Box(wrappedValue)
    }

    // MARK: - Wrapped Value

    public var wrappedValue: Value {
        get { box.value }
        set {
            guard newValue != box.value else { return }
            box.value = newValue
            let current = box.observers
            current.values.forEach { $0(newValue) }
        }
    }

    // MARK: - Projected Value (access via $)

    public var projectedValue: Self {
        get { self }
        set { self = newValue }
    }

    // MARK: - Observation

    /// 注册值变化观察者，返回可用于取消观察的 token。
    /// 仅在新值 != 旧值时触发（Equatable 去重）。
    @discardableResult
    public func observe(_ handler: @escaping (Value) -> Void) -> UUID {
        let id = UUID()
        box.observers[id] = handler
        return id
    }

    /// 取消注册指定 token 的观察者。
    public func removeObserver(_ token: UUID) {
        box.observers[token] = nil
    }

    /// 将当前值变化转发到另一个 `YogaState`，支持变换闭包。
    ///
    /// 转发通过共享 Box 实现（$ 投影的 struct 副本共享同一 Box 引用），
    /// 因此无论是目标值的 `$` 投影还是直接访问 `wrappedValue` 都能看到更新。
    ///
    /// ```
    /// $count.forward(to: $title) { "Count: \($0)" }
    /// ```
    public func forward<T>(to target: YogaState<T>, transform: @escaping (Value) -> T) {
        let targetBox = target.box
        observe { value in
            let transformed = transform(value)
            guard transformed != targetBox.value else { return }
            targetBox.value = transformed
            for observer in targetBox.observers.values {
                observer(transformed)
            }
        }
    }
}
