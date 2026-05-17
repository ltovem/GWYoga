import Foundation

// MARK: - Helper Functions

extension GWLayoutEngine {

    static func resolveDirection(_ style: GWStyle, ownerDirection: GWDirection) -> GWDirection {
        switch style.direction {
        case .inherit: return ownerDirection == .inherit ? .ltr : ownerDirection
        case .ltr: return .ltr
        case .rtl: return .rtl
        }
    }

    static func resolveDimensionLength(_ length: GWStyleSizeLength, ownerWidth: Float) -> GWFloatOptional {
        switch length.unit {
        case .point:
            return length.value
        case .percent:
            return length.value.isDefined ?
                GWFloatOptional(value: length.value.unwrap() * ownerWidth * 0.01) : .undefined
        default:
            return .undefined
        }
    }

    static func resolveLength(_ length: GWStyleLength, referenceLength: Float) -> GWFloatOptional {
        switch length.unit {
        case .point:
            return length.value
        case .percent:
            return length.value.isDefined ?
                GWFloatOptional(value: length.value.unwrap() * referenceLength * 0.01) : .undefined
        default:
            return .undefined
        }
    }

    static func resolveMargin(_ child: GWYogaNode, edge: GWEdge, direction: GWDirection, ownerWidth: Float) -> Float {
        let styleVal = child.style.resolvedMargin(for: edge, direction: direction)
        let resolved = resolveLength(styleVal, referenceLength: ownerWidth)
        return resolved.unwrap(orDefault: 0)
    }

    static func resolvePadding(_ child: GWYogaNode, edge: GWEdge, direction: GWDirection, ownerWidth: Float) -> Float {
        let styleVal = child.style.resolvedPadding(for: edge, direction: direction)
        let resolved = resolveLength(styleVal, referenceLength: ownerWidth)
        return resolved.unwrap(orDefault: 0)
    }

    static func resolveFlexGrow(_ child: GWYogaNode) -> Float {
        child.resolveFlexGrow()
    }

    static func resolveFlexShrink(_ child: GWYogaNode) -> Float {
        child.resolveFlexShrink()
    }

    // MARK: - Bound / Clamp

    static func paddingAndBorderForAxis(_ node: GWYogaNode, axis: GWFlexDirection, direction: GWDirection, widthSize: Float) -> Float {
        let startEdge = axis.flexStartEdge
        let endEdge = axis.flexEndEdge

        let paddingStart = resolvePadding(node, edge: startEdge, direction: direction, ownerWidth: widthSize)
        let paddingEnd = resolvePadding(node, edge: endEdge, direction: direction, ownerWidth: widthSize)
        let borderStart = node.style.resolvedBorder(for: startEdge, direction: direction)
        let borderEnd = node.style.resolvedBorder(for: endEdge, direction: direction)

        return (paddingStart.isNaN ? 0 : paddingStart) + (paddingEnd.isNaN ? 0 : paddingEnd)
            + (borderStart.isNaN ? 0 : borderStart) + (borderEnd.isNaN ? 0 : borderEnd)
    }

    static func boundAxisWithinMinAndMax(_ child: GWYogaNode, direction: GWDirection, axis: GWFlexDirection,
                                          value: GWFloatOptional, axisSize: Float, widthSize: Float) -> GWFloatOptional {
        if value.isUndefined { return value }

        let dim = axis.dimension
        let minLength = child.style.resolvedMinDimension(direction, dim, axisSize, widthSize)
        let maxLength = child.style.resolvedMaxDimension(direction, dim, axisSize, widthSize)

        var clamped = value

        if maxLength.isDefined && clamped > maxLength {
            clamped = maxLength
        }
        if minLength.isDefined && clamped < minLength {
            clamped = minLength
        }

        return clamped
    }

