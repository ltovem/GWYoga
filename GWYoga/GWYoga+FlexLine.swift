import Foundation

// MARK: - Flex Line

extension GWLayoutEngine {

    struct FlexLineItem {
        let node: GWYogaNode
        let flexBasis: Float
        let flexGrowFactor: Float
        let flexShrinkFactor: Float
        let flexShrinkScaledFactor: Float
        let mainMarginStart: Float
        let mainMarginEnd: Float
        let crossMarginStart: Float
        let crossMarginEnd: Float
        /// auto margins 标记：true 表示该边距为 auto（需要吸收剩余空间）
        let hasAutoMainMarginStart: Bool
        let hasAutoMainMarginEnd: Bool
    }

    struct FlexLineResult {
        var items: [FlexLineItem]
        var totalFlexGrowFactors: Float
        var totalFlexShrinkScaledFactors: Float
        var sizeConsumed: Float
        var numberOfAutoMargins: Int
        var mainDim: Float
        var crossDim: Float
        var nextIndex: Int
        var remainingFreeSpace: Float
    }

    static func calculateFlexLine(
        node: GWYogaNode,
        mainAxis: GWFlexDirection,
        crossAxis: GWFlexDirection,
        direction: GWDirection,
        ownerWidth: Float,
        mainAxisOwnerSize: Float,
        availableInnerWidth: Float,
        availableInnerMainDim: Float,
        startIndex: Int,
        lineCount: Int
    ) -> FlexLineResult {
        var items: [FlexLineItem] = []
        var totalFlexGrowFactors: Float = 0
        var totalFlexShrinkScaledFactors: Float = 0
        var sizeConsumed: Float = 0
        var numberOfAutoMargins: Int = 0
        let isMultiLine = node.style.flexWrap == .wrap || node.style.flexWrap == .wrapReverse
        var i = startIndex

        // 解析主轴 gap，用于换行判断（gap 也占用空间）
        let gapMain = node.style.resolvedGap(for: mainAxis.dimension == .width ? .column : .row)
        let gapLength = gapMain.resolve(referenceLength: mainAxisOwnerSize).unwrap(orDefault: 0)
        var firstElementInLine: GWYogaNode?

        while i < node.children.count {
            let child = node.children[i]
            i += 1

            if child.style.display == .none {
                zeroOutLayoutRecursively(child)
                continue
            }

            if child.style.positionType == .absolute {
                continue
            }

            // 获取缓存的 flex basis（已由 computeFlexBasisForChild 设置）
            let cachedFlexBasis = child.cache.computedFlexBasis.unwrap(orDefault: 0)

            // 在 min/max 范围内钳制 flex basis
            let clampedFlexBasis = boundAxisWithinMinAndMax(child, direction: direction, axis: mainAxis,
                                                             value: GWFloatOptional(value: cachedFlexBasis),
                                                             axisSize: mainAxisOwnerSize, widthSize: availableInnerWidth)
                .unwrap(orDefault: 0)

            // 计算 margin (使用 direction-aware 边)
            let mainMarginStart = resolveMargin(child, edge: inlineStartEdge(mainAxis, direction), direction: direction,
                                                 ownerWidth: availableInnerWidth)
            let mainMarginEnd = resolveMargin(child, edge: inlineEndEdge(mainAxis, direction), direction: direction,
                                               ownerWidth: availableInnerWidth)
            let crossMarginStart = resolveMargin(child, edge: inlineStartEdge(crossAxis, direction), direction: direction,
                                                  ownerWidth: availableInnerWidth)
            let crossMarginEnd = resolveMargin(child, edge: inlineEndEdge(crossAxis, direction), direction: direction,
                                                ownerWidth: availableInnerWidth)

            let marginMain = mainMarginStart + mainMarginEnd

            // Flex 增长/收缩因子
            let flexGrowFactor = max(resolveFlexGrow(child), 0)
            let flexShrinkFactor = max(resolveFlexShrink(child), 0)
            let flexShrinkScaledFactor = -flexShrinkFactor * clampedFlexBasis

            // 换行判断：gap 计入已消耗空间（CSS 标准行为）
            let childLeadingGap = firstElementInLine == nil ? 0.0 : gapLength
            let itemSizeWithGap = clampedFlexBasis + marginMain + childLeadingGap
            if isMultiLine && items.count > 0 && sizeConsumed + itemSizeWithGap > availableInnerMainDim {
                // 当前行放不下 — 结束本行
                i -= 1
                break
            }

            // 检测 auto margins：auto 边距会吸收主轴剩余空间
            let isAutoMainMarginStart = child.style.resolvedMargin(for: inlineStartEdge(mainAxis, direction), direction: direction).isAuto
            let isAutoMainMarginEnd = child.style.resolvedMargin(for: inlineEndEdge(mainAxis, direction), direction: direction).isAuto
            if isAutoMainMarginStart { numberOfAutoMargins += 1 }
            if isAutoMainMarginEnd { numberOfAutoMargins += 1 }

            sizeConsumed += itemSizeWithGap
            totalFlexGrowFactors += flexGrowFactor
            totalFlexShrinkScaledFactors += flexShrinkScaledFactor
            firstElementInLine = child

            items.append(FlexLineItem(
                node: child,
                flexBasis: clampedFlexBasis,
                flexGrowFactor: flexGrowFactor,
                flexShrinkFactor: flexShrinkFactor,
                flexShrinkScaledFactor: flexShrinkScaledFactor,
                mainMarginStart: mainMarginStart,
                mainMarginEnd: mainMarginEnd,
                crossMarginStart: crossMarginStart,
                crossMarginEnd: crossMarginEnd,
                hasAutoMainMarginStart: isAutoMainMarginStart,
                hasAutoMainMarginEnd: isAutoMainMarginEnd
            ))
        }

        // Floor total flex factors to 1 if between 0 and 1
        if totalFlexGrowFactors > 0 && totalFlexGrowFactors < 1 {
            totalFlexGrowFactors = 1
        }
        if totalFlexShrinkScaledFactors > 0 && totalFlexShrinkScaledFactors < 1 {
            totalFlexShrinkScaledFactors = 1
        }

        return FlexLineResult(
            items: items,
            totalFlexGrowFactors: totalFlexGrowFactors,
            totalFlexShrinkScaledFactors: totalFlexShrinkScaledFactors,
            sizeConsumed: sizeConsumed,
            numberOfAutoMargins: numberOfAutoMargins,
            mainDim: 0,
            crossDim: 0,
            nextIndex: i,
            remainingFreeSpace: 0
        )
    }

