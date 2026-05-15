import Foundation

// MARK: - Layout Engine

/// Pure Swift implementation of the Yoga flexbox layout algorithm.
/// Ported from Yoga's C++ `CalculateLayout.cpp` with Swift idioms.
public enum GWLayoutEngine {

    // MARK: - Generation count

    /// Monotonically increasing generation count for cache invalidation
    static var gCurrentGenerationCount: UInt32 = 0

    // MARK: - Public Entry Point

    /// Calculate layout for the given node tree.
    /// - Parameters:
    ///   - node: The root node to lay out
    ///   - ownerWidth: Available width from parent (NaN = undefined)
    ///   - ownerHeight: Available height from parent
    ///   - ownerDirection: Text direction (LTR/RTL/Inherit)
    public static func calculateLayout(
        node: GWYogaNode,
        ownerWidth: Float,
        ownerHeight: Float,
        ownerDirection: GWDirection
    ) {
        GWEvent.publish(node: node, type: .layoutPassStart)

        gCurrentGenerationCount += 1
        let generationCount = gCurrentGenerationCount
        var markerData = GWLayoutData()

        node.cache.configVersion = node.config.version

        // Resolve direction
        let direction = node.resolveDirection(ownerDirection)

        // Determine available space and sizing modes (C++ calculateLayout logic)
        var availableWidth = ownerWidth
        var widthSizingMode: GWSizingMode
        if node.hasDefiniteLength(.width, ownerWidth) {
            availableWidth = node.getResolvedDimension(direction, .width, ownerWidth, ownerWidth).unwrap()
                + node.style.computeMarginForAxis(.row, ownerWidth)
            widthSizingMode = .stretchFit
        } else {
            let maxWidth = node.style.resolvedMaxDimension(direction, .width, ownerWidth, ownerWidth)
            if maxWidth.isDefined {
                availableWidth = maxWidth.unwrap()
                widthSizingMode = .fitContent
            } else if !availableWidth.isNaN {
                widthSizingMode = .stretchFit
            } else {
                widthSizingMode = .maxContent
            }
        }

        var availableHeight = ownerHeight
        var heightSizingMode: GWSizingMode
        if node.hasDefiniteLength(.height, ownerHeight) {
            availableHeight = node.getResolvedDimension(direction, .height, ownerHeight, ownerWidth).unwrap()
                + node.style.computeMarginForAxis(.column, ownerWidth)
            heightSizingMode = .stretchFit
        } else {
            let maxHeight = node.style.resolvedMaxDimension(direction, .height, ownerHeight, ownerWidth)
            if maxHeight.isDefined {
                availableHeight = maxHeight.unwrap()
                heightSizingMode = .fitContent
            } else if !availableHeight.isNaN {
                heightSizingMode = .stretchFit
            } else {
                heightSizingMode = .maxContent
            }
        }

        if availableWidth.isNaN { availableWidth = .nan }
        if availableHeight.isNaN { availableHeight = .nan }

        // Run layout
        let layoutPerformed = calculateLayoutInternal(
            node: node,
            availableWidth: availableWidth,
            availableHeight: availableHeight,
            ownerDirection: direction,
            widthSizingMode: widthSizingMode,
            heightSizingMode: heightSizingMode,
            ownerWidth: ownerWidth,
            ownerHeight: ownerHeight,
            performLayout: true,
            layoutPassReason: .initial,
            layoutMarkerData: &markerData,
            depth: 0,
            generationCount: generationCount
        )

        if layoutPerformed {
            node.setPosition(direction, ownerWidth, ownerHeight)

            roundLayoutResultsToPixelGrid(
                node: node,
                absoluteLeft: 0,
                absoluteTop: 0
            )
        }

        GWEvent.publish(node: node, type: .layoutPassEnd, data: .layoutPassEnd(layoutData: markerData))
    }

    // MARK: - Pixel Grid（像素网格对齐）

    /// 把单个值按像素网格取整。
    /// - Parameters:
    ///   - value: 原始浮点值
    ///   - pointScaleFactor: 像素密度比例（0=不取整）
    ///   - forceCeil: 强制向上取整
    ///   - forceFloor: 强制向下取整
    static func roundValueToPixelGrid(
        _ value: Float,
        pointScaleFactor: Float,
        forceCeil: Bool,
        forceFloor: Bool
    ) -> Float {
        guard pointScaleFactor != 0, !value.isNaN else { return value }
        let scale = pointScaleFactor
        let scaledValue = value * scale
        var fractial = scaledValue.truncatingRemainder(dividingBy: 1.0)
        if fractial < 0 {
            fractial += 1.0
        }
        let epsilon: Float = 0.0001
        var roundedScaled: Float
        if abs(fractial) < epsilon {
            roundedScaled = scaledValue - fractial
        } else if abs(fractial - 1.0) < epsilon {
            roundedScaled = scaledValue - fractial + 1.0
        } else if forceCeil {
            roundedScaled = scaledValue - fractial + 1.0
        } else if forceFloor {
            roundedScaled = scaledValue - fractial
        } else {
            roundedScaled = scaledValue - fractial + (fractial > 0.5 ? 1.0 : 0.0)
        }
        return roundedScaled / scale
    }