    static func boundAxis(_ node: GWYogaNode, axis: GWFlexDirection, value: Float,
                           direction: GWDirection, axisSize: Float, widthSize: Float) -> Float {
        let pb = paddingAndBorderForAxis(node, axis: axis, direction: direction, widthSize: widthSize)
        var clamped = boundAxisWithinMinAndMax(node, direction: direction, axis: axis,
                                                value: GWFloatOptional(value: value),
                                                axisSize: axisSize, widthSize: widthSize)
            .unwrap(orDefault: value)
        clamped = max(clamped, pb)
        return clamped
    }

    static func clampDimension(child: GWYogaNode, axis: GWFlexDirection, value: Float,
                                direction: GWDirection, ownerWidth: Float, ownerHeight: Float) -> Float {
        let axisSize = axis.dimension == .width ? ownerWidth : ownerHeight
        return boundAxis(child, axis: axis, value: value, direction: direction,
                          axisSize: axisSize, widthSize: ownerWidth)
    }

    // MARK: - Layout Helpers

    static func setLayoutMargins(_ node: GWYogaNode, direction: GWDirection, ownerWidth: Float) {
        let edges: [GWEdge] = [.left, .top, .right, .bottom]
        let physEdges: [GWPhysicalEdge] = [.left, .top, .right, .bottom]
        for (i, edge) in edges.enumerated() {
            let val = resolveMargin(node, edge: edge, direction: direction, ownerWidth: ownerWidth)
            node.layout.setMargin(physEdges[i], val.isNaN ? 0 : val)
        }
    }

    static func setLayoutBorder(_ node: GWYogaNode, direction: GWDirection, ownerWidth: Float) {
        let edges: [GWEdge] = [.left, .top, .right, .bottom]
        let physEdges: [GWPhysicalEdge] = [.left, .top, .right, .bottom]
        for (i, edge) in edges.enumerated() {
            let val = node.style.resolvedBorder(for: edge, direction: direction)
            node.layout.setBorder(physEdges[i], val.isNaN ? 0 : val)
        }
    }

    static func setLayoutPadding(_ node: GWYogaNode, direction: GWDirection, ownerWidth: Float) {
        let edges: [GWEdge] = [.left, .top, .right, .bottom]
        let physEdges: [GWPhysicalEdge] = [.left, .top, .right, .bottom]
        for (i, edge) in edges.enumerated() {
            let val = resolvePadding(node, edge: edge, direction: direction, ownerWidth: ownerWidth)
            node.layout.setPadding(physEdges[i], val.isNaN ? 0 : val)
        }
    }

    static func calculateAvailableInnerDimension(
        _ node: GWYogaNode,
        dimension: GWDimension,
        availableDim: Float,
        paddingAndBorder: Float,
        ownerDim: Float,
        ownerWidth: Float
    ) -> Float {
        if availableDim.isNaN { return .nan }

        var innerDim = availableDim - paddingAndBorder

        // Apply min/max constraints
        let ref = dimension == .width ? ownerWidth : ownerDim
        let minLength = dimension == .width ?
            resolveDimensionLength(node.style.minWidth, ownerWidth: ref) :
            resolveDimensionLength(node.style.minHeight, ownerWidth: ref)
        let maxLength = dimension == .width ?
            resolveDimensionLength(node.style.maxWidth, ownerWidth: ref) :
            resolveDimensionLength(node.style.maxHeight, ownerWidth: ref)

        if minLength.isDefined { innerDim = max(innerDim, minLength.unwrap() - paddingAndBorder) }
        if maxLength.isDefined { innerDim = min(innerDim, maxLength.unwrap() - paddingAndBorder) }

        return innerDim
    }

