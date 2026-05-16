> [English](README.md) | [中文](README.zh-Hans.md)

# GWYoga

A pure Swift reimplementation of Meta's [Yoga](https://yogalayout.com) flexbox/grid layout engine with a comprehensive UIKit integration layer. No C/C++ dependency — built entirely with Swift value types.

![Platform](https://img.shields.io/badge/platform-iOS%2013%2B%20%7C%20macOS%2010.15%2B%20%7C%20tvOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/swift-5.6%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Features

- **Pure Swift Yoga engine** — Full flexbox/grid layout algorithm, no C/C++ dependency
- **UIView integration** — `view.style` property for all Yoga attributes, no Auto Layout needed
- **Declarative DSL** — VStack, HStack, ZStack with resultBuilder syntax
- **CSS stylesheets** — Parse and apply CSS to views at runtime
- **HTML tag DSL** — Write layout with `div`, `h1`, `section` and other HTML tags
- **Animations** — Layout animation, transitions, spring, and keyframe support
- **Data binding** — YogaState, YogaBinding, and Combine integration
- **Visual styles** — Corner radius, shadow, border, opacity, gradients, background images
- **Rich text** — Attributed text with automatic content sizing
- **Layout cache** — Pre-layout measurement and caching for performance
- **Debug tools** — Layout tree printing, debug borders, system layout size calculation
- **Complete ObjC bridge** — All modules available from Objective-C
- **59 Swift + 25 ObjC demo pages** — Every API has a dedicated, runnable demo

## Modules

| Module | Description | Platforms |
|--------|-------------|-----------|
| GWYoga | Core flexbox/grid layout engine | iOS, macOS, tvOS, watchOS |
| GWYogaKit | UIKit integration (YogaLayoutView, UIView extensions) | iOS, macOS, tvOS |
| GWYogaKitObjCCore | Objective-C bridge for GWYogaKit | iOS, macOS, tvOS |
| GWYogaKitAnimation | Layout animation & transition support | iOS, tvOS |
| GWYogaKitAnimationObjCCore | ObjC bridge for Animation | iOS, tvOS |
| GWYogaKitLayoutCache | Pre-layout measurement & caching | iOS, macOS, tvOS |
| GWYogaKitLayoutCacheObjCCore | ObjC bridge for LayoutCache | iOS, macOS, tvOS |
| GWYogaKitDSL | Declarative DSL (VStack, HStack, ZStack) | iOS, macOS, tvOS |
| GWYogaKitDSLObjCCore | ObjC bridge for DSL | iOS, macOS, tvOS |
| GWYogaKitStylesheet | CSS stylesheet parsing & application | iOS, macOS, tvOS |
| GWYogaKitStylesheetObjCCore | ObjC bridge for Stylesheet | iOS, macOS, tvOS |
| GWYogaKitHTML | HTML-style tag DSL (div, section, h1, etc.) | iOS, tvOS |
| GWYogaKitHTMLObjCCore | ObjC bridge for HTML | iOS, tvOS |

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.6+
- Xcode 14.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ltovem/GWYoga.git", from: "1.0.0")
]
```

Add modules as needed:

```swift
.target(
    dependencies: [
        "GWYoga",                       // Core engine
        "GWYogaKit",                    // UIKit integration
        "GWYogaKitDSL",                 // Declarative DSL (optional)
        "GWYogaKitStylesheet",          // CSS stylesheets (optional)
        "GWYogaKitObjCCore",            // ObjC bridge (optional)
    ]
)
```

### CocoaPods

```ruby
pod 'GWYoga', '~> 1.0'
pod 'GWYogaKit', '~> 1.0'
pod 'GWYogaKitDSL', '~> 1.0'
pod 'GWYogaKitAnimation', '~> 1.0'
pod 'GWYogaKitStylesheet', '~> 1.0'
pod 'GWYogaKitHTML', '~> 1.0'
pod 'GWYogaKitLayoutCache', '~> 1.0'
```

### Xcode Project

Open `Demo.xcworkspace` to explore the demo apps for both Swift and Objective-C.

## Quick Start

### Swift — UIKit Integration

```swift
import GWYogaKit

let container = YogaLayoutView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
container.style.flexDirection = .row
container.style.justifyContent = .spaceEvenly
container.style.alignItems = .center

let child = UIView()
child.style.width = 80
child.style.height = 80
child.style.backgroundColor = .systemBlue
child.style.cornerRadius = 8

container.addSubview(child)
container.performYogaLayout()
```

### Swift — Chained API

```swift
view.style
    .width(100).height(100)
    .flexDirection(.row)
    .justifyContent(.center)
    .alignItems(.center)
    .margin(.all, 16)
    .padding(.horizontal, 12)
    .cornerRadius(8)
    .shadow(color: .black, opacity: 0.3, radius: 4, offset: CGSize(width: 0, height: 2))
    .backgroundColor(.systemBackground)
```

### Objective-C

```objc
@import GWYogaKitObjCCore;

YGKLayoutView *container = [[YGKLayoutView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
container.gwstyle.flexDirection = YGKFlexDirectionRow;
container.gwstyle.justifyContent = YGKJustifySpaceEvenly;
container.gwstyle.alignItems = YGKAlignCenter;

UIView *child = [[UIView alloc] init];
child.gwstyle.width = 80;
child.gwstyle.height = 80;
child.gwstyle.backgroundColor = [UIColor systemBlueColor];
child.gwstyle.cornerRadius = 8;

[container addSubview:child];
[container performYogaLayout];
```

### CSS Inline Style

```swift
view.style.css("width: 100px; height: 100px; margin: 8px; padding: 12px; border-radius: 8px;")
```

### DSL (Declarative Layout)

```swift
import GWYogaKitDSL

YGKVStack(spacing: 8, padding: 16) {
    YGKText("Hello, GWYoga!")
        .font(.boldSystemFont(ofSize: 18))
        .margin(.bottom, 4)

    YGKButton(title: "Tap me") {
        print("tapped!")
    }

    YGKImage(someUIImage)
        .width(100).height(100)
        .cornerRadius(8)
}
```

## Documentation

- **[API Reference](API_REFERENCE.md)** — Complete API documentation
- **[AI Guide](GWYogaKit_GUIDE.md)** — Quick reference for developers and AI coding agents
- **[Demo Apps](Demo.xcworkspace)** — 59 Swift + 25 ObjC runnable demo pages

## Architecture

```
GWYoga/
├── GWYoga/                  # Core layout engine (pure Swift)
│   ├── GWYogaNode.swift     # Node class
│   ├── GWStyle.swift        # Flexbox/grid style property bag
│   ├── GWTypes.swift        # GWValue, units, type system
│   └── GWYoga+Layout.swift  # Layout algorithm
├── GWYogaKit/               # UIKit integration
│   ├── Core/                # YogaLayoutView, UIView extensions
│   │   ├── Swift/           # Swift API
│   │   └── ObjC/            # Objective-C bridge
│   ├── Animation/           # Animation & transitions
│   ├── LayoutCache/         # Pre-layout measurement
│   ├── DSL/                 # Declarative DSL
│   ├── Stylesheet/          # CSS parsing & application
│   └── HTML/                # HTML tag DSL
├── GWYogaDemoApp/           # Swift demo app (59 pages)
├── GWYogaDemoAppObjC/       # ObjC demo app (25 pages)
└── Package.swift            # SPM manifest
```

## License

GWYoga is available under the MIT license. See the [LICENSE](LICENSE) file for more information.
