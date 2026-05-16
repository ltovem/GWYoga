import Foundation
import GWYoga

#if os(iOS) || os(tvOS)
import UIKit

// MARK: - 特征变化观察视图

/// 不可见子视图，用于拦截 traitCollectionDidChange 回调。
private final class TraitObserverView: UIView {
    var onChange: ((UITraitCollection) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection != previousTraitCollection else { return }
        onChange?(traitCollection)
    }
}

// MARK: - 关联对象 Key

private var traitHandlersKey: UInt8 = 0
private var traitObserverKey: UInt8 = 0

// MARK: - YogaProperties 特征变化支持

extension YogaProperties {

    /// 注册特征变化回调。当视图的 `traitCollection` 发生变化时调用。
    ///
    /// 回调接收当前 `UITraitCollection` 和 `YogaProperties`，
    /// 可在闭包中根据 horizontalSizeClass / verticalSizeClass 等调整布局。
    ///
    /// ```
    /// view.style.onTraitChange { traits, style in
    ///     style.flexDirection = traits.horizontalSizeClass == .compact
    ///         ? .column : .row
    /// }
    /// ```
    /// - Parameter handler: 特征变化时调用的闭包
    /// - Returns: 自身（支持链式调用）
    @discardableResult
    public func onTraitChange(_ handler: @escaping (UITraitCollection, YogaProperties) -> Void) -> Self {
        var handlers = traitHandlers
        handlers.append(handler)
        traitHandlers = handlers
        ensureTraitObserver()
        return self
    }

    /// 清除所有已注册的特征变化回调。
    @discardableResult
    public func removeAllTraitHandlers() -> Self {
        traitHandlers = []
        return self
    }

    // MARK: - 内部

    private var traitHandlers: [(UITraitCollection, YogaProperties) -> Void] {
        get { objc_getAssociatedObject(self, &traitHandlersKey) as? [(UITraitCollection, YogaProperties) -> Void] ?? [] }
        set { objc_setAssociatedObject(self, &traitHandlersKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    /// 确保观察视图已添加到父视图层级。
    private func ensureTraitObserver() {
        guard objc_getAssociatedObject(self, &traitObserverKey) == nil,
              let parent = view else { return }

        let observer = TraitObserverView()
        parent.addSubview(observer)

        observer.onChange = { [weak self] traits in
            guard let self = self else { return }
            let handlers = self.traitHandlers
            for handler in handlers {
                handler(traits, self)
            }
            // 脏标记，让 Yoga 重新计算布局
            self.node.markDirty()
            #if os(iOS)
            parent.setNeedsLayout()
            #endif
        }

        objc_setAssociatedObject(self, &traitObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

#endif
