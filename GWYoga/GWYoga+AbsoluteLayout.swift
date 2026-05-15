import Foundation

// MARK: - 完整 AbsoluteLayout（对应 C++ AbsoluteLayout.cpp）

extension GWLayoutEngine {

    /// 在 flex-start 边设定 absolute 子节点位置
    private static func setFlexStartLayoutPosition(
        _ parent: GWYogaNode, _ child: GWYogaNode,
        _ direction: GWDirection, _ axis: GWFlexDirection,
        _ containingBlockWidth: Float
    ) {
        var position = child.style.computeFlexStartMargin(axis, direction, containingBlockWidth) +
            parent.layout.border(asPhysical(flexStartEdge(axis)))

        if !child.hasErrata(.absolutePositionWithoutInsetsExcludesPadding) &&
            parent.style.display != .grid {
            position += parent.layout.padding(asPhysical(flexStartEdge(axis)))
        }

        child.layout.setPosition(asPhysical(flexStartEdge(axis)), position)
    }

    /// 在 flex-end 边设定 absolute 子节点位置
    private static func setFlexEndLayoutPosition(
        _ parent: GWYogaNode, _ child: GWYogaNode,
        _ direction: GWDirection, _ axis: GWFlexDirection,
        _ containingBlockWidth: Float
    ) {
        var flexEndPosition = parent.layout.border(asPhysical(flexEndEdge(axis))) +
            child.style.computeFlexEndMargin(axis, direction, containingBlockWidth)

        if !child.hasErrata(.absolutePositionWithoutInsetsExcludesPadding) &&
            parent.style.display != .grid {
            flexEndPosition += parent.layout.padding(asPhysical(flexEndEdge(axis)))
        }

        child.layout.setPosition(
            asPhysical(flexStartEdge(axis)),
            getPositionOfOppositeEdge(flexEndPosition, axis, parent, child))
    }

    /// 居中定位 absolute 子节点
    private static func setCenterLayoutPosition(
        _ parent: GWYogaNode, _ child: GWYogaNode,
        _ direction: GWDirection, _ axis: GWFlexDirection,
        _ containingBlockWidth: Float
    ) {
        var parentContentBoxSize = parent.layout.dimension(dimension(axis)) -
            parent.layout.border(asPhysical(flexStartEdge(axis))) - parent.layout.border(asPhysical(flexEndEdge(axis)))

        if !child.hasErrata(.absolutePositionWithoutInsetsExcludesPadding) &&
            parent.style.display != .grid {
            parentContentBoxSize -= parent.layout.padding(asPhysical(flexStartEdge(axis)))
            parentContentBoxSize -= parent.layout.padding(asPhysical(flexEndEdge(axis)))
        }

        let childOuterSize = child.layout.dimension(dimension(axis)) +
            child.style.computeMarginForAxis(axis, containingBlockWidth)

        var position = (parentContentBoxSize - childOuterSize) / 2.0 +
            parent.layout.border(asPhysical(flexStartEdge(axis))) +
            child.style.computeFlexStartMargin(axis, direction, containingBlockWidth)

        if !child.hasErrata(.absolutePositionWithoutInsetsExcludesPadding) &&
            parent.style.display != .grid {
            position += parent.layout.padding(asPhysical(flexStartEdge(axis)))
        }

        child.layout.setPosition(asPhysical(flexStartEdge(axis)), position)
    }

    /// 主轴 justify 定位（用于 absolute 子节点）
    private static func justifyAbsoluteChild(
        _ parent: GWYogaNode, _ child: GWYogaNode,
        _ direction: GWDirection, _ mainAxis: GWFlexDirection,
        _ containingBlockWidth: Float
    ) {
        let justify: GWJustify = parent.style.display == .grid
            ? resolveChildJustification(parent: parent.style, child: child.style)
            : parent.style.justifyContent

        switch justify {
        case .start, .auto, .stretch, .flexStart, .spaceBetween:
            setFlexStartLayoutPosition(parent, child, direction, mainAxis, containingBlockWidth)
        case .end, .flexEnd:
            setFlexEndLayoutPosition(parent, child, direction, mainAxis, containingBlockWidth)
        case .center, .spaceAround, .spaceEvenly:
            setCenterLayoutPosition(parent, child, direction, mainAxis, containingBlockWidth)
        }
    }

