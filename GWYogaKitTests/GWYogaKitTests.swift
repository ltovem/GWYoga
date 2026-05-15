import XCTest
@testable import GWYoga
@testable import GWYogaKit

final class GWYogaKitTests: XCTestCase {

    // MARK: - YogaLayoutView

    func testYogaLayoutViewAutoLayout() {
        #if os(iOS)
        let view = YogaLayoutView(frame: .zero)
        view.yoga.flexDirection = .row
        view.yoga.width = .points(300)
        view.yoga.height = .points(100)

        let child = YogaLayoutView(frame: .zero)
        child.yoga.width = .points(100)
        child.yoga.height = .points(50)
        view.addSubview(child)

        view.performYogaLayout()
        XCTAssertGreaterThan(view.bounds.width, 0)
        #endif
    }

    func testYogaLayoutViewForcedLayout() {
        #if os(iOS)
        let view = YogaLayoutView(frame: .init(x: 0, y: 0, width: 200, height: 100))
        view.yogaLayoutMode = .forced
        let child = YogaLayoutView(frame: .zero)
        child.yoga.width = .points(80)
        child.yoga.height = .points(40)
        view.addSubview(child)
        view.performYogaLayout()
        XCTAssertEqual(view.bounds.width, 200)
        #endif
    }

    func testYogaLayoutViewManualLayout() {
        #if os(iOS)
        let view = YogaLayoutView(frame: .zero)
        view.yogaLayoutMode = .manual
        view.yoga.width = .points(300)
        view.yoga.height = .points(150)
        view.performYogaLayout()
        XCTAssertGreaterThan(view.bounds.width, 0)
        #endif
    }

    // MARK: - YogaProperties

    func testYogaPropertiesSetGet() {
        let view = YogaLayoutView(frame: .zero)
        let p = view.yoga
        p.width = .points(200)
        p.height = .points(100)
        p.flexDirection = .row
        p.justifyContent = .center
        p.alignItems = .flexEnd
        p.alignSelf = .stretch
        p.flexGrow = 1
        p.flexShrink = 0
        p.flexBasis = .points(50)
        p.flexWrap = .wrap
        p.aspectRatio = 1.5
        p.overflow = .hidden

        XCTAssertEqual(p.width, .points(200))
        XCTAssertEqual(p.height, .points(100))
        XCTAssertEqual(p.flexDirection, .row)
        XCTAssertEqual(p.justifyContent, .center)
        XCTAssertEqual(p.alignItems, .flexEnd)
        XCTAssertEqual(p.flexGrow, 1)
        XCTAssertEqual(p.flexShrink, 0)
        XCTAssertEqual(p.aspectRatio, 1.5, accuracy: 0.001)
        XCTAssertEqual(p.flexWrap, .wrap)
        XCTAssertEqual(p.overflow, .hidden)
    }

    func testYogaPropertiesPercent() {
        let view = YogaLayoutView(frame: .zero)
        let p = view.yoga
        p.width = .percent(50)
        p.height = .percent(75)

        XCTAssertEqual(p.width.unit, .percent)
        XCTAssertEqual(p.width.value, 50)
        XCTAssertEqual(p.height.unit, .percent)
        XCTAssertEqual(p.height.value, 75)
    }

    func testYogaPropertiesMargin() {
        let view = YogaLayoutView(frame: .zero)
        let p = view.yoga
        p.setMargin(.all, .points(10))
        p.setMargin(.top, .points(5))
        p.setMargin(.left, .auto)
        XCTAssertTrue(p.isDirty)
    }

    func testYogaPropertiesPadding() {
        let view = YogaLayoutView(frame: .zero)
        let p = view.yoga
        p.setPadding(.all, .points(12))
        p.setPadding(.left, .points(8))
        XCTAssertTrue(p.isDirty)
    }

    func testYogaPropertiesBorder() {
        let view = YogaLayoutView(frame: .zero)
        let p = view.yoga
        p.setBorder(.all, 2)
        p.setBorder(.top, 1)
        XCTAssertTrue(p.isDirty)
    }

    func testYogaPropertiesPosition() {
        let view = YogaLayoutView(frame: .zero)
        let p = view.yoga
        p.positionType = .absolute
        p.setPosition(.top, .points(20))
        p.setPosition(.left, .points(15))
        XCTAssertEqual(p.positionType, .absolute)
    }

    func testYogaPropertiesGap() {
        let view = YogaLayoutView(frame: .zero)
        let p = view.yoga
        p.columnGap = .points(10)
        p.rowGap = .points(15)
        XCTAssertEqual(p.columnGap, .points(10))
        XCTAssertEqual(p.rowGap, .points(15))
    }

    func testYogaPropertiesGrid() {
        let view = YogaLayoutView(frame: .zero)
        let p = view.yoga
        p.display = .grid
        p.gridTemplateColumns = [.points(100), .fr(1)]
        p.gridTemplateRows = [.points(50)]
        p.gridColumnStart = GWGridLine(type: .integer, value: 2)
        p.gridColumnEnd = GWGridLine(type: .integer, value: 4)
        XCTAssertEqual(p.display, .grid)
    }

    // MARK: - UIView Yoga Extension

    func testUIViewYogaExtension() {
        #if os(iOS)
        let view = UIView()
        let p = view.yoga
        p.width = .points(100)
        p.height = .points(80)
        XCTAssertEqual(p.width, .points(100))
        XCTAssertEqual(p.height, .points(80))
        #endif
    }

    func testUILabelYogaIntrinsic() {
        #if os(iOS)
        let label = UILabel()
        label.text = "Hello Yoga"
        label.yoga.isIntrinsic = true
        XCTAssertTrue(label.yoga.isIntrinsic)
        #endif
    }

    // MARK: - YogaLayoutView Layout Result

    func testYogaLayoutViewLayoutResult() {
        #if os(iOS)
        let view = YogaLayoutView(frame: .zero)
        view.yoga.width = .points(200)
        view.yoga.height = .points(100)
        view.performYogaLayout()
        XCTAssertGreaterThan(view.yoga.node.layoutResult.width, 0)
        #endif
    }
}
