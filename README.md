> [English](README.md) | [中文](README.zh-Hans.md)

# GWYoga

A Swift wrapper around Meta's [Yoga](https://yogalayout.com) flexbox/grid layout engine with a complete UIKit integration layer. Write layout in **chained API**, **closure blocks**, or **inline CSS** — all backed by Yoga's battle-tested C++ layout engine.

![Platform](https://img.shields.io/badge/platform-iOS%2013%2B%20%7C%20macOS%2010.15%2B%20%7C%20tvOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/swift-5.6%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)

---

## Features

- **Three writing styles** — Chainable DSL, closure configuration, and CSS string — same Yoga engine, your choice of syntax.
- **Flexbox & Grid** — Full flexbox algorithm (11-step) and CSS Grid layout, both backed by Yoga C++.
- **UIKit integration** — `view.style` property on any UIView, no Auto Layout required.
- **Visual styles** — Corner radius (per-corner), shadow, border, gradient, background image, opacity.
- **Data binding** — `@YogaState` + `YogaBinding` for reactive layout updates.
- **Auto-mark-dirty** — UILabel/UIButton text changes automatically trigger Yoga re-layout.
- **Animation** — Layout animation with spring, keyframe, and transition support.
- **CSS stylesheet** — Parse and apply CSS at runtime; load from files.
- **Declarative DSL** — VStack, HStack, ZStack with resultBuilder syntax.
- **ObjC bridge** — All modules available from Objective-C with property-style API.
- **Debug tools** — Layout tree printing, debug borders, system layout size calculation.

---

## Modules

| Module | Description |
|--------|-------------|
| `GWYoga` | Core Yoga C++ engine with Swift bindings |
| `GWYogaKit` | UIKit integration: `UIView.style`, `YogaLayoutView`, auto-mark-dirty |
| `GWYogaKitObjCCore` | Objective-C property-style bridge |
| `GWYogaKitAnimation` | Layout animation & transitions |
| `GWYogaKitDSL` | VStack / HStack / ZStack resultBuilder DSL |
| `GWYogaKitStylesheet` | CSS stylesheet parsing & application |
| `GWYogaKitHTML` | HTML-style tag DSL (`div`, `h1`, `section`, etc.) |
| `GWYogaKitLayoutCache` | Pre-layout measurement & caching |

---

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+
- Swift 5.6+
- Xcode 14.0+

---

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(path: "path/to/GWYoga")
]
```

Add modules as needed:

```swift
.target(
    dependencies: [
        "GWYoga",
        "GWYogaKit",
        "GWYogaKitDSL",        // optional
        "GWYogaKitStylesheet", // optional
        "GWYogaKitObjCCore",   // optional, for ObjC
    ]
)
```

---

## Quick Start

### Swift — Chained API (链式)

Chain method calls directly on `.style`:

```swift
import GWYogaKit

let container = UIView()
container.style
    .flexDirection(.row)
    .justifyContent(.center)
    .alignItems(.center)
    .padding(.all, 16)
    .backgroundColor(.systemGray6)

for i in 1...4 {
    let child = UILabel()
    child.text = "\(i)"
    child.style
        .width(60).height(60)
        .margin(.all, 8)
        .backgroundColor(.systemBlue)
        .cornerRadius(8)
    container.addSubview(child)
}

// Trigger layout
container.performYogaLayout()
```

### Swift — Closure API (闭包)

Configure with a closure block:

```swift
import GWYogaKit

let container = UIView()
container.style {
    $0.flexDirection = .row
    $0.justifyContent = .center
    $0.alignItems = .center
    $0.padding = [.all: 16]
}

for color in [UIColor.systemRed, .systemGreen, .systemBlue, .systemOrange] {
    let child = UIView()
    child.style {
        $0.width = 60
        $0.height = 60
        $0.margin = [.all: 8]
        $0.backgroundColor = color
        $0.cornerRadius = 8
    }
    container.addSubview(child)
}

container.performYogaLayout()
```

### Swift — Inline CSS (CSS)

Write CSS strings directly:

```swift
import GWYogaKit

let container = UIView()
container.style.css("""
    flex-direction: row;
    justify-content: center;
    align-items: center;
    padding: 16px;
    background-color: #f0f0f0;
""")

