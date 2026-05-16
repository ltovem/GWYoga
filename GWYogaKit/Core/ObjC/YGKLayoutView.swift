import Foundation
import GWYoga
import GWYogaKit
#if os(iOS) || os(tvOS)
import UIKit
#endif

// MARK: - YGKLayoutView

/// Objective-C compatible Yoga layout view.
///
/// Auto-manages Yoga node tree for subviews and provides
/// layout calculation driven by Yoga's flexbox engine.
///
/// Usage:
/// ```objc
/// YGKLayoutView *container = [[YGKLayoutView alloc] init];
/// container.gwstyle.flexDirection = YGKFlexDirectionColumn;
/// container.gwstyle.padding = 16;
///
/// UIView *child = [[UIView alloc] init];
/// child.gwstyle.width = 100;
/// child.gwstyle.height = 100;
/// [container addSubview:child];
/// ```
@objc(YGKLayoutView)
open class YGKLayoutView: YogaLayoutView {

    /// ObjC-accessible yoga properties (inherited from UIView+YGK extension).
    /// Access via `view.gwstyle` from ObjC.

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Layout Mode

    /// Layout mode as raw integer (0=auto, 1=forced, 2=manual).
    /// Use this from ObjC since YogaLayoutMode is not ObjC-compatible.
    @objc public var yogaLayoutModeRaw: Int {
        get {
            switch yogaLayoutMode {
            case .auto: return 0
            case .forced: return 1
            case .manual: return 2
            }
        }
        set {
            switch newValue {
            case 1: yogaLayoutMode = .forced
            case 2: yogaLayoutMode = .manual
            default: yogaLayoutMode = .auto
            }
        }
    }

    /// Layout mode using the ObjC-compatible YGKLayoutMode enum.
    @objc public var layoutMode: YGKLayoutMode {
        get {
            switch yogaLayoutMode {
            case .auto: return .auto
            case .forced: return .forced
            case .manual: return .manual
            }
        }
        set {
            switch newValue {
            case .forced: yogaLayoutMode = .forced
            case .manual: yogaLayoutMode = .manual
            default: yogaLayoutMode = .auto
            }
        }
    }

    // MARK: - Content Size

    #if os(iOS)
    open override var intrinsicContentSize: CGSize {
        super.intrinsicContentSize
    }
    #endif
}
