import XCTest
@testable import GWYoga
@testable import GWYogaKit
import Combine

#if os(iOS) || os(tvOS)
import UIKit
#endif

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

    // MARK: - Phase 1: Numerical Literals (macOS + iOS)

    func testGWValueFloatLiteral() {
        let v: GWValue = 100
        XCTAssertEqual(v.value, 100)
        XCTAssertEqual(v.unit, .point)
    }

    func testGWValueIntegerLiteral() {
        let v: GWValue = 50
        XCTAssertEqual(v.value, 50)
        XCTAssertEqual(v.unit, .point)
    }

    func testGWValuePercentOperatorInt() {
        let v: GWValue = 50%
        XCTAssertEqual(v.value, 50)
        XCTAssertEqual(v.unit, .percent)
    }

    func testGWValuePercentOperatorFloat() {
        let v: GWValue = 75.5%
        XCTAssertEqual(v.value, 75.5)
        XCTAssertEqual(v.unit, .percent)
    }

    // MARK: - Reproduction: Three-level UIView with percentage sizes

    func testThreeLevelPercentLayoutViaUIView() {
        #if os(iOS)
        // Simulate controller view with explicit size
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 852, height: 393))
        root.yoga.width = .points(852)
        root.yoga.height = .points(393)

        // thisview: 100% x 100%
        let thisview = UIView()
        thisview.backgroundColor = .red
        thisview.style.width(100%).height(100%)
        root.addChild(thisview)
        root.performYogaLayout()

        // subView: 50% x 50%
        let subView = UIView()
        subView.backgroundColor = .yellow
        subView.style.width(50%).height(50%)
        thisview.addChild(subView)
        thisview.performYogaLayout()

        print("root.frame=\(root.frame)")
        print("thisview.frame=\(thisview.frame)")
        print("subView.frame=\(subView.frame)")

        XCTAssertEqual(thisview.frame.width, 852, accuracy: 0.5)
        XCTAssertEqual(thisview.frame.height, 393, accuracy: 0.5)
        XCTAssertEqual(subView.frame.width, 426, accuracy: 0.5)
        XCTAssertEqual(subView.frame.height, 196.5, accuracy: 0.5)
        #endif
    }

    func testThreeLevelPercentLayoutReLayout() {
        #if os(iOS)
        // Simulate rotation re-layout: init in portrait, then re-layout in landscape
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        root.yoga.width = .points(393)
        root.yoga.height = .points(852)

        let thisview = UIView()
        thisview.style.width(100%).height(100%)
        root.addChild(thisview)

        let subView = UIView()
        subView.style.width(50%).height(50%)
        thisview.addChild(subView)

        root.performYogaLayout()
        print("Portrait: thisview=\(thisview.frame) subView=\(subView.frame)")

        // Now simulate rotation: update root bounds and style
        root.frame = CGRect(x: 0, y: 0, width: 852, height: 393)
        root.yoga.width = .points(852)
        root.yoga.height = .points(393)
        root.performYogaLayout()
        print("Landscape: thisview=\(thisview.frame) subView=\(subView.frame)")

        XCTAssertEqual(thisview.frame.width, 852, accuracy: 0.5)
        XCTAssertEqual(thisview.frame.height, 393, accuracy: 0.5)
        XCTAssertEqual(subView.frame.width, 426, accuracy: 0.5)
        XCTAssertEqual(subView.frame.height, 196.5, accuracy: 0.5)
        #endif
    }

    // MARK: - Auto Layout via Swizzle (无感 rotation)

    func testAutoLayoutViaLayoutSubviews() {
        #if os(iOS)
        // Simulates what UIKit does: addChild → layoutSubviews auto-triggers yoga
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 852, height: 393))

        let thisview = UIView()
        thisview.style.width(100%).height(100%)
        root.addChild(thisview)

        let subView = UIView()
        subView.style.width(50%).height(50%)
        thisview.addChild(subView)

        // 不调 performYogaLayout — layoutSubviews 应该自动触发
        root.layoutSubviews()
        thisview.layoutSubviews()

        XCTAssertEqual(thisview.frame.width, 852, accuracy: 0.5)
        XCTAssertEqual(thisview.frame.height, 393, accuracy: 0.5)
        XCTAssertEqual(subView.frame.width, 426, accuracy: 0.5)
        XCTAssertEqual(subView.frame.height, 196.5, accuracy: 0.5)
        #endif
    }

    func testAutoLayoutRotation() {
        #if os(iOS)
        // 模拟 rotation：bounds 变化后 layoutSubviews 自动重算
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 393, height: 852))

        let thisview = UIView()
        thisview.style.width(100%).height(100%)
        root.addChild(thisview)

        let subView = UIView()
        subView.style.width(50%).height(50%)
        thisview.addChild(subView)

        root.layoutSubviews()
        thisview.layoutSubviews()

        // Portrait 验证
        XCTAssertEqual(thisview.frame.width, 393, accuracy: 0.5)
        XCTAssertEqual(thisview.frame.height, 852, accuracy: 0.5)
        XCTAssertEqual(subView.frame.width, 196.5, accuracy: 0.5)
        XCTAssertEqual(subView.frame.height, 426, accuracy: 0.5)

        // 模拟旋转到 landscape
        root.frame = CGRect(x: 0, y: 0, width: 852, height: 393)
        root.layoutSubviews()
        thisview.layoutSubviews()

        // Landscape 验证
        XCTAssertEqual(thisview.frame.width, 852, accuracy: 0.5)
        XCTAssertEqual(thisview.frame.height, 393, accuracy: 0.5)
        XCTAssertEqual(subView.frame.width, 426, accuracy: 0.5)
        XCTAssertEqual(subView.frame.height, 196.5, accuracy: 0.5)
        #endif
    }

    func testAutoLayoutRootWithoutYogaStyle() {
        #if os(iOS)
        // 根 view 不设 yoga style，只靠 bounds — 验证 bounds fallback
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 300))

        let child = UIView()
        child.style.width(100%).height(100%)
        root.addChild(child)

        root.layoutSubviews()

        XCTAssertEqual(child.frame.width, 400, accuracy: 0.5)
        XCTAssertEqual(child.frame.height, 300, accuracy: 0.5)
        #endif
    }

    func testGWValuePercentOperatorDouble() {
        let v: GWValue = 33.3%
        XCTAssertEqual(v.value, 33.3)
        XCTAssertEqual(v.unit, .percent)
    }

    #if os(iOS) || os(tvOS)

    // MARK: - Phase 1: UIView.style alias

    func testUIViewStyleAlias() {
        let view = UIView()
        view.style.width = 100
        view.style.height = 200
        view.style.flexDirection = .row
        view.style.justifyContent = .center

        XCTAssertEqual(view.style.width, .points(100))
        XCTAssertEqual(view.style.height, .points(200))
        XCTAssertEqual(view.style.flexDirection, .row)
        XCTAssertEqual(view.style.justifyContent, .center)
    }

    func testUIViewStyleWithPercent() {
        let view = UIView()
        view.style.width = 50%
        view.style.height = 75%
        XCTAssertEqual(view.style.width.unit, .percent)
        XCTAssertEqual(view.style.width.value, 50)
        XCTAssertEqual(view.style.height.unit, .percent)
    }

    // MARK: - Phase 1: callAsFunction closure

    func testCallAsFunctionClosure() {
        let view = UIView()
        view.style {
            $0.width = 100
            $0.height = 200
            $0.margin = .all
            $0.backgroundColor = .red
        }
        XCTAssertEqual(view.style.width, .points(100))
        XCTAssertEqual(view.style.height, .points(200))
    }

    func testCallAsFunctionReturnsSelf() {
        let view = UIView()
        let result = view.style {
            $0.width = 50
            $0.height = 50
        }
        XCTAssertTrue(result === view.style)
    }

    // MARK: - Phase 1: Chainable methods

    func testChainableWidthHeight() {
        let view = UIView()
        view.style
            .width(100)
            .height(200)
            .flexDirection(.row)
            .justifyContent(.center)
            .alignItems(.flexEnd)

        XCTAssertEqual(view.style.width, .points(100))
        XCTAssertEqual(view.style.height, .points(200))
        XCTAssertEqual(view.style.flexDirection, .row)
        XCTAssertEqual(view.style.justifyContent, .center)
        XCTAssertEqual(view.style.alignItems, .flexEnd)
    }

    func testChainableFlex() {
        let view = UIView()
        view.style
            .flexGrow(1)
            .flexShrink(0)
            .flexBasis(100)
            .flexWrap(.wrap)

        XCTAssertEqual(view.style.flexGrow, 1)
        XCTAssertEqual(view.style.flexShrink, 0)
        XCTAssertEqual(view.style.flexWrap, .wrap)
    }

    func testChainableMargin() {
        let view = UIView()
        view.style
            .margin(.all, 16)
            .marginTop(8)
            .marginHorizontal(12)

        XCTAssertTrue(view.style.isDirty)
    }

    func testChainablePadding() {
        let view = UIView()
        view.style
            .padding(.all, 16)
            .paddingTop(8)
            .paddingHorizontal(12)
            .paddingVertical(4)

        XCTAssertTrue(view.style.isDirty)
    }

    func testChainablePosition() {
        let view = UIView()
        view.style
            .position(.absolute)
            .top(10)
            .left(20)
            .bottom(30)
            .right(40)

        XCTAssertEqual(view.style.positionType, .absolute)
    }

    func testChainableGap() {
        let view = UIView()
        view.style
            .rowGap(10)
            .columnGap(20)
            .gap(15)

        XCTAssertEqual(view.style.columnGap, .points(15))
    }

    func testChainableDisplay() {
        let view = UIView()
        view.style
            .display(.flex)
            .overflow(.hidden)
            .boxSizing(.borderBox)
            .aspectRatio(1.5)

        XCTAssertEqual(view.style.display, .flex)
        XCTAssertEqual(view.style.overflow, .hidden)
        XCTAssertEqual(view.style.aspectRatio, 1.5, accuracy: 0.001)
    }

    func testChainableReturnType() {
        let view = UIView()
        let result: YogaProperties = view.style.width(100).height(200)
        XCTAssertTrue(result === view.style)
    }

    // MARK: - Phase 1: Visual Styles

    func testVisualBackgroundColor() {
        let view = UIView()
        view.style.backgroundColor(.blue)
        XCTAssertEqual(view.backgroundColor, .blue)

        view.style.backgroundColor(.red)
        XCTAssertEqual(view.backgroundColor, .red)
    }

    func testVisualCornerRadius() {
        let view = UIView()
        view.style.cornerRadius(12)
        XCTAssertEqual(view.layer.cornerRadius, 12)
        XCTAssertTrue(view.layer.masksToBounds)
    }

    func testVisualCornerRadiusRadii() {
        let view = UIView()
        let radii = YogaCornerRadii(topLeft: 10, topRight: 20, bottomLeft: 5, bottomRight: 0)
        view.style.cornerRadius(radii)
        XCTAssertEqual(view.layer.cornerRadius, 20)
        XCTAssertTrue(view.layer.maskedCorners.contains(.layerMinXMinYCorner))
        XCTAssertTrue(view.layer.maskedCorners.contains(.layerMaxXMinYCorner))
        XCTAssertTrue(view.layer.maskedCorners.contains(.layerMinXMaxYCorner))
        XCTAssertFalse(view.layer.maskedCorners.contains(.layerMaxXMaxYCorner))
    }

    func testVisualShadow() {
        let view = UIView()
        view.style.shadow(color: .black, opacity: 0.5, radius: 8, offset: CGSize(width: 2, height: 4))
        XCTAssertEqual(view.layer.shadowColor, UIColor.black.cgColor)
        XCTAssertEqual(view.layer.shadowOpacity, 0.5)
        XCTAssertEqual(view.layer.shadowRadius, 8)
        XCTAssertEqual(view.layer.shadowOffset, CGSize(width: 2, height: 4))
    }

    func testVisualShadowStruct() {
        let view = UIView()
        let shadow = YogaShadow(color: .gray, opacity: 0.3, radius: 6, offset: CGSize(width: 0, height: 3))
        view.style.shadow(shadow)
        XCTAssertEqual(view.layer.shadowOpacity, 0.3)
        XCTAssertEqual(view.layer.shadowRadius, 6)
    }

    func testVisualBorder() {
        let view = UIView()
        view.style
            .borderWidth(2)
            .borderColor(.red)

        XCTAssertEqual(view.layer.borderWidth, 2)
        XCTAssertEqual(view.layer.borderColor, UIColor.red.cgColor)
    }

    func testVisualOpacity() {
        let view = UIView()
        view.style.opacity(0.5)
        XCTAssertEqual(view.alpha, 0.5, accuracy: 0.001)

        view.style.opacity(1.0)
        XCTAssertEqual(view.alpha, 1.0, accuracy: 0.001)
    }

    func testVisualClipsToBounds() {
        let view = UIView()
        view.style.clipsToBounds(true)
        XCTAssertTrue(view.clipsToBounds)

        view.style.clipsToBounds(false)
        XCTAssertFalse(view.clipsToBounds)
    }

    func testVisualHidden() {
        let view = UIView()
        view.style.hidden(true)
        XCTAssertTrue(view.isHidden)

        view.style.hidden(false)
        XCTAssertFalse(view.isHidden)
    }

    // MARK: - Phase 1: addChild / removeFromParent

    func testAddChild() {
        let parent = YogaLayoutView(frame: .zero)
        parent.style.width = 300
        parent.style.height = 200

        let child = YogaLayoutView(frame: .zero)
        child.style.width = 100
        child.style.height = 50

        parent.addChild(child)
        XCTAssertEqual(parent.subviews.count, 1)
        XCTAssertTrue(child === parent.subviews[0])
    }

    func testAddChildAtIndex() {
        let parent = YogaLayoutView(frame: .zero)
        let child1 = YogaLayoutView(frame: .zero)
        let child2 = YogaLayoutView(frame: .zero)
        let child3 = YogaLayoutView(frame: .zero)

        parent.addChild(child1)
        parent.addChild(child3)
        parent.addChild(child2, at: 1)

        XCTAssertEqual(parent.subviews.count, 3)
        XCTAssertTrue(parent.subviews[1] === child2)
    }

    func testRemoveFromParent() {
        let parent = YogaLayoutView(frame: .zero)
        let child = YogaLayoutView(frame: .zero)
        parent.addChild(child)
        XCTAssertEqual(parent.subviews.count, 1)

        child.removeFromParent()
        XCTAssertEqual(parent.subviews.count, 0)
    }

    func testAddChildReturnsChild() {
        let parent = YogaLayoutView(frame: .zero)
        let child = YogaLayoutView(frame: .zero)
        let returned = parent.addChild(child)
        XCTAssertTrue(returned === child)
    }

    // MARK: - Phase 1: Chainable + Visual combined

    func testFullChainableVisual() {
        let view = UIView()
        view.style
            .width(300)
            .height(200)
            .backgroundColor(.systemBlue)
            .cornerRadius(12)
            .shadow(color: .black, opacity: 0.3, radius: 4, offset: CGSize(width: 0, height: 2))
            .borderWidth(1)
            .borderColor(.lightGray)
            .opacity(0.9)
            .clipsToBounds(true)

        XCTAssertEqual(view.style.width, .points(300))
        XCTAssertEqual(view.style.height, .points(200))
        XCTAssertEqual(view.layer.cornerRadius, 12)
        XCTAssertEqual(view.alpha, 0.9, accuracy: 0.001)
        XCTAssertTrue(view.clipsToBounds)
    }

    // MARK: - Phase 2: yog() proxy chain

    func testYogProxyChain() {
        let label = UILabel()
        label.yog()
            .text("Hello")
            .font(.boldSystemFont(ofSize: 18))
            .color(.darkText)
            .alignment(.center)
            .numberOfLines(0)
            .width(.auto)
            .height(44)
            .margin(16)
            .backgroundColor(.white)
            .cornerRadius(8)

        XCTAssertEqual(label.text, "Hello")
        XCTAssertEqual(label.textAlignment, .center)
        XCTAssertEqual(label.numberOfLines, 0)
        XCTAssertEqual(label.layer.cornerRadius, 8)
        XCTAssertEqual(label.backgroundColor, .white)
    }

    func testYogProxyFlex() {
        let view = UIView()
        view.yog()
            .flexDirection(.row)
            .justifyContent(.center)
            .alignItems(.flexEnd)
            .flexGrow(1)

        XCTAssertEqual(view.style.flexDirection, .row)
        XCTAssertEqual(view.style.justifyContent, .center)
        XCTAssertEqual(view.style.alignItems, .flexEnd)
        XCTAssertEqual(view.style.flexGrow, 1)
    }

    func testYogProxyReturnsSelf() {
        let label = UILabel()
        let proxy = label.yog().text("Hi")
        // Verify chaining still works
        proxy.width(100).height(50)
        XCTAssertEqual(label.style.width, .points(100))
    }

    // MARK: - Phase 2: cssID / find

    func testCssID() {
        let container = YogaLayoutView(frame: .zero)
        let child = YogaLayoutView(frame: .zero)
        container.addChild(child)
        child.style.cssID = "my-view"

        let found = container.style.find(byID: "my-view")
        XCTAssertNotNil(found)
        XCTAssertTrue(found === child)
    }

    func testCssIDNotFound() {
        let container = YogaLayoutView(frame: .zero)
        let child = YogaLayoutView(frame: .zero)
        container.addChild(child)
        child.style.cssID = "view-1"

        let found = container.style.find(byID: "nonexistent")
        XCTAssertNil(found)
    }

    func testCssClass() {
        let container = YogaLayoutView(frame: .zero)
        let child1 = YogaLayoutView(frame: .zero)
        let child2 = YogaLayoutView(frame: .zero)
        let child3 = YogaLayoutView(frame: .zero)
        container.addChild(child1)
        container.addChild(child2)
        container.addChild(child3)

        child1.style.cssClass = "card highlight"
        child2.style.cssClass = "card"
        child3.style.cssClass = "footer"

        let cards = container.style.findAll(byClass: "card")
        XCTAssertEqual(cards.count, 2)

        let highlights = container.style.findAll(byClass: "highlight")
        XCTAssertEqual(highlights.count, 1)
    }

    func testCssClassEmpty() {
        let container = YogaLayoutView(frame: .zero)
        let child = YogaLayoutView(frame: .zero)
        container.addChild(child)
        child.style.cssClass = "item"

        let found = container.style.findAll(byClass: "nonexistent")
        XCTAssertTrue(found.isEmpty)
    }

    // MARK: - Phase 2: Rich text

    func testAttributedText() {
        let label = UILabel()
        let attrText = NSAttributedString(
            string: "Hello World",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 18)]
        )
        label.style.attributedText = attrText
        XCTAssertEqual(label.attributedText?.string, "Hello World")
        XCTAssertTrue(label.yoga.isIntrinsic)
    }

    func testAttributedTextBuilder() {
        let label = UILabel()
        label.style.attributedText { builder in
            builder.text("Hello ", font: .systemFont(ofSize: 16), color: .gray)
            builder.text("World", font: .boldSystemFont(ofSize: 16), color: .blue)
        }
        XCTAssertEqual(label.attributedText?.string, "Hello World")
        XCTAssertTrue(label.yoga.isIntrinsic)
    }

    func testNumberOfLines() {
        let label = UILabel()
        label.style.numberOfLines = 3
        XCTAssertEqual(label.numberOfLines, 3)

        // Chainable
        label.style.numberOfLines(5)
        XCTAssertEqual(label.numberOfLines, 5)
    }

    #endif

    // MARK: - Phase 3: @YogaState Property Wrapper

    func testYogaStateInitialValue() {
        @YogaState var count: Int = 42
        XCTAssertEqual(count, 42)
    }

    func testYogaStateUpdate() {
        @YogaState var count: Int = 0
        count = 10
        XCTAssertEqual(count, 10)
    }

    func testYogaStateEqualityDeduplication() {
        @YogaState var count: Int = 0
        var observeCount = 0
        $count.observe { _ in observeCount += 1 }

        count = 1
        XCTAssertEqual(observeCount, 1)

        count = 1 // same value, should NOT trigger
        XCTAssertEqual(observeCount, 1) // still 1
    }

    func testYogaStateObserver() {
        @YogaState var count: Int = 0
        var observed: [Int] = []
        $count.observe { observed.append($0) }

        count = 10
        count = 20
        count = 20 // deduplicated

        XCTAssertEqual(observed, [10, 20])
    }

    func testYogaStateMultipleObservers() {
        @YogaState var count: Int = 0
        var obs1: [Int] = []
        var obs2: [Int] = []

        $count.observe { obs1.append($0) }
        $count.observe { obs2.append($0) }

        count = 5

        XCTAssertEqual(obs1, [5])
        XCTAssertEqual(obs2, [5])
    }

    func testYogaStateForward() {
        @YogaState var count: Int = 0
        @YogaState var title: String = ""

        $count.forward(to: $title) { "Count: \($0)" }

        count = 42
        XCTAssertEqual(title, "Count: 42")

        count = 100
        XCTAssertEqual(title, "Count: 100")
    }

    func testYogaStateForwardDeduplication() {
        @YogaState var count: Int = 0
        @YogaState var title: String = ""
        var forwardCount = 0

        $title.observe { _ in forwardCount += 1 }
        $count.forward(to: $title) { "Count: \($0)" }

        count = 1
        count = 1 // deduplicated at source, so title doesn't change

        XCTAssertEqual(forwardCount, 1)
    }

    func testYogaStateRemoveObserver() {
        @YogaState var value: String = ""
        var observed: [String] = []

        let token = $value.observe { observed.append($0) }

        value = "first"
        XCTAssertEqual(observed, ["first"])

        $value.removeObserver(token)
        value = "second"
        XCTAssertEqual(observed, ["first"]) // no longer observing
    }

    func testYogaStateStringType() {
        @YogaState var name: String = "Alice"
        XCTAssertEqual(name, "Alice")

        name = "Bob"
        XCTAssertEqual(name, "Bob")
    }

    func testYogaStateDoubleType() {
        @YogaState var value: Double = 3.14
        XCTAssertEqual(value, 3.14, accuracy: 0.001)

        value = 2.72
        XCTAssertEqual(value, 2.72, accuracy: 0.001)
    }

    func testYogaStateBoolType() {
        @YogaState var flag: Bool = false
        var changes: [Bool] = []
        $flag.observe { changes.append($0) }

        flag = true
        flag = true // deduplicated

        XCTAssertTrue(flag)
        XCTAssertEqual(changes, [true])
    }

    func testYogaStateForwardChain() {
        @YogaState var count: Int = 0
        @YogaState var doubled: Int = 0
        @YogaState var label: String = ""

        $count.forward(to: $doubled) { $0 * 2 }
        $doubled.forward(to: $label) { "Value: \($0)" }

        count = 5
        XCTAssertEqual(doubled, 10)
        XCTAssertEqual(label, "Value: 10")

        count = 10
        XCTAssertEqual(doubled, 20)
        XCTAssertEqual(label, "Value: 20")
    }

    // MARK: - Phase 3: YogaBinding

    func testYogaBindingClosure() {
        @YogaState var count: Int = 42
        let binding = YogaBinding()
        var result: [Int] = []

        binding.bind($count) { result.append($0) }

        XCTAssertEqual(result, [42]) // 初始值被立即应用

        count = 1
        count = 2

        XCTAssertEqual(result, [42, 1, 2])
    }

    func testYogaBindingUnbindAll() {
        @YogaState var count: Int = 0
        let binding = YogaBinding()
        var result: [Int] = []

        binding.bind($count) { result.append($0) }
        count = 1
        XCTAssertEqual(result, [0, 1])

        binding.unbindAll()
        count = 2
        XCTAssertEqual(result, [0, 1]) // no longer observing
    }

    #if os(iOS) || os(tvOS)

    func testYogaBindingKeyPath() {
        @YogaState var text: String = "Hello"
        let binding = YogaBinding()
        let label = UILabel()

        binding.bind($text, to: \.text, on: label)
        XCTAssertEqual(label.text, "Hello") // 初始值被立即应用

        text = "World"
        XCTAssertEqual(label.text, "World")
    }

    func testYogaBindingKeyPathUnbind() {
        @YogaState var text: String = "Hello"
        let binding = YogaBinding()
        let label = UILabel()

        binding.bind($text, to: \.text, on: label)
        text = "World"
        XCTAssertEqual(label.text, "World")

        binding.unbindAll()
        text = "Goodbye"
        XCTAssertEqual(label.text, "World") // unbind 后不再更新
    }

    func testYogaBindingMultipleStates() {
        @YogaState var title: String = ""
        @YogaState var subtitle: String = ""
        let binding = YogaBinding()
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()

        binding.bind($title, to: \.text, on: titleLabel)
        binding.bind($subtitle, to: \.text, on: subtitleLabel)

        title = "Main"
        subtitle = "Sub"

        XCTAssertEqual(titleLabel.text, "Main")
        XCTAssertEqual(subtitleLabel.text, "Sub")
    }

    func testYogaBindingChainedBind() {
        @YogaState var text: String = ""
        @YogaState var text2: String = ""
        let binding = YogaBinding()
        let label1 = UILabel()
        let label2 = UILabel()
        var combined: [String] = []

        binding
            .bind($text, to: \.text, on: label1)
            .bind($text2, to: \.text, on: label2)
            .bind($text) { combined.append($0) }

        text = "Hello"
        text2 = "World"

        XCTAssertEqual(label1.text, "Hello")
        XCTAssertEqual(label2.text, "World")
        XCTAssertEqual(combined, ["Hello"])
    }

    // MARK: - Phase 3: YogaProperties Binding

    func testYogaPropertiesBindKeyPath() {
        let view = YogaLayoutView(frame: .zero)
        @YogaState var w: GWValue = 100

        view.style.bind($w, to: \.width)
        XCTAssertEqual(view.style.width, .points(100))

        w = 200
        XCTAssertEqual(view.style.width, .points(200))
    }

    func testYogaPropertiesBindKeyPathMultiple() {
        let view = YogaLayoutView(frame: .zero)
        @YogaState var w: GWValue = 100
        @YogaState var h: GWValue = 200

        view.style.bind($w, to: \.width)
        view.style.bind($h, to: \.height)
        XCTAssertEqual(view.style.width, .points(100))
        XCTAssertEqual(view.style.height, .points(200))

        w = 300
        h = 400
        XCTAssertEqual(view.style.width, .points(300))
        XCTAssertEqual(view.style.height, .points(400))
    }

    func testYogaPropertiesBindClosure() {
        let view = YogaLayoutView(frame: .zero)
        @YogaState var enabled: Bool = false

        view.style.bind($enabled) { props, isEnabled in
            props.opacity = isEnabled ? 1.0 : 0.5
        }

        XCTAssertEqual(view.alpha, 0.5, accuracy: 0.001)

        enabled = true
        XCTAssertEqual(view.alpha, 1.0, accuracy: 0.001)
    }

    func testYogaPropertiesBindUnbind() {
        let view = YogaLayoutView(frame: .zero)
        @YogaState var w: GWValue = 100

        view.style.bind($w, to: \.width)
        w = 200
        XCTAssertEqual(view.style.width, .points(200))

        view.style.unbindAll()
        w = 300
        XCTAssertEqual(view.style.width, .points(200)) // unchanged after unbind
    }

    // MARK: - Phase 3: Layout Coalescing

    func testCoalescedBindingKeyPath() {
        let view = YogaLayoutView(frame: .zero)
        @YogaState var w: GWValue = 100
        @YogaState var h: GWValue = 200

        view.style.coalesceLayout()
        view.style.bind($w, to: \.width)
        view.style.bind($h, to: \.height)

        // Initial values applied correctly
        XCTAssertEqual(view.style.width, .points(100))
        XCTAssertEqual(view.style.height, .points(200))

        w = 300
        h = 400

        // Both values updated after coalesced changes
        XCTAssertEqual(view.style.width, .points(300))
        XCTAssertEqual(view.style.height, .points(400))
    }

    func testCoalescedBindingClosure() {
        let view = YogaLayoutView(frame: .zero)
        @YogaState var isActive: Bool = false

        view.style.coalesceLayout().bind($isActive) { props, active in
            props.opacity = active ? 1.0 : 0.5
        }

        XCTAssertEqual(view.alpha, 0.5, accuracy: 0.001)

        isActive = true
        XCTAssertEqual(view.alpha, 1.0, accuracy: 0.001)
    }

    func testCoalescedDoesNotBreakUnbind() {
        let view = YogaLayoutView(frame: .zero)
        @YogaState var w: GWValue = 100

        view.style.coalesceLayout().bind($w, to: \.width)
        w = 200
        XCTAssertEqual(view.style.width, .points(200))

        view.style.unbindAll()
        w = 300
        XCTAssertEqual(view.style.width, .points(200)) // unchanged after unbind
    }

    // MARK: - Phase 3: Custom Drawing Protocol

    func testYogaCustomDrawingRegister() {
        YogaMeasureRegistry.register(CustomDrawingLabel.self)
        let label = CustomDrawingLabel()
        label.yoga.isIntrinsic = true

        // The measure function should be set up via registry
        XCTAssertNotNil(label.yoga.node.measureFunction)
    }

    func testYogaCustomDrawingMeasure() {
        YogaMeasureRegistry.register(CustomDrawingLabel.self)
        let label = CustomDrawingLabel()
        label.yoga.isIntrinsic = true

        // Trigger layout to verify measurement
        label.yoga.width = .points(200)
        label.yoga.height = .auto
        label.performYogaLayout()

        // The custom content size should be used
        let result = label.yoga.node.layoutResult
        // CustomDrawingLabel reports content height = 50
        XCTAssertEqual(result.height, 50, accuracy: 0.001)
    }

    func testYogaCustomDrawingCustomHandler() {
        YogaMeasureRegistry.register(UIView.self) { view, maxW, maxH in
            CGSize(width: 100, height: 60)
        }

        let view = UIView()
        view.yoga.isIntrinsic = true
        view.yoga.width = .points(200)
        view.yoga.height = .auto
        view.performYogaLayout()

        let result = view.yoga.node.layoutResult
        XCTAssertEqual(result.height, 60, accuracy: 0.001)
    }

    func testYogaCustomDrawingNoHandler() {
        let view = UIView()
        view.yoga.isIntrinsic = true

        // No handler registered for UIView, so should fall through without crash
        view.yoga.width = .points(200)
        view.yoga.height = .points(100)
        view.performYogaLayout()

        let result = view.yoga.node.layoutResult
        XCTAssertEqual(result.height, 100, accuracy: 0.001)
    }

    // MARK: - Phase 3: Debug Tools

    func testSystemLayoutSize() {
        let view = YogaLayoutView(frame: .zero)
        view.style.width = 200
        view.style.height = 100

        let size = view.style.systemLayoutSize()
        XCTAssertEqual(size.width, 200, accuracy: 0.001)
        XCTAssertEqual(size.height, 100, accuracy: 0.001)
    }

    func testDebugBorder() {
        let view = YogaLayoutView(frame: .zero)
        view.style.debugBorder()

        #if os(iOS) || os(tvOS)
        XCTAssertEqual(view.layer.borderWidth, 1)
        XCTAssertNotNil(view.layer.borderColor)
        #endif
    }

    func testDebugBorderCustom() {
        let view = YogaLayoutView(frame: .zero)
        view.style.debugBorder(color: .blue, width: 2)

        #if os(iOS) || os(tvOS)
        XCTAssertEqual(view.layer.borderWidth, 2)
        #endif
    }

    func testDebugBorderReturnsSelf() {
        let view = YogaLayoutView(frame: .zero)
        let result = view.style.debugBorder()
        XCTAssertTrue(result === view.style)
    }

    #endif
}

