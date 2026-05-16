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

    // MARK: - YogaSpringConfig

    func testSpringConfigDefault() {
        let config = YogaSpringConfig.default
        XCTAssertEqual(config.dampingRatio, 0.5)
        XCTAssertEqual(config.initialVelocity, 0)
    }

    func testSpringConfigCustom() {
        let config = YogaSpringConfig(dampingRatio: 0.8, initialVelocity: 0.5)
        XCTAssertEqual(config.dampingRatio, 0.8)
        XCTAssertEqual(config.initialVelocity, 0.5)
    }

    // MARK: - YogaKeyframeStyle Snapshot

    func testKeyframeStyleSnapshot() {
        let view = YogaLayoutView()
        view.yoga.width = 100
        view.yoga.height = 200
        view.yoga.margin(.all, 10)
        view.yoga.padding(.horizontal, 5)
        view.yoga.flexDirection = .row
        view.yoga.justifyContent = .center
        view.yoga.alignItems = .center

        let snapshot = YogaKeyframeStyle(snapshot: view.yoga)
        XCTAssertEqual(snapshot.width, GWValue(value: 100, unit: .point))
        XCTAssertEqual(snapshot.height, GWValue(value: 200, unit: .point))
        XCTAssertEqual(snapshot.margin[.all], GWValue(value: 10, unit: .point))
        XCTAssertEqual(snapshot.padding[.horizontal], GWValue(value: 5, unit: .point))
        XCTAssertEqual(snapshot.flexDirection, .row)
        XCTAssertEqual(snapshot.justifyContent, .center)
        XCTAssertEqual(snapshot.alignItems, .center)
    }

    func testKeyframeStyleSnapshotUnsetProperties() {
        let view = YogaLayoutView()
        let snapshot = YogaKeyframeStyle(snapshot: view.yoga)
        // Width/height default to .auto; min/max default to .undefined
        XCTAssertEqual(snapshot.width, GWValue(value: 0, unit: .auto))
        XCTAssertEqual(snapshot.height, GWValue(value: 0, unit: .auto))
        XCTAssertTrue(snapshot.flexGrow.isNaN)
    }

    // MARK: - Animate Convenience

    func testAnimateBasic() {
        let view = YogaLayoutView()
        view.yoga.width = 100

        let name = view.yoga.animate(duration: 0.3) {
            $0.width = 200
        }

        XCTAssertFalse(name.isEmpty)
        XCTAssertEqual(view.yoga.width, GWValue(value: 200, unit: .point))
        // 动画目标值已应用，动画管理器会在 tick 中持续覆盖为插值

        // 等待动画开始
        let exp = expectation(description: "animation start")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        YogaKeyframes.unregister(name)
        YogaAnimationManager.shared.stopAnimation(on: view.yoga)
    }

    func testAnimateSpring() {
        let view = YogaLayoutView()
        view.yoga.width = 100

        let name = view.yoga.animate(duration: 0.5, dampingRatio: 0.6, changes: {
            $0.width = 300
        })

        XCTAssertFalse(name.isEmpty)
        XCTAssertEqual(view.yoga.width, GWValue(value: 300, unit: .point))

        let exp = expectation(description: "spring animation start")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        YogaKeyframes.unregister(name)
        YogaAnimationManager.shared.stopAnimation(on: view.yoga)
    }

    func testAnimateWithTimingFunction() {
        let view = YogaLayoutView()
        view.yoga.flexDirection = .column

        let name = view.yoga.animate(duration: 0.3, timingFunction: .easeInOut, changes: {
            $0.flexDirection = .row
        })

        XCTAssertFalse(name.isEmpty)

        let exp = expectation(description: "animation with timing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        YogaKeyframes.unregister(name)
        YogaAnimationManager.shared.stopAnimation(on: view.yoga)
    }

    func testAnimateWithDelay() {
        let view = YogaLayoutView()
        view.yoga.width = 50

        let name = view.yoga.animate(duration: 0.2, delay: 0.1, changes: {
            $0.width = 150
        })

        XCTAssertFalse(name.isEmpty)

        let exp = expectation(description: "animation with delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        YogaKeyframes.unregister(name)
        YogaAnimationManager.shared.stopAnimation(on: view.yoga)
    }

    func testAnimateMultipleProperties() {
        let view = YogaLayoutView()
        view.yoga.width = 100
        view.yoga.height = 100
        view.yoga.margin(.all, 0)

        let name = view.yoga.animate(duration: 0.3) {
            $0.width = 200
            $0.height = 300
            $0.margin(.all, 20)
        }

        XCTAssertEqual(view.yoga.width, GWValue(value: 200, unit: .point))
        XCTAssertEqual(view.yoga.height, GWValue(value: 300, unit: .point))

        let exp = expectation(description: "multi property animation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        YogaKeyframes.unregister(name)
        YogaAnimationManager.shared.stopAnimation(on: view.yoga)
    }
}
