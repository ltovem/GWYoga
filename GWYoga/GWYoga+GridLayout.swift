import Foundation

// MARK: - Grid Layout Engine

/// Pure Swift implementation of CSS Grid Layout.
/// Follows the CSS Grid Layout spec (https://www.w3.org/TR/css-grid-1/).
internal enum GWGridLayoutEngine {

    /// Absolute-positioned children filter
    private static func gridChildren(_ node: GWYogaNode) -> [GWYogaNode] {
        node.children.filter { $0.style.display != .none && $0.style.positionType != .absolute }
    }

    private static func absoluteChildren(_ node: GWYogaNode) -> [GWYogaNode] {
        node.children.filter { $0.style.display != .none && $0.style.positionType == .absolute }
    }

    // MARK: - Public Entry Point

    /// Calculate layout for a `display: grid` node.
    static func calculateGridLayout(
        node: GWYogaNode,
        direction: GWDirection,
        availableInnerWidth: Float,
        availableInnerHeight: Float,
        ownerWidth: Float,
        ownerHeight: Float,
        paddingAndBorderMain: Float,
        paddingAndBorderCross: Float,
        performLayout: Bool,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        layoutMarkerData: inout GWLayoutData
    ) {
        let children = gridChildren(node)
        if !performLayout && children.isEmpty {
            // Measure empty grid container
            measureEmptyGrid(node, widthSizingMode: widthSizingMode, heightSizingMode: heightSizingMode,
                             availableInnerWidth: availableInnerWidth, availableInnerHeight: availableInnerHeight,
                             paddingAndBorderMain: paddingAndBorderMain, paddingAndBorderCross: paddingAndBorderCross,
                             direction: direction, ownerWidth: ownerWidth)
            return
        }

        // --- Step 1: Resolve grid template tracks ---
        let columnTemplates = resolveGridTracks(node.style.gridTemplateColumns, node.style.gridAutoColumns)
        let rowTemplates = resolveGridTracks(node.style.gridTemplateRows, node.style.gridAutoRows)

        // --- Step 2: Place items ---
        let placements = placeGridItems(children: children, columnTemplates: columnTemplates, rowTemplates: rowTemplates)

        // Determine effective grid dimensions
        let effectiveCols = determineEffectiveTrackCount(placements: placements, templates: columnTemplates, axis: .width)
        let effectiveRows = determineEffectiveTrackCount(placements: placements, templates: rowTemplates, axis: .height)

        // Expand tracks to match effective grid
        var colTracks = expandTracks(columnTemplates, count: effectiveCols)
        var rowTracks = expandTracks(rowTemplates, count: effectiveRows)

        // --- Step 3: Resolve gaps ---
        let columnGap = resolveGap(node.style.resolvedGap(for: .column), referenceLength: availableInnerWidth)
        let rowGap = resolveGap(node.style.resolvedGap(for: .row), referenceLength: availableInnerWidth)

        // --- Step 4: Track sizing ---
        // Phase 1: Initialize track sizes
        initializeTrackSizes(&colTracks, referenceLength: availableInnerWidth)
        initializeTrackSizes(&rowTracks, referenceLength: availableInnerHeight)

        // Phase 2: Intrinsic track sizing
        resolveIntrinsicTrackSizes(&colTracks, axis: .width, placements: placements, children: children,
                                   direction: direction, availableInnerWidth: availableInnerWidth,
                                   availableInnerHeight: availableInnerHeight, node: node, gap: columnGap)
        resolveIntrinsicTrackSizes(&rowTracks, axis: .height, placements: placements, children: children,
                                   direction: direction, availableInnerWidth: availableInnerWidth,
                                   availableInnerHeight: availableInnerHeight, node: node, gap: rowGap)

        // Phase 3: Distribute fr space
        let totalColumnFr = totalFr(colTracks)
        let totalRowFr = totalFr(rowTracks)

        if totalColumnFr > 0 {
            let usedColSpace = usedTrackSpace(colTracks) + max(0, Float(effectiveCols - 1)) * columnGap
            let availableForColumns = max(0, availableInnerWidth - usedColSpace)
            distributeFrSpace(&colTracks, totalFr: totalColumnFr, availableSpace: availableForColumns)
        }

        if totalRowFr > 0 {
            let usedRowSpace = usedTrackSpace(rowTracks) + max(0, Float(effectiveRows - 1)) * rowGap
            let availableForRows = max(0, availableInnerHeight - usedRowSpace)
            distributeFrSpace(&rowTracks, totalFr: totalRowFr, availableSpace: availableForRows)
        }

        // Phase 4: Stretch tracks (if align-content / justify-content is stretch)
        let justifyContent = node.style.justifyContent
        let alignContent = node.style.alignContent

        if justifyContent == .stretch || justifyContent == .spaceBetween {
            let trackTotal = usedTrackSpace(colTracks) + max(0, Float(effectiveCols - 1)) * columnGap
            let extra = availableInnerWidth - trackTotal
            if extra > 0 {
                stretchTracks(&colTracks, extraSpace: extra)
            }
        }

        if alignContent == .stretch || alignContent == .spaceBetween {
            let trackTotal = usedTrackSpace(rowTracks) + max(0, Float(effectiveRows - 1)) * rowGap
            let extra = availableInnerHeight - trackTotal
            if extra > 0 {
                stretchTracks(&rowTracks, extraSpace: extra)
            }
        }

        // --- Step 5: Compute track positions ---
        let leadingColOffset = node.style.computeInlineStartPadding(.row, direction, ownerWidth)
            + node.style.computeInlineStartBorder(.row, direction)
        let leadingRowOffset = node.style.computeInlineStartPadding(.column, direction, ownerWidth)
            + node.style.computeInlineStartBorder(.column, direction)
        let colPositions = computeTrackPositions(colTracks, gap: columnGap, start: leadingColOffset)
        let rowPositions = computeTrackPositions(rowTracks, gap: rowGap, start: leadingRowOffset)

        // --- Step 6: Position grid items ---
        if performLayout {
            for (i, child) in children.enumerated() {
                let placement = placements[i]

                let cs = placement.columnStart - 1
                let ce = placement.columnEnd - 1
                let rs = placement.rowStart - 1
                let re = placement.rowEnd - 1

                // Compute physical position + size, accounting for gaps between tracks
                var itemX = colPositions[cs] + Float(cs) * columnGap
                var itemY = rowPositions[rs] + Float(rs) * rowGap
                let itemWidth = (colPositions[ce] - colPositions[cs]) + max(0, Float(ce - cs - 1)) * columnGap
                let itemHeight = (rowPositions[re] - rowPositions[rs]) + max(0, Float(re - rs - 1)) * rowGap

                // Account for child margins
                let marginLeft = child.style.resolvedMargin(for: .left, direction: direction)
                    .resolve(referenceLength: availableInnerWidth).unwrap(orDefault: 0)
                let marginRight = child.style.resolvedMargin(for: .right, direction: direction)
                    .resolve(referenceLength: availableInnerWidth).unwrap(orDefault: 0)
                let marginTop = child.style.resolvedMargin(for: .top, direction: direction)
                    .resolve(referenceLength: availableInnerWidth).unwrap(orDefault: 0)
                let marginBottom = child.style.resolvedMargin(for: .bottom, direction: direction)
                    .resolve(referenceLength: availableInnerWidth).unwrap(orDefault: 0)

                let marginHorizontal = marginLeft + marginRight
                let marginVertical = marginTop + marginBottom

                // Apply item-level alignment (justify-self for column axis, align-self for row axis)
                let justifySelf = resolveJustifySelf(child.style, parentStyle: node.style)
                let alignSelf = resolveChildAlignment(parent: node.style, child: child.style)

                // Available size for alignment within the grid area
                let availableWidth = itemWidth - marginHorizontal
                let availableHeight = itemHeight - marginVertical

                // Check if child has an explicit (non-auto) size or a measure function
                let hasExplicitWidth = child.style.width.isPoints || child.style.width.isPercent
                let hasExplicitHeight = child.style.height.isPoints || child.style.height.isPercent
                let hasExplicitSize = hasExplicitWidth || hasExplicitHeight || child.measureFunction != nil

                if hasExplicitSize {
                    // Child has its own sizing — lay it out normally
                    let childWidth: Float
                    let childHeight: Float

                    if hasExplicitWidth {
                        let w = resolveStyleSizeLength(child.style.width, itemWidth).unwrap(orDefault: 0)
                        childWidth = w
                    } else {
                        childWidth = availableWidth
                    }

                    if hasExplicitHeight {
                        let h = resolveStyleSizeLength(child.style.height, itemHeight).unwrap(orDefault: 0)
                        childHeight = h
                    } else {
                        childHeight = availableHeight
                    }

                    // Layout the child with the grid area size
                    let _ = GWLayoutEngine.calculateLayoutInternal(
                        node: child,
                        availableWidth: childWidth,
                        availableHeight: childHeight,
                        ownerDirection: direction,
                        widthSizingMode: childWidth.isNaN ? .maxContent : .stretchFit,
                        heightSizingMode: childHeight.isNaN ? .maxContent : .stretchFit,
                        ownerWidth: itemWidth,
                        ownerHeight: itemHeight,
                        performLayout: true,
                        layoutPassReason: .initial,
                        layoutMarkerData: &layoutMarkerData,
                        depth: 0,
                        generationCount: 0
                    )

                    // Position within grid area based on alignment
                    let childW = child.layout.dimension(.width)
                    let childH = child.layout.dimension(.height)

                    itemX += marginLeft + alignInAxis(availableSize: availableWidth, childSize: childW, align: justifySelf)
                    itemY += marginTop + alignInAxis(availableSize: availableHeight, childSize: childH, align: alignmentToFallback(alignSelf))

                    child.layout.setPosition(.left, itemX)
                    child.layout.setPosition(.top, itemY)
                    child.layout.setPosition(.right, itemX + childW)
                    child.layout.setPosition(.bottom, itemY + childH)
                } else {
                    // No explicit size — child stretches to fill grid area
                    let childWidth = availableWidth
                    let childHeight = availableHeight

                    if childWidth > 0 && childHeight > 0 {
                        let _ = GWLayoutEngine.calculateLayoutInternal(
                            node: child,
                            availableWidth: childWidth,
                            availableHeight: childHeight,
                            ownerDirection: direction,
                            widthSizingMode: .stretchFit,
                            heightSizingMode: .stretchFit,
                            ownerWidth: itemWidth,
                            ownerHeight: itemHeight,
                            performLayout: true,
                            layoutPassReason: .initial,
                            layoutMarkerData: &layoutMarkerData,
                            depth: 0,
                            generationCount: 0
                        )
                    }

                    itemX += marginLeft + alignInAxis(availableSize: availableWidth, childSize: childWidth, align: justifySelf)
                    itemY += marginTop + alignInAxis(availableSize: availableHeight, childSize: childHeight, align: alignmentToFallback(alignSelf))

                    child.layout.setPosition(.left, itemX)
                    child.layout.setPosition(.top, itemY)
                    child.layout.setPosition(.right, itemX + childWidth)
                    child.layout.setPosition(.bottom, itemY + childHeight)
                    child.layout.setDimension(.width, childWidth)
                    child.layout.setDimension(.height, childHeight)
                }
            }
        }

        // --- Step 7: Container sizing ---
        let gridWidth = usedTrackSpace(colTracks) + max(0, Float(effectiveCols - 1)) * columnGap
        let gridHeight = usedTrackSpace(rowTracks) + max(0, Float(effectiveRows - 1)) * rowGap

        // Use available space when container has a definite size, otherwise sum of tracks
        var containerWidth: Float
        var containerHeight: Float

        if widthSizingMode == .stretchFit && availableInnerWidth.isFinite {
            containerWidth = availableInnerWidth
        } else {
            containerWidth = gridWidth
        }

        if heightSizingMode == .stretchFit && availableInnerHeight.isFinite {
            containerHeight = availableInnerHeight
        } else {
            containerHeight = gridHeight
        }

        // Add padding and border to get the outer box dimensions
        containerWidth += paddingAndBorderMain
        containerHeight += paddingAndBorderCross

        // Bound by min/max constraints
        let boundedWidth = GWLayoutEngine.boundAxis(node, axis: .row, value: containerWidth,
                                     direction: direction, axisSize: ownerWidth, widthSize: ownerWidth)
        let boundedHeight = GWLayoutEngine.boundAxis(node, axis: .column, value: containerHeight,
                                      direction: direction, axisSize: ownerHeight, widthSize: ownerWidth)

        node.layout.setDimension(.width, boundedWidth)
        node.layout.setDimension(.height, boundedHeight)
        node.layout.setMeasuredDimension(.width, boundedWidth)
        node.layout.setMeasuredDimension(.height, boundedHeight)

        // --- Step 8: Layout absolute children ---
        if performLayout {
            let absChildren = absoluteChildren(node)
            if !absChildren.isEmpty {
                let containingBlockWidth = boundedWidth
                let containingBlockHeight = boundedHeight

                for child in absChildren {
                    GWLayoutEngine.layoutAbsoluteChild(
                        containingNode: node, node: node, child: child,
                        containingBlockWidth: containingBlockWidth,
                        containingBlockHeight: containingBlockHeight,
                        widthMode: widthSizingMode, direction: direction,
                        depth: 0
                    )
                }
            }
        }

        // Mark children as no longer dirty
        if performLayout {
            for child in children {
                child.isDirty = false
                child.hasNewLayout = true
            }
        }
    }

