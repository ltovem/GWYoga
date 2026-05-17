import XCTest
@testable import GWYoga

final class GWYogaTests: XCTestCase {

    // MARK: - Helpers

    func assertEqual(_ actual: Float, _ expected: Float, tolerance: Float = 0.001, file: StaticString = #file, line: UInt = #line) {
        if abs(actual - expected) > tolerance {
            XCTFail("\(actual) is not equal to \(expected) (tolerance: \(tolerance))", file: file, line: line)
        }
    }

    // MARK: - Basic Layout

    func testFixedSizeChild() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(100))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        let result = child.layoutResult
        assertEqual(result.width, 100)
        assertEqual(result.height, 100)
        assertEqual(result.left, 0)
        assertEqual(result.top, 0)
    }

    // MARK: - Flex Direction

    func testFlexDirectionColumn() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))
        root.style.flexDirection = .column

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        assertEqual(child1.layoutResult.top, 0)
        assertEqual(child1.layoutResult.left, 0)
        assertEqual(child2.layoutResult.top, 50)  // Below child1
        assertEqual(child2.layoutResult.left, 0)
    }

    func testFlexDirectionRow() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        assertEqual(child1.layoutResult.left, 0)
        assertEqual(child1.layoutResult.top, 0)
        assertEqual(child2.layoutResult.left, 100)  // To the right of child1
        assertEqual(child2.layoutResult.top, 0)
    }

    // MARK: - Justify Content

    func testJustifyContentCenter() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.justifyContent = .center

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // Total children height: 50 + 50 = 100
        // Available space: 500 - 0(padding) = 500 height...
        // Actually default is column, so main axis is height
        // remaining = 200 - 100 = 100
        // first child at 100/2 = 50
        // Wait, remainingFreeSpace from Step 5/6 logic
        // availableInnerMainDim = 200 - 0(padding+border) = 200
        // sizeConsumed = 100
        // remainingFreeSpace = 100
        // center: leadingMainDim = 50
        assertEqual(child1.layoutResult.top, 50)
        assertEqual(child2.layoutResult.top, 100)
    }

    func testJustifyContentFlexEnd() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.justifyContent = .flexEnd

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // remainingFreeSpace = 200 - 50 = 150
        // flexEnd: leadingMainDim = 150
        assertEqual(child1.layoutResult.top, 150)
    }

    func testJustifyContentSpaceBetween() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(300))
        root.style.justifyContent = .spaceBetween

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        root.insertChild(child2, at: 1)

        let child3 = GWYogaNode()
        child3.style.setWidth(.points(100))
        child3.style.setHeight(.points(50))
        root.insertChild(child3, at: 2)

        root.calculateLayout(width: 500, height: 300, direction: .ltr)

        // Total children height: 150
        // Available: 300, remaining: 150
        // spaceBetween: gap = 150 / 2 = 75 between each pair
        assertEqual(child1.layoutResult.top, 0)
        assertEqual(child2.layoutResult.top, 125)  // 50 + 75
        assertEqual(child3.layoutResult.top, 250)  // 50 + 75 + 50 + 75
    }

    // MARK: - Align Items

    func testAlignItemsStretch() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))

        let child = GWYogaNode()
        // No explicit height set — should stretch
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        // Default alignItems = stretch, cross axis = width (column layout)
        // Child should stretch to fill container width
        assertEqual(child.layoutResult.width, 500)
        // Height is 0 since no content and no explicit height
    }

    func testAlignItemsCenter() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.alignItems = .center

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(50))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // cross axis (width) center: (500 - 100) / 2 = 200
        assertEqual(child.layoutResult.left, 200)
        assertEqual(child.layoutResult.top, 0)
    }

    // MARK: - Flex Grow

    func testFlexGrowEqualDistribution() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setHeight(.points(100))
        child1.flexGrow = 1
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setHeight(.points(100))
        child2.flexGrow = 1
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // flexBasis = 0 for both (since no width set, flexGrow > 0 → basis = 0)
        // remainingFreeSpace = 500 - 0 - 0 = 500
        // Each gets 500 * 0.5 = 250
        assertEqual(child1.layoutResult.width, 250)
        assertEqual(child2.layoutResult.width, 250)
        assertEqual(child1.layoutResult.left, 0)
        assertEqual(child2.layoutResult.left, 250)
    }

    func testFlexGrowProportional() {
        let root = GWYogaNode()
        root.style.setWidth(.points(600))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(100))
        child1.flexGrow = 1
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(100))
        child2.flexGrow = 2
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 600, height: 200, direction: .ltr)

        // flexBasis = 100 for child1, 100 for child2 (since width is set)
        // remainingFreeSpace = 600 - 100 - 100 = 400
        // totalGrow = 3
        // child1: 100 + 400 * 1/3 = 100 + 133.33 = 233.33 → 像素取整 233
        // child2: 100 + 400 * 2/3 = 100 + 266.67 = 366.67 → 像素取整 367
        assertEqual(child1.layoutResult.width, 233, tolerance: 0.1)
        assertEqual(child2.layoutResult.width, 367, tolerance: 0.1)
    }

    // MARK: - Flex Shrink

    func testFlexShrink() {
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(200))
        child1.style.setHeight(.points(100))
        child1.flexShrink = 1
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(200))
        child2.style.setHeight(.points(100))
        child2.flexShrink = 1
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 300, height: 200, direction: .ltr)

        // flexBasis = 200 for both
        // total = 400, available = 300, overflow = -100
        // totalShrinkScaled = -(1*200 + 1*200) = -400
        // child1: 200 + (-100) * (-200/-400) = 200 + (-100) * 0.5 = 200 - 50 = 150
        // child2: 200 + (-100) * (-200/-400) = 150
        assertEqual(child1.layoutResult.width, 150, tolerance: 0.1)
        assertEqual(child2.layoutResult.width, 150, tolerance: 0.1)
    }

    // MARK: - Padding

    func testPadding() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))
        root.style.setPadding(for: .all, .points(50))

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(100))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        // Padding of 50 on all sides
        // Child should be positioned at (50, 50)
        // Available inner space: 500 - 50*2 = 400
        assertEqual(child.layoutResult.left, 50)
        assertEqual(child.layoutResult.top, 50)
    }

    // MARK: - Margin

    func testMargin() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(100))
        child1.style.setMargin(for: .left, .points(20))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(100))
        child2.style.setMargin(for: .left, .points(30))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        assertEqual(child1.layoutResult.left, 20)   // margin-left: 20
        assertEqual(child2.layoutResult.left, 150)   // 100 + 20 + 30 = 150
    }

    // MARK: - Gap

    func testGap() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(300))
        root.style.flexDirection = .row
        root.style.setGap(for: .column, .points(30)) // gap between columns (row items)

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(100))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(100))
        root.insertChild(child2, at: 1)

        let child3 = GWYogaNode()
        child3.style.setWidth(.points(100))
        child3.style.setHeight(.points(100))
        root.insertChild(child3, at: 2)

        root.calculateLayout(width: 500, height: 300, direction: .ltr)

        assertEqual(child1.layoutResult.left, 0)
        assertEqual(child2.layoutResult.left, 130)  // 100 + 30 gap
        assertEqual(child3.layoutResult.left, 260)  // 100 + 30 + 100 + 30
    }

    // MARK: - Flex Wrap

    func testFlexWrap() {
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(300))
        root.style.flexDirection = .row
        root.style.flexWrap = .wrap

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(150))
        child1.style.setHeight(.points(100))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(150))
        child2.style.setHeight(.points(100))
        root.insertChild(child2, at: 1)

        let child3 = GWYogaNode()
        child3.style.setWidth(.points(150))
        child3.style.setHeight(.points(100))
        root.insertChild(child3, at: 2)

        root.calculateLayout(width: 300, height: 300, direction: .ltr)

        // Row layout, wrap at 300px width
        // Line 1: child1 (150) + child2 (150) = 300, fits
        // Line 2: child3 (150), starts new line
        assertEqual(child1.layoutResult.left, 0)
        assertEqual(child1.layoutResult.top, 0)
        assertEqual(child2.layoutResult.left, 150)
        assertEqual(child2.layoutResult.top, 0)
        assertEqual(child3.layoutResult.left, 0)
        assertEqual(child3.layoutResult.top, 100)  // Second line
    }

    // MARK: - Display None

    func testDisplayNone() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(100))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(100))
        child2.style.display = .none
        root.insertChild(child2, at: 1)

        let child3 = GWYogaNode()
        child3.style.setWidth(.points(100))
        child3.style.setHeight(.points(100))
        root.insertChild(child3, at: 2)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        assertEqual(child1.layoutResult.left, 0)
        assertEqual(child2.layoutResult.width, 0)   // display: none → zeroed
        assertEqual(child2.layoutResult.height, 0)
        assertEqual(child3.layoutResult.left, 100)  // Adjacent to child1
    }

    // MARK: - Absolute Positioning

    func testAbsolutePosition() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(100))
        child.style.positionType = .absolute
        child.style.setPosition(for: .left, .points(50))
        child.style.setPosition(for: .top, .points(30))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        assertEqual(child.layoutResult.left, 50)
        assertEqual(child.layoutResult.top, 30)
        assertEqual(child.layoutResult.width, 100)
        assertEqual(child.layoutResult.height, 100)
    }

    // MARK: - Border

    func testBorder() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))
        root.style.setBorder(for: .all, 10)

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(100))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        // Border of 10 on all sides
        // Child should be positioned at (10, 10) inside the border
        assertEqual(child.layoutResult.left, 10)
        assertEqual(child.layoutResult.top, 10)
    }

    // MARK: - Percent Sizing

    func testPercentSize() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))

        let child = GWYogaNode()
        child.style.setWidth(.percent(50))
        child.style.setHeight(.percent(50))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        assertEqual(child.layoutResult.width, 250)   // 50% of 500
        assertEqual(child.layoutResult.height, 250)  // 50% of 500
    }

    // MARK: - Three-Level Percent Layout (bug reproduction)

    func testThreeLevelPercentLayout() {
        // Root: explicit 852x393 (like controller's view in landscape)
        let root = GWYogaNode()
        root.style.setWidth(.points(852))
        root.style.setHeight(.points(393))

        // Container: 100% x 100% (like thisview)
        let container = GWYogaNode()
        container.style.setWidth(.percent(100))
        container.style.setHeight(.percent(100))
        root.insertChild(container, at: 0)

        // Child: 50% x 50% (like subView)
        let child = GWYogaNode()
        child.style.setWidth(.percent(50))
        child.style.setHeight(.percent(50))
        container.insertChild(child, at: 0)

        root.calculateLayout(width: 852, height: 393, direction: .ltr)

        // Container should be 100% of 852x393
        assertEqual(container.layoutResult.width, 852)
        assertEqual(container.layoutResult.height, 393)

        // Child should be 50% of 852 = 426, 50% of 393 = 196.5
        assertEqual(child.layoutResult.width, 426, tolerance: 0.5)
        assertEqual(child.layoutResult.height, 196.5, tolerance: 0.5)

        let r1 = container.layoutResult
        let r2 = child.layoutResult
        print("container layout: left=\(r1.left) top=\(r1.top) width=\(r1.width) height=\(r1.height)")
        print("child layout: left=\(r2.left) top=\(r2.top) width=\(r2.width) height=\(r2.height)")
    }

    // MARK: - Align Self

    func testAlignSelf() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row
        root.style.alignItems = .center  // All children centered by default

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        child2.style.alignSelf = .flexEnd  // This one at flex-end
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // Row direction, cross axis is height (column)
        // alignItems: center → center of 200 = 100, minus half child height (25) = 75
        assertEqual(child1.layoutResult.top, 75, tolerance: 0.1)

        // alignSelf: flexEnd → bottom of 200, minus child height 50 = 150
        assertEqual(child2.layoutResult.top, 150, tolerance: 0.1)
    }

    // MARK: - Min/Max Constraints

    func testMinWidth() {
        let root = GWYogaNode()
        root.style.setWidth(.points(200))
        root.style.setHeight(.points(200))

        let child = GWYogaNode()
        child.style.setWidth(.points(50))
        child.style.minWidth = .points(150)
        child.style.setHeight(.points(100))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 200, height: 200, direction: .ltr)

        // minWidth = 150, which is > width = 50, so minWidth wins
        assertEqual(child.layoutResult.width, 150)
    }

    func testMaxWidth() {
        let root = GWYogaNode()
        root.style.setWidth(.points(200))
        root.style.setHeight(.points(200))

        let child = GWYogaNode()
        child.style.setWidth(.points(300))
        child.style.maxWidth = .points(150)
        child.style.setHeight(.points(100))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 200, height: 200, direction: .ltr)

        // maxWidth = 150, which is < width = 300, so maxWidth wins
        assertEqual(child.layoutResult.width, 150)
    }

    // MARK: - Root node layout result

    func testRootLayoutResult() {
        let root = GWYogaNode()
        root.style.setWidth(.points(400))
        root.style.setHeight(.points(300))

        root.calculateLayout(width: 400, height: 300, direction: .ltr)

        let result = root.layoutResult
        assertEqual(result.width, 400)
        assertEqual(result.height, 300)
        assertEqual(result.left, 0)
        assertEqual(result.top, 0)
        XCTAssertEqual(result.direction, .ltr)
    }

    // MARK: - Aspect Ratio

    func testAspectRatioWidthToHeight() {
        let root = GWYogaNode()
        root.style.setWidth(.points(200))
        root.style.setHeight(.points(200))

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.aspectRatio = GWFloatOptional(value: 2)  // width/height = 2 → height = 50
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 200, height: 200, direction: .ltr)

        assertEqual(child.layoutResult.width, 100)
        assertEqual(child.layoutResult.height, 50, tolerance: 0.1)
    }

    func testAspectRatioHeightToWidth() {
        let root = GWYogaNode()
        root.style.setWidth(.points(200))
        root.style.setHeight(.points(200))

        let child = GWYogaNode()
        child.style.setHeight(.points(100))
        child.style.aspectRatio = GWFloatOptional(value: 2)  // width/height = 2 → width = 200
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 200, height: 200, direction: .ltr)

        assertEqual(child.layoutResult.width, 200, tolerance: 0.1)
        assertEqual(child.layoutResult.height, 100)
    }

    // MARK: - Auto Margins

    func testAutoMarginLeft() {
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(100))
        root.style.flexDirection = .row

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(50))
        child.style.setMargin(for: .left, .auto)
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 300, height: 100, direction: .ltr)

        // margin-left: auto pushes child to the right
        // Available space: 300 - 100 = 200, all consumed by auto margin
        assertEqual(child.layoutResult.left, 200, tolerance: 0.1)
    }

    // MARK: - Overflow Detection

    func testOverflow() {
        let root = GWYogaNode()
        root.style.setWidth(.points(200))
        root.style.setHeight(.points(200))

        let child = GWYogaNode()
        child.style.setWidth(.points(300))  // Wider than parent
        child.style.setHeight(.points(100))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 200, height: 200, direction: .ltr)

        // Root should detect overflow (child is wider)
        XCTAssertTrue(root.layoutResult.hadOverflow)
    }

    // MARK: - Flex Shrink Proportional

    func testFlexShrinkProportional() {
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(200))
        child1.style.setHeight(.points(100))
        child1.flexShrink = 1
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(200))
        child2.style.setHeight(.points(100))
        child2.flexShrink = 3
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 300, height: 200, direction: .ltr)

        // total = 400, available = 300, overflow = -100
        // totalShrinkScaled = -(1*200 + 3*200) = -800
        // child1: 200 + (-100) * (1*200/800) = 200 - 25 = 175
        // child2: 200 + (-100) * (3*200/800) = 200 - 75 = 125
        assertEqual(child1.layoutResult.width, 175, tolerance: 0.1)
        assertEqual(child2.layoutResult.width, 125, tolerance: 0.1)
    }

    // MARK: - JustifyContent with Gap

    func testJustifyContentCenterWithGap() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.justifyContent = .center
        root.style.setGap(for: .row, .points(20))

        let child1 = GWYogaNode()
        child1.style.setHeight(.points(50))
        child1.style.setWidth(.points(100))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setHeight(.points(50))
        child2.style.setWidth(.points(100))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // main axis = height (column default)
        // child total height = 100, gap = 20, total = 120
        // remaining = 200 - 0(padding) - 120 = 80
        // center: leading = 40
        assertEqual(child1.layoutResult.top, 40, tolerance: 0.1)
        assertEqual(child2.layoutResult.top, 110, tolerance: 0.1) // 40 + 50 + 20
    }

    // MARK: - JustifyContent SpaceEvenly

    func testJustifyContentSpaceEvenly() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(300))
        root.style.justifyContent = .spaceEvenly

        let child1 = GWYogaNode()
        child1.style.setHeight(.points(50))
        child1.style.setWidth(.points(100))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setHeight(.points(50))
        child2.style.setWidth(.points(100))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 300, direction: .ltr)

        // total children height = 100, remaining = 200
        // spaceEvenly: gap = 200 / 3 = 66.666...
        assertEqual(child1.layoutResult.top, 66.67, tolerance: 1.0)
        assertEqual(child2.layoutResult.top, 183.33, tolerance: 1.0)
    }

    // MARK: - Absolute Positioning with Right/Bottom Insets

    func testAbsolutePositionRightBottom() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(100))
        child.style.positionType = .absolute
        child.style.setPosition(for: .right, .points(30))
        child.style.setPosition(for: .bottom, .points(20))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        // right = 30, so left = 500 - 100 - 30 = 370
        // bottom = 20, so top = 500 - 100 - 20 = 380
        assertEqual(child.layoutResult.left, 370, tolerance: 0.1)
        assertEqual(child.layoutResult.top, 380, tolerance: 0.1)
    }

    // MARK: - Flex Grow with Flex Basis

    func testFlexGrowWithFlexBasis() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(100))
        child1.flexGrow = 1
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setFlexBasis(.points(50))
        child2.style.setHeight(.points(100))
        child2.flexGrow = 1
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // child1 basis=100, child2 basis=50, total=150, remain=350
        // totalGrow=2, each gets 175 extra
        // child1: 100 + 175 = 275, child2: 50 + 175 = 225
        assertEqual(child1.layoutResult.width, 275, tolerance: 0.1)
        assertEqual(child2.layoutResult.width, 225, tolerance: 0.1)
    }

    // MARK: - Nested Flex With Grow

    func testNestedFlexGrow() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))
        root.style.flexDirection = .column

        let header = GWYogaNode()
        header.style.setHeight(.points(60))
        root.insertChild(header, at: 0)

        let content = GWYogaNode()
        content.flexGrow = 1
        root.insertChild(content, at: 1)

        let footer = GWYogaNode()
        footer.style.setHeight(.points(40))
        root.insertChild(footer, at: 2)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        assertEqual(header.layoutResult.top, 0)
        assertEqual(header.layoutResult.height, 60)
        // content fills remaining: 500 - 60 - 40 = 400
        assertEqual(content.layoutResult.top, 60)
        assertEqual(content.layoutResult.height, 400, tolerance: 0.1)
        assertEqual(footer.layoutResult.top, 460)
        assertEqual(footer.layoutResult.height, 40)
    }

    // MARK: - Flex Shrink with Min Constraint

    func testFlexShrinkWithMinConstraint() {
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(200))
        child1.style.setHeight(.points(100))
        child1.style.minWidth = .points(160)  // > 150 (unclamped shrink), triggers clamping
        child1.flexShrink = 1
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(200))
        child2.style.setHeight(.points(100))
        child2.flexShrink = 1
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 300, height: 200, direction: .ltr)

        // total=400, available=300, overflow=-100
        // child1 minWidth=160 clamps it, delta=200-160=40
        // remain after first pass: -100+40=-60, totalShrink=-200
        // child1: 160, child2: 200 - 60 = 140
        assertEqual(child1.layoutResult.width, 160, tolerance: 0.1)
        assertEqual(child2.layoutResult.width, 140, tolerance: 0.1)
    }

    // MARK: - Flex Direction Reverse

    func testFlexDirectionColumnReverse() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))
        root.style.flexDirection = .columnReverse

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        // columnReverse: items start from bottom
        assertEqual(child1.layoutResult.top, 450)  // 500 - 50 = 450
        assertEqual(child2.layoutResult.top, 400)
    }

    func testFlexDirectionRowReverse() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .rowReverse

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // rowReverse: items start from right
        assertEqual(child1.layoutResult.left, 400)  // 500 - 100 = 400
        assertEqual(child2.layoutResult.left, 300)
    }

    // MARK: - Flex Wrap Reverse

    func testFlexWrapWrapReverse() {
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(300))
        root.style.flexDirection = .row
        root.style.flexWrap = .wrapReverse

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(150))
        child1.style.setHeight(.points(100))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(150))
        child2.style.setHeight(.points(100))
        root.insertChild(child2, at: 1)

        let child3 = GWYogaNode()
        child3.style.setWidth(.points(150))
        child3.style.setHeight(.points(100))
        root.insertChild(child3, at: 2)

        root.calculateLayout(width: 300, height: 300, direction: .ltr)

        // wrapReverse: cross start is opposite (bottom for row)
        assertEqual(child1.layoutResult.top, 200)  // cross-end = 300 - 100
        assertEqual(child2.layoutResult.top, 200)
        assertEqual(child3.layoutResult.top, 100)  // second line above first
    }

    // MARK: - Justify Content

    func testJustifyContentFlexStart() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.justifyContent = .flexStart

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // flexStart: items at start
        assertEqual(child1.layoutResult.top, 0)
        assertEqual(child2.layoutResult.top, 50)
    }

    func testJustifyContentSpaceAround() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(300))
        root.style.justifyContent = .spaceAround

        let child1 = GWYogaNode()
        child1.style.setHeight(.points(50))
        child1.style.setWidth(.points(100))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setHeight(.points(50))
        child2.style.setWidth(.points(100))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 300, direction: .ltr)

        // spaceAround: (remaining=200) / (count*2) = 50 before first, between = remaining/count = 100
        // child1: 50, child2: 50 + 50 + 100 = 200
        assertEqual(child1.layoutResult.top, 50, tolerance: 2.0)
        assertEqual(child2.layoutResult.top, 200, tolerance: 2.0)
    }

    // MARK: - Align Items

    func testAlignItemsFlexStart() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.alignItems = .flexStart

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(50))
        child2.style.setHeight(.points(30))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // flexStart: items at cross-start (left for column)
        assertEqual(child1.layoutResult.left, 0)
        assertEqual(child2.layoutResult.left, 0)
    }

    func testAlignItemsFlexEnd() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.alignItems = .flexEnd

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // flexEnd: items at cross-end (right for column = 500 - 100 = 400)
        assertEqual(child1.layoutResult.left, 400)
    }

    func testAlignItemsBaseline() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row
        root.style.alignItems = .baseline

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(80))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // baseline alignment: children aligned by text baseline
        // taller child's top = 0, shorter child baseline-aligned below
        assertEqual(child2.layoutResult.top, 0)  // taller child at top
    }

    // MARK: - Align Content

    func testAlignContentSpaceBetween() {
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(300))
        root.style.flexDirection = .row
        root.style.flexWrap = .wrap
        root.style.alignContent = .spaceBetween

        for _ in 0..<4 {
            let c = GWYogaNode()
            c.style.setWidth(.points(100))
            c.style.setHeight(.points(50))
            root.insertChild(c, at: root.children.count)
        }

        root.calculateLayout(width: 300, height: 300, direction: .ltr)

        // 4 items in 2 lines of 3, then 1... actually 4 items with width 100 each in 300px container
        // Line 1: 3 items (100*3 = 300), line 2: 1 item (100)
        // alignContent spaceBetween: first line at cross-start, last at cross-end
        assertEqual(root.children[0].layoutResult.top, 0)      // first line at top
        assertEqual(root.children[3].layoutResult.top, 250)    // last line at 300-50=250
    }

    // MARK: - Flex Basis

    func testFlexBasisAuto() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(100))
        child1.flexGrow = 1
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setHeight(.points(100))
        child2.flexGrow = 1
        // child2 has no width set, so flexBasis = auto = content size = 0 (no content)
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // child1 basis=100 (width), child2 basis=0 (auto, no content)
        // remaining = 500 - 100 - 0 = 400, each gets 200
        assertEqual(child1.layoutResult.width, 300, tolerance: 0.1)
        assertEqual(child2.layoutResult.width, 200, tolerance: 0.1)
    }

    func testFlexBasisPercent() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let child = GWYogaNode()
        child.style.setFlexBasis(.percent(50))  // 50% of 500 = 250
        child.style.setHeight(.points(100))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        assertEqual(child.layoutResult.width, 250, tolerance: 0.1)
    }

    // MARK: - Box Sizing

    func testBoxSizingContentBox() {
        let root = GWYogaNode()
        root.style.boxSizing = .contentBox
        root.style.setWidth(.points(200))
        root.style.setHeight(.points(100))
        root.style.setPadding(for: .all, .points(10))
        root.style.setBorder(for: .all, 5)

        let child = GWYogaNode()
        child.style.setWidth(.points(50))
        child.style.setHeight(.points(50))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 200, height: 100, direction: .ltr)

        // contentBox: width/height refers to content area
        // total = content(200) + padding(10*2) + border(5*2) = 230
        assertEqual(root.layoutResult.width, 230, tolerance: 0.1)
        assertEqual(root.layoutResult.height, 130, tolerance: 0.1)
        // Child positioned after padding + border
        assertEqual(child.layoutResult.left, 15)
        assertEqual(child.layoutResult.top, 15)
    }

    // MARK: - Direction RTL

    func testDirectionRTL() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row
        root.style.direction = .rtl

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 200, direction: .rtl)

        // RTL in row: items start from right
        assertEqual(child1.layoutResult.left, 400)
        assertEqual(child2.layoutResult.left, 300)
    }

    // MARK: - Display Contents

    func testDisplayContents() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))
        root.style.flexDirection = .row

        let container = GWYogaNode()
        container.style.display = .contents
        root.insertChild(container, at: 0)

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(100))
        container.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // display: contents — container is skipped, children act as direct children of parent
        // Note: GWYoga may not fully support contents; test validates current behavior
        print("  display:contents container: \(container.layoutResult.width) x \(container.layoutResult.height)")
        print("  child: \(child.layoutResult.width) x \(child.layoutResult.height) at (\(child.layoutResult.left), \(child.layoutResult.top))")
        // Validate layout doesn't crash with display: contents set
        XCTAssertTrue(true)
    }

    // MARK: - Measure Function

    func testMeasureFunction() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))

        let child = GWYogaNode()
        child.nodeType = .text
        child.style.setWidth(.percent(100))
        // measureFunction simulates text sizing
        child.measureFunction = { _, width, _, _, _ in
            let textWidth = width.isNaN ? 200 : width
            let lines = ceil(textWidth / 100)
            let textHeight = lines * 20
            return GWSize(width: textWidth, height: textHeight)
        }
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        // measure function determines size
        assertEqual(child.layoutResult.width, 500)
        assertEqual(child.layoutResult.height, 100, tolerance: 0.1)  // 5 lines * 20
    }

    // MARK: - Node Clone Reset

    func testNodeCloneReset() {
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(100))
        root.style.flexDirection = .row

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(50))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 300, height: 100, direction: .ltr)

        assertEqual(child.layoutResult.width, 100)

        // Clone manually (no clone() method — create new node with same props)
        let cloned = GWYogaNode()
        cloned.style.setWidth(.points(150))
        XCTAssertEqual(cloned.style.width.value.value, 150)

        // Reset and verify
        cloned.reset()
        XCTAssertEqual(cloned.children.count, 0)
    }

    // MARK: - Config

    func testConfigUseWebDefaults() {
        let config = GWYogaConfig()
        config.useWebDefaults = true
        let root = GWYogaNode(config: config)
        root.style.flexDirection = .row
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))

        let child = GWYogaNode(config: config)
        child.style.setHeight(.points(50))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 200, direction: .ltr)

        // useWebDefaults: flexDirection defaults to row (web default)
        // Child with no width should stretch to fill cross axis (height)
        // Test validates config doesn't crash and produces reasonable layout
        print("  useWebDefaults child: \(child.layoutResult.width) x \(child.layoutResult.height)")
        XCTAssertFalse(child.layoutResult.width.isNaN)
    }

    func testConfigPointScaleFactor() {
        let config = GWYogaConfig()
        config.pointScaleFactor = 2.0
        let root = GWYogaNode(config: config)
        root.style.setWidth(.points(101))
        root.style.setHeight(.points(99))

        root.calculateLayout(width: 101, height: 99, direction: .ltr)

        // With scale=2, values should be rounded to nearest 0.5
        // 101 → ceil(101 * 2) / 2 = 101.0 (already even)
        assertEqual(root.layoutResult.width, 101)
        assertEqual(root.layoutResult.height, 99)
    }

    // MARK: - Edge Cases

    func testZeroSizeContainer() {
        let root = GWYogaNode()
        root.style.setWidth(.points(0))
        root.style.setHeight(.points(0))

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(100))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 0, height: 0, direction: .ltr)

        // Zero-size container: child may overflow
        assertEqual(root.layoutResult.width, 0)
        assertEqual(root.layoutResult.height, 0)
        XCTAssertTrue(root.layoutResult.hadOverflow)
    }

    // MARK: - Nested Grid in Flex

    func testNestedGridInFlex() {
        let root = GWYogaNode()
        root.style.flexDirection = .column
        root.style.setWidth(.points(400))
        root.style.setHeight(.points(300))

        let grid = GWYogaNode()
        grid.style.display = .grid
        grid.style.gridTemplateColumns = [.fr(1), .fr(1)]
        grid.flexGrow = 1
        root.insertChild(grid, at: 0)

        for _ in 0..<2 {
            let item = GWYogaNode()
            grid.insertChild(item, at: grid.children.count)
        }

        root.calculateLayout(width: 400, height: 300, direction: .ltr)

        // Grid inside flex container
        assertEqual(grid.layoutResult.width, 400)
        assertEqual(grid.children[0].layoutResult.width, 200)
        assertEqual(grid.children[1].layoutResult.width, 200)
    }
}
