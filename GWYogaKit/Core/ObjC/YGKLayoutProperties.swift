import Foundation
import CoreGraphics
import GWYoga
import GWYogaKit

// MARK: - YGKGridLine

/// ObjC-compatible grid line (grid-column-start/end, grid-row-start/end)
@objc(YGKGridLine)
public class YGKGridLine: NSObject {
    @objc public var type: YGKGridLineType
    @objc public var value: Int32

    @objc public init(type: YGKGridLineType, value: Int32) {
        self.type = type
        self.value = value
    }

    @objc public static func auto() -> YGKGridLine {
        YGKGridLine(type: .auto, value: 0)
    }

    @objc public static func line(_ value: Int32) -> YGKGridLine {
        YGKGridLine(type: .integer, value: value)
    }

    @objc public static func span(_ value: Int32) -> YGKGridLine {
        YGKGridLine(type: .span, value: value)
    }

    internal var swiftValue: GWGridLine {
        GWGridLine(type: type.swiftValue, value: value)
    }
}

// MARK: - YGKGridTrackSize

/// ObjC-compatible grid track size.
@objc(YGKGridTrackSize)
public class YGKGridTrackSize: NSObject {
    @objc public var minPoints: CGFloat
    @objc public var maxPoints: CGFloat
    @objc public var isFlex: Bool

    @objc public init(points: CGFloat) {
        self.minPoints = points
        self.maxPoints = points
        self.isFlex = false
    }

    @objc public init(min: CGFloat, max: CGFloat) {
        self.minPoints = min
        self.maxPoints = max
        self.isFlex = false
    }

    @objc public static func points(_ value: CGFloat) -> YGKGridTrackSize {
        YGKGridTrackSize(points: value)
    }

    @objc public static func fr(_ fraction: CGFloat) -> YGKGridTrackSize {
        let t = YGKGridTrackSize(min: 0, max: fraction)
        t.isFlex = true
        return t
    }

    @objc public static func percent(_ value: CGFloat) -> YGKGridTrackSize {
        YGKGridTrackSize(points: value)
    }

    internal var swiftValue: GWGridTrackSize {
        if isFlex {
            return .fr(Float(maxPoints))
        }
        return .points(Float(minPoints))
    }
}

// MARK: - YGKLayoutProperties

/// Objective-C compatible wrapper around YogaProperties.
/// Provides named-style property access for Yoga layout attributes.
@objc(YGKLayoutProperties)
public class YGKLayoutProperties: NSObject {

    internal let yoga: YogaProperties

    internal init(yoga: YogaProperties) {
        self.yoga = yoga
    }

    // MARK: - Size

    @objc public var width: CGFloat {
        get { CGFloat(yoga.width.value) }
        set { yoga.width = .points(Float(newValue)) }
    }

    @objc public var height: CGFloat {
        get { CGFloat(yoga.height.value) }
        set { yoga.height = .points(Float(newValue)) }
    }

    @objc public var minWidth: CGFloat {
        get { CGFloat(yoga.minWidth.value) }
        set { yoga.minWidth = .points(Float(newValue)) }
    }

    @objc public var maxWidth: CGFloat {
        get { CGFloat(yoga.maxWidth.value) }
        set { yoga.maxWidth = .points(Float(newValue)) }
    }

    @objc public var minHeight: CGFloat {
        get { CGFloat(yoga.minHeight.value) }
        set { yoga.minHeight = .points(Float(newValue)) }
    }

    @objc public var maxHeight: CGFloat {
        get { CGFloat(yoga.maxHeight.value) }
        set { yoga.maxHeight = .points(Float(newValue)) }
    }

    @objc public func setWidthPercent(_ percent: CGFloat) {
        yoga.width = .percent(Float(percent))
    }

    @objc public func setHeightPercent(_ percent: CGFloat) {
        yoga.height = .percent(Float(percent))
    }

    @objc public func setMinWidthPercent(_ percent: CGFloat) {
        yoga.minWidth = .percent(Float(percent))
    }

    @objc public func setMaxWidthPercent(_ percent: CGFloat) {
        yoga.maxWidth = .percent(Float(percent))
    }

    @objc public func setMinHeightPercent(_ percent: CGFloat) {
        yoga.minHeight = .percent(Float(percent))
    }

    @objc public func setMaxHeightPercent(_ percent: CGFloat) {
        yoga.maxHeight = .percent(Float(percent))
    }

    // MARK: - Flex Direction

    @objc public var flexDirection: YGKFlexDirection {
        get { YGKFlexDirection.from(yoga.flexDirection) }
        set { yoga.flexDirection = newValue.swiftValue }
    }

    // MARK: - Alignment

    @objc public var justifyContent: YGKJustify {
        get { YGKJustify.from(yoga.justifyContent) }
        set { yoga.justifyContent = newValue.swiftValue }
    }