    // MARK: - Grid Template Resolution

    /// Resolve grid template tracks: if user-defined tracks exist, use them; otherwise use a single auto track.
    private static func resolveGridTracks(_ templates: GWGridTrackList, _ autoTracks: GWGridTrackList) -> GWGridTrackList {
        if !templates.isEmpty {
            return templates
        }
        if !autoTracks.isEmpty {
            return autoTracks
        }
        return [.auto()]
    }

    /// Expand template tracks to cover the effective grid size (for implicit tracks).
    private static func expandTracks(_ templates: GWGridTrackList, count: Int) -> [GWGridTrackSize] {
        if templates.count >= count { return Array(templates.prefix(count)) }
        var result = templates
        while result.count < count {
            result.append(.auto())
        }
        return result
    }

    /// Determine the effective number of tracks needed based on placements.
    /// columnEnd/rowEnd are exclusive (1-based), so the track count is maxEnd - 1.
    private static func determineEffectiveTrackCount(placements: [GWGridArea], templates: GWGridTrackList, axis: GWDimension) -> Int {
        let maxEnd = placements.map { axis == .width ? $0.columnEnd : $0.rowEnd }.max() ?? 1
        let neededTracks = max(maxEnd - 1, 1)
        return max(neededTracks, templates.count)
    }

