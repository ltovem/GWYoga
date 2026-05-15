import XCTest
@testable import GWYoga
@testable import GWYogaKit
@testable import GWYogaKitAnimation

final class GWYogaKitAnimationTests: XCTestCase {

    // MARK: - YogaTimingFunction

    func testTimingFunctionLinear() {
        let tf = YogaTimingFunction.linear
        if case .linear = tf { } else { XCTFail("expected linear") }
    }

    func testTimingFunctionEaseInOut() {
        let tf = YogaTimingFunction.easeInOut
        if case .easeInOut = tf { } else { XCTFail("expected easeInOut") }
    }

    func testTimingFunctionCubicBezier() {
        let tf = YogaTimingFunction.cubicBezier(0.25, 0.1, 0.25, 1.0)
        if case .cubicBezier(let x1, let y1, let x2, let y2) = tf {
            XCTAssertEqual(x1, 0.25)
            XCTAssertEqual(y1, 0.1)
            XCTAssertEqual(x2, 0.25)
            XCTAssertEqual(y2, 1.0)
        } else {
            XCTFail("expected cubicBezier")
        }
    }

    func testTimingFunctionSteps() {
        let tf = YogaTimingFunction.steps(4, stepPosition: .end)
        if case .steps(let count, let position) = tf {
            XCTAssertEqual(count, 4)
            XCTAssertEqual(position, .end)
        } else {
            XCTFail("expected steps")
        }
    }

    // MARK: - YogaAnimation

    func testAnimationConfig() {
        let anim = YogaAnimation(
            name: "test",
            duration: 0.3,
            timingFunction: .easeInOut,
            delay: 0.1,
            direction: .normal,
            fillMode: .forwards
        )
        XCTAssertEqual(anim.duration, 0.3)
        XCTAssertEqual(anim.delay, 0.1)
        XCTAssertEqual(anim.name, "test")
    }

    func testAnimationDefaultInit() {
        let anim = YogaAnimation(name: "quick", duration: 0.5)
        XCTAssertEqual(anim.duration, 0.5)
        XCTAssertEqual(anim.delay, 0)
        if case .ease = anim.timingFunction { } else { XCTFail("expected ease") }
    }

    // MARK: - YogaTransition

    func testTransitionConfig() {
        let trans = YogaTransition(
            duration: 0.3,
            timingFunction: .ease,
            delay: 0,
            propertyFilter: .layout
        )
        XCTAssertEqual(trans.duration, 0.3)
        if case .layout = trans.propertyFilter { } else { XCTFail("expected layout") }
    }

    func testTransitionDefaultInit() {
        let trans = YogaTransition(duration: 0.25)
        XCTAssertEqual(trans.duration, 0.25)
        if case .ease = trans.timingFunction { } else { XCTFail("expected ease") }
        XCTAssertEqual(trans.delay, 0)
        if case .all = trans.propertyFilter { } else { XCTFail("expected all") }
    }
}
