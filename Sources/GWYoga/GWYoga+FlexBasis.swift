import Foundation

// MARK: - Flex Basis

extension GWLayoutEngine {

    static func resolveFlexBasis(_ child: GWYogaNode, direction: GWDirection,
                                  flexDirection: GWFlexDirection,
                                  referenceLength: Float, ownerWidth: Float) -> Float {
        let flexBasis = child.style.flexBasis

        // Check if flex-basis is set
        if flexBasis.isDefined && !flexBasis.isAuto {
            let resolved = flexBasis.resolve(referenceLength: referenceLength)
            if resolved.isDefined {
                // Apply boxSizing adjustment (matching C++ Node::resolveFlexBasis)
                if child.style.boxSizing == .contentBox {
                    let dim = flexDirection.dimension
                    let dimPaddingAndBorder = child.style.computePaddingAndBorderForDimension(direction, dim, ownerWidth)
                    return resolved.unwrap() + dimPaddingAndBorder
                }
                return resolved.unwrap()
            }
        }

        // Fall back to main-axis dimension
        let mainDim = flexDirection.dimension
        let dimLength = mainDim == .width ? child.style.width : child.style.height

        if dimLength.isPoints {
            return dimLength.value.unwrap(orDefault: 0)
        }
        if dimLength.isPercent {
            let resolved = dimLength.resolve(referenceLength: referenceLength)
            return resolved.unwrap(orDefault: 0)
        }

        // For flex basis, if flex > 0, use 0
        let flexVal = child.style.flex.unwrap(orDefault: 0)
        if flexVal > 0 { return 0 }

        return 0
    }

    // MARK: - Content-Measuring Flex Basis