    @objc public var alignItems: YGKAlign {
        get { YGKAlign.from(yoga.alignItems) }
        set { yoga.alignItems = newValue.swiftValue }
    }

    @objc public var alignSelf: YGKAlign {
        get { YGKAlign.from(yoga.alignSelf) }
        set { yoga.alignSelf = newValue.swiftValue }
    }

    @objc public var alignContent: YGKAlign {
        get { YGKAlign.from(yoga.alignContent) }
        set { yoga.alignContent = newValue.swiftValue }
    }

    // MARK: - Flex

    @objc public var flexGrow: Float {
        get { yoga.flexGrow }
        set { yoga.flexGrow = newValue }
    }

    @objc public var flexShrink: Float {
        get { yoga.flexShrink }
        set { yoga.flexShrink = newValue }
    }

    @objc public var flexBasis: CGFloat {
        get { CGFloat(yoga.flexBasis.value) }
        set { yoga.flexBasis = .points(Float(newValue)) }
    }

    @objc public var flex: Float {
        get { yoga.flex }
        set { yoga.flex = newValue }
    }

    // MARK: - Wrap

    @objc public var flexWrap: YGKWrap {
        get { YGKWrap.from(yoga.flexWrap) }
        set { yoga.flexWrap = newValue.swiftValue }
    }

    // MARK: - Position

    @objc public var positionType: YGKPositionType {
        get { YGKPositionType.from(yoga.positionType) }
        set { yoga.positionType = newValue.swiftValue }
    }

    // MARK: - Display / Overflow

    @objc public var display: YGKDisplay {
        get { YGKDisplay.from(yoga.display) }
        set { yoga.display = newValue.swiftValue }
    }

    @objc public var overflow: YGKOverflow {
        get { YGKOverflow.from(yoga.overflow) }
        set { yoga.overflow = newValue.swiftValue }
    }

    // MARK: - Box Sizing

    @objc public var boxSizing: YGKBoxSizing {
        get { YGKBoxSizing.from(yoga.boxSizing) }
        set { yoga.boxSizing = newValue.swiftValue }
    }

    // MARK: - Aspect Ratio

    @objc public var aspectRatio: Float {
        get { yoga.aspectRatio }
        set { yoga.aspectRatio = newValue }
    }

    // MARK: - Gap

    @objc public var rowGap: CGFloat {
        get { CGFloat(yoga.rowGap.value) }
        set { yoga.rowGap = .points(Float(newValue)) }
    }

    @objc public var columnGap: CGFloat {
        get { CGFloat(yoga.columnGap.value) }
        set { yoga.columnGap = .points(Float(newValue)) }
    }

    // MARK: - Margin

    @objc public func setMargin(_ edge: YGKEdge, _ value: CGFloat) {
        yoga.setMargin(edge.swiftValue, .points(Float(value)))
    }

    @objc public func setMarginPercent(_ edge: YGKEdge, _ percent: CGFloat) {
        yoga.setMargin(edge.swiftValue, .percent(Float(percent)))
    }

    @objc public func setMarginAuto(_ edge: YGKEdge) {
        yoga.setMargin(edge.swiftValue, .auto)
    }

    @objc public func margin(forEdge edge: YGKEdge) -> CGFloat {
        CGFloat(yoga[edge.swiftValue].value)
    }

    @objc public func padding(forEdge edge: YGKEdge) -> CGFloat {
        let len = yoga.node.style.padding[edge.swiftValue.rawValue]
        return CGFloat(GWValue(from: len).value)
    }

    @objc public func border(forEdge edge: YGKEdge) -> CGFloat {
        let v = yoga.node.style.border[edge.swiftValue.rawValue]
        return v.isNaN ? 0 : CGFloat(v)
    }

    @objc public func position(forEdge edge: YGKEdge) -> CGFloat {
        let len = yoga.node.style.position[edge.swiftValue.rawValue]
        return CGFloat(GWValue(from: len).value)
    }

    // MARK: - Padding

    @objc public func setPadding(_ edge: YGKEdge, _ value: CGFloat) {
        yoga.setPadding(edge.swiftValue, .points(Float(value)))
    }

    @objc public func setPaddingPercent(_ edge: YGKEdge, _ percent: CGFloat) {
        yoga.setPadding(edge.swiftValue, .percent(Float(percent)))
    }

    // MARK: - Border

    @objc public func setBorder(_ edge: YGKEdge, _ width: CGFloat) {
        yoga.setBorder(edge.swiftValue, Float(width))
    }

    // MARK: - Position Offsets

    @objc public func setPosition(_ edge: YGKEdge, _ value: CGFloat) {
        yoga.setPosition(edge.swiftValue, .points(Float(value)))
    }

