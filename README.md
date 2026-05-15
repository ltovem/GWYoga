# GWYoga

Pure Swift reimplementation of Meta's [Yoga](https://yogalayout.com) flexbox layout engine. No C/C++ dependency — uses Swift value types and language features throughout.

## Project Structure

```
GWYoga/
├── Package.swift              # Swift Package Manager manifest
├── GWYoga/                    # Core layout engine
│   ├── GWEnums.swift          # All enums
│   ├── GWStyle.swift          # CSS flexbox style property bag
│   ├── GWTypes.swift          # GWValue, GWStyleLength, GWSize, etc.
│   ├── GWYoga+Layout.swift    # Flexbox layout algorithm
│   ├── GWYogaNode.swift       # Node class
│   └── ...
├── GWYogaKit/                 # UIKit integration
│   ├── Core/                  # Core layout view + ObjC bridge
│   │   ├── Swift/             # YogaLayoutView, UIView+yoga, etc.
│   │   └── ObjC/              # YGKLayoutView, YGKLayoutProperties, etc.
│   ├── Animation/             # Animation & transition support
│   ├── LayoutCache/           # Pre-layout measurement & caching
│   ├── DSL/                   # Declarative DSL (VStack, HStack, ZStack)
│   ├── Stylesheet/            # CSS stylesheet parsing & application
│   └── HTML/                  # HTML-style tag DSL (div, section, h1, etc.)
├── GWYogaTests/               # Core engine tests
├── GWYogaKitStylesheetTests/  # Stylesheet tests
├── GWYogaAPIDemo/             # API usage demos
├── GWYogaDemo/                # Visual demo app
└── *.podspec                  # CocoaPods specs (13 pods)
```

## Modules

| Module | Description | SPM | CocoaPods |
|--------|-------------|-----|-----------|
| GWYoga | Core flexbox layout engine | ✅ | ✅ |
| GWYogaKit | UIKit integration (YogaLayoutView, UIView extensions) | ✅ | ✅ |
| GWYogaKitObjCCore | Objective-C bridge for GWYogaKit | ✅ | ✅ |
| GWYogaKitAnimation | Animation & transition support | ✅ | ✅ |
| GWYogaKitAnimationObjCCore | ObjC bridge for Animation | ✅ | ✅ |
| GWYogaKitLayoutCache | Pre-layout measurement & caching | ✅ | ✅ |
| GWYogaKitLayoutCacheObjCCore | ObjC bridge for LayoutCache | ✅ | ✅ |
| GWYogaKitDSL | Declarative DSL (VStack, HStack, ZStack) | ✅ | ✅ |
| GWYogaKitDSLObjCCore | ObjC bridge for DSL | ✅ | ✅ |
| GWYogaKitStylesheet | CSS stylesheet support | ✅ | ✅ |
| GWYogaKitStylesheetObjCCore | ObjC bridge for Stylesheet | ✅ | ✅ |
| GWYogaKitHTML | HTML-style tag DSL | ✅ | ✅ |
| GWYogaKitHTMLObjCCore | ObjC bridge for HTML | ✅ | ✅ |

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ltovem/GWYoga.git", from: "1.0.0")
]
```

Then add whichever modules you need:

```swift
.target(
    dependencies: [
        "GWYoga",                    // Core engine
        "GWYogaKit",                 // UIKit integration
        "GWYogaKitDSL",             // Declarative DSL (optional)
        "GWYogaKitStylesheet",      // CSS stylesheets (optional)
        "GWYogaKitObjCCore",        // ObjC bridge (optional)
    ]
)
```

### CocoaPods

```ruby
pod 'GWYoga', '~> 1.0'
pod 'GWYogaKit', '~> 1.0'
pod 'GWYogaKitDSL', '~> 1.0'
pod 'GWYogaKitStylesheet', '~> 1.0'
```

## Usage Examples

### Basic Flexbox

```swift
import GWYoga

let root = GWYogaNode()
root.style.setWidth(.points(500))
root.style.setHeight(.points(500))

let child = GWYogaNode()
child.style.setWidth(.points(100))
child.style.setHeight(.points(100))
root.insertChild(child, at: 0)

root.calculateLayout(width: 500, height: 500, direction: .ltr)
print(child.layoutResult)
```

### UIKit Integration

```swift
import GWYogaKit

let view = YogaLayoutView()
view.yoga.justifyContent = .center
view.yoga.alignItems = .center

let child = UIView()
child.yoga.setWidth(.points(100))
child.yoga.setHeight(.points(100))
view.addSubview(child)

view.yoga.layout()
```

### Declarative DSL

```swift
import GWYogaKitDSL

let stack = YGKVStack(
    spacing: 8,
    padding: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
) {
    YGKText("Hello")
    YGKImage(image)
    YGKButton(title: "Tap me")
}
```

### Objective-C

```objc
@import GWYogaKitObjCCore;

YGKLayoutView *view = [[YGKLayoutView alloc] init];
view.yogaProperties.justifyContent = YGKJustifyCenter;
view.yogaProperties.alignItems = YGKAlignCenter;
```

## Test Report

All tests pass:

```sh
swift test
```

## License

MIT