    // MARK: - Gap Resolution

    private static func resolveGap(_ gap: GWStyleLength, referenceLength: Float) -> Float {
        let resolved = gap.resolve(referenceLength: referenceLength)
        return max(0, resolved.unwrap(orDefault: 0))
    }

    // MARK: - Item Placement

    /// Place all grid items, returning a grid area for each child.
    /// Items with definite positions are placed first, then auto-placement fills remaining items.
    private static func placeGridItems(
        children: [GWYogaNode],
        columnTemplates: GWGridTrackList,
        rowTemplates: GWGridTrackList
    ) -> [GWGridArea] {
        var placements: [GWGridArea] = Array(repeating: GWGridArea(), count: children.count)
        var occupied: Set<GWGridCell> = Set()
        let maxCols = max(1, columnTemplates.count)

        // First pass: place items with definite positions (non-auto on the axis)
        for (i, child) in children.enumerated() {
            let hasDefiniteCol = child.style.gridColumnStart.type == .integer
            let hasDefiniteRow = child.style.gridRowStart.type == .integer

            if hasDefiniteCol || hasDefiniteRow {
                let colStart = resolveGridLine(child.style.gridColumnStart, definiteIfAuto: 1)
                let colEnd = resolveGridLineEnd(child.style.gridColumnEnd, start: colStart, definiteIfAuto: colStart + 1)
                let rowStart = resolveGridLine(child.style.gridRowStart, definiteIfAuto: 1)
                let rowEnd = resolveGridLineEnd(child.style.gridRowEnd, start: rowStart, definiteIfAuto: rowStart + 1)

                let area = GWGridArea(columnStart: colStart, columnEnd: colEnd, rowStart: rowStart, rowEnd: rowEnd)
                placements[i] = area

                for r in rowStart..<rowEnd {
                    for c in colStart..<colEnd {
                        occupied.insert(GWGridCell(row: r, column: c))
                    }
                }
            }
        }

        // Second pass: auto-place items (those without definite positions)
        var cursor = GWGridCursor()
        for i in 0..<children.count {
            let child = children[i]
            let hasDefiniteCol = child.style.gridColumnStart.type == .integer
            let hasDefiniteRow = child.style.gridRowStart.type == .integer

            if !hasDefiniteCol || !hasDefiniteRow {
                let colSpan: Int
                let rowSpan: Int
                if placements[i] == GWGridArea() {
                    // Compute span from end properties
                    let ce = child.style.gridColumnEnd
                    let re = child.style.gridRowEnd
                    colSpan = ce.type == .span ? max(1, Int(ce.value)) : 1
                    rowSpan = re.type == .span ? max(1, Int(re.value)) : 1
                } else {
                    colSpan = placements[i].columns
                    rowSpan = placements[i].rows
                }

                let (placedRow, placedCol) = findNextAvailableCell(
                    occupied: &occupied,
                    cursor: &cursor,
                    colSpan: colSpan,
                    rowSpan: rowSpan,
                    maxCols: maxCols
                )

                if !hasDefiniteCol {
                    placements[i].columnStart = placedCol
                    placements[i].columnEnd = placedCol + colSpan
                }
                if !hasDefiniteRow {
                    placements[i].rowStart = placedRow
                    placements[i].rowEnd = placedRow + rowSpan
                }
                // If both are auto, set both
                if !hasDefiniteCol && !hasDefiniteRow {
                    placements[i].columnStart = placedCol
                    placements[i].columnEnd = placedCol + colSpan
                    placements[i].rowStart = placedRow
                    placements[i].rowEnd = placedRow + rowSpan
                }

                for r in placements[i].rowStart..<placements[i].rowEnd {
                    for c in placements[i].columnStart..<placements[i].columnEnd {
                        occupied.insert(GWGridCell(row: r, column: c))
                    }
                }
            }
        }

        return placements
    }