    /// Resolve a child's flex basis, measuring content when needed.
    /// Mirrors Yoga's `computeFlexBasisForChild` with full content measurement path.
    static func computeFlexBasisForChild(
        node: GWYogaNode,
        child: GWYogaNode,
        availableInnerWidth: Float,
        availableInnerHeight: Float,
        ownerWidth: Float,
        ownerHeight: Float,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        direction: GWDirection,
        mainAxis: GWFlexDirection,
        performLayout: Bool,
        depth: UInt32,
        generationCount: UInt32
    ) {
        let isMainAxisRow = mainAxis.isRow
        let mainAxisSize = isMainAxisRow ? availableInnerWidth : availableInnerHeight
        let mainAxisOwnerSize = isMainAxisRow ? ownerWidth : ownerHeight

        let isRowStyleDimDefined = resolveDimensionLength(child.style.width, ownerWidth: ownerWidth).isDefined
        let isColumnStyleDimDefined = resolveDimensionLength(child.style.height, ownerWidth: ownerHeight).isDefined

        // Case 1: Flex basis is explicitly set (non-auto, non-undefined)
        let flexBasisStyle = child.style.flexBasis
        let resolvedFlexBasis = flexBasisStyle.resolve(referenceLength: mainAxisOwnerSize)

        let fixFlexBasisFitContent = node.config.isExperimentalFeatureEnabled(.fixFlexBasisFitContent)
        let isResolvedDefined = flexBasisStyle.isDefined && !flexBasisStyle.isAuto && resolvedFlexBasis.isDefined

        var useResolvedFlexBasis = isResolvedDefined && !mainAxisSize.isNaN
        if fixFlexBasisFitContent && isResolvedDefined && resolvedFlexBasis.unwrap() > 0 {
            useResolvedFlexBasis = true
        }

        if useResolvedFlexBasis {
            let webFlexBasis = child.config.isExperimentalFeatureEnabled(.webFlexBasis)
            if child.cache.computedFlexBasis.isUndefined || (webFlexBasis && child.cache.computedFlexBasisGeneration != generationCount) {
                let pb = paddingAndBorderForAxis(child, axis: mainAxis, direction: direction, widthSize: ownerWidth)
                child.cache.computedFlexBasis = GWFloatOptional(value: max(resolvedFlexBasis.unwrap(), pb))
            }
            child.cache.computedFlexBasisGeneration = generationCount
            return
        }

        // Case 2: Main axis dimension is explicitly defined on the child
        if isMainAxisRow && isRowStyleDimDefined {
            let pb = paddingAndBorderForAxis(child, axis: .row, direction: direction, widthSize: ownerWidth)
            let dim = resolveDimensionLength(child.style.width, ownerWidth: ownerWidth)
            child.cache.computedFlexBasis = GWFloatOptional(value: max(dim.unwrap(orDefault: 0), pb))
            child.cache.computedFlexBasisGeneration = generationCount
            return
        }
        if !isMainAxisRow && isColumnStyleDimDefined {
            let pb = paddingAndBorderForAxis(child, axis: .column, direction: direction, widthSize: ownerWidth)
            let dim = resolveDimensionLength(child.style.height, ownerWidth: ownerHeight)
            child.cache.computedFlexBasis = GWFloatOptional(value: max(dim.unwrap(orDefault: 0), pb))
            child.cache.computedFlexBasisGeneration = generationCount
            return
        }

        // Case 3: Measure content by running layout with performLayout=false
        var childWidth = Float.nan
        var childHeight = Float.nan
        var childWidthMode: GWSizingMode = .maxContent
        var childHeightMode: GWSizingMode = .maxContent

        let marginRow = resolveMargin(child, edge: .left, direction: direction, ownerWidth: ownerWidth) +
                        resolveMargin(child, edge: .right, direction: direction, ownerWidth: ownerWidth)
        let marginColumn = resolveMargin(child, edge: .top, direction: direction, ownerWidth: ownerWidth) +
                           resolveMargin(child, edge: .bottom, direction: direction, ownerWidth: ownerWidth)

        // If a dimension is definite, use it as StretchFit
        if isRowStyleDimDefined {
            let dim = resolveDimensionLength(child.style.width, ownerWidth: ownerWidth)
            childWidth = dim.unwrap(orDefault: 0) + marginRow
            childWidthMode = .stretchFit
        }
        if isColumnStyleDimDefined {
            let dim = resolveDimensionLength(child.style.height, ownerWidth: ownerHeight)
            childHeight = dim.unwrap(orDefault: 0) + marginColumn
            childHeightMode = .stretchFit
        }

        // Apply available width as FitContent constraint (with C++ overflow:scroll behavior)
        let isOverflowScroll = node.style.overflow == .scroll
        if (!isMainAxisRow || !isOverflowScroll) && childWidth.isNaN && !availableInnerWidth.isNaN {
            childWidth = availableInnerWidth
            childWidthMode = .fitContent
        }

        // Apply available height as FitContent constraint (with C++ overflow:scroll
        // and FixFlexBasisFitContent optimization for non-measure children)
        var applyHeightFitContent = isMainAxisRow || !isOverflowScroll
        if fixFlexBasisFitContent {
            applyHeightFitContent = isMainAxisRow ||
                (child.measureFunction != nil && !isOverflowScroll)
        }
        if applyHeightFitContent && childHeight.isNaN && !availableInnerHeight.isNaN {
            childHeight = availableInnerHeight
            childHeightMode = .fitContent
        }

        // Stretch for cross-axis alignment: if child aligns stretch and parent has exact size,
        // constrain the child's cross dimension to the available size
        let hasExactWidth = !availableInnerWidth.isNaN && widthSizingMode == .stretchFit
        let childWidthStretch = resolveChildAlignment(parent: node.style, child: child.style) == .stretch
                             && childWidthMode != .stretchFit
        if !isMainAxisRow && !isRowStyleDimDefined && hasExactWidth && childWidthStretch {
            childWidth = availableInnerWidth
            childWidthMode = .stretchFit
        }

        let hasExactHeight = !availableInnerHeight.isNaN && heightSizingMode == .stretchFit
        let childHeightStretch = resolveChildAlignment(parent: node.style, child: child.style) == .stretch
                              && childHeightMode != .stretchFit
        if isMainAxisRow && !isColumnStyleDimDefined && hasExactHeight && childHeightStretch {
            childHeight = availableInnerHeight
            childHeightMode = .stretchFit
        }

        // Aspect Ratio: 当一个维度是 stretchFit、另一个还不是时，用比例推导
        let aspectRatio = child.style.aspectRatio
        if aspectRatio.isDefined && !aspectRatio.unwrap().isNaN {
            let ratio = aspectRatio.unwrap()
            if ratio > 0 {
                if !isMainAxisRow && childWidthMode == .stretchFit && childHeightMode != .stretchFit {
                    // 宽度为 stretchFit，用比例推导高度
                    let marginRowSum = resolveMargin(child, edge: .left, direction: direction, ownerWidth: ownerWidth) +
                                       resolveMargin(child, edge: .right, direction: direction, ownerWidth: ownerWidth)
                    childHeight = (childWidth - marginRowSum) / ratio + marginColumn
                    childHeightMode = .stretchFit
                } else if isMainAxisRow && childHeightMode == .stretchFit && childWidthMode != .stretchFit {
                    // 高度为 stretchFit，用比例推导宽度
                    let marginColumnSum = resolveMargin(child, edge: .top, direction: direction, ownerWidth: ownerWidth) +
                                          resolveMargin(child, edge: .bottom, direction: direction, ownerWidth: ownerWidth)
                    childWidth = (childHeight - marginColumnSum) * ratio + marginRow
                    childWidthMode = .stretchFit
                }
            }
        }

        // Apply max constraints before measuring (matching C++ constrainMaxSizeForMode)
        constrainMaxSizeForMode(&childWidthMode, &childWidth,
                                node: child, direction: direction, axis: .row,
                                ownerAxisSize: ownerWidth, ownerWidth: ownerWidth)
        constrainMaxSizeForMode(&childHeightMode, &childHeight,
                                node: child, direction: direction, axis: .column,
                                ownerAxisSize: ownerHeight, ownerWidth: ownerWidth)

        // Measure the child subtree
        var markerData = GWLayoutData()
        let _ = calculateLayoutInternal(
            node: child,
            availableWidth: childWidth,
            availableHeight: childHeight,
            ownerDirection: direction,
            widthSizingMode: childWidthMode,
            heightSizingMode: childHeightMode,
            ownerWidth: ownerWidth,
            ownerHeight: ownerHeight,
            performLayout: false,
            layoutPassReason: .measureChild,
            layoutMarkerData: &markerData,
            depth: depth + 1,
            generationCount: gCurrentGenerationCount
        )

        // Use measured main dimension as flex basis (clamped to padding+border minimum)
        let measuredMainDim = mainAxis.dimension == .width ?
            child.layout.dimension(.width) : child.layout.dimension(.height)
        let pb = paddingAndBorderForAxis(child, axis: mainAxis, direction: direction, widthSize: ownerWidth)
        child.cache.computedFlexBasis = GWFloatOptional(value: max(measuredMainDim, pb))
        child.cache.computedFlexBasisGeneration = generationCount
    }

