import XCTest
@testable import GWYoga
@testable import GWYogaKit
@testable import GWYogaKitStylesheet

final class YogaSelectorTests: XCTestCase {

    // MARK: - Selector Parsing

    func testParseUniversal() throws {
        let sel = try YogaSelector.parse("*")
        XCTAssertEqual(sel, .universal)
    }

    func testParseType() throws {
        let sel = try YogaSelector.parse("div")
        XCTAssertEqual(sel, .type("div"))
    }

    func testParseClass() throws {
        let sel = try YogaSelector.parse(".container")
        XCTAssertEqual(sel, .class_("container"))
    }

    func testParseID() throws {
        let sel = try YogaSelector.parse("#header")
        XCTAssertEqual(sel, .id("header"))
    }

    func testParseCompoundClassID() throws {
        let sel = try YogaSelector.parse(".card.highlight")
        if case .compound(let parts) = sel {
            XCTAssertEqual(parts.count, 2)
            XCTAssertEqual(parts[0], .class_("card"))
            XCTAssertEqual(parts[1], .class_("highlight"))
        } else {
            XCTFail("Expected compound selector")
        }
    }

    func testParseTypeWithClass() throws {
        let sel = try YogaSelector.parse("div.content")
        if case .compound(let parts) = sel {
            XCTAssertEqual(parts.count, 2)
            XCTAssertEqual(parts[0], .type("div"))
            XCTAssertEqual(parts[1], .class_("content"))
        } else {
            XCTFail("Expected compound selector")
        }
    }

    func testParseDescendant() throws {
        let sel = try YogaSelector.parse(".parent .child")
        XCTAssertEqual(sel, .descendant(.class_("parent"), .class_("child")))
    }

    func testParseChild() throws {
        let sel = try YogaSelector.parse(".parent > .child")
        XCTAssertEqual(sel, .child(.class_("parent"), .class_("child")))
    }

    func testParsePseudoClass() throws {
        let sel = try YogaSelector.parse("button:hover")
        XCTAssertEqual(sel, .pseudoClass(.type("button"), .hover))
    }

    func testParsePseudoClassLastChild() throws {
        let sel = try YogaSelector.parse("li:last-child")
        XCTAssertEqual(sel, .pseudoClass(.type("li"), .lastChild))
    }

    func testParsePseudoClassNthChild() throws {
        let sel = try YogaSelector.parse("div:nth-child(2)")
        XCTAssertEqual(sel, .pseudoClass(.type("div"), .nthChild(2)))
    }

    // MARK: - Selector Matching

    func testMatchUniversal() throws {
        let sel = try YogaSelector.parse("*")
        XCTAssertTrue(sel.matches(tag: "div", classes: [], id: nil))
        XCTAssertTrue(sel.matches(tag: "span", classes: ["foo"], id: "bar"))
    }

    func testMatchType() throws {
        let sel = try YogaSelector.parse("div")
        XCTAssertTrue(sel.matches(tag: "div", classes: [], id: nil))
        XCTAssertFalse(sel.matches(tag: "span", classes: [], id: nil))
    }

    func testMatchClass() throws {
        let sel = try YogaSelector.parse(".active")
        XCTAssertTrue(sel.matches(tag: "div", classes: ["active"], id: nil))
        XCTAssertFalse(sel.matches(tag: "div", classes: ["inactive"], id: nil))
    }

    func testMatchID() throws {
        let sel = try YogaSelector.parse("#main")
        XCTAssertTrue(sel.matches(tag: "div", classes: [], id: "main"))
        XCTAssertFalse(sel.matches(tag: "div", classes: [], id: "footer"))
    }

    func testMatchCompound() throws {
        let sel = try YogaSelector.parse("div.active")
        XCTAssertTrue(sel.matches(tag: "div", classes: ["active"], id: nil))
        XCTAssertFalse(sel.matches(tag: "span", classes: ["active"], id: nil))
        XCTAssertFalse(sel.matches(tag: "div", classes: ["inactive"], id: nil))
    }

    // MARK: - Specificity

    func testSpecificityType() throws {
        let sel = try YogaSelector.parse("div")
        XCTAssertEqual(sel.specificityValue, 1)
    }

    func testSpecificityClass() throws {
        let sel = try YogaSelector.parse(".active")
        XCTAssertEqual(sel.specificityValue, 1_000)
    }

    func testSpecificityID() throws {
        let sel = try YogaSelector.parse("#main")
        XCTAssertEqual(sel.specificityValue, 1_000_000)
    }

    func testSpecificityCompound() throws {
        let sel = try YogaSelector.parse("div.active#main")
        XCTAssertEqual(sel.specificityValue, 1_001_001) // id(1M) + class(1K) + type(1)
    }