    /// 递归取整节点及其子树的布局结果到像素网格。
    /// 基于 C++ Yoga 的 `roundLayoutResultsToPixelGrid`。
    private static func roundLayoutResultsToPixelGrid(
        node: GWYogaNode,
        absoluteLeft: Float,
        absoluteTop: Float
    ) {
        let scale = node.config.pointScaleFactor
        let nodeLeft = node.layout.position(.left)
        let nodeTop = node.layout.position(.top)
        let nodeWidth = node.layout.dimension(.width)
        let nodeHeight = node.layout.dimension(.height)

        let absoluteNodeLeft = absoluteLeft + nodeLeft
        let absoluteNodeTop = absoluteTop + nodeTop
        let absoluteNodeRight = absoluteNodeLeft + nodeWidth
        let absoluteNodeBottom = absoluteNodeTop + nodeHeight

        if scale != 0 {
            // Text 节点使用 measure function，不能向下取整（可能截断文字）
            let textRounding = node.nodeType == .text

            node.layout.setPosition(.left, roundValueToPixelGrid(
                nodeLeft, pointScaleFactor: scale, forceCeil: false, forceFloor: textRounding))
            node.layout.setPosition(.top, roundValueToPixelGrid(
                nodeTop, pointScaleFactor: scale, forceCeil: false, forceFloor: textRounding))

            let scaledWidth = nodeWidth * scale
            let hasFractionalWidth = abs(round(scaledWidth) - scaledWidth) > 0.0001
            let scaledHeight = nodeHeight * scale
            let hasFractionalHeight = abs(round(scaledHeight) - scaledHeight) > 0.0001

            node.layout.setDimension(.width,
                roundValueToPixelGrid(absoluteNodeRight, pointScaleFactor: scale,
                    forceCeil: textRounding && hasFractionalWidth,
                    forceFloor: textRounding && !hasFractionalWidth)
                - roundValueToPixelGrid(absoluteNodeLeft, pointScaleFactor: scale,
                    forceCeil: false, forceFloor: textRounding))

            node.layout.setDimension(.height,
                roundValueToPixelGrid(absoluteNodeBottom, pointScaleFactor: scale,
                    forceCeil: textRounding && hasFractionalHeight,
                    forceFloor: textRounding && !hasFractionalHeight)
                - roundValueToPixelGrid(absoluteNodeTop, pointScaleFactor: scale,
                    forceCeil: false, forceFloor: textRounding))
        }

        for child in node.children {
            roundLayoutResultsToPixelGrid(node: child, absoluteLeft: absoluteNodeLeft, absoluteTop: absoluteNodeTop)
        }
    }

    // MARK: - Cache layer

