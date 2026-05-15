import Foundation
import GWYoga
import GWYogaKit
#if os(iOS)
import UIKit
#endif

// MARK: - YogaCSSPropertyMapper

/// Maps CSS property name-value pairs to YogaProperties setters.
public enum YogaCSSPropertyMapper {

    /// Apply a CSS property-value pair to a YogaProperties instance.
    public static func apply(property: String, value: String, to yoga: YogaProperties) {
        let prop = property.trimmingCharacters(in: .whitespaces).lowercased()
        let val = value.trimmingCharacters(in: .whitespaces)
        guard let handler = propertyHandlers[prop] else { return }
        handler(val, yoga)
    }

    // MARK: - Property Handlers

    private typealias Handler = (String, YogaProperties) -> Void

    private static let propertyHandlers: [String: Handler] = {
        var h: [String: Handler] = [:]

        // ── Size ──
        h["width"] = { v, y in if let l = parseLength(v) { y.width = l } }
        h["height"] = { v, y in if let l = parseLength(v) { y.height = l } }
        h["min-width"] = { v, y in if let l = parseLength(v) { y.minWidth = l } }
        h["min-height"] = { v, y in if let l = parseLength(v) { y.minHeight = l } }
        h["max-width"] = { v, y in if let l = parseLength(v) { y.maxWidth = l } }
        h["max-height"] = { v, y in if let l = parseLength(v) { y.maxHeight = l } }

        // ── Flex Container ──
        h["flex-direction"] = { v, y in
            if let d = parseFlexDirection(v) { y.flexDirection = d }
        }
        h["flex-wrap"] = { v, y in
            if let w = parseFlexWrap(v) { y.flexWrap = w }
        }
        h["justify-content"] = { v, y in
            if let j = parseJustifyContent(v) { y.justifyContent = j }
        }
        h["align-items"] = { v, y in
            if let a = parseAlign(v) { y.alignItems = a }
        }
        h["align-self"] = { v, y in
            if let a = parseAlign(v) { y.alignSelf = a }
        }
        h["align-content"] = { v, y in
            if let a = parseAlign(v) { y.alignContent = a }
        }

        // ── Flex Item ──
        h["flex-grow"] = { v, y in
            if let n = Float(v.trimmingCharacters(in: .whitespaces)) { y.flexGrow = n }
        }
        h["flex-shrink"] = { v, y in
            if let n = Float(v.trimmingCharacters(in: .whitespaces)) { y.flexShrink = n }
        }
        h["flex-basis"] = { v, y in
            if let l = parseLength(v) { y.flexBasis = l }
        }
        h["flex"] = { v, y in applyFlexShorthand(v, y) }

        // ── Margin ──
        h["margin"] = { v, y in applyEdgeShorthand(v, y, setter: { y.setMargin($0, $1) }) }
        h["margin-top"] = { v, y in if let l = parseLength(v) { y.setMargin(.top, l) } }
        h["margin-bottom"] = { v, y in if let l = parseLength(v) { y.setMargin(.bottom, l) } }
        h["margin-left"] = { v, y in if let l = parseLength(v) { y.setMargin(.left, l) } }
        h["margin-right"] = { v, y in if let l = parseLength(v) { y.setMargin(.right, l) } }

        // ── Padding ──
        h["padding"] = { v, y in applyEdgeShorthand(v, y, setter: { y.setPadding($0, $1) }) }
        h["padding-top"] = { v, y in if let l = parseLength(v) { y.setPadding(.top, l) } }
        h["padding-bottom"] = { v, y in if let l = parseLength(v) { y.setPadding(.bottom, l) } }
        h["padding-left"] = { v, y in if let l = parseLength(v) { y.setPadding(.left, l) } }
        h["padding-right"] = { v, y in if let l = parseLength(v) { y.setPadding(.right, l) } }

        // ── Border ──
        h["border-width"] = { v, y in if let l = parseFloat(v) { y.setBorder(.all, l) } }
        h["border-top-width"] = { v, y in if let l = parseFloat(v) { y.setBorder(.top, l) } }
        h["border-bottom-width"] = { v, y in if let l = parseFloat(v) { y.setBorder(.bottom, l) } }
        h["border-left-width"] = { v, y in if let l = parseFloat(v) { y.setBorder(.left, l) } }
        h["border-right-width"] = { v, y in if let l = parseFloat(v) { y.setBorder(.right, l) } }
        h["border"] = { v, y in applyBorderShorthand(v, y) }

        // ── Position ──
        h["position"] = { v, y in
            if let p = parsePositionType(v) { y.positionType = p }
        }
        h["top"] = { v, y in if let l = parseLength(v) { y.setPosition(.top, l) } }
        h["right"] = { v, y in if let l = parseLength(v) { y.setPosition(.right, l) } }
        h["bottom"] = { v, y in if let l = parseLength(v) { y.setPosition(.bottom, l) } }
        h["left"] = { v, y in if let l = parseLength(v) { y.setPosition(.left, l) } }

        // ── Display & Overflow ──
        h["display"] = { v, y in
            if let d = parseDisplay(v) { y.display = d }
        }
        h["overflow"] = { v, y in
            if let o = parseOverflow(v) { y.overflow = o }
        }
        h["overflow-x"] = { v, y in
            if let o = parseOverflow(v) { y.overflow = o }
        }
        h["overflow-y"] = { v, y in
            if let o = parseOverflow(v) { y.overflow = o }
        }

        // ── Gap ──
        h["gap"] = { v, y in
            let parts = parseSpaceSeparated(v)
            if let g = parseLength(parts[0]) {
                y.rowGap = g
                y.columnGap = g
            }
        }
        h["row-gap"] = { v, y in if let l = parseLength(v) { y.rowGap = l } }
        h["column-gap"] = { v, y in if let l = parseLength(v) { y.columnGap = l } }

        // ── Box Sizing ──
        h["box-sizing"] = { v, y in
            switch v.lowercased() {
            case "border-box": y.boxSizing = .borderBox
            case "content-box": y.boxSizing = .contentBox
            default: break
            }
        }

        // ── Aspect Ratio ──
        h["aspect-ratio"] = { v, y in
            if let n = Float(v.trimmingCharacters(in: .whitespaces)) { y.aspectRatio = n }
        }

        // ── Visual (UIKit/AppKit) ──
        #if os(iOS)
        h["background-color"] = { v, y in
            guard let view = y.view as? UIView else { return }
            if let color = parseColor(v) { view.backgroundColor = color }
        }
        h["border-radius"] = { v, y in
            guard let view = y.view as? UIView else { return }
            if let n = parseFloat(v) { view.layer.cornerRadius = CGFloat(n) }
        }
        h["opacity"] = { v, y in
            guard let view = y.view as? UIView else { return }
            if let n = parseFloat(v) { view.alpha = CGFloat(n) }
        }
        h["border-color"] = { v, y in
            guard let view = y.view as? UIView else { return }
            if let color = parseColor(v) { view.layer.borderColor = color.cgColor }
        }
        #endif

        // ── Grid ──
        h["grid-template-columns"] = { v, y in
            if let list = parseTrackList(v) { y.gridTemplateColumns = list }
        }
        h["grid-template-rows"] = { v, y in
            if let list = parseTrackList(v) { y.gridTemplateRows = list }
        }
        h["grid-auto-columns"] = { v, y in
            if let list = parseTrackList(v) { y.gridAutoColumns = list }
        }
        h["grid-auto-rows"] = { v, y in
            if let list = parseTrackList(v) { y.gridAutoRows = list }
        }
        h["grid-column-start"] = { v, y in
            if let line = parseGridLine(v) { y.gridColumnStart = line }
        }
        h["grid-column-end"] = { v, y in
            if let line = parseGridLine(v) { y.gridColumnEnd = line }
        }
        h["grid-row-start"] = { v, y in
            if let line = parseGridLine(v) { y.gridRowStart = line }
        }
        h["grid-row-end"] = { v, y in
            if let line = parseGridLine(v) { y.gridRowEnd = line }
        }

        return h
    }()

