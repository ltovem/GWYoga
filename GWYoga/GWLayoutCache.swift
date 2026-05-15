import Foundation

/// A cached measurement entry matching specific available-size and sizing-mode constraints.
internal struct GWCachedMeasurement: Equatable, Sendable {
    var availableWidth: Float = -1
    var availableHeight: Float = -1
    var widthSizingMode: GWSizingMode = .maxContent
    var heightSizingMode: GWSizingMode = .maxContent
    var computedWidth: Float = -1
    var computedHeight: Float = -1
}

/// Layout cache for a single node: one primary layout entry + ring buffer of measurement entries.
internal struct GWLayoutCache: Equatable, Sendable {
    /// The primary cached layout result (from performLayout=true calls)
    var cachedLayout: GWCachedMeasurement = .init()

    /// Ring buffer for additional cached measurements
    var cachedMeasurements: [GWCachedMeasurement] = Array(repeating: .init(), count: 8)
    var nextMeasurementIndex: UInt32 = 0

    /// Generation tracking for cache invalidation
    var computedFlexBasisGeneration: UInt32 = 0
    var computedFlexBasis: GWFloatOptional = .undefined
    var generationCount: UInt32 = 0
    var configVersion: UInt32 = 0
    var lastOwnerDirection: GWDirection = .inherit

    // MARK: - Cache Operations

    /// Check if cached layout can be used with the given constraints.
    mutating func canUseCachedLayout(
        availableWidth: Float,
        availableHeight: Float,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode
    ) -> Bool {
        cachedLayout.availableWidth == availableWidth
            && cachedLayout.availableHeight == availableHeight
            && cachedLayout.widthSizingMode == widthSizingMode
            && cachedLayout.heightSizingMode == heightSizingMode
    }

    /// Add a measurement to the ring buffer.
    mutating func addMeasurement(
        availableWidth: Float,
        availableHeight: Float,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        computedWidth: Float,
        computedHeight: Float
    ) {
        let index = Int(nextMeasurementIndex) % cachedMeasurements.count
        cachedMeasurements[index] = GWCachedMeasurement(
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            widthSizingMode: widthSizingMode,
            heightSizingMode: heightSizingMode,
            computedWidth: computedWidth,
            computedHeight: computedHeight
        )
        nextMeasurementIndex += 1
    }

    /// Find a matching measurement in the ring buffer.
    func findMeasurement(
        availableWidth: Float,
        availableHeight: Float,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode
    ) -> GWCachedMeasurement? {
        let count = min(Int(nextMeasurementIndex), cachedMeasurements.count)
        for i in 0..<count {
            let m = cachedMeasurements[i]
            if m.availableWidth == availableWidth
                && m.availableHeight == availableHeight
                && m.widthSizingMode == widthSizingMode
                && m.heightSizingMode == heightSizingMode {
                return m
            }
        }
        return nil
    }
}
