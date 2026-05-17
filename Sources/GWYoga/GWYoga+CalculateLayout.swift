import Foundation

// MARK: - Main 11-Step Algorithm

extension GWLayoutEngine {

    static func calculateLayoutImpl(
        node: GWYogaNode,
        availableWidth: Float,
        availableHeight: Float,
        ownerDirection: GWDirection,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        ownerWidth: Float,
        ownerHeight: Float,
        performLayout: Bool,
        layoutPassReason: GWLayoutPassReason = .initial,
        layoutMarkerData: inout GWLayoutData,
        depth: UInt32
    ) {
        // Guard against excessive recursion
        if depth > 100 { return }

        // Clear stale layout dimensions from a previous generation.
        // This ensures measureNodeWithoutChildren's isNaN guard correctly
        // distinguishes between dimensions set by the parent during THIS
        // layout pass (preserved) vs leftovers from a prior pass (recomputed).
        if node.cache.generationCount != gCurrentGenerationCount {
            node.layout.setDimension(.width, .nan)
            node.layout.setDimension(.height, .nan)
        }

        assertFatalWithNode(node, isUndefined(availableWidth) ? widthSizingMode == .maxContent : true,
                            "availableWidth is indefinite so widthSizingMode must be MaxContent")
        assertFatalWithNode(node, isUndefined(availableHeight) ? heightSizingMode == .maxContent : true,
                            "availableHeight is indefinite so heightSizingMode must be MaxContent")

        if performLayout { layoutMarkerData.layouts += 1 }
        else { layoutMarkerData.measures += 1 }

        // Set the resolved direction in the node's layout
        let direction = node.resolveDirection(ownerDirection)
        node.layout.direction = direction

        let flexRowDirection = GWFlexDirection.row.resolved(for: direction)
        let flexColumnDirection = GWFlexDirection.column.resolved(for: direction)

        let startEdge: GWPhysicalEdge = direction == .rtl ? .right : .left
        let endEdge: GWPhysicalEdge = direction == .rtl ? .left : .right

        // Set margins, border, padding on layout (matching C++ inline-start/end ordering)
        let marginRowLeading = node.style.computeInlineStartMargin(flexRowDirection, direction, ownerWidth)
        node.layout.setMargin(startEdge, marginRowLeading)
        let marginRowTrailing = node.style.computeInlineEndMargin(flexRowDirection, direction, ownerWidth)
        node.layout.setMargin(endEdge, marginRowTrailing)
        let marginColumnLeading = node.style.computeInlineStartMargin(flexColumnDirection, direction, ownerWidth)
        node.layout.setMargin(.top, marginColumnLeading)
        let marginColumnTrailing = node.style.computeInlineEndMargin(flexColumnDirection, direction, ownerWidth)
        node.layout.setMargin(.bottom, marginColumnTrailing)

        let marginAxisRow = marginRowLeading + marginRowTrailing
        let marginAxisColumn = marginColumnLeading + marginColumnTrailing

        node.layout.setBorder(startEdge, node.style.computeInlineStartBorder(flexRowDirection, direction))
        node.layout.setBorder(endEdge, node.style.computeInlineEndBorder(flexRowDirection, direction))
        node.layout.setBorder(.top, node.style.computeInlineStartBorder(flexColumnDirection, direction))
        node.layout.setBorder(.bottom, node.style.computeInlineEndBorder(flexColumnDirection, direction))

        node.layout.setPadding(startEdge, node.style.computeInlineStartPadding(flexRowDirection, direction, ownerWidth))
        node.layout.setPadding(endEdge, node.style.computeInlineEndPadding(flexRowDirection, direction, ownerWidth))
        node.layout.setPadding(.top, node.style.computeInlineStartPadding(flexColumnDirection, direction, ownerWidth))
        node.layout.setPadding(.bottom, node.style.computeInlineEndPadding(flexColumnDirection, direction, ownerWidth))

        // Determine main and cross axes
        let mainAxis = node.style.flexDirection.resolved(for: direction)
        let crossAxis = mainAxis.cross

        // Calculate padding + border for each axis
        let paddingAndBorderMain = paddingAndBorderForAxis(node, axis: mainAxis, direction: direction, widthSize: ownerWidth)
        let paddingAndBorderCross = paddingAndBorderForAxis(node, axis: crossAxis, direction: direction, widthSize: ownerWidth)

        // Early exit: measure function leaf
        if node.measureFunction != nil {
            measureNodeWithMeasureFunc(node,
                                       direction: direction,
                                       availableWidth: availableWidth - marginAxisRow,
                                       availableHeight: availableHeight - marginAxisColumn,
                                       widthSizingMode: widthSizingMode,
                                       heightSizingMode: heightSizingMode,
                                       ownerWidth: ownerWidth,
                                       ownerHeight: ownerHeight)
            return
        }

        // Early exit: no layout children (treat as empty container)
        let hasLayoutChildren = node.children.contains { $0.style.display != .none }
        if !hasLayoutChildren {
            measureNodeWithoutChildren(node, widthSizingMode: widthSizingMode,
                                       heightSizingMode: heightSizingMode,
                                       availableWidth: availableWidth - marginAxisRow,
                                       availableHeight: availableHeight - marginAxisColumn,
                                       paddingAndBorderMain: paddingAndBorderMain,
                                       paddingAndBorderCross: paddingAndBorderCross,
                                       ownerWidth: ownerWidth,
                                       ownerHeight: ownerHeight)
            cleanupContentsNodesRecursively(node)
            return
        }

        // If we're not being asked to perform a full layout we can skip
        // if both dimensions already have fixed sizes
        if !performLayout &&
            measureNodeWithFixedSize(node, direction: direction,
                                     availableWidth: availableWidth - marginAxisRow,
                                     availableHeight: availableHeight - marginAxisColumn,
                                     widthSizingMode: widthSizingMode,
                                     heightSizingMode: heightSizingMode,
                                     ownerWidth: ownerWidth,
                                     ownerHeight: ownerHeight) {
            cleanupContentsNodesRecursively(node)
            return
        }

        // Reset layout flags
        node.layout.hadOverflow = false

        // Clean display:contents nodes
        cleanupContentsNodesRecursively(node)

        // Step 1: Determine available inner space
        let availableInnerWidth = calculateAvailableInnerDimension(
            node, dimension: .width,
            availableDim: availableWidth - marginAxisRow,
            paddingAndBorder: paddingAndBorderForAxis(node, axis: .row, direction: direction, widthSize: ownerWidth),
            ownerDim: ownerWidth,
            ownerWidth: ownerWidth
        )

        let availableInnerHeight = calculateAvailableInnerDimension(
            node, dimension: .height,
            availableDim: availableHeight - marginAxisColumn,
            paddingAndBorder: paddingAndBorderForAxis(node, axis: .column, direction: direction, widthSize: ownerWidth),
            ownerDim: ownerHeight,
            ownerWidth: ownerWidth
        )

        let availableInnerMainDim = mainAxis.dimension == .width ? availableInnerWidth : availableInnerHeight
        let availableInnerCrossDim = crossAxis.dimension == .width ? availableInnerWidth : availableInnerHeight

        // Step 2: Determine main axis owner size for percentage basis
        let mainAxisOwnerSize: Float = mainAxis.dimension == .width ?
            (ownerWidth.isNaN ? availableWidth : ownerWidth) :
            (ownerHeight.isNaN ? availableHeight : ownerHeight)

        let crossAxisOwnerSize: Float = crossAxis.dimension == .width ? ownerWidth : ownerHeight

        // Derive owner dimensions for children (FixFlexBasisFitContent: use definite inner size
        // when available inner size is undefined but owner size is known)
        var ownerWidthForChildren = availableInnerWidth
        var ownerHeightForChildren = availableInnerHeight
        if node.config.isExperimentalFeatureEnabled(.fixFlexBasisFitContent) {
            let isChildOfScrollContainer = node.owner?.style.overflow == .scroll
            if !isChildOfScrollContainer {
                if ownerWidthForChildren.isNaN && !ownerWidth.isNaN {
                    ownerWidthForChildren = calculateAvailableInnerDimension(
                        node, dimension: .width,
                        availableDim: ownerWidth - marginAxisRow,
                        paddingAndBorder: paddingAndBorderForAxis(node, axis: .row, direction: direction, widthSize: ownerWidth),
                        ownerDim: ownerWidth,
                        ownerWidth: ownerWidth
                    )
                }
                if ownerHeightForChildren.isNaN && !ownerHeight.isNaN {
                    ownerHeightForChildren = calculateAvailableInnerDimension(
                        node, dimension: .height,
                        availableDim: ownerHeight - marginAxisColumn,
                        paddingAndBorder: paddingAndBorderForAxis(node, axis: .column, direction: direction, widthSize: ownerWidth),
                        ownerDim: ownerHeight,
                        ownerWidth: ownerWidth
                    )
                }
            }
        }

        // Grid branch: if display: grid, use the grid layout algorithm instead of flex
        if node.style.display == .grid {
            GWGridLayoutEngine.calculateGridLayout(
                node: node,
                direction: direction,
                availableInnerWidth: availableInnerWidth,
                availableInnerHeight: availableInnerHeight,
                ownerWidth: ownerWidth,
                ownerHeight: ownerHeight,
                paddingAndBorderMain: paddingAndBorderMain,
                paddingAndBorderCross: paddingAndBorderCross,
                performLayout: performLayout,
                widthSizingMode: widthSizingMode,
                heightSizingMode: heightSizingMode,
                layoutMarkerData: &layoutMarkerData
            )
            cleanupContentsNodesRecursively(node)
            return
        }

        // Step 3: Compute flex basis for children
        var markerData = GWLayoutData()
        let totalOuterFlexBasis = computeFlexBasisForChildren(
            node: node,
            availableInnerWidth: availableInnerWidth,
            availableInnerHeight: availableInnerHeight,
            ownerWidth: ownerWidthForChildren,
            ownerHeight: ownerHeightForChildren,
            widthSizingMode: widthSizingMode,
            heightSizingMode: heightSizingMode,
            direction: node.layout.direction,
            mainAxis: mainAxis,
            performLayout: performLayout,
            depth: depth,
            generationCount: gCurrentGenerationCount,
            layoutMarkerData: &markerData
        )

        // Step 4: Collect items into flex lines
        let isMultiLine = node.style.flexWrap == .wrap || node.style.flexWrap == .wrapReverse
        let flexWrapReverse = node.style.flexWrap == .wrapReverse

        // Add gap to total main dimension for overflow detection
        var totalMainDim = totalOuterFlexBasis
        let gapMain = node.style.resolvedGap(for: mainAxis.dimension == .width ? .column : .row)
        let gapLength = gapMain.resolve(referenceLength: mainAxisOwnerSize)
        let gapCross = node.style.resolvedGap(for: crossAxis.dimension == .width ? .column : .row)
        let gapCrossLength = gapCross.resolve(referenceLength: crossAxisOwnerSize)
        let childCount = node.children.filter { $0.style.display != .none && $0.style.positionType != .absolute }.count
        if childCount > 1 && gapLength.isDefined {
            totalMainDim += gapLength.unwrap() * Float(childCount - 1)
        }

        // Compute main-axis sizing mode (may be mutated by overflow detection)
        var widthSizingModeMainDim = mainAxis.dimension == .width ? widthSizingMode : heightSizingMode

        // 检测主轴溢出：当内容超过可用空间时，在 FitContent 模式下
        // 切换为 StretchFit 让 flex 子项收缩适配（符合浏览器行为）
        let mainAxisOverflows = widthSizingModeMainDim != .maxContent && totalMainDim > availableInnerMainDim && !availableInnerMainDim.isNaN
        if isMultiLine && mainAxisOverflows && widthSizingModeMainDim == .fitContent {
            widthSizingModeMainDim = .stretchFit
        }

        var lines: [FlexLineResult] = []
        var childIndex = 0
        var lineCount = 0

        while childIndex < node.children.count {
            let flexLineResult = calculateFlexLine(
                node: node,
                mainAxis: mainAxis,
                crossAxis: crossAxis,
                direction: node.layout.direction,
                ownerWidth: ownerWidth,
                mainAxisOwnerSize: mainAxisOwnerSize,
                availableInnerWidth: availableInnerWidth,
                availableInnerMainDim: availableInnerMainDim,
                startIndex: childIndex,
                lineCount: lineCount
            )
            childIndex = flexLineResult.nextIndex
            lines.append(flexLineResult)
            lineCount += 1
            if !isMultiLine { break } // Single-line mode
        }

        // Steps 5-8: Process each flex line
        let sizingModeCrossDim = crossAxis.dimension == .width ? widthSizingMode : heightSizingMode

        var totalLineCrossDim: Float = 0
        var hadOverflow = false
        var maxLineMainDim: Float = 0

        for (lineIdx, var line) in lines.enumerated() {
            // Step 5: Resolve flexible lengths
            resolveFlexibleLength(
                node: node,
                flexLine: &line,
                mainAxis: mainAxis,
                crossAxis: crossAxis,
                direction: node.layout.direction,
                ownerWidth: ownerWidth,
                mainAxisOwnerSize: mainAxisOwnerSize,
                availableInnerMainDim: availableInnerMainDim,
                availableInnerCrossDim: availableInnerCrossDim,
                availableInnerWidth: availableInnerWidth,
                availableInnerHeight: availableInnerHeight,
                mainAxisOverflows: mainAxisOverflows,
                widthSizingModeMainDim: widthSizingModeMainDim,
                sizingModeCrossDim: sizingModeCrossDim,
                performLayout: performLayout,
                depth: depth,
                generationCount: gCurrentGenerationCount,
                layoutMarkerData: &markerData
            )

            // Step 6: Main axis justification
            justifyMainAxis(
                flexLine: &line,
                mainAxis: mainAxis,
                crossAxis: crossAxis,
                direction: node.layout.direction,
                widthSizingModeMainDim: widthSizingModeMainDim,
                sizingModeCrossDim: sizingModeCrossDim,
                mainAxisOwnerSize: mainAxisOwnerSize,
                ownerWidth: ownerWidth,
                availableInnerMainDim: availableInnerMainDim,
                availableInnerCrossDim: availableInnerCrossDim,
                availableInnerWidth: availableInnerWidth,
                node: node,
                performLayout: performLayout
            )

            // For single-line containers with stretch-fit cross dimension,
            // the line's cross dimension is the available cross dimension
            if !isMultiLine && sizingModeCrossDim == .stretchFit {
                line.crossDim = availableInnerCrossDim
            }

            // Clamp single-line cross dimension to min/max constraints
            if !isMultiLine {
                line.crossDim = boundAxis(node, axis: crossAxis, value: line.crossDim + paddingAndBorderCross,
                                           direction: node.layout.direction, axisSize: crossAxisOwnerSize, widthSize: ownerWidth) - paddingAndBorderCross
            }

            totalLineCrossDim += line.crossDim + (lineIdx > 0 && gapCrossLength.isDefined ? gapCrossLength.unwrap() : 0)
            lines[lineIdx] = line // propagate modified struct back

            // Track maximum line main dimension across all lines (for Step 9)
            maxLineMainDim = maxOrDefined(maxLineMainDim, line.mainDim)

            // 检测主轴溢出：剩余空间为负表示内容超出可用空间
            hadOverflow = hadOverflow || line.remainingFreeSpace < 0
            // 从子节点传播溢出状态
            for item in line.items {
                if item.node.layout.hadOverflow {
                    hadOverflow = true
                }
            }
            // 检测交叉轴溢出：子元素在交叉轴上的尺寸超出容器可用空间
            for item in line.items {
                if item.node.style.display == .none { continue }
                let childCrossSize = crossAxis.dimension == .width ?
                    item.node.layout.dimension(.width) : item.node.layout.dimension(.height)
                if childCrossSize > availableInnerCrossDim + 0.001 {
                    hadOverflow = true
                    break
                }
            }
        }

        node.layout.hadOverflow = hadOverflow

        // Step 7: Cross axis alignment per child
        let leadingPaddingAndBorderCross: Float = crossAxis.dimension == .width ?
            node.layout.border(.left) + node.layout.padding(.left) :
            node.layout.border(.top) + node.layout.padding(.top)
        var currentCrossPosition: Float = leadingPaddingAndBorderCross
        var extraSpacePerLine: Float = 0
        var leadPerLine: Float = 0

        // AlignContent adjustments applied once before the line loop (matching C++ behavior)
        if lineCount > 1 {
            let rawRemaining = availableInnerCrossDim - totalLineCrossDim
            let effectiveAlignContent = rawRemaining >= 0
                ? node.style.alignContent
                : fallbackAlignment(node.style.alignContent)
            let remainingAlignContentDim = max(0, rawRemaining)
            switch effectiveAlignContent {
            case .flexEnd, .end:
                currentCrossPosition += remainingAlignContentDim
            case .center:
                currentCrossPosition += remainingAlignContentDim / 2
            case .stretch:
                extraSpacePerLine = remainingAlignContentDim / Float(lineCount)
            case .spaceAround:
                currentCrossPosition += remainingAlignContentDim / (2 * Float(lineCount))
                leadPerLine = remainingAlignContentDim / Float(lineCount)
            case .spaceEvenly:
                currentCrossPosition += remainingAlignContentDim / Float(lineCount + 1)
                leadPerLine = remainingAlignContentDim / Float(lineCount + 1)
            case .spaceBetween:
                if lineCount > 1 {
                    leadPerLine = remainingAlignContentDim / Float(lineCount - 1)
                }
            default: // flex-start, start, auto, baseline
                break
            }
        }

        for lineIdx in 0..<lines.count {
            let line = lines[lineIdx]
            var crossDim = line.crossDim
            crossDim += extraSpacePerLine

            // Baseline: compute max ascent for the line (matching C++ Step 8)
            var lineMaxAscent: Float = 0
            let needsBaseline = isBaselineLayout(node)
            if needsBaseline {
                for item in line.items {
                    if item.node.style.display == .none { continue }
                    let childAlign = resolveChildAlignment(parent: node.style, child: item.node.style)
                    if childAlign == .baseline {
                        let childBaseline = calculateBaseline(item.node)
                        let ascent = childBaseline + item.crossMarginStart
                        lineMaxAscent = max(lineMaxAscent, ascent)
                    }
                }
            }

            for item in line.items {
                if item.node.style.display == .none { continue }

                let childMainAxis = item.node.style.flexDirection.resolved(for: node.layout.direction)
                let childCrossAxis = childMainAxis.cross

                let childAlign = resolveChildAlignment(parent: node.style, child: item.node.style)
                let isCrossBaseline = childAlign == .baseline && childCrossAxis.isRow

                // Determine cross size and position
                var crossSize: Float
                let childCrossSize = crossAxis.dimension == .width ?
                    item.node.layout.dimension(.width) : item.node.layout.dimension(.height)

                if childAlign == .stretch && !isCrossBaseline {
                    // Use availableInnerCrossDim for percentage resolution (matching C++ behavior)
                    let childCrossDimStyle = resolveDimensionLength(
                        crossAxis.dimension == .width ? item.node.style.width : item.node.style.height,
                        ownerWidth: availableInnerCrossDim)

                    let marginCross = item.crossMarginStart + item.crossMarginEnd

                    // Aspect Ratio: 如果设置了 aspectRatio，交叉轴尺寸从主轴推导
                    let aspectRatio = item.node.style.aspectRatio
                    if aspectRatio.isDefined && !aspectRatio.unwrap().isNaN && aspectRatio.unwrap() > 0 {
                        let childMainSize = mainAxis.dimension == .width ?
                            item.node.layout.dimension(.width) : item.node.layout.dimension(.height)
                        let marginMain = item.mainMarginStart + item.mainMarginEnd
                        let isMainAxisRow = mainAxis.isRow
                        if isMainAxisRow {
                            crossSize = (childMainSize - marginMain) / aspectRatio.unwrap() + marginCross
                        } else {
                            crossSize = (childMainSize - marginMain) * aspectRatio.unwrap() + marginCross
                        }
                    } else if !childCrossDimStyle.isDefined {
                        // 拉伸填充交叉轴空间
                        crossSize = crossDim - marginCross
                    } else {
                        crossSize = childCrossSize
                    }
                    // 应用 min/max 约束（使用父容器交叉轴方向，确保用正确的 min-height/max-height 约束）
                    crossSize = clampDimension(child: item.node, axis: crossAxis, value: crossSize,
                                               direction: node.layout.direction, ownerWidth: ownerWidth, ownerHeight: ownerHeight)

                    // Re-layout child with new cross size
                    if performLayout {
                        let childMainDim = childMainAxis.dimension == .width ?
                            item.node.layout.dimension(.width) : item.node.layout.dimension(.height)

                        let childAvailWidth = childMainAxis.dimension == .width ? childMainDim : crossSize
                        let childAvailHeight = childMainAxis.dimension == .height ? childMainDim : crossSize

                        // Only re-layout if cross size actually changed
                        let oldCrossDim = crossAxis.dimension == .width ?
                            item.node.layout.dimension(.width) : item.node.layout.dimension(.height)
                        if abs(oldCrossDim - crossSize) > 0.001 {
                            let childWidthMode: GWSizingMode = childMainAxis.dimension == .width ? .stretchFit : .fitContent
                            let childHeightMode: GWSizingMode = childMainAxis.dimension == .height ? .stretchFit : .fitContent
                            var stretchMarker = GWLayoutData()
                            let _ = calculateLayoutInternal(
                                node: item.node,
                                availableWidth: childAvailWidth,
                                availableHeight: childAvailHeight,
                                ownerDirection: node.layout.direction,
                                widthSizingMode: childWidthMode,
                                heightSizingMode: childHeightMode,
                                ownerWidth: availableInnerWidth,
                                ownerHeight: availableInnerHeight,
                                performLayout: true,
                                layoutPassReason: .stretch,
                                layoutMarkerData: &stretchMarker,
                                depth: depth + 1,
                                generationCount: gCurrentGenerationCount
                            )

                            // 传播子节点溢出状态
                            if item.node.layout.hadOverflow {
                                node.layout.hadOverflow = true
                            }
                        }
                    }
                } else {
                    crossSize = childCrossSize
                }

                // Position along cross axis
                if performLayout {
                    var crossPosition = currentCrossPosition

                    switch childAlign {
                    case .flexEnd, .end:
                        crossPosition += crossDim - crossSize - item.crossMarginEnd
                    case .center:
                        crossPosition += (crossDim - crossSize - item.crossMarginStart - item.crossMarginEnd) / 2 + item.crossMarginStart
                    case .baseline:
                        crossPosition += max(0, lineMaxAscent - calculateBaseline(item.node)) + item.crossMarginStart
                    default: // flex-start, start, auto, stretch
                        crossPosition += item.crossMarginStart
                    }

                    // Set cross-axis position (main axis position already set by justifyMainAxis)
                    if crossAxis.dimension == .width {
                        item.node.layout.setPosition(.left, crossPosition)
                    } else {
                        item.node.layout.setPosition(.top, crossPosition)
                    }
                }
            }

            // Advance cross position for next line
            currentCrossPosition += crossDim + leadPerLine + (gapCrossLength.isDefined ? gapCrossLength.unwrap() : 0)
        }

        // Step 9: Compute final node dimensions (matching C++ logic)
        // Start with available dimensions clamped through boundAxis
        node.layout.setDimension(.width, boundAxis(node, axis: .row, value: availableWidth - marginAxisRow,
                                                     direction: direction, axisSize: ownerWidth, widthSize: ownerWidth))
        node.layout.setDimension(.height, boundAxis(node, axis: .column, value: availableHeight - marginAxisColumn,
                                                      direction: direction, axisSize: ownerHeight, widthSize: ownerWidth))


        // Override main axis dimension for content-based sizing modes
        let isMainAxisOverflowScroll = node.style.overflow == .scroll
        let mainAxisSizingMode = mainAxis.dimension == .width ? widthSizingMode : heightSizingMode
        if mainAxisSizingMode == .maxContent ||
            (!isMainAxisOverflowScroll && mainAxisSizingMode == .fitContent) {
            // Clamp maxLineMainDim through min/max constraints
            let contentMain = boundAxis(node, axis: mainAxis, value: maxLineMainDim,
                                         direction: direction, axisSize: mainAxisOwnerSize, widthSize: ownerWidth)
            node.layout.setDimension(dimension(mainAxis), contentMain)
        } else if mainAxisSizingMode == .fitContent && isMainAxisOverflowScroll {
            let clampedInner = maxOrDefined(
                minOrDefined(availableInnerMainDim + paddingAndBorderMain,
                    boundAxisWithinMinAndMax(node, direction: direction, axis: mainAxis,
                                              value: GWFloatOptional(value: maxLineMainDim),
                                              axisSize: mainAxisOwnerSize, widthSize: ownerWidth).unwrap()),
                paddingAndBorderMain)
            node.layout.setDimension(dimension(mainAxis), clampedInner)
        }

        // Override cross axis dimension for content-based sizing modes
        let crossAxisSizingMode = crossAxis.dimension == .width ? widthSizingMode : heightSizingMode

        if crossAxisSizingMode == .maxContent ||
            (!isMainAxisOverflowScroll && crossAxisSizingMode == .fitContent) {
            let contentCross = boundAxis(node, axis: crossAxis, value: totalLineCrossDim + paddingAndBorderCross,
                                          direction: direction, axisSize: crossAxisOwnerSize, widthSize: ownerWidth)
            node.layout.setDimension(dimension(crossAxis), contentCross)
        } else if crossAxisSizingMode == .fitContent && isMainAxisOverflowScroll {
            let clampedCross = maxOrDefined(
                minOrDefined(availableInnerCrossDim + paddingAndBorderCross,
                    boundAxisWithinMinAndMax(node, direction: direction, axis: crossAxis,
                                              value: GWFloatOptional(value: totalLineCrossDim + paddingAndBorderCross),
                                              axisSize: crossAxisOwnerSize, widthSize: ownerWidth).unwrap()),
                paddingAndBorderCross)
            node.layout.setDimension(dimension(crossAxis), clampedCross)
        }

        // Step 10: wrap-reverse flip + trailing positions for reverse flex directions
        if performLayout {
            // 1) wrap-reverse: flip cross axis positions
            if flexWrapReverse {
                let crossDimForReverse = crossAxis.dimension == .width ?
                    node.layout.dimension(.width) : node.layout.dimension(.height)
                for child in node.children {
                    if child.style.positionType != .absolute {
                        let childCrossPos = crossAxis.dimension == .width ?
                            child.layout.position(.left) : child.layout.position(.top)
                        let childCrossSize = crossAxis.dimension == .width ?
                            child.layout.dimension(.width) : child.layout.dimension(.height)
                        let flipped = crossDimForReverse - childCrossPos - childCrossSize
                        if crossAxis.dimension == .width {
                            child.layout.setPosition(.left, flipped)
                        } else {
                            child.layout.setPosition(.top, flipped)
                        }
                    }
                }
            }

            // 2) Trailing positions for reverse flex directions (column-reverse, row-reverse)
            let needsMainTrailingPos = needsTrailingPosition(mainAxis)
            let needsCrossTrailingPos = needsTrailingPosition(crossAxis)
            if needsMainTrailingPos || needsCrossTrailingPos {
                for child in node.children {
                    if child.style.display == .none || child.style.positionType == .absolute {
                        continue
                    }
                    if needsMainTrailingPos {
                        setChildTrailingPosition(node, child, mainAxis)
                    }
                    if needsCrossTrailingPos {
                        setChildTrailingPosition(node, child, crossAxis)
                    }
                }
            }
        }

        // Step 11: Layout absolute descendants
        if performLayout {
            let _ = layoutAbsoluteDescendants(
                containingNode: node,
                currentNode: node,
                widthSizingMode: widthSizingMode,
                direction: node.layout.direction,
                depth: depth,
                currentNodeLeftOffsetFromContainingBlock: 0,
                currentNodeTopOffsetFromContainingBlock: 0,
                containingNodeAvailableInnerWidth: availableInnerWidth,
                containingNodeAvailableInnerHeight: availableInnerHeight
            )
        }
    }
}
