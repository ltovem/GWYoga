import XCTest
@testable import GWYoga

final class GWYogaGridTests: XCTestCase {

    // MARK: - Helpers

    func assertEqual(_ actual: Float, _ expected: Float, tolerance: Float = 0.001, file: StaticString = #file, line: UInt = #line) {
        if abs(actual - expected) > tolerance {
            XCTFail("\(actual) is not equal to \(expected) (tolerance: \(tolerance))", file: file, line: line)
        }
    }

    // MARK: - Basic Fixed Grid

    func testGridFixedTracks2x2() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(100), .points(200)]
        root.style.gridTemplateRows = [.points(50), .points(150)]

        for _ in 0..<4 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        // Container content-sized
        assertEqual(root.layoutResult.width, 300)
        assertEqual(root.layoutResult.height, 200)

        let c = root.children
        // Row 0: col 0, col 1
        assertEqual(c[0].layoutResult.left, 0)
        assertEqual(c[0].layoutResult.top, 0)
        assertEqual(c[0].layoutResult.width, 100)
        assertEqual(c[0].layoutResult.height, 50)

        assertEqual(c[1].layoutResult.left, 100)
        assertEqual(c[1].layoutResult.top, 0)
        assertEqual(c[1].layoutResult.width, 200)
        assertEqual(c[1].layoutResult.height, 50)

        // Row 1: col 0, col 1
        assertEqual(c[2].layoutResult.left, 0)
        assertEqual(c[2].layoutResult.top, 50)
        assertEqual(c[2].layoutResult.width, 100)
        assertEqual(c[2].layoutResult.height, 150)

        assertEqual(c[3].layoutResult.left, 100)
        assertEqual(c[3].layoutResult.top, 50)
        assertEqual(c[3].layoutResult.width, 200)
        assertEqual(c[3].layoutResult.height, 150)
    }

    // MARK: - Fr Units

    func testGridFrEqual() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(300))
        root.style.gridTemplateColumns = [.fr(1), .fr(1)]

        for _ in 0..<2 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: 300, height: .nan, direction: .ltr)

        assertEqual(root.children[0].layoutResult.width, 150)
        assertEqual(root.children[1].layoutResult.width, 150)
        assertEqual(root.children[0].layoutResult.left, 0)
        assertEqual(root.children[1].layoutResult.left, 150)
    }

    func testGridFrUnequal() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(300))
        root.style.gridTemplateColumns = [.fr(1), .fr(2)]

        for _ in 0..<2 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: 300, height: .nan, direction: .ltr)

        assertEqual(root.children[0].layoutResult.width, 100)
        assertEqual(root.children[1].layoutResult.width, 200)
        assertEqual(root.children[0].layoutResult.left, 0)
        assertEqual(root.children[1].layoutResult.left, 100)
    }

    func testGridFrWithFixed() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(400))
        root.style.gridTemplateColumns = [.points(100), .fr(1), .fr(1)]

        for _ in 0..<3 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: 400, height: .nan, direction: .ltr)

        // Fixed 100 + fr(1)=150 + fr(1)=150 = 400
        assertEqual(root.children[0].layoutResult.width, 100)
        assertEqual(root.children[1].layoutResult.width, 150)
        assertEqual(root.children[2].layoutResult.width, 150)
        assertEqual(root.children[0].layoutResult.left, 0)
        assertEqual(root.children[1].layoutResult.left, 100)
        assertEqual(root.children[2].layoutResult.left, 250)
    }

    // MARK: - Gaps

    func testGridColumnGap() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(100), .points(100)]
        root.style.gridTemplateRows = [.points(50)]
        root.style.setGap(for: .column, .points(10))

        for _ in 0..<2 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        assertEqual(root.layoutResult.width, 210) // 100 + 10 + 100

        let c = root.children
        assertEqual(c[0].layoutResult.left, 0)
        assertEqual(c[0].layoutResult.width, 100)
        assertEqual(c[1].layoutResult.left, 110)
        assertEqual(c[1].layoutResult.width, 100)
    }

    func testGridRowGap() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(100)]
        root.style.gridTemplateRows = [.points(50), .points(50)]
        root.style.setGap(for: .row, .points(20))

        for _ in 0..<2 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        assertEqual(root.layoutResult.height, 120) // 50 + 20 + 50

        let c = root.children
        assertEqual(c[0].layoutResult.top, 0)
        assertEqual(c[0].layoutResult.height, 50)
        assertEqual(c[1].layoutResult.top, 70)
        assertEqual(c[1].layoutResult.height, 50)
    }

    func testGridBothGaps() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(100), .points(100)]
        root.style.gridTemplateRows = [.points(50), .points(50)]
        root.style.setGap(for: .column, .points(10))
        root.style.setGap(for: .row, .points(20))

        for _ in 0..<4 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        assertEqual(root.layoutResult.width, 210)
        assertEqual(root.layoutResult.height, 120)

        let c = root.children
        // (0,0)
        assertEqual(c[0].layoutResult.left, 0)
        assertEqual(c[0].layoutResult.top, 0)
        assertEqual(c[0].layoutResult.width, 100)
        assertEqual(c[0].layoutResult.height, 50)

        // (1,0)
        assertEqual(c[1].layoutResult.left, 110)
        assertEqual(c[1].layoutResult.top, 0)
        assertEqual(c[1].layoutResult.width, 100)
        assertEqual(c[1].layoutResult.height, 50)

        // (0,1)
        assertEqual(c[2].layoutResult.left, 0)
        assertEqual(c[2].layoutResult.top, 70)
        assertEqual(c[2].layoutResult.width, 100)
        assertEqual(c[2].layoutResult.height, 50)

        // (1,1)
        assertEqual(c[3].layoutResult.left, 110)
        assertEqual(c[3].layoutResult.top, 70)
        assertEqual(c[3].layoutResult.width, 100)
        assertEqual(c[3].layoutResult.height, 50)
    }

    // MARK: - Explicit Placement

    func testGridExplicitColumnPlacement() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(100), .points(200), .points(50)]

        let child = GWYogaNode()
        child.style.gridColumnStart = GWGridLine(type: .integer, value: 3)
        child.style.gridColumnEnd = GWGridLine(type: .integer, value: 4)
        root.insertChild(child, at: 0)

        // An auto-placed item
        let child2 = GWYogaNode()
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        // child placed at column 3 (1-indexed), which is the 3rd track (2nd index)
        assertEqual(child.layoutResult.left, 300) // 100 + 200
        assertEqual(child.layoutResult.width, 50)

        // child2 auto-placed: cursor starts at (1,1) but child at col 3
        // doesn't occupy column 1, so cursor advances and child2 gets column 2
        assertEqual(child2.layoutResult.left, 100)
        assertEqual(child2.layoutResult.width, 200)
    }

    func testGridExplicitRowPlacement() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(100)]
        root.style.gridTemplateRows = [.points(50), .points(80), .points(60)]

        let child = GWYogaNode()
        child.style.gridRowStart = GWGridLine(type: .integer, value: 2)
        child.style.gridRowEnd = GWGridLine(type: .integer, value: 4)
        root.insertChild(child, at: 0)

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        // child spans rows 2-3 (1-indexed): track index 1 to 3 (0-indexed, exclusive)
        // row 1 (index 0) = 50, row 2 (index 1) = 80, row 3 (index 2) = 60
        // child starts at row 2: top = 50, height = 80 + 60 = 140
        assertEqual(child.layoutResult.top, 50)
        assertEqual(child.layoutResult.height, 140)
    }

    // MARK: - Span

    func testGridItemSpanColumns() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(100), .points(100), .points(100)]
        root.style.gridTemplateRows = [.points(50)]

        let child = GWYogaNode()
        child.style.gridColumnEnd = GWGridLine(type: .span, value: 2)
        root.insertChild(child, at: 0)

        let child2 = GWYogaNode()
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        // child spans 2 columns: width = 100 + 0(gap) + 100 = 200
        assertEqual(child.layoutResult.width, 200)
        assertEqual(child.layoutResult.left, 0)

        // child2 auto-placed after child: starts at column 3
        assertEqual(child2.layoutResult.left, 200)
        assertEqual(child2.layoutResult.width, 100)
    }

    // MARK: - Auto-Placement

    func testGridAutoPlacementWrapsToNextRow() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(100), .points(100)]

        for _ in 0..<5 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        let c = root.children
        // Row 0: 2 items
        assertEqual(c[0].layoutResult.left, 0)
        assertEqual(c[1].layoutResult.left, 100)

        // Row 1: 2 items
        assertEqual(c[2].layoutResult.left, 0)
        assertEqual(c[2].layoutResult.top, 0) // Note: row height is auto, will be 0 for intrinsic sizing since children have no content

        assertEqual(c[3].layoutResult.left, 100)
        assertEqual(c[3].layoutResult.top, 0)

        // Row 2: 1 item
        assertEqual(c[4].layoutResult.left, 0)
        assertEqual(c[4].layoutResult.top, 0)
    }

    // MARK: - Mixed Track Types

    func testGridAutoTrackWithStretch() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(300))
        root.style.gridTemplateColumns = [.auto()]
        root.style.justifyContent = .stretch

        root.insertChild(GWYogaNode(), at: 0)

        root.calculateLayout(width: 300, height: .nan, direction: .ltr)

        // auto track stretched to fill container
        assertEqual(root.children[0].layoutResult.width, 300)
    }

    func testGridFixedAndFr() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(400))
        root.style.gridTemplateColumns = [.points(100), .fr(1)]

        for _ in 0..<2 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: 400, height: .nan, direction: .ltr)

        // 100 fixed + 300 fr = 400
        assertEqual(root.children[0].layoutResult.width, 100)
        assertEqual(root.children[1].layoutResult.width, 300)
    }

    // MARK: - Container with Stretch

    func testGridContainerStretchesToAvailableSize() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(300))
        root.style.gridTemplateColumns = [.points(100), .points(100)]
        root.style.gridTemplateRows = [.points(50)]

        for _ in 0..<2 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: 500, height: 300, direction: .ltr)

        // Container fills available space
        assertEqual(root.layoutResult.width, 500)
        assertEqual(root.layoutResult.height, 300)

        // Items still positioned at grid positions
        assertEqual(root.children[0].layoutResult.left, 0)
        assertEqual(root.children[0].layoutResult.width, 100)
        assertEqual(root.children[1].layoutResult.left, 100)
        assertEqual(root.children[1].layoutResult.width, 100)
    }

    // MARK: - MinMax

    func testGridMinmaxTracks() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(300))
        root.style.gridTemplateColumns = [
            .minmax(min: .points(50), max: .points(100)),
            .minmax(min: .points(80), max: .points(200))
        ]

        for _ in 0..<2 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: 300, height: .nan, direction: .ltr)

        // Without stretch, minmax resolves to the min sizing function
        assertEqual(root.children[0].layoutResult.width, 50)
        assertEqual(root.children[1].layoutResult.width, 80)
    }

    func testGridMinmaxWithStretch() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(300))
        root.style.gridTemplateColumns = [
            .minmax(min: .points(50), max: .points(100)),
            .minmax(min: .points(80), max: .points(200))
        ]
        root.style.justifyContent = .stretch

        for _ in 0..<2 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: 300, height: .nan, direction: .ltr)

        // Stretch distributes extra (300 - 50 - 80 = 170) evenly.
        // Track 0: 50 + 85 = 135, capped at growthLimit 100 → overflow 35 redistributed
        // Track 1: 80 + 85 = 165 + 35 = 200, capped at growthLimit 200
        assertEqual(root.children[0].layoutResult.width, 100)
        assertEqual(root.children[1].layoutResult.width, 200)
    }

    // MARK: - Empty Grid

    func testGridEmptyContainer() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(200))
        root.style.setHeight(.points(100))

        root.calculateLayout(width: 200, height: 100, direction: .ltr)

        assertEqual(root.layoutResult.width, 200)
        assertEqual(root.layoutResult.height, 100)
    }

    // MARK: - Grid with Padding

    func testGridWithPadding() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(100), .points(100)]
        root.style.gridTemplateRows = [.points(50)]
        root.style.setPadding(for: .all, .points(10))

        for _ in 0..<2 {
            root.insertChild(GWYogaNode(), at: root.children.count)
        }

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        // Container: 10 + 100 + 0(gap) + 100 + 10 = 220
        assertEqual(root.layoutResult.width, 220)
        assertEqual(root.layoutResult.height, 70) // 10 + 50 + 10

        // Items positioned from padding start
        assertEqual(root.children[0].layoutResult.left, 10)
        assertEqual(root.children[0].layoutResult.top, 10)
        assertEqual(root.children[1].layoutResult.left, 110)
        assertEqual(root.children[1].layoutResult.top, 10)
    }

    // MARK: - Grid with Aspect Ratio Children

    func testGridChildWithExplicitSize() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.gridTemplateColumns = [.points(200)]
        root.style.gridTemplateRows = [.points(100)]

        let child = GWYogaNode()
        child.style.setWidth(.points(80))
        child.style.setHeight(.points(60))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: .nan, height: .nan, direction: .ltr)

        // Child has explicit size, so it retains it (not stretched)
        // Justify-self defaults to stretch, but child's explicit size
        // should be respected
        assertEqual(child.layoutResult.width, 80)
        assertEqual(child.layoutResult.height, 60)
    }
}