    @discardableResult
    static func calculateLayoutInternal(
        node: GWYogaNode,
        availableWidth: Float,
        availableHeight: Float,
        ownerDirection: GWDirection,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        ownerWidth: Float,
        ownerHeight: Float,
        performLayout: Bool,
        layoutPassReason: GWLayoutPassReason,
        layoutMarkerData: inout GWLayoutData,
        depth: UInt32,
        generationCount: UInt32
    ) -> Bool {
        let depth = depth + 1

        // Determine if we need to visit (recalculate) this node
        let needToVisitNode: Bool = {
            if node.isDirty { return true }
            if node.cache.lastOwnerDirection != ownerDirection { return true }
            if node.cache.configVersion != node.config.version { return true }
            return false
        }()

        if needToVisitNode {
            // Invalidate the cached results
            node.cache.nextMeasurementIndex = 0
            node.cache.cachedLayout = GWCachedMeasurement(
                availableWidth: -1, availableHeight: -1,
                widthSizingMode: .maxContent, heightSizingMode: .maxContent,
                computedWidth: -1, computedHeight: -1
            )
        }

        var cachedResults: GWCachedMeasurement? = nil

        // Determine whether the results are already cached
        if node.measureFunction != nil {
            let marginAxisRow = node.style.computeMarginForAxis(.row, ownerWidth)
            let marginAxisColumn = node.style.computeMarginForAxis(.column, ownerWidth)

            // First, try to use the layout cache
            if canUseCachedMeasurement(
                widthMode: widthSizingMode, availableWidth: availableWidth,
                heightMode: heightSizingMode, availableHeight: availableHeight,
                lastWidthMode: node.cache.cachedLayout.widthSizingMode,
                lastAvailableWidth: node.cache.cachedLayout.availableWidth,
                lastHeightMode: node.cache.cachedLayout.heightSizingMode,
                lastAvailableHeight: node.cache.cachedLayout.availableHeight,
                lastComputedWidth: node.cache.cachedLayout.computedWidth,
                lastComputedHeight: node.cache.cachedLayout.computedHeight,
                marginRow: marginAxisRow, marginColumn: marginAxisColumn,
                config: node.config
            ) {
                cachedResults = node.cache.cachedLayout
            } else {
                // Try to use the measurement cache ring buffer
                let count = min(Int(node.cache.nextMeasurementIndex), node.cache.cachedMeasurements.count)
                for i in 0..<count {
                    let m = node.cache.cachedMeasurements[i]
                    if canUseCachedMeasurement(
                        widthMode: widthSizingMode, availableWidth: availableWidth,
                        heightMode: heightSizingMode, availableHeight: availableHeight,
                        lastWidthMode: m.widthSizingMode,
                        lastAvailableWidth: m.availableWidth,
                        lastHeightMode: m.heightSizingMode,
                        lastAvailableHeight: m.availableHeight,
                        lastComputedWidth: m.computedWidth,
                        lastComputedHeight: m.computedHeight,
                        marginRow: marginAxisRow, marginColumn: marginAxisColumn,
                        config: node.config
                    ) {
                        cachedResults = node.cache.cachedMeasurements[i]
                        break
                    }
                }
            }
        } else if performLayout {
            if inexactEquals(node.cache.cachedLayout.availableWidth, availableWidth) &&
                inexactEquals(node.cache.cachedLayout.availableHeight, availableHeight) &&
                node.cache.cachedLayout.widthSizingMode == widthSizingMode &&
                node.cache.cachedLayout.heightSizingMode == heightSizingMode {
                cachedResults = node.cache.cachedLayout
            }
        } else {
            let count = min(Int(node.cache.nextMeasurementIndex), node.cache.cachedMeasurements.count)
            for i in 0..<count {
                let m = node.cache.cachedMeasurements[i]
                if inexactEquals(m.availableWidth, availableWidth) &&
                    inexactEquals(m.availableHeight, availableHeight) &&
                    m.widthSizingMode == widthSizingMode &&
                    m.heightSizingMode == heightSizingMode {
                    cachedResults = node.cache.cachedMeasurements[i]
                    break
                }
            }
        }

        if !needToVisitNode, let cached = cachedResults {
            // Cache hit — reuse computed dimensions
            node.layout.setDimension(.width, cached.computedWidth)
            node.layout.setDimension(.height, cached.computedHeight)

            if performLayout {
                layoutMarkerData.cachedLayouts += 1
            } else {
                layoutMarkerData.cachedMeasures += 1
            }
        } else {
            // Cache miss — perform full layout
            if performLayout {
                layoutMarkerData.layouts += 1
            } else {
                layoutMarkerData.measures += 1
            }

            calculateLayoutImpl(
                node: node,
                availableWidth: availableWidth,
                availableHeight: availableHeight,
                ownerDirection: ownerDirection,
                widthSizingMode: widthSizingMode,
                heightSizingMode: heightSizingMode,
                ownerWidth: ownerWidth,
                ownerHeight: ownerHeight,
                performLayout: performLayout,
                layoutPassReason: layoutPassReason,
                layoutMarkerData: &layoutMarkerData,
                depth: depth
            )

            // Update tracking
            node.cache.lastOwnerDirection = ownerDirection
            node.cache.configVersion = node.config.version

            if cachedResults == nil {
                if node.cache.nextMeasurementIndex >= UInt32(node.cache.cachedMeasurements.count) {
                    node.cache.nextMeasurementIndex = 0
                }

                if performLayout {
                    node.cache.cachedLayout = GWCachedMeasurement(
                        availableWidth: availableWidth,
                        availableHeight: availableHeight,
                        widthSizingMode: widthSizingMode,
                        heightSizingMode: heightSizingMode,
                        computedWidth: node.layout.dimension(.width),
                        computedHeight: node.layout.dimension(.height)
                    )
                } else {
                    let idx = Int(node.cache.nextMeasurementIndex)
                    node.cache.cachedMeasurements[idx] = GWCachedMeasurement(
                        availableWidth: availableWidth,
                        availableHeight: availableHeight,
                        widthSizingMode: widthSizingMode,
                        heightSizingMode: heightSizingMode,
                        computedWidth: node.layout.dimension(.width),
                        computedHeight: node.layout.dimension(.height)
                    )
                    node.cache.nextMeasurementIndex += 1
                }
            }
        }

        if performLayout {
            node.hasNewLayout = true
            node.isDirty = false
        }

        node.cache.generationCount = generationCount

        // Publish NodeLayout event
        let layoutType: GWLayoutType
        if performLayout {
            layoutType = (!needToVisitNode && cachedResults?.widthSizingMode == node.cache.cachedLayout.widthSizingMode)
                ? .cachedLayout : .layout
        } else {
            layoutType = cachedResults != nil ? .cachedMeasure : .measure
        }
        GWEvent.publish(node: node, type: .nodeLayout, data: .nodeLayout(layoutType: layoutType))

        return needToVisitNode || cachedResults == nil
    }
}
