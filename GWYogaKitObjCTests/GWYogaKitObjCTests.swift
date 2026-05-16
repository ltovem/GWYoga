import XCTest
@testable import GWYoga
@testable import GWYogaKit
@testable import GWYogaKitObjCCore
@testable import GWYogaKitDSLObjCCore
@testable import GWYogaKitLayoutCacheObjCCore
@testable import GWYogaKitHTMLObjCCore

/// Tests for the ObjC-compatible @objc bridge API.
final class GWYogaKitObjCTests: XCTestCase {

    // MARK: - Core YGKLayoutView & Properties (iOS/tvOS only)

    #if os(iOS) || os(tvOS)

    func testYGKLayoutViewDefault() {
        let view = YGKLayoutView(frame: .init(x: 0, y: 0, width: 300, height: 200))
        view.gwstyle.flexDirection = .row
        view.gwstyle.justifyContent = .center
        view.gwstyle.alignItems = .center

        XCTAssertEqual(view.gwstyle.flexDirection, .row)
        XCTAssertEqual(view.gwstyle.justifyContent, .center)
        XCTAssertEqual(view.gwstyle.alignItems, .center)
    }

    func testYGKLayoutPropertiesSize() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.width = 200
        view.gwstyle.height = 100
        XCTAssertEqual(view.gwstyle.width, 200)
        XCTAssertEqual(view.gwstyle.height, 100)
    }

    func testYGKLayoutPropertiesPercent() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.setWidthPercent(50)
        view.gwstyle.setHeightPercent(75)
        XCTAssertGreaterThan(view.gwstyle.width, 0)
    }

    func testYGKLayoutPropertiesMargin() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.setMargin(.all, 10)
        view.gwstyle.setMargin(.top, 5)
        view.gwstyle.setMarginAuto(.left)
        XCTAssertTrue(view.gwstyle.isDirty)
    }

    func testYGKLayoutPropertiesPadding() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.setPadding(.all, 12)
        view.gwstyle.setPadding(.left, 8)
        let padding = view.gwstyle.padding(forEdge: .left)
        XCTAssertEqual(padding, 8)
    }

    func testYGKLayoutPropertiesBorder() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.setBorder(.all, 2)
        view.gwstyle.setBorder(.top, 1)
        let border = view.gwstyle.border(forEdge: .top)
        XCTAssertEqual(border, 1)
    }

    func testYGKLayoutPropertiesPosition() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.positionType = .absolute
        view.gwstyle.setPosition(.top, 20)
        view.gwstyle.setPosition(.left, 15)
        XCTAssertEqual(view.gwstyle.positionType, .absolute)
    }

    func testYGKLayoutPropertiesGap() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.columnGap = 10
        view.gwstyle.rowGap = 15
        XCTAssertEqual(view.gwstyle.columnGap, 10)
        XCTAssertEqual(view.gwstyle.rowGap, 15)
    }

    func testYGKLayoutPropertiesFlex() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.flexGrow = 1
        view.gwstyle.flexShrink = 0
        view.gwstyle.flexBasis = 50
        XCTAssertEqual(view.gwstyle.flexGrow, 1)
        XCTAssertEqual(view.gwstyle.flexShrink, 0)
        XCTAssertEqual(view.gwstyle.flexBasis, 50)
    }

    func testYGKLayoutPropertiesIsIntrinsic() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.isIntrinsic = true
        XCTAssertTrue(view.gwstyle.isIntrinsic)
    }

    func testYGKLayoutPropertiesGrid() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.display = .grid
        view.gwstyle.setGridTemplateColumns([.points(100), .fr(1)])
        view.gwstyle.gridColumnStart = .line(2)
        view.gwstyle.gridColumnEnd = .line(4)
        XCTAssertEqual(view.gwstyle.display, .grid)
    }

    func testYGKLayoutViewLayout() {
        let container = YGKLayoutView(frame: .init(x: 0, y: 0, width: 300, height: 100))
        container.gwstyle.flexDirection = .row
        container.gwstyle.justifyContent = .spaceBetween

        let child1 = YGKLayoutView(frame: .zero)
        child1.gwstyle.width = 80
        child1.gwstyle.height = 40
        container.addSubview(child1)

        let child2 = YGKLayoutView(frame: .zero)
        child2.gwstyle.width = 80
        child2.gwstyle.height = 40
        container.addSubview(child2)

        container.performYogaLayout()
        XCTAssertGreaterThan(container.gwstyle.layoutWidth, 0)
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

    func testYGKLayoutPropertiesBackgroundColor() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.backgroundColor = .blue
        XCTAssertEqual(view.backgroundColor, .blue)
    }

    func testYGKLayoutPropertiesCornerRadius() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.cornerRadius = 12
        XCTAssertEqual(view.layer.cornerRadius, 12)
    }

    func testYGKLayoutPropertiesShadow() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.shadowColor = .black
        view.gwstyle.shadowOpacity = 0.5
        view.gwstyle.shadowRadius = 8
        view.gwstyle.shadowOffset = CGSize(width: 2, height: 4)
        XCTAssertEqual(view.gwstyle.shadowOpacity, 0.5)
        XCTAssertEqual(view.gwstyle.shadowRadius, 8)
    }

    func testYGKLayoutPropertiesBorder() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.borderWidth = 2
        view.gwstyle.borderUIColor = .red
        XCTAssertEqual(view.gwstyle.borderWidth, 2)
    }

    func testYGKLayoutPropertiesOpacity() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.alpha = 0.5
        XCTAssertEqual(view.gwstyle.alpha, 0.5, accuracy: 0.001)
    }

    func testYGKLayoutPropertiesClipsToBounds() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.clipsToBounds = true
        XCTAssertTrue(view.gwstyle.clipsToBounds)
    }

    func testYGKLayoutValueIntegration() {
        let view = YGKLayoutView(frame: .zero)
        view.gwstyle.setWidth(YGKLayoutValue.points(100))
        view.gwstyle.setHeight(YGKLayoutValue.percent(50))
        XCTAssertEqual(view.gwstyle.width, 100)
    }

    // MARK: - DSL ObjC Bridge

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
        XCTAssertEqual(spacer.gwstyle.flexGrow, 1)

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
        let pre = label.gwstyle.preLayout
        let size = pre.measure(width: 200)
        XCTAssertGreaterThan(size.width, 0)
    }

    func testYGKPreLayoutInvalidate() {
        let label = YGKText(text: "Cached")
        let pre = label.gwstyle.preLayout
        let size1 = pre.measure(width: 200)
        pre.invalidateCache()
        let size2 = pre.measure(width: 200)
        XCTAssertEqual(size1.width, size2.width)
    }

    #endif

    // MARK: - YGK Enums (cross-platform)

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

    // MARK: - YGKLayoutValue (cross-platform)

    func testYGKLayoutValuePoints() {
        let v = YGKLayoutValue.points(100)
        XCTAssertEqual(v.value, 100)
        XCTAssertEqual(v.unit, .point)
        let swift = v.swiftValue
        XCTAssertEqual(swift, .points(100))
    }

    func testYGKLayoutValuePercent() {
        let v = YGKLayoutValue.percent(50)
        XCTAssertEqual(v.value, 50)
        XCTAssertEqual(v.unit, .percent)
        let swift = v.swiftValue
        XCTAssertEqual(swift, .percent(50))
    }

    func testYGKLayoutValueAuto() {
        let v = YGKLayoutValue.autoValue
        XCTAssertEqual(v.unit, .auto)
        let swift = v.swiftValue
        XCTAssertEqual(swift, .auto)
    }

    func testYGKLayoutConvenience() {
        let pts = YGKLayout.pts(100)
        XCTAssertEqual(pts.value, 100)
        XCTAssertEqual(pts.unit, .point)

        let pct = YGKLayout.pct(50)
        XCTAssertEqual(pct.value, 50)
        XCTAssertEqual(pct.unit, .percent)

        let auto = YGKLayout.autoVal
        XCTAssertEqual(auto.unit, .auto)
    }
}