for i in 1...4 {
    let child = UIView()
    child.style.css("width: 60; height: 60; margin: 8px; border-radius: 8px; background-color: #007AFF;")
    container.addSubview(child)
}

container.performYogaLayout()
```

---

## Objective-C

### Property Style (属性)

```objc
@import GWYogaKitObjCCore;

YGKLayoutView *container = [[YGKLayoutView alloc] init];
container.gwstyle.flexDirection = YGKFlexDirectionRow;
container.gwstyle.justifyContent = YGKJustifyCenter;
container.gwstyle.alignItems = YGKAlignCenter;
container.gwstyle.padding = 16;

for (NSInteger i = 1; i <= 4; i++) {
    UIView *child = [[UIView alloc] init];
    child.gwstyle.width = 60;
    child.gwstyle.height = 60;
    child.gwstyle.margin = 8;
    child.gwstyle.backgroundColor = [UIColor systemBlueColor];
    child.gwstyle.cornerRadius = 8;
    [container addSubview:child];
}

[container performYogaLayout];
```

### Block Style (Block)

```objc
@import GWYogaKitObjCCore;

YGKLayoutView *container = [[YGKLayoutView alloc] init];
[container gwstyle:^(YGKLayoutProperties *p) {
    p.flexDirection = YGKFlexDirectionRow;
    p.justifyContent = YGKJustifyCenter;
    p.alignItems = YGKAlignCenter;
    p.padding = 16;
}];

for (NSInteger i = 1; i <= 4; i++) {
    UIView *child = [[UIView alloc] init];
    [child gwstyle:^(YGKLayoutProperties *p) {
        p.width = 60;
        p.height = 60;
        p.margin = 8;
        p.backgroundColor = [UIColor systemBlueColor];
        p.cornerRadius = 8;
    }];
    [container addSubview:child];
}

[container performYogaLayout];
```

---

## Visual Styles

```swift
view.style
    .cornerRadius(12)
    .shadow(color: .black, opacity: 0.3, radius: 4, offset: CGSize(width: 0, height: 2))
    .borderWidth(1)
    .borderColor(.systemBlue)
    .opacity(0.8)

// Per-corner radius
view.style.cornerRadius([.topLeft: 12, .topRight: 12, .bottomLeft: 0, .bottomRight: 0])

// Gradient background
view.style.background(.linearGradient(
    colors: [.red, .blue],
    startPoint: CGPoint(x: 0, y: 0),
    endPoint: CGPoint(x: 1, y: 1)
))
```

## Layout Animation

```swift
view.style.animate(duration: 0.4) {
    $0.width = 200
    $0.height = 200
}

// Spring animation
view.style.animate(duration: 0.6, dampingRatio: 0.4) {
    $0.width = 80
    $0.height = 80
}
```

---

## Data Binding

```swift
class ViewModel {
    @YogaState var width: GWValue = 50%
    @YogaState var margin: CGFloat = 16
}

let vm = ViewModel()
let binding = YogaBinding()

binding.bind(vm.$width) { [weak self] newWidth in
    self?.subView.style.width = newWidth
}
binding.bind(vm.$margin) { [weak self] newMargin in
    self?.subView.style.setMargin(.all, .points(Float(newMargin)))
}

vm.width = 100  // Auto-updates layout
```

---

## Documentation

- **[API Reference](.docs/API_REFERENCE.md)** — Complete API documentation
- **[Framework Guide](.docs/GWYogaKit_GUIDE.md)** — Detailed usage guide with code templates
- **[Demo App Plan](.docs/DEMO_APP_PLAN.md)** — Demo application architecture and implementation plan

---

## Architecture

```
GWYoga/
├── GWYoga/                  # Core Yoga C++ engine + Swift bindings
├── GWYogaKit/               # UIKit integration layer
│   ├── Core/                # YogaLayoutView, UIView+style, yoga properties
│   ├── Animation/           # Layout animation & transitions
│   ├── LayoutCache/         # Pre-layout measurement
│   ├── DSL/                 # Declarative VStack/HStack/ZStack
│   ├── Stylesheet/          # CSS parsing & application
│   └── HTML/                # HTML-style tag DSL
└── Apps/
    └── GWYogaDemoApp/       # Demo application
```

---

## License

GWYoga is available under the MIT license.