    /// Resolve a grid line value (1-based).
    /// Returns the line number. For auto, returns the definite fallback.
    private static func resolveGridLine(_ line: GWGridLine, definiteIfAuto: Int) -> Int {
        switch line.type {
        case .integer:
            let val = Int(line.value)
            return val >= 0 ? val : val // allow negative later
        case .span:
            return definiteIfAuto // span doesn't define start
        case .auto:
            return definiteIfAuto
        }
    }

    /// Resolve grid line end value.
    /// For auto, returns start + 1 (span 1). For span N, returns start + N.
    private static func resolveGridLineEnd(_ line: GWGridLine, start: Int, definiteIfAuto: Int) -> Int {
        switch line.type {
        case .integer:
            let val = Int(line.value)
            if val > start { return val }
            return start + 1
        case .span:
            let span = max(1, Int(line.value))
            return start + span
        case .auto:
            return definiteIfAuto
        }
    }

    /// Find the next available cell in the grid for auto-placement.
    /// Row-major sparse scan from cursor position. Wraps at maxCols.
    private static func findNextAvailableCell(
        occupied: inout Set<GWGridCell>,
        cursor: inout GWGridCursor,
        colSpan: Int,
        rowSpan: Int,
        maxCols: Int
    ) -> (row: Int, column: Int) {
        var row = max(1, cursor.row)
        var col = max(1, cursor.column)

        // Safety bound: scan up to 1000 rows
        for _ in 0..<1000 {
            // Try each column in this row starting from `col`
            for c in col..<col + maxCols + 50 {
                // If we've gone past maxCols, wrap to next row
                if c > maxCols { break }

                var canPlace = true
                checkSpan: for dr in 0..<rowSpan {
                    for dc in 0..<colSpan {
                        if occupied.contains(GWGridCell(row: row + dr, column: c + dc)) {
                            canPlace = false
                            break checkSpan
                        }
                    }
                }
                if canPlace {
                    cursor.row = row
                    cursor.column = c + colSpan
                    return (row, c)
                }
            }
            // Move to next row, column 1
            row += 1
            col = 1
        }
        return (cursor.row, cursor.column)
    }

