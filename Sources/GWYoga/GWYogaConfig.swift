import Foundation

/// Configuration for the Yoga layout engine.
public final class GWYogaConfig: @unchecked Sendable {
    /// Whether to use web defaults (flexDirection: row, alignContent: stretch)
    public var useWebDefaults: Bool = false {
        didSet {
            if useWebDefaults != oldValue {
                markChanged()
            }
        }
    }

    /// Point scale factor for pixel rounding (0 = no rounding)
    public var pointScaleFactor: Float = 1.0 {
        didSet {
            if pointScaleFactor != oldValue {
                markChanged()
            }
        }
    }

    /// Errata flags for backward compatibility
    public var errata: GWErrata = .none {
        didSet {
            if errata != oldValue {
                markChanged()
            }
        }
    }

    /// Enabled experimental features
    public var experimentalFeatures: Set<GWExperimentalFeature> = [] {
        didSet {
            markChanged()
        }
    }

    /// User-defined context object
    public var context: Any?

    /// Custom logger callback
    public var logger: GWLogger?

    /// Version counter bumped when config changes that invalidate layout caches
    internal private(set) var version: UInt32 = 0

    public init() {}

    public func setExperimentalFeature(_ feature: GWExperimentalFeature, enabled: Bool) {
        if enabled {
            experimentalFeatures.insert(feature)
        } else {
            experimentalFeatures.remove(feature)
        }
    }

    public func isExperimentalFeatureEnabled(_ feature: GWExperimentalFeature) -> Bool {
        experimentalFeatures.contains(feature)
    }

    private func markChanged() {
        version += 1
    }
}

/// Default shared config for nodes that don't have a custom one.
internal let defaultConfig = GWYogaConfig()