    // MARK: - Flex Shorthand

    private static func applyFlexShorthand(_ value: String, _ yoga: YogaProperties) {
        let parts = value.trimmingCharacters(in: .whitespaces).split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard !parts.isEmpty else { return }

        let lower = value.lowercased().trimmingCharacters(in: .whitespaces)
        if lower == "none" {
            yoga.flexGrow = 0
            yoga.flexShrink = 0
            yoga.flexBasis = GWValue.auto
            return
        }
        if lower == "auto" {
            yoga.flexGrow = 1
            yoga.flexShrink = 1
            yoga.flexBasis = GWValue.auto
            return
        }
        if lower == "initial" {
            yoga.flexGrow = 0
            yoga.flexShrink = 1
            yoga.flexBasis = GWValue.auto
            return
        }

        // flex: <grow> <shrink> <basis>
        if parts.count >= 1, let grow = Float(parts[0]) {
            yoga.flexGrow = grow
        }
        if parts.count >= 2, let shrink = Float(parts[1]) {
            yoga.flexShrink = shrink
        } else if parts.count >= 1 {
            yoga.flexShrink = 1
        }
        if parts.count >= 3, let basis = parseLength(parts[2]) {
            yoga.flexBasis = basis
        } else if parts.count >= 1 {
            yoga.flexBasis = GWValue.points(0)
        }
    }