    // MARK: - Track Sizing: Initialization

    /// Phase 1: Initialize base sizes and growth limits for each track.
    private static func initializeTrackSizes(_ tracks: inout [GWGridTrackSize], referenceLength: Float) {
        for i in 0..<tracks.count {
            let track = tracks[i]

            // Base size comes from the min sizing function
            let minResolved = resolveTrackLength(track.minSizingFunction, referenceLength: referenceLength)
            if minResolved.isDefined {
                tracks[i].baseSize = max(0, minResolved.unwrap())
            } else {
                tracks[i].baseSize = 0
            }

            // Growth limit comes from the max sizing function
            if track.isMaxFlex {
                // fr tracks: growth limit is infinite initially (capped during fr distribution)
                tracks[i].growthLimit = .infinity
            } else {
                let maxResolved = resolveTrackLength(track.maxSizingFunction, referenceLength: referenceLength)
                if maxResolved.isDefined {
                    tracks[i].growthLimit = max(0, maxResolved.unwrap())
                } else {
                    tracks[i].growthLimit = .infinity
                }
            }

            // Growth limit must be >= base size
            if tracks[i].growthLimit < tracks[i].baseSize {
                tracks[i].growthLimit = tracks[i].baseSize
            }
        }
    }

    /// Resolve a sizing function to a definite length.
    private static func resolveTrackLength(_ length: GWStyleSizeLength, referenceLength: Float) -> GWFloatOptional {
        switch length.unit {
        case .point:
            return length.value
        case .percent:
            if length.value.isUndefined { return .undefined }
            return GWFloatOptional(value: length.value.unwrap() * referenceLength * 0.01)
        case .auto, .maxContent, .fitContent, .stretch:
            return .undefined
        default:
            return .undefined
        }
    }

