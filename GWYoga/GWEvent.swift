import Foundation

// MARK: - 布局事件系统（对应 C++ yoga/event/event.h 和 event.cpp）

/// 布局类型
internal enum GWLayoutType: Int, Sendable {
    case layout = 0
    case measure = 1
    case cachedLayout = 2
    case cachedMeasure = 3
}

/// 布局传递原因
internal enum GWLayoutPassReason: Int, Sendable {
    case initial = 0
    case absLayout = 1
    case stretch = 2
    case multilineStretch = 3
    case flexLayout = 4
    case measureChild = 5
    case absMeasureChild = 6
    case flexMeasure = 7
    case gridLayout = 8

    static let count = 9

    var description: String {
        switch self {
        case .initial: return "initial"
        case .absLayout: return "abs_layout"
        case .stretch: return "stretch"
        case .multilineStretch: return "multiline_stretch"
        case .flexLayout: return "flex_layout"
        case .measureChild: return "measure"
        case .absMeasureChild: return "abs_measure"
        case .flexMeasure: return "flex_measure"
        case .gridLayout: return "grid_layout"
        }
    }
}

/// 布局统计数据
internal struct GWLayoutData {
    var layouts: Int = 0
    var measures: Int = 0
    var maxMeasureCache: UInt32 = 0
    var cachedLayouts: Int = 0
    var cachedMeasures: Int = 0
    var measureCallbacks: Int = 0
    var measureCallbackReasonsCount: [Int] = [Int](repeating: 0, count: GWLayoutPassReason.count)
}

/// 事件类型
internal enum GWEventType: Int, Sendable {
    case nodeAllocation
    case nodeDeallocation
    case nodeLayout
    case layoutPassStart
    case layoutPassEnd
    case measureCallbackStart
    case measureCallbackEnd
    case nodeBaselineStart
    case nodeBaselineEnd
}

/// 事件数据
internal enum GWEventData: Sendable {
    case nodeAllocation(configVersion: UInt32)
    case nodeDeallocation(configVersion: UInt32)
    case nodeLayout(layoutType: GWLayoutType)
    case layoutPassEnd(layoutData: GWLayoutData)
    case measureCallbackEnd(
        width: Float, widthMeasureMode: GWMeasureMode,
        height: Float, heightMeasureMode: GWMeasureMode,
        measuredWidth: Float, measuredHeight: Float,
        reason: GWLayoutPassReason
    )
    case none
}

/// 事件订阅者类型
internal typealias GWEventSubscriber = (GWYogaNode?, GWEventType, GWEventData) -> Void

/// 事件管理器（简化版，无锁单链表）
internal final class GWEvent {
    private static var subscribers: [GWEventSubscriber] = []

    /// 重置所有订阅者
    static func reset() {
        subscribers.removeAll()
    }

    /// 添加订阅者
    static func subscribe(_ subscriber: @escaping GWEventSubscriber) {
        subscribers.append(subscriber)
    }

    /// 发布事件
    static func publish(
        node: GWYogaNode?,
        type: GWEventType,
        data: GWEventData = .none
    ) {
        for subscriber in subscribers {
            subscriber(node, type, data)
        }
    }
}