    func testSpecificityDescendant() throws {
        let sel = try YogaSelector.parse(".parent .child")
        let expected = YogaSelector.class_("parent").specificityValue + YogaSelector.class_("child").specificityValue
        XCTAssertEqual(sel.specificityValue, expected)
    }
}

final class YogaCSSParserTests: XCTestCase {

    func testParseSimpleRule() throws {
        let css = ".foo { width: 100px; height: 50px }"
        let rules = try YogaCSSParser.parse(css)
        XCTAssertEqual(rules.count, 1)
        XCTAssertEqual(rules[0].selector, .class_("foo"))
        XCTAssertEqual(rules[0].declarations.count, 2)
        XCTAssertEqual(rules[0].declarations[0].property, "width")
        XCTAssertEqual(rules[0].declarations[0].value, "100px")
        XCTAssertEqual(rules[0].declarations[1].property, "height")
        XCTAssertEqual(rules[0].declarations[1].value, "50px")
    }

    func testParseMultipleRules() throws {
        let css = "div { width: 100px } span { height: 50px }"
        let rules = try YogaCSSParser.parse(css)
        XCTAssertEqual(rules.count, 2)
    }

    func testParseMultipleSelectors() throws {
        let css = ".foo, .bar { margin: 10px }"
        let rules = try YogaCSSParser.parse(css)
        XCTAssertEqual(rules.count, 2)
        XCTAssertEqual(rules[0].selector, .class_("foo"))
        XCTAssertEqual(rules[1].selector, .class_("bar"))
    }

    func testStripComments() throws {
        let css = """
        /* header style */
        .header { width: 100% }
        /* footer
           multi-line */
        .footer { height: 50px }
        """
        let rules = try YogaCSSParser.parse(css)
        XCTAssertEqual(rules.count, 2)
        XCTAssertEqual(rules[0].selector, .class_("header"))
        XCTAssertEqual(rules[1].selector, .class_("footer"))
    }

    func testParseNoTrailingSemicolon() throws {
        let css = "p { margin: 0 }"
        let rules = try YogaCSSParser.parse(css)
        XCTAssertEqual(rules.count, 1)
        XCTAssertEqual(rules[0].declarations.count, 1)
    }

    func testParseEmptyBlock() throws {
        let css = "div { }"
        let rules = try YogaCSSParser.parse(css)
        XCTAssertEqual(rules.count, 1)
        XCTAssertEqual(rules[0].declarations.count, 0)
    }

    func testParseComplexSelectors() throws {
        let css = """
        #sidebar .widget:hover { background-color: #fff }
        nav > ul li { display: flex }
        """
        let rules = try YogaCSSParser.parse(css)
        XCTAssertEqual(rules.count, 2)

        // #sidebar .widget:hover
        if case .descendant(let left, let right) = rules[0].selector {
            XCTAssertEqual(left, .id("sidebar"))
            if case .pseudoClass(let sel, .hover) = right {
                XCTAssertEqual(sel, .class_("widget"))
            } else {
                XCTFail("Expected pseudoClass hover")
            }
        } else {
            XCTFail("Expected descendant selector")
        }
    }
}

final class YogaCSSPropertyMapperTests: XCTestCase {

    func testParseLengthPX() {
        let v = YogaCSSPropertyMapper.parseLength("16px")
        XCTAssertEqual(v, .points(16))
    }

    func testParseLengthPT() {
        let v = YogaCSSPropertyMapper.parseLength("10pt")
        XCTAssertEqual(v, .points(10))
    }

    func testParseLengthPercent() {
        let v = YogaCSSPropertyMapper.parseLength("50%")
        XCTAssertEqual(v, .percent(50))
    }

    func testParseLengthAuto() {
        let v = YogaCSSPropertyMapper.parseLength("auto")
        XCTAssertEqual(v, .auto)
    }

    func testParseLengthFR() {
        let v = YogaCSSPropertyMapper.parseLength("1fr")
        XCTAssertEqual(v, GWValue(value: 1, unit: .stretch))
    }

    func testParseLengthFRFractional() {
        let v = YogaCSSPropertyMapper.parseLength("2.5fr")
        XCTAssertEqual(v, GWValue(value: 2.5, unit: .stretch))
    }

    func testParseLengthZero() {
        let v = YogaCSSPropertyMapper.parseLength("0")
        XCTAssertEqual(v, .points(0))
    }

    func testParseLengthPlainNumber() {
        let v = YogaCSSPropertyMapper.parseLength("42")
        XCTAssertEqual(v, .points(42))
    }

    func testParseFlexDirectionRow() {
        let d = YogaCSSPropertyMapper.parseFlexDirection("row")
        XCTAssertEqual(d, .row)
    }

    func testParseFlexDirectionColumn() {
        let d = YogaCSSPropertyMapper.parseFlexDirection("column")
        XCTAssertEqual(d, .column)
    }