    @objc public func setPositionPercent(_ edge: YGKEdge, _ percent: CGFloat) {
        yoga.setPosition(edge.swiftValue, .percent(Float(percent)))
    }

    // MARK: - Layout

    /// Mark the node as dirty (needs re-layout).
    @objc public func markDirty() {
        yoga.markDirty()
    }

    /// The computed frame from the last layout pass.
    @objc public var frame: CGRect {
        yoga.frame
    }

    /// Whether the node is dirty.
    @objc public var isDirty: Bool {
        yoga.isDirty
    }

    // MARK: - Direction

    @objc public var direction: YGKDirection {
        get { YGKDirection.from(yoga.node.style.direction) }
        set { yoga.node.style.direction = newValue.swiftValue; yoga.node.markDirty() }
    }

    // MARK: - Intrinsic Content

    /// Whether the view's size is determined by its content (text, image, etc.)
    @objc public var isIntrinsic: Bool {
        get { yoga.isIntrinsic }
        set { yoga.isIntrinsic = newValue }
    }

    // MARK: - Grid

    @objc public func setGridTemplateColumns(_ tracks: [YGKGridTrackSize]) {
        yoga.gridTemplateColumns = tracks.map { $0.swiftValue }
        yoga.node.markDirty()
    }

    @objc public func setGridTemplateRows(_ tracks: [YGKGridTrackSize]) {
        yoga.gridTemplateRows = tracks.map { $0.swiftValue }
        yoga.node.markDirty()
    }

    @objc public func setGridAutoColumns(_ tracks: [YGKGridTrackSize]) {
        yoga.gridAutoColumns = tracks.map { $0.swiftValue }
        yoga.node.markDirty()
    }

    @objc public func setGridAutoRows(_ tracks: [YGKGridTrackSize]) {
        yoga.gridAutoRows = tracks.map { $0.swiftValue }
        yoga.node.markDirty()
    }

    @objc public var gridColumnStartLine: Int32 {
        get { yoga.gridColumnStart.value }
        set { yoga.gridColumnStart = GWGridLine(type: .integer, value: newValue); yoga.node.markDirty() }
    }

    @objc public var gridColumnEndLine: Int32 {
        get { yoga.gridColumnEnd.value }
        set { yoga.gridColumnEnd = GWGridLine(type: .integer, value: newValue); yoga.node.markDirty() }
    }

    @objc public var gridRowStartLine: Int32 {
        get { yoga.gridRowStart.value }
        set { yoga.gridRowStart = GWGridLine(type: .integer, value: newValue); yoga.node.markDirty() }
    }

    @objc public var gridRowEndLine: Int32 {
        get { yoga.gridRowEnd.value }
        set { yoga.gridRowEnd = GWGridLine(type: .integer, value: newValue); yoga.node.markDirty() }
    }

    @objc public var gridColumnStart: YGKGridLine {
        get { YGKGridLine(type: .from(yoga.gridColumnStart.type), value: yoga.gridColumnStart.value) }
        set { yoga.gridColumnStart = newValue.swiftValue; yoga.node.markDirty() }
    }

    @objc public var gridColumnEnd: YGKGridLine {
        get { YGKGridLine(type: .from(yoga.gridColumnEnd.type), value: yoga.gridColumnEnd.value) }
        set { yoga.gridColumnEnd = newValue.swiftValue; yoga.node.markDirty() }
    }

    @objc public var gridRowStart: YGKGridLine {
        get { YGKGridLine(type: .from(yoga.gridRowStart.type), value: yoga.gridRowStart.value) }
        set { yoga.gridRowStart = newValue.swiftValue; yoga.node.markDirty() }
    }

    @objc public var gridRowEnd: YGKGridLine {
        get { YGKGridLine(type: .from(yoga.gridRowEnd.type), value: yoga.gridRowEnd.value) }
        set { yoga.gridRowEnd = newValue.swiftValue; yoga.node.markDirty() }
    }

    // MARK: - Gap by gutter type

    @objc public func setGap(_ gutter: YGKGutter, _ value: CGFloat) {
        yoga.node.style.setGap(for: gutter.swiftValue, .points(Float(value)))
        yoga.node.markDirty()
    }

    // MARK: - Layout Result

    /// The computed left position from the last layout pass.
    @objc public var layoutLeft: CGFloat { CGFloat(yoga.layoutResult.left) }

    /// The computed top position from the last layout pass.
    @objc public var layoutTop: CGFloat { CGFloat(yoga.layoutResult.top) }

    /// The computed width from the last layout pass.
    @objc public var layoutWidth: CGFloat { CGFloat(yoga.layoutResult.width) }

    /// The computed height from the last layout pass.
    @objc public var layoutHeight: CGFloat { CGFloat(yoga.layoutResult.height) }
}