    static func measureNodeWithMeasureFunc(
        _ node: GWYogaNode,
        direction: GWDirection,
        availableWidth: Float,
        availableHeight: Float,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        ownerWidth: Float,
        ownerHeight: Float
    ) {
        guard let measureFunc = node.measureFunction else { return }

        let paddingBorderWidth = paddingAndBorderForAxis(node, axis: .row, direction: direction, widthSize: ownerWidth)
        let paddingBorderHeight = paddingAndBorderForAxis(node, axis: .column, direction: direction, widthSize: ownerWidth)

        if widthSizingMode == .stretchFit && heightSizingMode == .stretchFit {
            // Both dimensions already defined — no need to measure
            node.layout.setDimension(.width, boundAxis(node, axis: .row, value: availableWidth,
                                                         direction: direction, axisSize: ownerWidth, widthSize: ownerWidth))
            node.layout.setDimension(.height, boundAxis(node, axis: .column, value: availableHeight,
                                                          direction: direction, axisSize: ownerHeight, widthSize: ownerWidth))
        } else {
            // C++: convert MaxContent sizing mode to undefined size for measure function
            var effectiveAvailableWidth = availableWidth
            var effectiveAvailableHeight = availableHeight
            if widthSizingMode == .maxContent { effectiveAvailableWidth = .nan }
            if heightSizingMode == .maxContent { effectiveAvailableHeight = .nan }

            let innerWidth = isUndefined(effectiveAvailableWidth) ? effectiveAvailableWidth : maxOrDefined(0, effectiveAvailableWidth - paddingBorderWidth)
            let innerHeight = isUndefined(effectiveAvailableHeight) ? effectiveAvailableHeight : maxOrDefined(0, effectiveAvailableHeight - paddingBorderHeight)

            let widthMode: GWMeasureMode = widthSizingMode == .stretchFit ? .exactly :
                widthSizingMode == .maxContent ? .undefined : .atMost
            let heightMode: GWMeasureMode = heightSizingMode == .stretchFit ? .exactly :
                heightSizingMode == .maxContent ? .undefined : .atMost

            let measured = measureFunc(node, innerWidth.isNaN ? 0 : innerWidth, widthMode,
                                        innerHeight.isNaN ? 0 : innerHeight, heightMode)

            node.layout.setDimension(.width, boundAxis(node, axis: .row, value:
                (widthSizingMode == .maxContent || widthSizingMode == .fitContent)
                    ? measured.width + paddingBorderWidth : availableWidth,
                direction: direction, axisSize: ownerWidth, widthSize: ownerWidth))
            node.layout.setDimension(.height, boundAxis(node, axis: .column, value:
                (heightSizingMode == .maxContent || heightSizingMode == .fitContent)
                    ? measured.height + paddingBorderHeight : availableHeight,
                direction: direction, axisSize: ownerHeight, widthSize: ownerWidth))
        }
    }

    static func measureNodeWithoutChildren(
        _ node: GWYogaNode,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        availableWidth: Float,
        availableHeight: Float,
        paddingAndBorderMain: Float,
        paddingAndBorderCross: Float,
        ownerWidth: Float,
        ownerHeight: Float
    ) {
        // Only set dimensions that haven't been determined yet (needed for cases
        // where the parent's flex algorithm already set the main axis dimension).
        if node.layout.dimension(.width).isNaN {
            if widthSizingMode == .maxContent || widthSizingMode == .fitContent {
                node.layout.setDimension(.width, paddingAndBorderMain)
            } else {
                node.layout.setDimension(.width, boundAxis(node, axis: .row, value: availableWidth,
                                                             direction: node.layout.direction,
                                                             axisSize: ownerWidth, widthSize: ownerWidth))
            }
        }

        if node.layout.dimension(.height).isNaN {
            if heightSizingMode == .maxContent || heightSizingMode == .fitContent {
                node.layout.setDimension(.height, paddingAndBorderCross)
            } else {
                node.layout.setDimension(.height, boundAxis(node, axis: .column, value: availableHeight,
                                                              direction: node.layout.direction,
                                                              axisSize: ownerHeight, widthSize: ownerWidth))
            }
        }
    }

