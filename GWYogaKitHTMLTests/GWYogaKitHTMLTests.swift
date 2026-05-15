import XCTest
@testable import GWYoga
@testable import GWYogaKit
@testable import GWYogaKitDSL
@testable import GWYogaKitHTML

#if os(iOS)
import UIKit

final class GWYogaKitHTMLTests: XCTestCase {

    func testDivTag() {
        let view = div {
            YogaText("content")
        }
        XCTAssertEqual(view.yoga.flexDirection, .column)
    }

    func testSectionTag() {
        let view = section {
            YogaText("section")
        }
        XCTAssertEqual(view.yoga.flexDirection, .column)
    }

    func testHeaderTag() {
        let view = header {
            YogaText("header")
        }
        XCTAssertEqual(view.yoga.flexDirection, .column)
    }

    func testHeadingTags() {
        let h1View = h1("Big Title")
        XCTAssertEqual(h1View.text, "Big Title")

        let h6View = h6("Small Title")
        XCTAssertEqual(h6View.text, "Small Title")
    }

    func testParagraphTag() {
        let pView = p("Hello world")
        XCTAssertEqual(pView.text, "Hello world")
        XCTAssertTrue(pView.yoga.isIntrinsic)
    }

    func testRowTag() {
        let view = row {
            YogaText("A")
            YogaText("B")
        }
        XCTAssertEqual(view.yoga.flexDirection, .row)
        XCTAssertEqual(view.yoga.alignItems, .center)
    }

    func testHTMLModifiers() {
        let view = div {
            h1("Title")
                .padding(.all, value: .points(8))
        }
        let subview = view.subviews.first
        XCTAssertNotNil(subview)
        let padding = subview!.yoga.node.style.padding[GWEdge.all.rawValue].value.value
        XCTAssertGreaterThan(padding, 0)
    }

    func testNestedHTMLTags() {
        let view = div {
            h1("Site Title")
            section {
                p("Content here")
            }
            row {
                YogaText("Footer")
            }
        }
        XCTAssertEqual(view.subviews.count, 3)
    }
}
#endif