    // MARK: - Edge Shorthand (margin / padding)

    private static func applyEdgeShorthand(_ value: String, _ yoga: YogaProperties,
                                            setter: (GWEdge, GWValue) -> Void) {
        let parts = value.trimmingCharacters(in: .whitespaces).split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard !parts.isEmpty else { return }

        let lengths = parts.compactMap(parseLength)
        guard lengths.count == parts.count else { return }

        switch lengths.count {
        case 1:
            let v = lengths[0]
            for edge: GWEdge in [.top, .right, .bottom, .left] { setter(edge, v) }
        case 2:
            setter(.top, lengths[0]); setter(.bottom, lengths[0])
            setter(.left, lengths[1]); setter(.right, lengths[1])
        case 3:
            setter(.top, lengths[0])
            setter(.left, lengths[1]); setter(.right, lengths[1])
            setter(.bottom, lengths[2])
        case 4:
            setter(.top, lengths[0])
            setter(.right, lengths[1])
            setter(.bottom, lengths[2])
            setter(.left, lengths[3])
        default:
            break
        }
    }

    // MARK: - Border Shorthand

    private static func applyBorderShorthand(_ value: String, _ yoga: YogaProperties) {
        // Parse "1px solid #fff" or "1px" — extract the width part
        let parts = value.trimmingCharacters(in: .whitespaces).split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        for part in parts {
            if let w = parseFloat(part) {
                yoga.setBorder(GWEdge.all, w)
                return
            }
            // Check for CSS color (after width and style)
            if parseColor(part) != nil {
                #if os(iOS)
                if let view = yoga.view as? UIView, let color = parseColor(part) {
                    view.layer.borderColor = color.cgColor
                }
                #endif
            }
        }
    }

    // MARK: - Value Parsing