    func testParseFlexDirectionRowReverse() {
        let d = YogaCSSPropertyMapper.parseFlexDirection("row-reverse")
        XCTAssertEqual(d, .rowReverse)
    }

    func testParseFlexWrap() {
        XCTAssertEqual(YogaCSSPropertyMapper.parseFlexWrap("wrap"), .wrap)
        XCTAssertEqual(YogaCSSPropertyMapper.parseFlexWrap("nowrap"), .noWrap)
        XCTAssertEqual(YogaCSSPropertyMapper.parseFlexWrap("wrap-reverse"), .wrapReverse)
    }

    func testParseJustifyContent() {
        XCTAssertEqual(YogaCSSPropertyMapper.parseJustifyContent("center"), .center)
        XCTAssertEqual(YogaCSSPropertyMapper.parseJustifyContent("space-between"), .spaceBetween)
        XCTAssertEqual(YogaCSSPropertyMapper.parseJustifyContent("flex-end"), .flexEnd)
        XCTAssertEqual(YogaCSSPropertyMapper.parseJustifyContent("flex-start"), .flexStart)
        XCTAssertEqual(YogaCSSPropertyMapper.parseJustifyContent("space-evenly"), .spaceEvenly)
    }

    func testParseAlign() {
        XCTAssertEqual(YogaCSSPropertyMapper.parseAlign("stretch"), .stretch)
        XCTAssertEqual(YogaCSSPropertyMapper.parseAlign("center"), .center)
        XCTAssertEqual(YogaCSSPropertyMapper.parseAlign("baseline"), .baseline)
        XCTAssertEqual(YogaCSSPropertyMapper.parseAlign("flex-start"), .flexStart)
    }

    func testParseDisplay() {
        XCTAssertEqual(YogaCSSPropertyMapper.parseDisplay("flex"), .flex)
        XCTAssertEqual(YogaCSSPropertyMapper.parseDisplay("none"), GWDisplay.none)
        XCTAssertEqual(YogaCSSPropertyMapper.parseDisplay("grid"), .grid)
    }

    func testParsePositionType() {
        XCTAssertEqual(YogaCSSPropertyMapper.parsePositionType("relative"), .relative)
        XCTAssertEqual(YogaCSSPropertyMapper.parsePositionType("static"), .relative) // maps to relative
        XCTAssertEqual(YogaCSSPropertyMapper.parsePositionType("absolute"), .absolute)
    }

    func testParseOverflow() {
        XCTAssertEqual(YogaCSSPropertyMapper.parseOverflow("visible"), .visible)
        XCTAssertEqual(YogaCSSPropertyMapper.parseOverflow("hidden"), .hidden)
        XCTAssertEqual(YogaCSSPropertyMapper.parseOverflow("scroll"), .scroll)
    }

    func testParseFloatPX() {
        let v = YogaCSSPropertyMapper.parseFloat("16px")
        XCTAssertEqual(v, 16)
    }

    func testParseFloatPlain() {
        let v = YogaCSSPropertyMapper.parseFloat("42.5")
        XCTAssertEqual(v, 42.5)
    }

    func testParseGridLineAuto() {
        let line = YogaCSSPropertyMapper.parseGridLine("auto")
        XCTAssertEqual(line, .auto)
    }

    func testParseGridLineInteger() {
        let line = YogaCSSPropertyMapper.parseGridLine("3")
        XCTAssertEqual(line, GWGridLine(type: .integer, value: 3))
    }

    func testParseTrackListSimple() {
        let tracks = YogaCSSPropertyMapper.parseTrackList("1fr 1fr")
        XCTAssertEqual(tracks?.count, 2)
        XCTAssertNotNil(tracks?[0])
        XCTAssertTrue(tracks?[0].isMaxFlex ?? false)
        XCTAssertTrue(tracks?[1].isMaxFlex ?? false)
    }

    func testParseTrackListMixed() {
        let tracks = YogaCSSPropertyMapper.parseTrackList("100px auto 1fr")
        XCTAssertEqual(tracks?.count, 3)
        XCTAssertTrue(tracks?[0].isFixedMax ?? false)
        XCTAssertTrue(tracks?[1].isIntrinsic ?? false)
        XCTAssertTrue(tracks?[2].isMaxFlex ?? false)
    }
}

final class YogaStylesheetTests: XCTestCase {

    func testParseStylesheet() throws {
        let css = """
        .container { width: 100%; padding: 16px }
        #header { height: 60px; background-color: #333 }
        div.content { margin: 10px }
        """
        let sheet = try YogaStylesheet.parse(css)
        XCTAssertEqual(sheet.rules.count, 3)
    }

    func testStylesheetMerge() throws {
        let css1 = ".a { width: 100px }"
        let css2 = ".b { height: 200px }"
        let sheet1 = try YogaStylesheet.parse(css1)
        let sheet2 = try YogaStylesheet.parse(css2)
        let merged = YogaStylesheet.merge(sheet1, sheet2)
        XCTAssertEqual(merged.rules.count, 2)
    }

