import XCTest
@testable import GWYoga
@testable import GWYogaKit
@testable import GWYogaKitDSL

#if os(iOS)
import UIKit

final class GWYogaKitDSLTests: XCTestCase {

    func testYogaVStack() {
        let stack = YogaVStack(spacing: 8, alignment: .center) {
            YogaText("A")
            YogaText("B")
        }
        XCTAssertEqual(stack.yoga.flexDirection, .column)
        XCTAssertEqual(stack.yoga.alignItems, .center)
    }

    func testYogaHStack() {
        let stack = YogaHStack(spacing: 12, alignment: .center) {
            YogaText("A")
            YogaText("B")
        }
        XCTAssertEqual(stack.yoga.flexDirection, .row)
        XCTAssertEqual(stack.yoga.alignItems, .center)
    }

    func testYogaZStack() {
        let stack = YogaZStack(alignment: .center) {
            YogaText("Back")
            YogaText("Front")
        }
        // First child is relative, others are absolute
        XCTAssertEqual(stack.subviews.count, 2)
    }

    func testYogaScrollView() {
        let scroll = YogaScrollView(axis: .vertical) {
            YogaText("Content")
        }
        XCTAssertNotNil(scroll)
    }

    func testYogaSpacer() {
        let spacer = YogaSpacer(minLength: 10)
        XCTAssertEqual(spacer.yoga.flexGrow, 1)
    }

    func testYogaDivider() {
        let divider = YogaDivider()
        XCTAssertNotNil(divider)
    }

    func testYogaText() {
        let text = YogaText("Hello")
        XCTAssertEqual(text.text, "Hello")
        XCTAssertTrue(text.yoga.isIntrinsic)
    }

    func testYogaImage() {
        let image = YogaImage(nil)
        XCTAssertNotNil(image)
        XCTAssertTrue(image.yoga.isIntrinsic)
    }

    func testYogaButton() {
        let button = YogaButton("Tap Me") {}
        XCTAssertEqual(button.title(for: .normal), "Tap Me")
        XCTAssertTrue(button.yoga.isIntrinsic)
    }

    // MARK: - Modifiers

    func testPaddingModifier() {
        let text = YogaText("Hello")
        text.padding(.all, value: .points(16))
        let padding = text.yoga.node.style.padding[GWEdge.all.rawValue].value.value
        XCTAssertGreaterThan(padding, 0)
    }

    func testFrameModifier() {
        let text = YogaText("Hello")
        text.width(.points(100))
        text.height(.points(50))
        let style = text.yoga.node.style
        XCTAssertEqual(style.dimensions[GWDimension.width.rawValue].value.value, 100)
        XCTAssertEqual(style.dimensions[GWDimension.height.rawValue].value.value, 50)
    }

    func testFlexModifier() {
        let text = YogaText("Hello")
        text.flexGrow(1)
        text.flexShrink(0)
        XCTAssertEqual(text.yoga.flexGrow, 1)
        XCTAssertEqual(text.yoga.flexShrink, 0)
    }

    func testCombinedModifiers() {
        let text = YogaText("Hello")
            .padding(.all, value: .points(12))
            .flexGrow(1)
            .backgroundColor(.lightGray)
        let style = text.yoga.node.style
        XCTAssertEqual(text.yoga.flexGrow, 1)
        XCTAssertGreaterThan(style.padding[GWEdge.top.rawValue].value.value, 0)
    }
}
#endif
