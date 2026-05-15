import XCTest
@testable import GWYoga

final class GWYogaDebugTests: XCTestCase {

    func testSimpleChildGetsCorrectWidth() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))

        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(100))
        root.insertChild(child, at: 0)

        // Check state before layout
        print("BEFORE LAYOUT:")
        print("  root style width: \(root.style.width.value)")
        print("  child style width: \(child.style.width.value)")
        print("  child isDirty: \(child.isDirty)")

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        print("AFTER LAYOUT:")
        print("  root layout: \(root.layoutResult)")
        print("  child layout: \(child.layoutResult)")
        print("  child internal: dim=\(child.layout.dimensions) measured=\(child.layout.measuredDimensions)")

        XCTAssertEqual(child.layout.dimension(.width), 100, "Child width should be 100")
        XCTAssertEqual(child.layout.dimension(.height), 100, "Child height should be 100")
    }

    func testRootSize() {
        let root = GWYogaNode()
        root.style.setWidth(.points(400))
        root.style.setHeight(.points(300))

        root.calculateLayout(width: 400, height: 300, direction: .ltr)

        print("Root layout: \(root.layoutResult)")
        print("Root internal dim: \(root.layout.dimensions)")

        XCTAssertEqual(root.layoutResult.width, 400)
        XCTAssertEqual(root.layoutResult.height, 300)
    }

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

        print("MinWidth test - child layout: \(child.layoutResult)")
        print("  child style: w=\(child.style.width) minW=\(child.style.minWidth)")

        XCTAssertEqual(child.layoutResult.width, 150)
    }

    func testPercentSize() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))

        let child = GWYogaNode()
        child.style.setWidth(.percent(50))
        child.style.setHeight(.percent(50))
        root.insertChild(child, at: 0)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        let w = child.layoutResult.width
        let h = child.layoutResult.height
        print("Percent test - child layout: (\(w), \(h))")
        XCTAssertTrue(abs(w - 250) < 0.1, "Expected width ~250, got \(w)")
        XCTAssertTrue(abs(h - 250) < 0.1, "Expected height ~250, got \(h)")
    }
}