    // MARK: - Track Sizing: Intrinsic Sizing

    /// Phase 2: Resolve intrinsic track sizing by measuring items.
    /// For the initial implementation, intrinsic tracks are sized based on
    /// item content contributions or simply remain at baseSize.
    private static func resolveIntrinsicTrackSizes(
        _ tracks: inout [GWGridTrackSize],
        axis: GWDimension,
        placements: [GWGridArea],
        children: [GWYogaNode],
        direction: GWDirection,
        availableInnerWidth: Float,
        availableInnerHeight: Float,
        node: GWYogaNode,
        gap: Float
    ) {
        // For non-intrinsic tracks (fixed, fr), skip phase 2 since sizes are already determined
        // For auto tracks, we estimate based on items spanning each track.
        // In a full implementation, this would measure item content contributions.

        // Simple approach: for each item spanning a single intrinsic track,
        // increase that track to accommodate the item.
        for (i, child) in children.enumerated() {
            let placement = placements[i]
            let span = axis == .width ? placement.columns : placement.rows
            let start = axis == .width ? placement.columnStart : placement.rowStart

            // If the child has an explicit size on this axis, use it
            let explicitSize: Float?
            if axis == .width && child.style.width.isDefined {
                explicitSize = resolveStyleSizeLength(child.style.width, availableInnerWidth).unwrap(orDefault: 0)
            } else if axis == .height && child.style.height.isDefined {
                explicitSize = resolveStyleSizeLength(child.style.height, availableInnerHeight).unwrap(orDefault: 0)
            } else {
                explicitSize = nil
            }

            if let size = explicitSize, span == 1 && start > 0 && start <= tracks.count {
                // Distribute to the single track
                let trackIndex = start - 1
                let itemSize = size / Float(span)
                if itemSize > tracks[trackIndex].baseSize {
                    tracks[trackIndex].baseSize = itemSize
                }
                if tracks[trackIndex].growthLimit < tracks[trackIndex].baseSize {
                    tracks[trackIndex].growthLimit = tracks[trackIndex].baseSize
                }
            }
        }

        // Ensure growth limit >= base size for all tracks
        for i in 0..<tracks.count {
            if tracks[i].growthLimit < tracks[i].baseSize {
                tracks[i].growthLimit = tracks[i].baseSize
            }
        }
    }