    public static func parseLength(_ value: String) -> GWValue? {
        let v = value.trimmingCharacters(in: .whitespaces).lowercased()
        if v == "auto" { return .auto }
        if v == "0" { return .points(0) }
        if v == "min-content" || v == "min_content" { return .maxContent() }
        if v == "max-content" || v == "max_content" { return .maxContent() }
        if v == "fit-content" || v == "fit_content" { return .fitContent() }

        if v.hasSuffix("fr") {
            let numStr = String(v.dropLast(2)).trimmingCharacters(in: .whitespaces)
            if let num = Float(numStr) {
                return GWValue(value: num, unit: .stretch)
            }
            return nil
        }

        if v.hasSuffix("%") {
            let numStr = String(v.dropLast()).trimmingCharacters(in: .whitespaces)
            if let num = Float(numStr) { return .percent(num) }
            return nil
        }

        if v.hasSuffix("px") || v.hasSuffix("pt") {
            let suffix = v.hasSuffix("px") ? "px" : "pt"
            let numStr = String(v.dropLast(suffix.count)).trimmingCharacters(in: .whitespaces)
            if let num = Float(numStr) { return .points(num) }
            return nil
        }

        if let num = Float(v) { return .points(num) }
        return nil
    }

    public static func parseFloat(_ value: String) -> Float? {
        let v = value.trimmingCharacters(in: .whitespaces).lowercased()
        if v.hasSuffix("px") { return Float(String(v.dropLast(2))) }
        if v.hasSuffix("pt") { return Float(String(v.dropLast(2))) }
        return Float(v)
    }

    #if os(iOS)
    public static func parseColor(_ value: String) -> UIColor? {
        let v = value.trimmingCharacters(in: .whitespaces).lowercased()

        // Named colors (subset)
        if let named = namedColors[v] { return named }

        // Hex: #fff, #ffffff, #ffffffff
        if v.hasPrefix("#") {
            let hex = String(v.dropFirst())
            if hex.count == 3 {
                return shortHexToColor(hex)
            }
            if hex.count == 6 {
                return hexToColor(hex)
            }
            if hex.count == 8 {
                return hexToColor(String(hex.dropLast(2)), alpha: hexToAlpha(hex))
            }
        }

        // rgb() / rgba()
        if v.hasPrefix("rgba(") || v.hasPrefix("rgb(") {
            return parseRGB(v)
        }

        return nil
    }
    #else
    /// On non-iOS platforms, color parsing is a stub that validates format only.
    public static func parseColor(_ value: String) -> Any? {
        // Basic format validation without UIKit
        let v = value.trimmingCharacters(in: .whitespaces).lowercased()
        if v.hasPrefix("#") {
            let hex = String(v.dropFirst())
            if hex.count == 3 || hex.count == 6 || hex.count == 8 {
                return true // valid hex format
            }
        }
        if v.hasPrefix("rgba") || v.hasPrefix("rgb") {
            return true
        }
        if ["red","green","blue","black","white","gray","clear","transparent",
            "yellow","orange","purple","brown","cyan","magenta","pink"].contains(v) {
            return true
        }
        return nil
    }
    #endif

    // MARK: - Keyword Parsing

    public static func parseFlexDirection(_ value: String) -> GWFlexDirection? {
        switch value.lowercased() {
        case "row": return .row
        case "row-reverse", "row_reverse": return .rowReverse
        case "column": return .column
        case "column-reverse", "column_reverse": return .columnReverse
        default: return nil
        }
    }

    public static func parseFlexWrap(_ value: String) -> GWWrap? {
        switch value.lowercased() {
        case "nowrap", "no-wrap": return .noWrap
        case "wrap": return .wrap
        case "wrap-reverse", "wrap_reverse": return .wrapReverse
        default: return nil
        }
    }

    public static func parseJustifyContent(_ value: String) -> GWJustify? {
        switch value.lowercased() {
        case "flex-start", "start": return .flexStart
        case "center": return .center
        case "flex-end", "end": return .flexEnd
        case "space-between": return .spaceBetween
        case "space-around": return .spaceAround
        case "space-evenly": return .spaceEvenly
        case "stretch": return .stretch
        default: return nil
        }
    }

