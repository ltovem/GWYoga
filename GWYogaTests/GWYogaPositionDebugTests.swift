import XCTest
@testable import GWYoga

final class GWYogaPositionDebugTests: XCTestCase {

    func testColumnChildrenPositions() {
        let root = GWYogaNode()
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(500))

        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(50))
        root.insertChild(child1, at: 0)

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(50))
        root.insertChild(child2, at: 1)

        root.calculateLayout(width: 500, height: 500, direction: .ltr)

        print("child1: top=\(child1.layout.position(.top)) left=\(child1.layout.position(.left)) dim=[\(child1.layout.dimension(.width)), \(child1.layout.dimension(.height))]")
        print("child2: top=\(child2.layout.position(.top)) left=\(child2.layout.position(.left)) dim=[\(child2.layout.dimension(.width)), \(child2.layout.dimension(.height))]")

        XCTAssertEqual(child1.layout.position(.top), 0)
        XCTAssertEqual(child2.layout.position(.top), 50)
    }

    func testRowChildrenPositions() {
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

        print("row child1: left=\(child1.layout.position(.left)) top=\(child1.layout.position(.top)) dim=[\(child1.layout.dimension(.width)), \(child1.layout.dimension(.height))]")
        print("row child2: left=\(child2.layout.position(.left)) top=\(child2.layout.position(.top)) dim=[\(child2.layout.dimension(.width)), \(child2.layout.dimension(.height))]")

        XCTAssertEqual(child1.layout.position(.left), 0)
        XCTAssertEqual(child2.layout.position(.left), 100)
    }

    func testFlexGrowPositions() {
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

        print("grow child1: left=\(child1.layout.position(.left)) w=\(child1.layout.dimension(.width))")
        print("grow child2: left=\(child2.layout.position(.left)) w=\(child2.layout.dimension(.width))")

        XCTAssertEqual(child1.layout.position(.left), 0)
        XCTAssertEqual(child2.layout.position(.left), 250)
    }
}