    // MARK: - Track Sizing: Fr Distribution

    /// Phase 3: Distribute remaining free space to fr tracks.
    private static func distributeFrSpace(_ tracks: inout [GWGridTrackSize], totalFr: Float, availableSpace: Float) {
        guard totalFr > 0, availableSpace > 0 else { return }
        let spacePerFr = availableSpace / totalFr

        for i in 0..<tracks.count {
            guard tracks[i].isMaxFlex else { continue }

            // Get the fr value from the stretch unit
            let frValue: Float
            if tracks[i].maxSizingFunction.isStretch {
                frValue = max(0, tracks[i].maxSizingFunction.value.unwrap(orDefault: 0))
            } else {
                frValue = 0
            }

            if frValue > 0 {
                let computedSize = spacePerFr * frValue
                var newSize: Float
                if tracks[i].growthLimit.isFinite {
                    newSize = min(tracks[i].baseSize + computedSize, tracks[i].growthLimit)
                } else {
                    newSize = tracks[i].baseSize + computedSize
                }
                tracks[i].baseSize = max(tracks[i].baseSize, newSize)
            }
        }
    }

    /// Sum of all fr (flex) values in the track list.
    private static func totalFr(_ tracks: [GWGridTrackSize]) -> Float {
        tracks.reduce(0) { sum, track in
            if track.isMaxFlex && track.maxSizingFunction.isStretch {
                return sum + max(0, track.maxSizingFunction.value.unwrap(orDefault: 0))
            }
            return sum
        }
    }

    /// Total used space from all non-fr tracks.
    private static func usedTrackSpace(_ tracks: [GWGridTrackSize]) -> Float {
        tracks.reduce(0) { $0 + $1.baseSize }
    }

    // MARK: - Track Stretching