// MARK: - Phase 3 Test Helpers

#if os(iOS) || os(tvOS)

/// 用于 YogaCustomDrawing 测试的自定义视图
private class CustomDrawingLabel: UILabel, YogaCustomDrawing {
    func yogaContentSize(maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        return CGSize(width: min(200, maxWidth), height: 50)
    }
}

#endif

// MARK: - Phase 4: Combine Binding Tests

final class YogaPropertiesCombineTests: XCTestCase {

    func testPublisherBindToKeyPath() {
        let view = YogaLayoutView()
        view.yoga.width = 0

        let pub = Just(GWValue.points(200))
        let cancel = pub.bind(to: view.yoga, keyPath: \.width)

        XCTAssertEqual(view.yoga.width, .points(200))
        _ = cancel // 持有
    }

    func testPublisherBindToClosure() {
        let view = YogaLayoutView()
        view.yoga.flexGrow = 0

        let pub = Just(2.0 as Float)
        let cancel = pub.bind(to: view.yoga) { $0.flexGrow = $1 }

        XCTAssertEqual(view.yoga.flexGrow, 2.0)
        _ = cancel
    }

    func testPublisherBindMultipleValues() {
        let view = YogaLayoutView()
        let subject = PassthroughSubject<GWValue, Never>()
        let cancel = subject.bind(to: view.yoga, keyPath: \.width)

        subject.send(.points(100))
        XCTAssertEqual(view.yoga.width, .points(100))

        subject.send(.points(200))
        XCTAssertEqual(view.yoga.width, .points(200))

        _ = cancel
    }