    static func zeroOutLayoutRecursively(_ node: GWYogaNode) {
        node.layout.setDimension(.width, 0)
        node.layout.setDimension(.height, 0)
        node.layout.setPosition(.left, 0)
        node.layout.setPosition(.top, 0)
        node.layout.setPosition(.right, 0)
        node.layout.setPosition(.bottom, 0)
        for child in node.children {
            zeroOutLayoutRecursively(child)
        }
    }

    /// Clean up and update all display: contents nodes with a direct path
    /// to the current node, as they will not be traversed.
    static func cleanupContentsNodesRecursively(_ node: GWYogaNode) {
        for child in node.children where child.style.display == .contents {
            child.layout.setDimension(.width, 0)
            child.layout.setDimension(.height, 0)
            child.layout.setPosition(.left, 0)
            child.layout.setPosition(.top, 0)
            child.layout.setPosition(.right, 0)
            child.layout.setPosition(.bottom, 0)
            child.hasNewLayout = true
            child.isDirty = false
            cleanupContentsNodesRecursively(child)
        }
    }

    /// Returns true if both dimensions have fixed sizes, allowing layout to be skipped.
    static func measureNodeWithFixedSize(
        _ node: GWYogaNode,
        direction: GWDirection,
        availableWidth: Float,
        availableHeight: Float,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        ownerWidth: Float,
        ownerHeight: Float
    ) -> Bool {
        func isFixedSize(_ dim: Float, _ mode: GWSizingMode) -> Bool {
            return mode == .stretchFit ||
                (isDefined(dim) && mode == .fitContent && dim <= 0.0)
        }

        if isFixedSize(availableWidth, widthSizingMode) &&
           isFixedSize(availableHeight, heightSizingMode) {
            let clampedWidth = boundAxis(node, axis: .row, value:
                (isUndefined(availableWidth) || (widthSizingMode == .fitContent && availableWidth < 0)) ? 0 : availableWidth,
                direction: direction, axisSize: ownerWidth, widthSize: ownerWidth)
            let clampedHeight = boundAxis(node, axis: .column, value:
                (isUndefined(availableHeight) || (heightSizingMode == .fitContent && availableHeight < 0)) ? 0 : availableHeight,
                direction: direction, axisSize: ownerHeight, widthSize: ownerWidth)
            node.layout.setDimension(.width, clampedWidth)
            node.layout.setDimension(.height, clampedHeight)
            return true
        }
        return false
    }

    // MARK: - TrailingPosition（对应 C++ TrailingPosition.h）

    /// 计算对边位置（用于 reverse 方向）
    static func getPositionOfOppositeEdge(
        _ position: Float, _ axis: GWFlexDirection,
        _ containingNode: GWYogaNode, _ node: GWYogaNode
    ) -> Float {
        let containerDim = containingNode.layout.dimension(dimension(axis))
        let nodeDim = node.layout.dimension(dimension(axis))
        return containerDim - nodeDim - position
    }

    /// 设置子节点的 trailing 位置（flex-end 边）
    static func setChildTrailingPosition(
        _ node: GWYogaNode, _ child: GWYogaNode, _ axis: GWFlexDirection
    ) {
        let pos = child.layout.position(asPhysical(flexStartEdge(axis)))
        let opposite = getPositionOfOppositeEdge(pos, axis, node, child)
        child.layout.setPosition(asPhysical(flexEndEdge(axis)), opposite)
    }

    /// 是否需要 trailing 位置（reverse 方向需要）
    static func needsTrailingPosition(_ axis: GWFlexDirection) -> Bool {
        axis == .rowReverse || axis == .columnReverse
    }

    // MARK: - Baseline（对应 C++ Baseline.h/cpp）