    /// Phase 4: Distribute extra space evenly across tracks, respecting growth limits.
    private static func stretchTracks(_ tracks: inout [GWGridTrackSize], extraSpace: Float) {
        guard extraSpace > 0, !tracks.isEmpty else { return }
        var remaining = extraSpace
        var flexibleTracks = tracks.count

        while remaining > 0 && flexibleTracks > 0 {
            let perTrack = remaining / Float(flexibleTracks)
            var newlyCapped = 0

            for i in 0..<tracks.count {
                guard tracks[i].growthLimit.isFinite else { continue }
                let space = tracks[i].growthLimit - tracks[i].baseSize
                if space <= 0 { continue }
                let add = min(perTrack, space)
                tracks[i].baseSize += add
                remaining -= add
                if add >= space - 0.001 { newlyCapped += 1 }
            }

            // Redistribute to tracks without finite growth limits
            if newlyCapped == 0 { break }
            flexibleTracks -= newlyCapped
        }

        // Give remaining to tracks with infinite growth limits
        if remaining > 0 {
            let infTracks = tracks.filter { !$0.growthLimit.isFinite }.count
            if infTracks > 0 {
                let perTrack = remaining / Float(infTracks)
                for i in 0..<tracks.count {
                    if !tracks[i].growthLimit.isFinite {
                        tracks[i].baseSize += perTrack
                    }
                }
            }
        }
    }

    // MARK: - Track Positions

    /// Compute the line positions of the grid (positions between tracks, without gaps).
    /// Returns an array of line positions: linePositions[0] = start, linePositions[N] = end of last track.
    /// Line i is the boundary before track i (0-indexed).
    private static func computeTrackPositions(_ tracks: [GWGridTrackSize], gap: Float, start: Float) -> [Float] {
        var positions = [start]
        var p = start
        for t in tracks {
            p += t.baseSize
            positions.append(p)
        }
        return positions
    }

    // MARK: - Alignment Helpers

    /// Resolve justify-self from child style, falling back to parent justify-items.
    private static func resolveJustifySelf(_ childStyle: GWStyle, parentStyle: GWStyle) -> GWJustify {
        if childStyle.justifySelf != .auto {
            return childStyle.justifySelf
        }
        let parentItems = parentStyle.justifyItems
        return parentItems == .auto ? .stretch : parentItems
    }

    /// Map GWJustify to GWAlign for alignment calculations in an axis.
    private static func alignmentToFallback(_ align: GWAlign) -> GWJustify {
        switch align {
        case .stretch: return .stretch
        case .flexStart, .start: return .start
        case .flexEnd, .end: return .end
        case .center: return .center
        case .baseline: return .start
        default: return .start
        }
    }

    /// Compute the offset for aligning a child within its available space.
    private static func alignInAxis(availableSize: Float, childSize: Float, align: GWJustify) -> Float {
        let extra = availableSize - childSize
        if extra <= 0 { return 0 }
        switch align {
        case .start, .flexStart, .auto:
            return 0
        case .end, .flexEnd:
            return extra
        case .center:
            return extra / 2
        case .stretch:
            return 0 // already stretched
        case .spaceBetween, .spaceAround, .spaceEvenly:
            return 0
        }
    }

    // MARK: - Empty Grid Container

    /// Measure an empty grid container.
    private static func measureEmptyGrid(
        _ node: GWYogaNode,
        widthSizingMode: GWSizingMode,
        heightSizingMode: GWSizingMode,
        availableInnerWidth: Float,
        availableInnerHeight: Float,
        paddingAndBorderMain: Float,
        paddingAndBorderCross: Float,
        direction: GWDirection,
        ownerWidth: Float
    ) {
        let width: Float
        let height: Float

        if widthSizingMode == .stretchFit {
            width = availableInnerWidth
        } else {
            width = 0
        }

        if heightSizingMode == .stretchFit {
            height = availableInnerHeight
        } else {
            height = 0
        }

        node.layout.setDimension(.width, width)
        node.layout.setDimension(.height, height)
        node.layout.setMeasuredDimension(.width, width)
        node.layout.setMeasuredDimension(.height, height)
    }
}

// MARK: - Grid Cell Hash

/// A single cell in the grid (row, column pair). Used for occupancy tracking.
internal struct GWGridCell: Hashable {
    var row: Int
    var column: Int
}