    /// 交叉轴 align 定位（用于 absolute 子节点）
    private static func alignAbsoluteChild(
        _ parent: GWYogaNode, _ child: GWYogaNode,
        _ direction: GWDirection, _ crossAxis: GWFlexDirection,
        _ containingBlockWidth: Float
    ) {
        var itemAlign = resolveChildAlignment(parent: parent.style, child: child.style)
        let parentWrap = parent.style.flexWrap
        if parentWrap == .wrapReverse {
            itemAlign = itemAlign == .flexEnd ? .flexStart : .flexEnd
        }

        switch itemAlign {
        case .start, .auto, .flexStart, .baseline, .spaceAround, .spaceBetween, .stretch, .spaceEvenly:
            setFlexStartLayoutPosition(parent, child, direction, crossAxis, containingBlockWidth)
        case .end, .flexEnd:
            setFlexEndLayoutPosition(parent, child, direction, crossAxis, containingBlockWidth)
        case .center:
            setCenterLayoutPosition(parent, child, direction, crossAxis, containingBlockWidth)
        }
    }

    /// 定位单个 absolute 子节点（完整实现，对应 C++ layoutAbsoluteChild）
    static func layoutAbsoluteChild(
        containingNode: GWYogaNode, node: GWYogaNode, child: GWYogaNode,
        containingBlockWidth: Float, containingBlockHeight: Float,
        widthMode: GWSizingMode, direction: GWDirection,
        depth: UInt32
    ) {
        let mainAxis: GWFlexDirection = node.style.display == .grid
            ? .row.resolved(for: direction)
            : node.style.flexDirection.resolved(for: direction)
        let crossAxis: GWFlexDirection = node.style.display == .grid
            ? .column
            : mainAxis.isColumn ? .row.resolved(for: direction) : .column
        let isMainAxisRow = mainAxis.isRow

        var childWidth: Float = .nan
        var childHeight: Float = .nan
        var childWidthSizingMode: GWSizingMode = .maxContent
        var childHeightSizingMode: GWSizingMode = .maxContent

        let marginRow = child.style.computeMarginForAxis(.row, containingBlockWidth)
        let marginColumn = child.style.computeMarginForAxis(.column, containingBlockWidth)

        // 确定宽度
        if child.hasDefiniteLength(.width, containingBlockWidth) {
            childWidth = child.getResolvedDimension(direction, .width, containingBlockWidth, containingBlockWidth).unwrap() + marginRow
        } else if child.style.isFlexStartPositionDefined(.row, direction) &&
                  child.style.isFlexEndPositionDefined(.row, direction) &&
                  !child.style.isFlexStartPositionAuto(.row, direction) &&
                  !child.style.isFlexEndPositionAuto(.row, direction) {
            childWidth = containingNode.layout.dimension(.width) -
                (containingNode.style.computeFlexStartBorder(.row, direction) +
                 containingNode.style.computeFlexEndBorder(.row, direction)) -
                (child.style.computeFlexStartPosition(.row, direction, containingBlockWidth) +
                 child.style.computeFlexEndPosition(.row, direction, containingBlockWidth))
            childWidth = boundAxis(child, axis: .row, value: childWidth,
                                   direction: direction, axisSize: containingBlockWidth, widthSize: containingBlockWidth)
        }

        // 确定高度
        if child.hasDefiniteLength(.height, containingBlockHeight) {
            childHeight = child.getResolvedDimension(direction, .height, containingBlockHeight, containingBlockWidth).unwrap() + marginColumn
        } else if child.style.isFlexStartPositionDefined(.column, direction) &&
                  child.style.isFlexEndPositionDefined(.column, direction) &&
                  !child.style.isFlexStartPositionAuto(.column, direction) &&
                  !child.style.isFlexEndPositionAuto(.column, direction) {
            childHeight = containingNode.layout.dimension(.height) -
                (containingNode.style.computeFlexStartBorder(.column, direction) +
                 containingNode.style.computeFlexEndBorder(.column, direction)) -
                (child.style.computeFlexStartPosition(.column, direction, containingBlockHeight) +
                 child.style.computeFlexEndPosition(.column, direction, containingBlockHeight))
            childHeight = boundAxis(child, axis: .column, value: childHeight,
                                    direction: direction, axisSize: containingBlockHeight, widthSize: containingBlockWidth)
        }

        // Aspect Ratio：只有一个维度定义时用比例推导
        let childStyle = child.style
        if isUndefined(childWidth) != isUndefined(childHeight) {
            if childStyle.aspectRatio.isDefined {
                if isUndefined(childWidth) {
                    childWidth = marginRow + (childHeight - marginColumn) * childStyle.aspectRatio.unwrap()
                } else {
                    childHeight = marginColumn + (childWidth - marginRow) / childStyle.aspectRatio.unwrap()
                }
            }
        }

        // 测量未确定的维度
        if isUndefined(childWidth) || isUndefined(childHeight) {
            childWidthSizingMode = isUndefined(childWidth) ? .maxContent : .stretchFit
            childHeightSizingMode = isUndefined(childHeight) ? .maxContent : .stretchFit

            // 如果容器尺寸已知，约束 absolute 子节点到容器尺寸（让文字能换行）
            if !isMainAxisRow && isUndefined(childWidth) &&
                widthMode != .maxContent && isDefined(containingBlockWidth) && containingBlockWidth > 0 {
                childWidth = containingBlockWidth
                childWidthSizingMode = .fitContent
            }

            var absMarker = GWLayoutData()
            let _ = calculateLayoutInternal(
                node: child, availableWidth: childWidth, availableHeight: childHeight,
                ownerDirection: direction,
                widthSizingMode: childWidthSizingMode, heightSizingMode: childHeightSizingMode,
                ownerWidth: containingBlockWidth, ownerHeight: containingBlockHeight,
                performLayout: false,
                layoutPassReason: .absMeasureChild,
                layoutMarkerData: &absMarker,
                depth: depth + 1,
                generationCount: gCurrentGenerationCount
            )

            childWidth = child.layout.dimension(.width) +
                child.style.computeMarginForAxis(.row, containingBlockWidth)
            childHeight = child.layout.dimension(.height) +
                child.style.computeMarginForAxis(.column, containingBlockWidth)
        }

        // 最终布局（stretchFit）
        var absLayoutMarker = GWLayoutData()
        let _ = calculateLayoutInternal(
            node: child, availableWidth: childWidth, availableHeight: childHeight,
            ownerDirection: direction,
            widthSizingMode: .stretchFit, heightSizingMode: .stretchFit,
            ownerWidth: containingBlockWidth, ownerHeight: containingBlockHeight,
            performLayout: true,
            layoutPassReason: .absLayout,
            layoutMarkerData: &absLayoutMarker,
            depth: depth + 1,
            generationCount: gCurrentGenerationCount
        )

        // 主轴定位
        positionAbsoluteChild(
            containingNode: containingNode, parent: node, child: child,
            direction: direction, axis: mainAxis, isMainAxis: true,
            containingBlockWidth: containingBlockWidth, containingBlockHeight: containingBlockHeight)
        // 交叉轴定位
        positionAbsoluteChild(
            containingNode: containingNode, parent: node, child: child,
            direction: direction, axis: crossAxis, isMainAxis: false,
            containingBlockWidth: containingBlockWidth, containingBlockHeight: containingBlockHeight)
    }

