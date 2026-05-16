import XCTest
@testable import GWYoga
@testable import GWYogaKit
@testable import GWYogaKitLayoutCache

#if os(iOS)
import UIKit

final class GWYogaKitLayoutCacheTests: XCTestCase {

    func testPreLayoutMeasureWidth() {
        let label = UILabel()
        label.text = "Hello Layout Cache"
        label.font = .systemFont(ofSize: 16)
        let pre = label.yoga.measurement
        let size = pre.measure(width: 200)
        XCTAssertGreaterThan(size.width, 0)
        XCTAssertGreaterThan(size.height, 0)
    }

    func testPreLayoutMeasureSize() {
        let label = UILabel()
        label.text = "Hello"
        label.font = .systemFont(ofSize: 16)
        let pre = label.yoga.measurement
        let size = pre.measure(width: 100, height: 50)
        XCTAssertGreaterThan(size.width, 0)
    }

    func testPreLayoutCacheInvalidation() {
        let label = UILabel()
        label.text = "Cached Text"
        let pre = label.yoga.measurement
        let size1 = pre.measure(width: 200)
        pre.invalidateCache()
        let size2 = pre.measure(width: 200)
        XCTAssertEqual(size1.width, size2.width)
    }

    func testPreLayoutMeasureAll() {
        let label1 = UILabel()
        label1.text = "Hello"
        let label2 = UILabel()
        label2.text = "World"
        let sizes = YogaPreLayout.measureAll([label1, label2], width: 200)
        XCTAssertEqual(sizes.count, 2)
        XCTAssertGreaterThan(sizes[0].width, 0)
        XCTAssertGreaterThan(sizes[1].width, 0)
    }

    func testPreLayoutMeasurementAccessor() {
        let label = UILabel()
        label.text = "Test"
        let pre = label.yoga.measurement
        XCTAssertNotNil(pre)
    }
}
#endif