    public static func parseAlign(_ value: String) -> GWAlign? {
        switch value.lowercased() {
        case "auto": return .auto
        case "flex-start", "start": return .flexStart
        case "center": return .center
        case "flex-end", "end": return .flexEnd
        case "stretch": return .stretch
        case "baseline": return .baseline
        case "space-between": return .spaceBetween
        case "space-around": return .spaceAround
        case "space-evenly": return .spaceEvenly
        default: return nil
        }
    }

    public static func parsePositionType(_ value: String) -> GWPositionType? {
        switch value.lowercased() {
        case "static", "relative": return .relative
        case "absolute": return .absolute
        default: return nil
        }
    }

    public static func parseDisplay(_ value: String) -> GWDisplay? {
        switch value.lowercased() {
        case "flex": return .flex
        case "none": return GWDisplay.none
        case "contents": return .contents
        case "grid": return .grid
        default: return nil
        }
    }

    public static func parseOverflow(_ value: String) -> GWOverflow? {
        switch value.lowercased() {
        case "visible": return .visible
        case "hidden": return .hidden
        case "scroll": return .scroll
        default: return nil
        }
    }

    public static func parseTrackList(_ value: String) -> GWGridTrackList? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        var tracks: [GWGridTrackSize] = []
        let parts = splitTrackValues(trimmed)
        for part in parts {
            if let track = parseSingleTrack(part) {
                tracks.append(track)
            } else {
                return nil
            }
        }
        guard !tracks.isEmpty else { return nil }
        return tracks
    }

    public static func parseGridLine(_ value: String) -> GWGridLine? {
        let v = value.trimmingCharacters(in: .whitespaces).lowercased()
        if v == "auto" { return .auto }
        if let n = Int(v) { return GWGridLine(type: .integer, value: Int32(n)) }
        return nil
    }

    // MARK: - Private Parsing Helpers

    private static func parseNumber(_ value: String) -> Float? {
        let v = value.trimmingCharacters(in: .whitespaces)
        guard !v.isEmpty else { return nil }
        return Float(v)
    }

    private static func parseSpaceSeparated(_ value: String) -> [String] {
        value.trimmingCharacters(in: .whitespaces)
            .split(separator: " ", omittingEmptySubsequences: true)
            .map(String.init)
    }

    private static func splitTrackValues(_ value: String) -> [String] {
        var parts: [String] = []
        var current = ""
        var parenDepth = 0
        for c in value {
            if c == "(" { parenDepth += 1; current.append(c) }
            else if c == ")" { parenDepth -= 1; current.append(c) }
            else if c == " " && parenDepth == 0 {
                if !current.isEmpty {
                    parts.append(current)
                    current = ""
                }
            } else {
                current.append(c)
            }
        }
        if !current.isEmpty { parts.append(current) }
        return parts
    }

    private static func parseSingleTrack(_ value: String) -> GWGridTrackSize? {
        let v = value.trimmingCharacters(in: .whitespaces).lowercased()

        if v.hasPrefix("minmax(") {
            let inner = String(v.dropFirst(7).dropLast())
            let parts = inner.split(separator: ",", omittingEmptySubsequences: true).map { String($0).trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { return nil }
            guard let min = parseStyleSizeLength(parts[0]), let max = parseStyleSizeLength(parts[1]) else { return nil }
            return .minmax(min: min, max: max)
        }

        // fr unit → flex track
        if v.hasSuffix("fr") {
            let numStr = String(v.dropLast(2)).trimmingCharacters(in: .whitespaces)
            if let num = Float(numStr) { return .fr(num) }
        }

        // Points
        if v.hasSuffix("px") || v.hasSuffix("pt") {
            let suffix = v.hasSuffix("px") ? "px" : "pt"
            let numStr = String(v.dropLast(suffix.count)).trimmingCharacters(in: .whitespaces)
            if let num = Float(numStr) { return .points(num) }
        }

        // Percent
        if v.hasSuffix("%") {
            let numStr = String(v.dropLast()).trimmingCharacters(in: .whitespaces)
            if let num = Float(numStr) { return .percent(num) }
        }

        // Keywords
        if v == "auto" { return .auto() }

        // Plain number → points
        if let num = Float(v) { return .points(num) }

        return nil
    }

    private static func parseStyleSizeLength(_ value: String) -> GWStyleSizeLength? {
        let v = value.trimmingCharacters(in: .whitespaces).lowercased()
        if v == "auto" { return .auto }
        if v == "min-content" || v == "min_content" { return .maxContent }
        if v == "max-content" || v == "max_content" { return .maxContent }
        if v == "fit-content" || v == "fit_content" { return .fitContent }

        if v.hasSuffix("fr") {
            let numStr = String(v.dropLast(2)).trimmingCharacters(in: .whitespaces)
            if let num = Float(numStr) { return .stretch(num) }
            return nil
        }

        if v.hasSuffix("%") {
            let numStr = String(v.dropLast()).trimmingCharacters(in: .whitespaces)
            if let num = Float(numStr) { return .percent(num) }
            return nil
        }

        if v.hasSuffix("px") || v.hasSuffix("pt") {
            let suffix = v.hasSuffix("px") ? "px" : "pt"
            let numStr = String(v.dropLast(suffix.count)).trimmingCharacters(in: .whitespaces)
            if let num = Float(numStr) { return .points(num) }
            return nil
        }

        if let num = Float(v) { return .points(num) }
        return nil
    }

    // MARK: - Color Parsing Internals

    #if os(iOS)
    private static func shortHexToColor(_ hex: String) -> UIColor? {
        guard hex.count == 3 else { return nil }
        let chars = Array(hex)
        let rHex = String(repeating: chars[0], count: 2)
        let gHex = String(repeating: chars[1], count: 2)
        let bHex = String(repeating: chars[2], count: 2)
        var rgb: UInt64 = 0
        guard Scanner(string: rHex + gHex + bHex).scanHexInt64(&rgb) else { return nil }
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    private static func hexToColor(_ hex: String) -> UIColor? {
        guard hex.count == 6 else { return nil }
        var rgb: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgb) else { return nil }
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    private static func hexToColor(_ hex: String, alpha: CGFloat) -> UIColor? {
        guard hex.count == 6 else { return nil }
        var rgb: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgb) else { return nil }
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

    private static func hexToAlpha(_ hex: String) -> CGFloat {
        guard hex.count == 8 else { return 1 }
        let alphaHex = String(hex.suffix(2))
        var alpha: UInt64 = 0
        Scanner(string: alphaHex).scanHexInt64(&alpha)
        return CGFloat(alpha) / 255.0
    }

    private static func parseRGB(_ value: String) -> UIColor? {
        // rgba(r, g, b, a) or rgb(r, g, b)
        let inner: String
        if value.hasPrefix("rgba(") {
            inner = String(value.dropFirst(5).dropLast())
        } else {
            inner = String(value.dropFirst(4).dropLast())
        }
        let parts = inner.split(separator: ",", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count >= 3 else { return nil }
        guard let r = Float(parts[0]), let g = Float(parts[1]), let b = Float(parts[2]) else { return nil }
        let a: Float = parts.count >= 4 ? Float(parts[3]) ?? 1 : 1
        return UIColor(red: CGFloat(r/255), green: CGFloat(g/255), blue: CGFloat(b/255), alpha: CGFloat(a))
    }

    private static let namedColors: [String: UIColor] = {
        [
            "red": .red, "green": .green, "blue": .blue,
            "black": .black, "white": .white, "gray": .gray,
            "darkgray": .darkGray, "lightgray": .lightGray,
            "clear": .clear, "transparent": .clear,
            "yellow": .yellow, "orange": .orange, "purple": .purple,
            "brown": .brown, "cyan": .cyan, "magenta": .magenta,
            "pink": UIColor(red: 1, green: 0.75, blue: 0.8, alpha: 1),
        ]
    }()
    #endif
}
