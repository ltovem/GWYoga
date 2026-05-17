import Foundation
import GWYoga
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - YogaProperties Associated Object Key（跨文件共享）

/// YogaProperties 关联对象的 key，供 swizzle 代码检查视图是否已启用 Yoga
internal var YogaPropertiesAssociatedKey: UInt8 = 0

// MARK: - Platform 类型别名

#if os(iOS) || os(tvOS)
public typealias YKLView = UIView
public typealias PlatformFont = UIFont
public typealias PlatformColor = UIColor
public typealias PlatformImage = UIImage
public typealias PlatformTextAlignment = NSTextAlignment
public typealias PlatformContentMode = UIView.ContentMode
#elseif os(macOS)
public typealias YKLView = NSView
public typealias PlatformFont = NSFont
public typealias PlatformColor = NSColor
public typealias PlatformImage = NSImage
public typealias PlatformTextAlignment = NSTextAlignment
#endif

// MARK: - YogaLayoutMode

/// Yoga 布局执行策略
public enum YogaLayoutMode: Sendable {
    /// 仅节点 dirty 时重算（增量模式，默认）
    case auto
    /// 每次 layoutSubviews/layout 都重算
    case forced
    /// 不自动触发，需手动调用 performYogaLayout
    case manual
}

// MARK: - YogaMeasurementMode

/// Yoga 测量模式（对 GWMeasureMode 的封装）
public enum YogaMeasurementMode: Sendable {
    case exact
    case maxContent
    case fitContent

    internal static func fromGW(_ mode: GWMeasureMode) -> YogaMeasurementMode {
        switch mode {
        case .undefined:
            return .maxContent
        case .exactly:
            return .exact
        case .atMost:
            return .fitContent
        }
    }
}

// MARK: - YogaSafeAreaMode

/// Safe area 处理策略
public enum YogaSafeAreaMode: Sendable {
    /// 自动避开 safe area。布局时自动将内容限制在 safe area 内
    case auto
    /// 将 safe area insets 映射到 padding，叠加到已有 padding 上
    case padding
    /// 不处理，手动控制（默认）
    case manual
}

// MARK: - GWValue 便捷构造（internal → public 桥接）

extension GWValue {
    /// 从 GWStyleSizeLength 构造
    public init(from sizeLength: GWStyleSizeLength) {
        self.init(value: sizeLength.value.unwrap(orDefault: 0), unit: sizeLength.unit)
    }

    /// 从 GWStyleLength 构造
    public init(from length: GWStyleLength) {
        self.init(value: length.value.unwrap(orDefault: 0), unit: length.unit)
    }
}

extension GWStyleLength {
    /// 从 GWValue 构造
    public init(from value: GWValue) {
        switch value.unit {
        case .undefined:
            self = .undefined
        case .auto:
            self = .auto
        case .maxContent:
            self = .maxContent
        case .fitContent:
            self = .fitContent
        case .stretch:
            self = .stretch
        case .point:
            self = .points(value.value)
        case .percent:
            self = .percent(value.value)
        }
    }
}

extension GWStyleSizeLength {
    /// 从 GWValue 构造
    public init(from value: GWValue) {
        switch value.unit {
        case .undefined:
            self = .undefined
        case .auto:
            self = .auto
        case .maxContent:
            self = .maxContent
        case .fitContent:
            self = .fitContent
        case .stretch:
            self = .stretch
        case .point:
            self = .points(value.value)
        case .percent:
            self = .percent(value.value)
        }
    }
}