    // MARK: - Flexible Length Resolution (Two-Pass, matching C++)

    /// First pass: detect min/max constraint triggering and adjust flex factors.
    /// Does NOT set child dimensions or call calculateLayoutInternal.
    private static func distributeFreeSpaceFirstPass(
        flexLine: inout FlexLineResult,
        direction: GWDirection,
        mainAxis: GWFlexDirection,
        ownerWidth: Float,
        mainAxisOwnerSize: Float,
        availableInnerMainDim: Float,
        availableInnerWidth: Float
    ) {
        var remain = flexLine.remainingFreeSpace
        var totalGrow = flexLine.totalFlexGrowFactors
        var totalShrink = flexLine.totalFlexShrinkScaledFactors

        for i in 0..<flexLine.items.count {
            let item = flexLine.items[i]
            let childFlexBasis = boundAxisWithinMinAndMax(
                item.node, direction: direction, axis: mainAxis,
                value: GWFloatOptional(value: item.flexBasis),
                axisSize: mainAxisOwnerSize, widthSize: ownerWidth
            ).unwrap()

            if remain < 0 {
                let flexShrinkScaledFactor = -item.node.resolveFlexShrink() * childFlexBasis
                if isDefined(flexShrinkScaledFactor) && flexShrinkScaledFactor != 0 && totalShrink != 0 {
                    let baseMainSize = childFlexBasis + remain / totalShrink * flexShrinkScaledFactor
                    let boundMainSize = boundAxis(item.node, axis: mainAxis, value: baseMainSize,
                                                   direction: direction, axisSize: mainAxisOwnerSize, widthSize: ownerWidth)
                    if isDefined(baseMainSize) && isDefined(boundMainSize) && abs(baseMainSize - boundMainSize) > 0.001 {
                        remain += childFlexBasis - boundMainSize
                        totalShrink -= (-item.node.resolveFlexShrink() * item.flexBasis)
                    }
                }
            } else if remain > 0 {
                let flexGrowFactor = item.node.resolveFlexGrow()
                if isDefined(flexGrowFactor) && flexGrowFactor != 0 && totalGrow != 0 {
                    let baseMainSize = childFlexBasis + remain / totalGrow * flexGrowFactor
                    let boundMainSize = boundAxis(item.node, axis: mainAxis, value: baseMainSize,
                                                   direction: direction, axisSize: mainAxisOwnerSize, widthSize: ownerWidth)
                    if isDefined(baseMainSize) && isDefined(boundMainSize) && abs(baseMainSize - boundMainSize) > 0.001 {
                        remain += childFlexBasis - boundMainSize
                        totalGrow -= flexGrowFactor
                    }
                }
            }
        }

        flexLine.remainingFreeSpace = remain
        flexLine.totalFlexGrowFactors = totalGrow
        flexLine.totalFlexShrinkScaledFactors = totalShrink
    }

