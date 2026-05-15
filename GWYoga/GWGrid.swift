import Foundation

// MARK: - CSS Grid 类型（对应 C++ yoga/style/GridLine.h 和 GridTrack.h）

/// 网格线值的类型
public enum GWGridLineType: Int, CaseIterable, Sendable {
    case auto = 0
    case integer = 1
    case span = 2
}

/// 网格线定义（grid-column-start/end, grid-row-start/end）
/// 对应 C++ yoga/style/GridLine.h
public struct GWGridLine: Equatable, Sendable {
    public var type: GWGridLineType
    public var value: Int32

    public init(type: GWGridLineType = .auto, value: Int32 = 0) {
        self.type = type
        self.value = value
    }

    public static let auto = GWGridLine(type: .auto, value: 0)
    public static let `default` = GWGridLine.auto
}

/// 网格轨道尺寸（对应 C++ GridTrackSize）
/// 对应 C++ yoga/style/GridTrack.h
public struct GWGridTrackSize: Equatable, Sendable {
    /// Minimum sizing function (min track sizing function)
    public var minSizingFunction: GWStyleSizeLength

    /// Maximum sizing function (max track sizing function)
    public var maxSizingFunction: GWStyleSizeLength

    // MARK: - Algorithm state (used during track sizing)

    /// Base size — the resolved minimum size of the track
    public var baseSize: Float = 0

    /// Growth limit — the resolved maximum size of the track
    public var growthLimit: Float = 0

    /// Whether this track was marked infinitely growable during intrinsic sizing
    public var infinitelyGrowable: Bool = false

    public init(
        minSizingFunction: GWStyleSizeLength = .auto,
        maxSizingFunction: GWStyleSizeLength = .auto,
        baseSize: Float = 0,
        growthLimit: Float = 0,
        infinitelyGrowable: Bool = false
    ) {
        self.minSizingFunction = minSizingFunction
        self.maxSizingFunction = maxSizingFunction
        self.baseSize = baseSize
        self.growthLimit = growthLimit
        self.infinitelyGrowable = infinitelyGrowable
    }

    // MARK: - Static factories

    /// Auto-sized track (default): min = auto, max = auto
    public static func auto() -> GWGridTrackSize {
        GWGridTrackSize(
            minSizingFunction: .auto,
            maxSizingFunction: .auto
        )
    }

    /// Fixed-length track: e.g. `grid-template-columns: 100px`
    public static func points(_ value: Float) -> GWGridTrackSize {
        let len = GWStyleSizeLength.points(value)
        return GWGridTrackSize(
            minSizingFunction: len,
            maxSizingFunction: len
        )
    }

    /// Flex track: e.g. `grid-template-columns: 1fr`
    /// fr is always a max-sizing-function; min defaults to auto.
    public static func fr(_ fraction: Float) -> GWGridTrackSize {
        GWGridTrackSize(
            minSizingFunction: .auto,
            maxSizingFunction: .stretch(fraction)
        )
    }

    /// Percentage track: e.g. `grid-template-columns: 50%`
    public static func percent(_ value: Float) -> GWGridTrackSize {
        let len = GWStyleSizeLength.percent(value)
        return GWGridTrackSize(
            minSizingFunction: len,
            maxSizingFunction: len
        )
    }

    /// Minmax track: e.g. `grid-template-columns: minmax(100px, 1fr)`
    public static func minmax(min minLen: GWStyleSizeLength, max maxLen: GWStyleSizeLength) -> GWGridTrackSize {
        GWGridTrackSize(
            minSizingFunction: minLen,
            maxSizingFunction: maxLen
        )
    }

    // MARK: - Query helpers

    /// Whether the max sizing function is an fr (flex) unit
    public var isMaxFlex: Bool {
        maxSizingFunction.isStretch
    }

    /// Whether the max sizing function has a fixed/definite size
    public var isFixedMax: Bool {
        maxSizingFunction.isPoints
    }

    /// Whether the min sizing function is intrinsic (auto, min-content, max-content)
    public var isIntrinsic: Bool {
        let u = minSizingFunction.unit
        return u == .auto || u == .maxContent || u == .fitContent || u == .stretch
    }
}

/// 网格轨道列表（对应 C++ GridTrackList = vector<GridTrackSize>）
public typealias GWGridTrackList = [GWGridTrackSize]

// MARK: - Grid Area (internal)

/// Represents a placed grid item's spans in both axes.
internal struct GWGridArea: Equatable {
    /// Column start line (1-based)
    var columnStart: Int = 0
    /// Column end line (1-based, exclusive)
    var columnEnd: Int = 0
    /// Row start line (1-based)
    var rowStart: Int = 0
    /// Row end line (1-based, exclusive)
    var rowEnd: Int = 0

    var columns: Int { columnEnd - columnStart }
    var rows: Int { rowEnd - rowStart }
}

/// Represents a grid placement cursor used during auto-placement.
/// Tracks the current position in the grid for placing auto-positioned items.
internal struct GWGridCursor {
    var row: Int = 1
    var column: Int = 1
}