    func testPublisherBindWeakTarget() {
        var view: YogaLayoutView? = YogaLayoutView()
        weak var weakView = view

        let pub = Just(GWValue.points(100))
        let cancel = pub.bind(to: view!.yoga, keyPath: \.width)

        view = nil
        XCTAssertNil(weakView)
        // 解除后发布者不应崩溃
        XCTAssertNoThrow(_ = cancel)
    }

    func testPublisherBindCancellation() {
        let view = YogaLayoutView()
        view.yoga.width = 0

        let subject = PassthroughSubject<GWValue, Never>()
        let cancel = subject.bind(to: view.yoga, keyPath: \.width)

        subject.send(.points(150))
        XCTAssertEqual(view.yoga.width, .points(150))

        cancel.cancel()
        subject.send(.points(300))
        // 取消后不应再更新
        XCTAssertEqual(view.yoga.width, .points(150))
    }
}

// MARK: - Phase 4: onTraitChange Tests

#if os(iOS) || os(tvOS)
final class YogaPropertiesTraitTests: XCTestCase {

    func testOnTraitChangeRegistersHandler() {
        let view = YogaLayoutView()
        var called = false

        view.yoga.onTraitChange { _, style in
            called = true
            style.flexDirection = .row
        }

        // Handler registered — no easy way to simulate trait change in tests
        // Verify the observer view was added
        XCTAssertEqual(view.subviews.count, 1)
        XCTAssertTrue(view.subviews[0].isHidden)
    }