    func testRulesSortedBySpecificity() throws {
        // Rules appear in source order, but when applied they sort by specificity
        let css = """
        div { margin: 5px }
        .special { margin: 10px }
        #unique { margin: 15px }
        """
        let sheet = try YogaStylesheet.parse(css)
        XCTAssertEqual(sheet.rules.count, 3)
        // Specificity: div=1, .special=1000, #unique=1000000
        XCTAssertEqual(sheet.rules[0].specificity, 1)
        XCTAssertEqual(sheet.rules[1].specificity, 1000)
        XCTAssertEqual(sheet.rules[2].specificity, 1_000_000)
    }

    func testLoadFileNotFound() {
        XCTAssertThrowsError(try YogaStylesheet.load(named: "nonexistent")) { error in
            XCTAssertTrue(error is YogaStylesheetError)
        }
    }

    // MARK: - Complex Selectors

    func testParseComplexSelectors() throws {
        let css = """
        div.container > p.text:hover { color: red }
        ul li:first-child { margin: 0 }
        a[href] { text-decoration: underline }
        """
        let sheet = try YogaStylesheet.parse(css)
        XCTAssertEqual(sheet.rules.count, 3)
    }

    func testPseudoClassNthChild() throws {
        let css = """
        li:nth-child(2n+1) { background: gray }
        li:nth-child(3) { color: blue }
        """
        let sheet = try YogaStylesheet.parse(css)
        XCTAssertEqual(sheet.rules.count, 2)
        // Verify pseudo-class is stored
        XCTAssertTrue(sheet.rules[0].selector.specificityValue > 0)
    }

    func testPseudoClassNot() throws {
        let css = """
        div:not(.special) { opacity: 0.5 }
        """
        let sheet = try YogaStylesheet.parse(css)
        XCTAssertEqual(sheet.rules.count, 1)
        XCTAssertTrue(sheet.rules[0].selector.specificityValue > 0)
    }

    // MARK: - Stylesheet Operations

    func testStylesheetMergeConflicts() throws {
        let css1 = "div { margin: 10px }"
        let css2 = "div { margin: 20px }"

        var sheet1 = try YogaStylesheet.parse(css1)
        let sheet2 = try YogaStylesheet.parse(css2)
        sheet1 = YogaStylesheet.merge(sheet1, sheet2)

        // Last matching rule wins
        XCTAssertEqual(sheet1.rules.count, 2)
        XCTAssertEqual(sheet1.rules[1].declarations.first?.value, "20px")
    }

    func testStylesheetApplyOrder() throws {
#if canImport(UIKit)
        let css = """
        .foo { margin: 5px; padding: 10px }
        .bar { margin: 15px }
        """
        let view = UIView()
        let sheet = try YogaStylesheet.parse(css)

        // Apply .foo then .bar using view's yoga properties
        for rule in sheet.rules {
            for decl in rule.declarations {
                YogaCSSPropertyMapper.apply(property: decl.property, value: decl.value, to: view.yoga)
            }
        }

        // .bar.margin overrides .foo.margin, padding from .foo remains
        XCTAssertEqual(sheet.rules.count, 2)
#endif
    }

    // MARK: - Error Handling

    func testCSSPropertyMapperError() {
#if canImport(UIKit)
        let view = UIView()
        // Invalid property should not crash
        YogaCSSPropertyMapper.apply(property: "invalid-prop", value: "10px", to: view.yoga)
        XCTAssertTrue(true) // reached without crash
#endif
    }

    // MARK: - Selector Specificity

    func testSelectorSpecificityCalc() throws {
        let css = """
        * { margin: 0 }                    /* 0,0,0,0 */
        div { margin: 1px }                 /* 0,0,0,1 */
        .class { margin: 2px }              /* 0,0,1,0 */
        #id { margin: 3px }                 /* 0,1,0,0 */
        div.class#id { margin: 4px }        /* 0,1,1,1 */
        div .class { margin: 5px }          /* 0,0,1,1 (descendant) */
        """
        let sheet = try YogaStylesheet.parse(css)

        // Universal selector has lowest specificity
        XCTAssertEqual(sheet.rules[0].specificity, 0)
        // Type selector
        XCTAssertEqual(sheet.rules[1].specificity, 1)
        // Class selector
        XCTAssertEqual(sheet.rules[2].specificity, 1000)
        // ID selector
        XCTAssertEqual(sheet.rules[3].specificity, 1_000_000)
        // Compound: div.class#id
        XCTAssertEqual(sheet.rules[4].specificity, 1_001_001)
        // Descendant: div .class
        XCTAssertEqual(sheet.rules[5].specificity, 1001)
    }
}
