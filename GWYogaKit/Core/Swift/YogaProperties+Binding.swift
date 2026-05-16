import Foundation
import GWYoga

// MARK: - 关联对象 Key

private var bindingKey: UInt8 = 0

// MARK: - YogaProperties 数据绑定扩展

extension YogaProperties {

    /// 内部 YogaBinding 实例（惰性创建，通过关联对象持有）
    private var binding: YogaBinding {
        if let existing = objc_getAssociatedObject(self, &bindingKey) as? YogaBinding {
            return existing
        }
        let new = YogaBinding()
        objc_setAssociatedObject(self, &bindingKey, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return new
    }

    /// 绑定 `@YogaState` 到 YogaProperties 的某个 keyPath。
    ///
    /// 绑定时立即应用当前状态值，之后状态变化时自动更新。
    ///
    /// 如果 YogaBinding 启用了 `coalesceLayout()`，同一 RunLoop 内多次变更
    /// 只会触发一次 `node.markDirty()`。
    ///
    /// ```
    /// @YogaState var width: GWValue = 100
    /// view.style.bind($width, to: \.width)
    /// ```
    public func bind<Value>(
        _ state: YogaState<Value>,
        to keyPath: ReferenceWritableKeyPath<YogaProperties, Value>
    ) {
        let shouldCoalesce = binding.isLayoutCoalescing

        // 立即应用当前值（可选的 dirty 合并）
        if shouldCoalesce { Self._suppressDirtyMarking = true }
        self[keyPath: keyPath] = state.wrappedValue
        if shouldCoalesce {
            Self._suppressDirtyMarking = false
            binding.scheduleDirty(self)
        }

        // 注册观察者
        let token = state.observe { [weak self] value in
            guard let self = self else { return }
            if shouldCoalesce { Self._suppressDirtyMarking = true }
            self[keyPath: keyPath] = value
            if shouldCoalesce {
                Self._suppressDirtyMarking = false
                self.binding.scheduleDirty(self)
            }
        }
        binding._addCleanup { state.removeObserver(token) }
    }

    /// 绑定 `@YogaState` 到自定义更新闭包。
    ///
    /// 闭包接收 `YogaProperties` 实例和新值，可用于批量更新样式属性。
    ///
    /// ```
    /// @YogaState var isActive: Bool = true
    /// view.style.coalesceLayout().bind($isActive) { props, active in
    ///     props.backgroundColor = active ? .green : .gray
    ///     props.cornerRadius = active ? 12 : 8
    /// }
    /// ```
    public func bind<Value>(
        _ state: YogaState<Value>,
        update: @escaping (YogaProperties, Value) -> Void
    ) {
        let shouldCoalesce = binding.isLayoutCoalescing

        // 立即用当前值调用
        if shouldCoalesce { Self._suppressDirtyMarking = true }
        update(self, state.wrappedValue)
        if shouldCoalesce {
            Self._suppressDirtyMarking = false
            binding.scheduleDirty(self)
        }

        let token = state.observe { [weak self] value in
            guard let self = self else { return }
            if shouldCoalesce { Self._suppressDirtyMarking = true }
            update(self, value)
            if shouldCoalesce {
                Self._suppressDirtyMarking = false
                self.binding.scheduleDirty(self)
            }
        }
        binding._addCleanup { state.removeObserver(token) }
    }

    /// 启用 layout 合并。
    ///
    /// 启用后，同一 RunLoop 内多次变更只会触发一次 `node.markDirty()`。
    /// 需要在 `bind()` 之前调用。
    @discardableResult
    public func coalesceLayout() -> Self {
        binding.coalesceLayout()
        return self
    }

    /// 解除当前 YogaProperties 上的所有绑定。
    public func unbindAll() {
        binding.unbindAll()
    }
}
