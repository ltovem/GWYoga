import Foundation

// MARK: - Justify Main Axis

extension GWLayoutEngine {

    static func justifyMainAxis(
        flexLine: inout FlexLineResult,
        mainAxis: GWFlexDirection,
        crossAxis: GWFlexDirection,
        direction: GWDirection,
        widthSizingModeMainDim: GWSizingMode,
        sizingModeCrossDim: GWSizingMode,
        mainAxisOwnerSize: Float,
        ownerWidth: Float,
        availableInnerMainDim: Float,
        availableInnerCrossDim: Float,
        availableInnerWidth: Float,
        node: GWYogaNode,
        performLayout: Bool
    ) {
        let style = node.style
        var flexLineCrossDim: Float = 0

        // --- FitContent remainingFreeSpace adjustment (matching C++ lines 1037-1063) ---
        if widthSizingModeMainDim == .fitContent && flexLine.remainingFreeSpace > 0 {
            let mainLeadingPhys = flexStartPhysicalEdge(mainAxis)
            let mainTrailingPhys = flexEndPhysicalEdge(mainAxis)
            let leadingPaddingAndBorderMain: Float = mainAxis.dimension == .width ?
                node.layout.border(mainLeadingPhys) + node.layout.padding(mainLeadingPhys) :
                node.layout.border(.top) + node.layout.padding(.top)
            let trailingPaddingAndBorderMain: Float = mainAxis.dimension == .width ?
                node.layout.border(mainTrailingPhys) + node.layout.padding(mainTrailingPhys) :
                node.layout.border(.bottom) + node.layout.padding(.bottom)
            let minDim = mainAxis.dimension == .width ? style.minWidth : style.minHeight
            let resolvedMin = style.resolvedMinDimension(direction, dimension(mainAxis), mainAxisOwnerSize, ownerWidth)
            if minDim.isDefined && resolvedMin.isDefined {
                let minAvailableMainDim = resolvedMin.unwrap() - leadingPaddingAndBorderMain - trailingPaddingAndBorderMain
                let occupiedSpaceByChildNodes = availableInnerMainDim - flexLine.remainingFreeSpace
                flexLine.remainingFreeSpace = maxOrDefined(0, minAvailableMainDim - occupiedSpaceByChildNodes)
            } else {
                flexLine.remainingFreeSpace = 0
            }
        }

        // --- Justify content spacing ---
        let remainingFreeSpace = flexLine.remainingFreeSpace
        let effectiveJustify: GWJustify = remainingFreeSpace < 0
            ? fallbackAlignment(node.style.justifyContent)
            : node.style.justifyContent
        let justifyContent = effectiveJustify

        // Calculate leading and between spacing
        let (leadingMainDim, betweenMainDim): (Float, Float) = {
            switch justifyContent {
            case .center:
                return (remainingFreeSpace / 2, 0)
            case .flexEnd, .end:
                return (remainingFreeSpace, 0)
            case .spaceBetween:
                let count = flexLine.items.count
                let gap = count > 1 ? remainingFreeSpace / Float(count - 1) : 0
                return (0, gap)
            case .spaceAround:
                let count = flexLine.items.count
                let gap = count > 0 ? remainingFreeSpace / Float(count) : 0
                return (gap / 2, gap)
            case .spaceEvenly:
                let count = flexLine.items.count
                let gap = count > 0 ? remainingFreeSpace / Float(count + 1) : 0
                return (gap, gap)
            default: // flex-start, start, auto
                return (0, 0)
            }
        }()

        // Include parent's leading padding/border in initial offset (direction-aware)
        let mainLeadingPhys = flexStartPhysicalEdge(mainAxis)
        let mainTrailingPhys = flexEndPhysicalEdge(mainAxis)
        let leadingPaddingAndBorderMain: Float = mainAxis.dimension == .width ?
            node.layout.border(mainLeadingPhys) + node.layout.padding(mainLeadingPhys) :
            node.layout.border(.top) + node.layout.padding(.top)
        let trailingPaddingAndBorderMain: Float = mainAxis.dimension == .width ?
            node.layout.border(mainTrailingPhys) + node.layout.padding(mainTrailingPhys) :
            node.layout.border(.bottom) + node.layout.padding(.bottom)
        var currentMainDim = leadingPaddingAndBorderMain + leadingMainDim
        flexLine.mainDim = leadingPaddingAndBorderMain + leadingMainDim

        // Resolve gap
        let mainAxisGutter: GWGutter = mainAxis.isRow ? .column : .row
        let resolvedGap = node.style.resolvedGap(for: mainAxisGutter)
        let gapLength = resolvedGap.resolve(referenceLength: mainAxisOwnerSize).unwrap(orDefault: 0)

        // Baseline tracking
        var maxAscentForCurrentLine: Float = 0
        var maxDescentForCurrentLine: Float = 0
        let isNodeBaselineLayout = isBaselineLayout(node)

        let canSkipFlex = !performLayout && sizingModeCrossDim == .stretchFit

        for (itemIdx, item) in flexLine.items.enumerated() {
            let child = item.node
            let autoCount = flexLine.numberOfAutoMargins
            let spacePerAutoMargin = (remainingFreeSpace > 0 && autoCount > 0) ? remainingFreeSpace / Float(autoCount) : 0 as Float

            let childMainDim = mainAxis.dimension == .width ?
                child.layout.dimension(.width) : child.layout.dimension(.height)
            let childCrossDim = crossAxis.dimension == .width ?
                child.layout.dimension(.width) : child.layout.dimension(.height)

            // Auto margin (start)
            if item.hasAutoMainMarginStart && spacePerAutoMargin > 0 {
                currentMainDim += spacePerAutoMargin
            }

            // Position child (direction-aware start edge)
            if performLayout {
                let position = currentMainDim + item.mainMarginStart
                let mainPhysEdge = flexStartPhysicalEdge(mainAxis)
                child.layout.setPosition(mainPhysEdge, position)
            }

            // Between items spacing (not for last item)
            if itemIdx < flexLine.items.count - 1 {
                currentMainDim += betweenMainDim + gapLength
            }

            // Auto margin (end)
            if item.hasAutoMainMarginEnd && spacePerAutoMargin > 0 {
                currentMainDim += spacePerAutoMargin
            }

            // Main dimension accumulation (matching C++ dimensionWithMargin + canSkipFlex)
            if canSkipFlex {
                currentMainDim +=
                    child.style.computeMarginForAxis(mainAxis, availableInnerWidth) +
                    boundAxisWithinMinAndMax(child, direction: direction, axis: mainAxis,
                                              value: child.cache.computedFlexBasis,
                                              axisSize: mainAxisOwnerSize, widthSize: ownerWidth).unwrap()
                flexLineCrossDim = availableInnerCrossDim
            } else {
                currentMainDim += childMainDim + item.mainMarginStart + item.mainMarginEnd

                if isNodeBaselineLayout {
                    let ascent = calculateBaseline(child) +
                        child.style.computeFlexStartMargin(.column, direction, availableInnerWidth)
                    let descent = child.layout.dimension(dimension(.column)) +
                        child.style.computeMarginForAxis(.column, availableInnerWidth) - ascent
                    maxAscentForCurrentLine = maxOrDefined(maxAscentForCurrentLine, ascent)
                    maxDescentForCurrentLine = maxOrDefined(maxDescentForCurrentLine, descent)
                } else {
                    // Cross dimension is max of children's dimensionWithMargin
                    let childCrossWithMargin = childCrossDim + item.crossMarginStart + item.crossMarginEnd
                    flexLineCrossDim = max(flexLineCrossDim, childCrossWithMargin)
                }
            }
        }

        flexLine.mainDim = currentMainDim + trailingPaddingAndBorderMain

        if isNodeBaselineLayout {
            flexLine.crossDim = maxAscentForCurrentLine + maxDescentForCurrentLine
        } else {
            flexLine.crossDim = flexLineCrossDim
        }
    }
}