    /// Second pass: resolve sizes of flexible items and recursively lay out children.
    /// Returns deltaFreeSpace (total change from flex bases).
    private static func distributeFreeSpaceSecondPass(
        flexLine: FlexLineResult,
        node: GWYogaNode,
        mainAxis: GWFlexDirection,
        crossAxis: GWFlexDirection,
        direction: GWDirection,
        ownerWidth: Float,
        mainAxisOwnerSize: Float,
        availableInnerMainDim: Float,
        availableInnerCrossDim: Float,
        availableInnerWidth: Float,
        availableInnerHeight: Float,
        mainAxisOverflows: Bool,
        sizingModeCrossDim: GWSizingMode,
        performLayout: Bool,
        depth: UInt32,
        generationCount: UInt32,
        layoutMarkerData: inout GWLayoutData
    ) -> Float {
        let isMainAxisRow = mainAxis.isRow
        let isNodeFlexWrap = node.style.flexWrap != .noWrap
        let remain = flexLine.remainingFreeSpace
        let totalGrow = flexLine.totalFlexGrowFactors
        let totalShrink = flexLine.totalFlexShrinkScaledFactors
        var deltaFreeSpace: Float = 0

        for currentLineChild in flexLine.items {
            let child = currentLineChild.node
            let childFlexBasis = boundAxisWithinMinAndMax(
                child, direction: direction, axis: mainAxis,
                value: GWFloatOptional(value: currentLineChild.flexBasis),
                axisSize: mainAxisOwnerSize, widthSize: ownerWidth
            ).unwrap()
            var updatedMainSize = childFlexBasis

            if isDefined(remain) && remain < 0 {
                let flexShrinkScaledFactor = -child.resolveFlexShrink() * childFlexBasis
                if flexShrinkScaledFactor != 0 {
                    if isDefined(totalShrink) && totalShrink == 0 {
                        updatedMainSize = childFlexBasis + flexShrinkScaledFactor
                    } else if totalShrink != 0 {
                        updatedMainSize = childFlexBasis + (remain / totalShrink) * flexShrinkScaledFactor
                    }
                }
            } else if isDefined(remain) && remain > 0 {
                let flexGrowFactor = child.resolveFlexGrow()
                if flexGrowFactor != 0 {
                    updatedMainSize = boundAxis(
                        child, axis: mainAxis, value: childFlexBasis + remain / totalGrow * flexGrowFactor,
                        direction: direction, axisSize: mainAxisOwnerSize, widthSize: ownerWidth)
                }
            }

            // Skip shrinking if clamping to min/max will make it the same
            if remain < 0 {
                updatedMainSize = boundAxis(
                    child, axis: mainAxis, value: updatedMainSize,
                    direction: direction, axisSize: mainAxisOwnerSize, widthSize: ownerWidth)
            }

            deltaFreeSpace += updatedMainSize - childFlexBasis

            // Determine cross-axis sizing
            let marginMain = child.style.computeMarginForAxis(mainAxis, availableInnerWidth)
            let marginCross = child.style.computeMarginForAxis(crossAxis, availableInnerWidth)

            var childCrossSize = Float.nan
            var childMainSize = updatedMainSize + marginMain
            var childCrossSizingMode: GWSizingMode = .maxContent
            var childMainSizingMode: GWSizingMode = .stretchFit

            if child.style.aspectRatio.isDefined {
                let ratio = child.style.aspectRatio.unwrap()
                if isMainAxisRow {
                    childCrossSize = (childMainSize - marginMain) / ratio + marginCross
                } else {
                    childCrossSize = (childMainSize - marginMain) * ratio + marginCross
                }
                childCrossSizingMode = .stretchFit
            } else if !isUndefined(availableInnerCrossDim) &&
                        !child.hasDefiniteLength(crossAxis.dimension, availableInnerCrossDim) &&
                        sizingModeCrossDim == .stretchFit &&
                        !(isNodeFlexWrap && mainAxisOverflows) &&
                        resolveChildAlignment(parent: node.style, child: child.style) == .stretch &&
                        !child.style.flexStartMarginIsAuto(crossAxis, direction) &&
                        !child.style.flexEndMarginIsAuto(crossAxis, direction) {
                childCrossSize = availableInnerCrossDim
                childCrossSizingMode = .stretchFit
            } else if !child.hasDefiniteLength(crossAxis.dimension, availableInnerCrossDim) {
                childCrossSize = availableInnerCrossDim
                childCrossSizingMode = isUndefined(childCrossSize) ? .maxContent : .fitContent
            } else {
                let resolvedDim = child.getResolvedDimension(direction, crossAxis.dimension, availableInnerCrossDim, availableInnerWidth)
                childCrossSize = resolvedDim.unwrap(orDefault: 0) + marginCross
                let dimStyle = child.style.dimensions[crossAxis.dimension.rawValue]
                let isLoosePercent = dimStyle.isPercent &&
                                     sizingModeCrossDim != .stretchFit
                childCrossSizingMode = isUndefined(childCrossSize) || isLoosePercent ? .maxContent : .stretchFit
            }

            // Apply max size constraints
            constrainMaxSizeForMode(&childMainSizingMode, &childMainSize,
                                     node: child, direction: direction, axis: mainAxis,
                                     ownerAxisSize: availableInnerMainDim, ownerWidth: availableInnerWidth)
            constrainMaxSizeForMode(&childCrossSizingMode, &childCrossSize,
                                     node: child, direction: direction, axis: crossAxis,
                                     ownerAxisSize: availableInnerCrossDim, ownerWidth: availableInnerWidth)

            // Determine if this item needs stretch re-measurement after alignment
            let requiresStretchLayout = !child.hasDefiniteLength(crossAxis.dimension, availableInnerCrossDim) &&
                resolveChildAlignment(parent: node.style, child: child.style) == .stretch &&
                !child.style.flexStartMarginIsAuto(crossAxis, direction) &&
                !child.style.flexEndMarginIsAuto(crossAxis, direction)

            // Set child main axis dimension
            let finalMainDim = boundAxis(child, axis: mainAxis, value: updatedMainSize,
                                          direction: direction, axisSize: mainAxisOwnerSize, widthSize: ownerWidth)
            if mainAxis.dimension == .width {
                child.layout.setDimension(.width, finalMainDim)
            } else {
                child.layout.setDimension(.height, finalMainDim)
            }

            let childWidth = isMainAxisRow ? childMainSize : childCrossSize
            let childHeight = !isMainAxisRow ? childMainSize : childCrossSize
            let childWidthSizingMode = isMainAxisRow ? childMainSizingMode : childCrossSizingMode
            let childHeightSizingMode = !isMainAxisRow ? childMainSizingMode : childCrossSizingMode

            let isLayoutPass = performLayout && !requiresStretchLayout
            let _ = calculateLayoutInternal(
                node: child,
                availableWidth: childWidth,
                availableHeight: childHeight,
                ownerDirection: direction,
                widthSizingMode: childWidthSizingMode,
                heightSizingMode: childHeightSizingMode,
                ownerWidth: availableInnerWidth,
                ownerHeight: availableInnerHeight,
                performLayout: isLayoutPass,
                layoutPassReason: isLayoutPass ? .flexLayout : .flexMeasure,
                layoutMarkerData: &layoutMarkerData,
                depth: depth + 1,
                generationCount: generationCount
            )

            if child.layout.hadOverflow {
                node.layout.hadOverflow = true
            }

        }

        return deltaFreeSpace
    }