    static func computeFlexBasisForChildren(
        node: GWYogaNode,
        availableInnerWidth: Float,
        availableInnerHeight: Float,
        ownerWidth: Float,
        ownerHeight: Float,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        direction: GWDirection,
        mainAxis: GWFlexDirection,
        performLayout: Bool,
        depth: UInt32,
        generationCount: UInt32,
        layoutMarkerData: inout GWLayoutData
    ) -> Float {
        var totalOuterFlexBasis: Float = 0
        let sizingModeMainDim = mainAxis.dimension == .width ? widthSizingMode : heightSizingMode

        // SingleFlexChild optimization: if there's exactly one flexible child in a
        // StretchFit container, skip measurement — it will fill remaining space.
        var singleFlexChild: GWYogaNode?
        if sizingModeMainDim == .stretchFit {
            for child in node.children {
                if child.style.display == .none { continue }
                if child.style.positionType == .absolute { continue }
                let fg = resolveFlexGrow(child)
                let fs = resolveFlexShrink(child)
                if fg > 0 || fs > 0 {
                    if singleFlexChild != nil || (fg > 0 && fs > 0) {
                        singleFlexChild = nil
                        break
                    }
                    singleFlexChild = child
                }
            }
        }

        for child in node.children {
            if child.style.display == .none {
                zeroOutLayoutRecursively(child)
                continue
            }
            if child.style.positionType == .absolute { continue }

            // Set initial position when performing layout (matching C++ behavior)
            if performLayout {
                let childDirection = child.resolveDirection(direction)
                child.setPosition(childDirection, availableInnerWidth, availableInnerHeight)
            }

            if child === singleFlexChild {
                // Skip measurement — basis is 0; will stretch to fill
                child.cache.computedFlexBasis = GWFloatOptional(value: 0)
                child.cache.computedFlexBasisGeneration = generationCount
            } else {
                computeFlexBasisForChild(
                    node: node, child: child,
                    availableInnerWidth: availableInnerWidth,
                    availableInnerHeight: availableInnerHeight,
                    ownerWidth: ownerWidth, ownerHeight: ownerHeight,
                    widthSizingMode: widthSizingMode,
                    heightSizingMode: heightSizingMode,
                    direction: direction, mainAxis: mainAxis,
                    performLayout: performLayout, depth: depth,
                    generationCount: generationCount
                )
            }

            let marginMain = resolveMargin(child, edge: mainAxis.flexStartEdge, direction: direction,
                                           ownerWidth: ownerWidth)
                          + resolveMargin(child, edge: mainAxis.flexEndEdge, direction: direction,
                                          ownerWidth: ownerWidth)
            totalOuterFlexBasis += child.cache.computedFlexBasis.unwrap(orDefault: 0) + marginMain
        }

        return totalOuterFlexBasis
    }
}