    /// 定位 absolute 子节点（根据 inset 或 justify/align）
    private static func positionAbsoluteChild(
        containingNode: GWYogaNode, parent: GWYogaNode, child: GWYogaNode,
        direction: GWDirection, axis: GWFlexDirection, isMainAxis: Bool,
        containingBlockWidth: Float, containingBlockHeight: Float
    ) {
        let isAxisRow = axis.isRow
        let containingBlockSize = isAxisRow ? containingBlockWidth : containingBlockHeight

        // inline-start 优先于 inline-end
        if child.style.isInlineStartPositionDefined(axis, direction) &&
            !child.style.isInlineStartPositionAuto(axis, direction) {
            let posRelativeToInlineStart = child.style.computeInlineStartPosition(axis, direction, containingBlockSize) +
                containingNode.style.computeInlineStartBorder(axis, direction) +
                child.style.computeInlineStartMargin(axis, direction, containingBlockSize)
            let posRelativeToFlexStart = inlineStartEdge(axis, direction) != flexStartEdge(axis)
                ? getPositionOfOppositeEdge(posRelativeToInlineStart, axis, containingNode, child)
                : posRelativeToInlineStart
            child.layout.setPosition(asPhysical(flexStartEdge(axis)), posRelativeToFlexStart)
        } else if child.style.isInlineEndPositionDefined(axis, direction) &&
                  !child.style.isInlineEndPositionAuto(axis, direction) {
            let posRelativeToInlineStart = containingNode.layout.dimension(dimension(axis)) -
                child.layout.dimension(dimension(axis)) -
                containingNode.style.computeInlineEndBorder(axis, direction) -
                child.style.computeInlineEndMargin(axis, direction, containingBlockSize) -
                child.style.computeInlineEndPosition(axis, direction, containingBlockSize)
            let posRelativeToFlexStart = inlineStartEdge(axis, direction) != flexStartEdge(axis)
                ? getPositionOfOppositeEdge(posRelativeToInlineStart, axis, containingNode, child)
                : posRelativeToInlineStart
            child.layout.setPosition(asPhysical(flexStartEdge(axis)), posRelativeToFlexStart)
        } else {
            if isMainAxis {
                justifyAbsoluteChild(parent, child, direction, axis, containingBlockWidth)
            } else {
                alignAbsoluteChild(parent, child, direction, axis, containingBlockWidth)
            }
        }
    }