    /// Resolve flexible lengths via two-pass distribution (matching C++).
    static func resolveFlexibleLength(
        node: GWYogaNode,
        flexLine: inout FlexLineResult,
        mainAxis: GWFlexDirection,
        crossAxis: GWFlexDirection,
        direction: GWDirection,
        ownerWidth: Float,
        mainAxisOwnerSize: Float,
        availableInnerMainDim: Float,
        availableInnerCrossDim: Float,
        availableInnerWidth: Float,
        availableInnerHeight: Float,
        mainAxisOverflows: Bool,
        widthSizingModeMainDim: GWSizingMode,
        sizingModeCrossDim: GWSizingMode,
        performLayout: Bool,
        depth: UInt32,
        generationCount: UInt32,
        layoutMarkerData: inout GWLayoutData
    ) {
        // --- sizeBasedOnContent logic (C++ step 5) ---
        var effectiveAvailableInnerMainDim = availableInnerMainDim
        var sizeBasedOnContent = false

        if widthSizingModeMainDim != .stretchFit {
            let minInnerWidth =
                node.style.resolvedMinDimension(direction, .width, mainAxisOwnerSize, ownerWidth).unwrap() -
                paddingAndBorderForAxis(node, axis: .row, direction: direction, widthSize: ownerWidth)
            let maxInnerWidth =
                node.style.resolvedMaxDimension(direction, .width, mainAxisOwnerSize, ownerWidth).unwrap() -
                paddingAndBorderForAxis(node, axis: .row, direction: direction, widthSize: ownerWidth)
            let minInnerHeight =
                node.style.resolvedMinDimension(direction, .height, mainAxisOwnerSize, ownerWidth).unwrap() -
                paddingAndBorderForAxis(node, axis: .column, direction: direction, widthSize: ownerWidth)
            let maxInnerHeight =
                node.style.resolvedMaxDimension(direction, .height, mainAxisOwnerSize, ownerWidth).unwrap() -
                paddingAndBorderForAxis(node, axis: .column, direction: direction, widthSize: ownerWidth)

            let minInnerMainDim = mainAxis.dimension == .width ? minInnerWidth : minInnerHeight
            let maxInnerMainDim = mainAxis.dimension == .width ? maxInnerWidth : maxInnerHeight

            if isDefined(minInnerMainDim) && flexLine.sizeConsumed < minInnerMainDim {
                effectiveAvailableInnerMainDim = minInnerMainDim
            } else if isDefined(maxInnerMainDim) && flexLine.sizeConsumed > maxInnerMainDim {
                effectiveAvailableInnerMainDim = maxInnerMainDim
            } else {
                let useLegacyStretchBehaviour = node.hasErrata(.stretchFlexBasis)
                if !useLegacyStretchBehaviour &&
                    ((isDefined(flexLine.totalFlexGrowFactors) && flexLine.totalFlexGrowFactors == 0) ||
                     (isDefined(node.resolveFlexGrow()) && node.resolveFlexGrow() == 0)) {
                    effectiveAvailableInnerMainDim = flexLine.sizeConsumed
                }
                sizeBasedOnContent = !useLegacyStretchBehaviour
            }
        }

        // Compute remaining free space (matching C++ step 5 post-min/max logic)
        if !sizeBasedOnContent && isDefined(effectiveAvailableInnerMainDim) {
            flexLine.remainingFreeSpace = effectiveAvailableInnerMainDim - flexLine.sizeConsumed
        } else if flexLine.sizeConsumed < 0 {
            flexLine.remainingFreeSpace = -flexLine.sizeConsumed
        } else {
            flexLine.remainingFreeSpace = 0
        }

        // canSkipFlex: when measuring and cross axis is stretch-fit, skip flex resolution
        let canSkipFlex = !performLayout && sizingModeCrossDim == .stretchFit
        guard !canSkipFlex else { return }

        let originalFreeSpace = flexLine.remainingFreeSpace

        // First pass: detect min/max constraint triggering
        distributeFreeSpaceFirstPass(
            flexLine: &flexLine,
            direction: direction,
            mainAxis: mainAxis,
            ownerWidth: ownerWidth,
            mainAxisOwnerSize: mainAxisOwnerSize,
            availableInnerMainDim: availableInnerMainDim,
            availableInnerWidth: availableInnerWidth
        )

        // Second pass: resolve sizes and recursively lay out children
        let distributedFreeSpace = distributeFreeSpaceSecondPass(
            flexLine: flexLine,
            node: node,
            mainAxis: mainAxis,
            crossAxis: crossAxis,
            direction: direction,
            ownerWidth: ownerWidth,
            mainAxisOwnerSize: mainAxisOwnerSize,
            availableInnerMainDim: availableInnerMainDim,
            availableInnerCrossDim: availableInnerCrossDim,
            availableInnerWidth: availableInnerWidth,
            availableInnerHeight: availableInnerHeight,
            mainAxisOverflows: mainAxisOverflows,
            sizingModeCrossDim: sizingModeCrossDim,
            performLayout: performLayout,
            depth: depth,
            generationCount: generationCount,
            layoutMarkerData: &layoutMarkerData
        )

        flexLine.remainingFreeSpace = originalFreeSpace - distributedFreeSpace
    }
}