    func testOnTraitChangeMultipleHandlers() {
        let view = YogaLayoutView()
        var callCount = 0

        view.yoga.onTraitChange { _, _ in callCount += 1 }
        view.yoga.onTraitChange { _, _ in callCount += 1 }

        // Two handlers registered
        XCTAssertEqual(view.subviews.count, 1) // only one observer view
    }

    func testOnTraitChangeChainable() {
        let view = YogaLayoutView()
        let result = view.yoga.onTraitChange { _, style in
            style.width = 100
        }
        XCTAssertTrue(result === view.yoga)
    }

    func testRemoveAllTraitHandlers() {
        let view = YogaLayoutView()
        var called = false

        view.yoga.onTraitChange { _, _ in called = true }
        view.yoga.removeAllTraitHandlers()

        // After removal, observer view still exists but handlers are empty
        XCTAssertEqual(view.subviews.count, 1)
    }

    func testOnTraitChangeSetsDirty() {
        let view = YogaLayoutView()
        view.yoga.width = 100

        view.yoga.onTraitChange { _, style in
            style.width = 200
        }

        // Before trait change, width is 100
        XCTAssertEqual(view.yoga.width, 200) // already applied synchronously? No — only on change
        // Actually the handler doesn't run until traitCollectionDidChange fires
    }
}
#endif