    /// 布局所有 absolute 后代（重写版，对应 C++ layoutAbsoluteDescendants）
    internal static func layoutAbsoluteDescendants(
        containingNode: GWYogaNode, currentNode: GWYogaNode,
        widthSizingMode: GWSizingMode, direction: GWDirection,
        depth: UInt32,
        currentNodeLeftOffsetFromContainingBlock: Float = 0,
        currentNodeTopOffsetFromContainingBlock: Float = 0,
        containingNodeAvailableInnerWidth: Float = 0,
        containingNodeAvailableInnerHeight: Float = 0
    ) -> Bool {
        var hasNewLayout = false
        for child in layoutChildren(currentNode) {
            if child.style.display == .none { continue }

            if child.style.positionType == .absolute {
                let absoluteErrata = currentNode.hasErrata(.absolutePercentAgainstInnerSize)
                let containingBlockWidth = absoluteErrata
                    ? containingNodeAvailableInnerWidth
                    : containingNode.layout.dimension(.width) - containingNode.style.computeBorderForAxis(.row)
                let containingBlockHeight = absoluteErrata
                    ? containingNodeAvailableInnerHeight
                    : containingNode.layout.dimension(.height) - containingNode.style.computeBorderForAxis(.column)

                layoutAbsoluteChild(
                    containingNode: containingNode, node: currentNode, child: child,
                    containingBlockWidth: containingBlockWidth,
                    containingBlockHeight: containingBlockHeight,
                    widthMode: widthSizingMode, direction: direction,
                    depth: depth + 1)

                hasNewLayout = hasNewLayout || child.hasNewLayout

                // trailing position for reverse directions
                let parentMainAxis = currentNode.style.flexDirection.resolved(for: direction)
                let parentCrossAxis = parentMainAxis.isColumn ? GWFlexDirection.row.resolved(for: direction) : GWFlexDirection.column

                if needsTrailingPosition(parentMainAxis) {
                    let mainInsetsDefined = parentMainAxis.isRow
                        ? child.style.horizontalInsetsDefined
                        : child.style.verticalInsetsDefined
                    setChildTrailingPosition(
                        mainInsetsDefined ? containingNode : currentNode, child, parentMainAxis)
                }
                if needsTrailingPosition(parentCrossAxis) {
                    let crossInsetsDefined = parentCrossAxis.isRow
                        ? child.style.horizontalInsetsDefined
                        : child.style.verticalInsetsDefined
                    setChildTrailingPosition(
                        crossInsetsDefined ? containingNode : currentNode, child, parentCrossAxis)
                }

                // 偏移：减去当前节点相对于 containing block 的偏移
                let childLeftPosition = child.layout.position(.left)
                let childTopPosition = child.layout.position(.top)

                let childLeftOffsetFromParent = child.style.horizontalInsetsDefined
                    ? (childLeftPosition - currentNodeLeftOffsetFromContainingBlock)
                    : childLeftPosition
                let childTopOffsetFromParent = child.style.verticalInsetsDefined
                    ? (childTopPosition - currentNodeTopOffsetFromContainingBlock)
                    : childTopPosition

                child.layout.setPosition(.left, childLeftOffsetFromParent)
                child.layout.setPosition(.top, childTopOffsetFromParent)

                // 继续处理下一个子节点

            } else if child.style.positionType == .static && !child.alwaysFormsContainingBlock {
                let childDirection = resolveDirection(child.style, ownerDirection: direction)
                let childLeftOffsetFromContainingBlock = currentNodeLeftOffsetFromContainingBlock +
                    child.layout.position(.left)
                let childTopOffsetFromContainingBlock = currentNodeTopOffsetFromContainingBlock +
                    child.layout.position(.top)

                hasNewLayout = layoutAbsoluteDescendants(
                    containingNode: containingNode, currentNode: child,
                    widthSizingMode: widthSizingMode, direction: childDirection,
                    depth: depth + 1,
                    currentNodeLeftOffsetFromContainingBlock: childLeftOffsetFromContainingBlock,
                    currentNodeTopOffsetFromContainingBlock: childTopOffsetFromContainingBlock,
                    containingNodeAvailableInnerWidth: containingNodeAvailableInnerWidth,
                    containingNodeAvailableInnerHeight: containingNodeAvailableInnerHeight) || hasNewLayout

                if hasNewLayout {
                    child.hasNewLayout = hasNewLayout
                }
            }
        }
        return hasNewLayout
    }
}