    /// 计算节点 baseline（相对于顶部边缘的偏移）
    static func calculateBaseline(_ node: GWYogaNode) -> Float {
        if let baselineFunc = node.baselineFunction {
            let baseline = baselineFunc(
                node, node.layout.dimension(.width), node.layout.dimension(.height))
            assertFatalWithNode(node, !baseline.isNaN, "baseline 函数不能返回 NaN")
            return baseline
        }

        // 查找第一个非 absolute 的子节点作为 baseline 参考
        var baselineChild: GWYogaNode? = nil
        for child in node.children {
            if child.lineIndex > 0 { break }
            if child.style.positionType == .absolute { continue }
            let childAlign = resolveChildAlignment(parent: node.style, child: child.style)
            if childAlign == .baseline || child.isReferenceBaseline {
                baselineChild = child
                break
            }
            if baselineChild == nil {
                baselineChild = child
            }
        }

        guard let found = baselineChild else {
            return node.layout.dimension(.height)
        }

        return calculateBaseline(found) + found.layout.position(.top)
    }

    /// 检查是否有子节点参与 baseline 对齐（仅对 row 方向有效）
    static func isBaselineLayout(_ node: GWYogaNode) -> Bool {
        if node.style.flexDirection.isColumn { return false }
        if node.style.alignItems == .baseline { return true }
        for child in node.children {
            if child.style.positionType != .absolute && child.style.alignSelf == .baseline {
                return true
            }
        }
        return false
    }

    // MARK: - LayoutableChildren（对应 C++ LayoutableChildren.h，处理 display:contents）

    /// 布局子节点迭代器：跳过 display:none 和 absolute 子节点，
    /// 展开 display:contents 子节点的子节点。
    /// 简化版：不含 contents 展开（contents 节点会递归展开子节点）
    static func layoutChildren(_ node: GWYogaNode) -> [GWYogaNode] {
        var result: [GWYogaNode] = []
        for child in node.children {
            if child.style.display == .none { continue }
            if child.style.display == .contents {
                // 将 contents 节点的子节点提升到当前层
                for grandchild in child.children {
                    if grandchild.style.display == .none { continue }
                    result.append(grandchild)
                }
                continue
            }
            result.append(child)
        }
        return result
    }

    // MARK: - constrainMaxSizeForMode（对应 C++ CalculateLayout 中的约束逻辑）

    /// 应用 max 约束，如果内容超过 max 则调整 SizingMode
    private static func constrainMaxSizeForMode(
        _ size: Float, _ maxSize: GWFloatOptional, _ mode: inout GWSizingMode
    ) -> Float {
        guard maxSize.isDefined && maxSize.unwrap() >= 0 else { return size }
        let maxVal = maxSize.unwrap()
        if mode == .fitContent && size > maxVal {
            return maxVal
        }
        if mode == .maxContent {
            mode = .fitContent
            return maxVal
        }
        if mode == .stretchFit {
            mode = .fitContent
            return maxVal
        }
        return maxVal
    }

    /// Node-based constrainMaxSizeForMode (reads max from node style, matching C++).
    static func constrainMaxSizeForMode(
        _ mode: inout GWSizingMode, _ size: inout Float,
        node: GWYogaNode, direction: GWDirection, axis: GWFlexDirection,
        ownerAxisSize: Float, ownerWidth: Float
    ) {
        let maxVal = node.style.resolvedMaxDimension(
            direction, axis.dimension, ownerAxisSize, ownerWidth)
        let maxSize = maxVal + GWFloatOptional(value: node.style.computeMarginForAxis(axis, ownerWidth))
        switch mode {
        case .stretchFit, .fitContent:
            if maxSize.isDefined && size > maxSize.unwrap() {
                size = maxSize.unwrap()
            }
        case .maxContent:
            if maxSize.isDefined {
                mode = .fitContent
                size = maxSize.unwrap()
            }
        }
    }

    // MARK: - Margin-aware caching（对应 C++ Cache.h/cpp）

