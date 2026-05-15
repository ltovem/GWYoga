import XCTest
@testable import GWYoga
@testable import GWYogaKit
@testable import GWYogaKitObjCCore
@testable import GWYogaKitDSLObjCCore
@testable import GWYogaKitLayoutCacheObjCCore
@testable import GWYogaKitHTMLObjCCore

/// Tests for the ObjC-compatible @objc bridge API.
/// These tests validate that all YGK* classes and enums work correctly,
/// simulating what an Objective-C consumer would use.
final class GWYogaKitObjCTests: XCTestCase {

    // MARK: - Core YGKLayoutView & Properties

    func testYGKLayoutViewDefault() {
        let view = YGKLayoutView(frame: .init(x: 0, y: 0, width: 300, height: 200))
        view.yogaProperties.flexDirection = .row
        view.yogaProperties.justifyContent = .center
        view.yogaProperties.alignItems = .center

        XCTAssertEqual(view.yogaProperties.flexDirection, .row)
        XCTAssertEqual(view.yogaProperties.justifyContent, .center)
        XCTAssertEqual(view.yogaProperties.alignItems, .center)
    }

    func testYGKLayoutPropertiesSize() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.width = 200
        view.yogaProperties.height = 100
        XCTAssertEqual(view.yogaProperties.width, 200)
        XCTAssertEqual(view.yogaProperties.height, 100)
    }

    func testYGKLayoutPropertiesPercent() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.setWidthPercent(50)
        view.yogaProperties.setHeightPercent(75)
        XCTAssertGreaterThan(view.yogaProperties.width, 0)
    }

    func testYGKLayoutPropertiesMargin() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.setMargin(.all, 10)
        view.yogaProperties.setMargin(.top, 5)
        view.yogaProperties.setMarginAuto(.left)
        XCTAssertTrue(view.yogaProperties.isDirty)
    }

    func testYGKLayoutPropertiesPadding() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.setPadding(.all, 12)
        view.yogaProperties.setPadding(.left, 8)
        let padding = view.yogaProperties.padding(forEdge: .left)
        XCTAssertEqual(padding, 8)
    }

    func testYGKLayoutPropertiesBorder() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.setBorder(.all, 2)
        view.yogaProperties.setBorder(.top, 1)
        let border = view.yogaProperties.border(forEdge: .top)
        XCTAssertEqual(border, 1)
    }

    func testYGKLayoutPropertiesPosition() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.positionType = .absolute
        view.yogaProperties.setPosition(.top, 20)
        view.yogaProperties.setPosition(.left, 15)
        XCTAssertEqual(view.yogaProperties.positionType, .absolute)
    }

    func testYGKLayoutPropertiesGap() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.columnGap = 10
        view.yogaProperties.rowGap = 15
        XCTAssertEqual(view.yogaProperties.columnGap, 10)
        XCTAssertEqual(view.yogaProperties.rowGap, 15)
    }

    func testYGKLayoutPropertiesFlex() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.flexGrow = 1
        view.yogaProperties.flexShrink = 0
        view.yogaProperties.flexBasis = 50
        XCTAssertEqual(view.yogaProperties.flexGrow, 1)
        XCTAssertEqual(view.yogaProperties.flexShrink, 0)
        XCTAssertEqual(view.yogaProperties.flexBasis, 50)
    }

    func testYGKLayoutPropertiesIsIntrinsic() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.isIntrinsic = true
        XCTAssertTrue(view.yogaProperties.isIntrinsic)
    }

    func testYGKLayoutPropertiesGrid() {
        let view = YGKLayoutView(frame: .zero)
        view.yogaProperties.display = .grid
        view.yogaProperties.setGridTemplateColumns([.points(100), .fr(1)])
        view.yogaProperties.gridColumnStart = .line(2)
        view.yogaProperties.gridColumnEnd = .line(4)
        XCTAssertEqual(view.yogaProperties.display, .grid)
    }

    func testYGKLayoutViewLayout() {
        let container = YGKLayoutView(frame: .init(x: 0, y: 0, width: 300, height: 100))
        container.yogaProperties.flexDirection = .row
        container.yogaProperties.justifyContent = .spaceBetween

        let child1 = YGKLayoutView(frame: .zero)
        child1.yogaProperties.width = 80
        child1.yogaProperties.height = 40
        container.addSubview(child1)

        let child2 = YGKLayoutView(frame: .zero)
        child2.yogaProperties.width = 80
        child2.yogaProperties.height = 40
        container.addSubview(child2)

        container.performYogaLayout()
        XCTAssertGreaterThan(container.yogaProperties.layoutWidth, 0)
    }

    func testYGKLayoutViewLayoutMode() {
        let view = YGKLayoutView(frame: .zero)
        view.layoutMode = .forced
        XCTAssertEqual(view.layoutMode, .forced)

        view.layoutMode = .manual
        XCTAssertEqual(view.layoutMode, .manual)

        view.layoutMode = .auto
        XCTAssertEqual(view.layoutMode, .auto)
    }

    // MARK: - YGK Enums

    func testYGKFlexDirectionValues() {
        XCTAssertEqual(YGKFlexDirection.column.rawValue, 0)
        XCTAssertEqual(YGKFlexDirection.row.rawValue, 2)
    }

    func testYGKAlignValues() {
        XCTAssertEqual(YGKAlign.flexStart.rawValue, 1)
        XCTAssertEqual(YGKAlign.center.rawValue, 2)
        XCTAssertEqual(YGKAlign.stretch.rawValue, 4)
    }

    func testYGKEdgeValues() {
        XCTAssertEqual(YGKEdge.all.rawValue, 8)
        XCTAssertEqual(YGKEdge.top.rawValue, 1)
    }

    // MARK: - DSL ObjC Bridge

    #if os(iOS)

    func testYGKVStack() {
        let stack = YGKVStack(spacing: 8, alignment: .center)
        XCTAssertNotNil(stack)
    }

    func testYGKHStack() {
        let stack = YGKHStack(spacing: 12, alignment: .center)
        XCTAssertNotNil(stack)
    }

    func testYGKZStack() {
        let stack = YGKZStack(frame: .zero)
        let child1 = YGKLayoutView(frame: .zero)
        let child2 = YGKLayoutView(frame: .zero)
        stack.addChild(child1, alignment: .center)
        stack.addChild(child2, alignment: .center)
        XCTAssertEqual(stack.subviews.count, 2)
    }

    func testYGKScrollView() {
        let scroll = YGKScrollView(frame: .zero)
        let content = YGKLayoutView(frame: .zero)
        scroll.addSubview(content)
        XCTAssertNotNil(scroll)
    }

    func testYGKControls() {
        let spacer = YGKSpacer(minLength: 10)
        XCTAssertEqual(spacer.yogaProperties.flexGrow, 1)

        let divider = YGKDivider(color: .lightGray, thickness: 1)
        XCTAssertNotNil(divider)
    }

    // MARK: - HTML ObjC Bridge

    func testYGKHTMLFactory() {
        let div = YGKHTMLFactory.makeDiv()
        XCTAssertNotNil(div)

        let section = YGKHTMLFactory.makeSection()
        XCTAssertNotNil(section)

        let row = YGKHTMLFactory.makeRow()
        XCTAssertNotNil(row)
    }

    // MARK: - LayoutCache ObjC Bridge

    func testYGKPreLayout() {
        let label = YGKText(text: "Hello")
        let pre = label.yogaProperties.preLayout
        let size = pre.measure(width: 200)
        XCTAssertGreaterThan(size.width, 0)
    }

    func testYGKPreLayoutInvalidate() {
        let label = YGKText(text: "Cached")
        let pre = label.yogaProperties.preLayout
        let size1 = pre.measure(width: 200)
        pre.invalidateCache()
        let size2 = pre.measure(width: 200)
        XCTAssertEqual(size1.width, size2.width)
    }

    #endif
}
