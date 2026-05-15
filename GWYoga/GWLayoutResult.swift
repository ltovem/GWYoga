import Foundation

/// Computed layout results after a node has been laid out.
public struct GWLayoutResult: Equatable, Sendable {
    public var left: Float
    public var top: Float
    public var right: Float
    public var bottom: Float
    public var width: Float
    public var height: Float
    public var direction: GWDirection
    public var hadOverflow: Bool

    public static let zero = GWLayoutResult(
        left: 0, top: 0, right: 0, bottom: 0,
        width: 0, height: 0,
        direction: .ltr, hadOverflow: false
    )

    public init(left: Float, top: Float, right: Float, bottom: Float,
                width: Float, height: Float,
                direction: GWDirection, hadOverflow: Bool) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
        self.width = width
        self.height = height
        self.direction = direction
        self.hadOverflow = hadOverflow
    }
}

// MARK: - Internal layout data stored per node

/// Internal storage for per-node layout results during computation.
/// Mirrors the Yoga C++ LayoutResults structure.
internal struct GWInternalLayout: Equatable, Sendable {
    // Resolved direction for this node
    var direction: GWDirection = .inherit

    // Whether content overflowed available space
    var hadOverflow: Bool = false

    // Desired/final dimensions [width, height]
    var dimensions: [Float] = [.nan, .nan]

    // Measured dimensions from measure function [width, height]
    var measuredDimensions: [Float] = [.nan, .nan]

    // Pre-rounding dimensions [width, height]
    var rawDimensions: [Float] = [.nan, .nan]

    // Position per physical edge [left, top, right, bottom]
    var position: [Float] = [0, 0, 0, 0]

    // Computed margin per physical edge
    var margin: [Float] = [0, 0, 0, 0]

    // Computed border per physical edge
    var border: [Float] = [0, 0, 0, 0]

    // Computed padding per physical edge
    var padding: [Float] = [0, 0, 0, 0]

    // MARK: Accessors

    func dimension(_ dim: GWDimension) -> Float {
        dimensions[dim == .width ? 0 : 1]
    }

    mutating func setDimension(_ dim: GWDimension, _ value: Float) {
        dimensions[dim == .width ? 0 : 1] = value
    }

    func measuredDimension(_ dim: GWDimension) -> Float {
        measuredDimensions[dim == .width ? 0 : 1]
    }

    mutating func setMeasuredDimension(_ dim: GWDimension, _ value: Float) {
        measuredDimensions[dim == .width ? 0 : 1] = value
    }

    func position(_ edge: GWPhysicalEdge) -> Float {
        position[edge.rawValue]
    }

    mutating func setPosition(_ edge: GWPhysicalEdge, _ value: Float) {
        position[edge.rawValue] = value
    }

    func margin(_ edge: GWPhysicalEdge) -> Float {
        margin[edge.rawValue]
    }

    mutating func setMargin(_ edge: GWPhysicalEdge, _ value: Float) {
        margin[edge.rawValue] = value
    }

    func border(_ edge: GWPhysicalEdge) -> Float {
        border[edge.rawValue]
    }

    mutating func setBorder(_ edge: GWPhysicalEdge, _ value: Float) {
        border[edge.rawValue] = value
    }

    func padding(_ edge: GWPhysicalEdge) -> Float {
        padding[edge.rawValue]
    }

    mutating func setPadding(_ edge: GWPhysicalEdge, _ value: Float) {
        padding[edge.rawValue] = value
    }

    // MARK: Convert to public layout result

    func toPublicLayoutResult() -> GWLayoutResult {
        GWLayoutResult(
            left: position(.left),
            top: position(.top),
            right: position(.right),
            bottom: position(.bottom),
            width: dimension(.width),
            height: dimension(.height),
            direction: direction,
            hadOverflow: hadOverflow
        )
    }
}