    /// 检查是否能使用缓存的测量结果（margin-aware 版本）
    static func canUseCachedMeasurement(
        widthMode: GWSizingMode, availableWidth: Float,
        heightMode: GWSizingMode, availableHeight: Float,
        lastWidthMode: GWSizingMode, lastAvailableWidth: Float,
        lastHeightMode: GWSizingMode, lastAvailableHeight: Float,
        lastComputedWidth: Float, lastComputedHeight: Float,
        marginRow: Float, marginColumn: Float,
        config: GWYogaConfig
    ) -> Bool {
        // 缓存结果为负时无效
        if (isDefined(lastComputedHeight) && lastComputedHeight < 0) ||
           (isDefined(lastComputedWidth) && lastComputedWidth < 0) {
            return false
        }

        let pointScaleFactor = config.pointScaleFactor

        let useRounded = pointScaleFactor != 0
        let effectiveWidth = useRounded
            ? roundValueToPixelGrid(availableWidth, pointScaleFactor: pointScaleFactor, forceCeil: false, forceFloor: false)
            : availableWidth
        let effectiveHeight = useRounded
            ? roundValueToPixelGrid(availableHeight, pointScaleFactor: pointScaleFactor, forceCeil: false, forceFloor: false)
            : availableHeight
        let effectiveLastWidth = useRounded
            ? roundValueToPixelGrid(lastAvailableWidth, pointScaleFactor: pointScaleFactor, forceCeil: false, forceFloor: false)
            : lastAvailableWidth
        let effectiveLastHeight = useRounded
            ? roundValueToPixelGrid(lastAvailableHeight, pointScaleFactor: pointScaleFactor, forceCeil: false, forceFloor: false)
            : lastAvailableHeight

        let hasSameWidthSpec = lastWidthMode == widthMode &&
            inexactEquals(effectiveLastWidth, effectiveWidth)
        let hasSameHeightSpec = lastHeightMode == heightMode &&
            inexactEquals(effectiveLastHeight, effectiveHeight)

        func sizeIsExactAndMatchesOld(_ sizeMode: GWSizingMode, _ size: Float, _ lastSize: Float) -> Bool {
            sizeMode == .stretchFit && inexactEquals(size, lastSize)
        }

        func oldSizeIsMaxContentAndStillFits(_ sizeMode: GWSizingMode, _ size: Float,
                                              _ lastSizeMode: GWSizingMode, _ lastSize: Float) -> Bool {
            sizeMode == .fitContent && lastSizeMode == .maxContent &&
            (size >= lastSize || inexactEquals(size, lastSize))
        }

        func newSizeIsStricterAndStillValid(_ sizeMode: GWSizingMode, _ size: Float,
                                             _ lastSizeMode: GWSizingMode, _ lastSize: Float,
                                             _ lastComputedSize: Float) -> Bool {
            lastSizeMode == .fitContent && sizeMode == .fitContent &&
            isDefined(lastSize) && isDefined(size) && isDefined(lastComputedSize) &&
            lastSize > size &&
            (lastComputedSize <= size || inexactEquals(size, lastComputedSize))
        }

        let widthIsCompatible = hasSameWidthSpec ||
            sizeIsExactAndMatchesOld(widthMode, availableWidth - marginRow, lastComputedWidth) ||
            oldSizeIsMaxContentAndStillFits(widthMode, availableWidth - marginRow, lastWidthMode, lastComputedWidth) ||
            newSizeIsStricterAndStillValid(widthMode, availableWidth - marginRow, lastWidthMode, lastAvailableWidth, lastComputedWidth)

        let heightIsCompatible = hasSameHeightSpec ||
            sizeIsExactAndMatchesOld(heightMode, availableHeight - marginColumn, lastComputedHeight) ||
            oldSizeIsMaxContentAndStillFits(heightMode, availableHeight - marginColumn, lastHeightMode, lastComputedHeight) ||
            newSizeIsStricterAndStillValid(heightMode, availableHeight - marginColumn, lastHeightMode, lastAvailableHeight, lastComputedHeight)

        return widthIsCompatible && heightIsCompatible
    }
}
