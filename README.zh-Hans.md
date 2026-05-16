> [English](README.md) | [中文](README.zh-Hans.md)

# GWYoga

基于 Swift 纯重写的 Meta [Yoga](https://yogalayout.com) flexbox/grid 布局引擎，提供完整的 UIKit 集成层。完全使用 Swift 值类型构建，无 C/C++ 依赖。

![Platform](https://img.shields.io/badge/platform-iOS%2013%2B%20%7C%20macOS%2010.15%2B%20%7C%20tvOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/swift-5.6%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## 特性

- **纯 Swift Yoga 引擎** — 完整的 flexbox/grid 布局算法，无 C/C++ 依赖
- **UIView 集成** — 通过 `view.style` 属性访问所有 Yoga 属性，无需 Auto Layout
- **声明式 DSL** — VStack、HStack、ZStack，支持 resultBuilder
- **CSS 样式表** — 运行时解析和应用 CSS 样式
- **HTML 标签 DSL** — 使用 `div`、`h1`、`section` 等 HTML 标签构建布局
- **动画** — 布局动画、过渡、弹簧动画和关键帧动画
- **数据绑定** — YogaState、YogaBinding 和 Combine 集成
- **视觉样式** — 圆角、阴影、边框、透明度、渐变、背景图
- **富文本** — 支持 attributedText，自动内容尺寸
- **布局缓存** — 预测量与缓存优化
- **调试工具** — 布局树打印、调试边框、systemLayoutSize
- **完整 ObjC 桥接** — 所有模块均支持 Objective-C
- **59 个 Swift + 25 个 ObjC 示例页面** — 每个 API 都有独立可运行的示例

## 模块

| 模块 | 说明 | 平台 |
|------|------|------|
| GWYoga | 核心 flexbox/grid 布局引擎 | iOS, macOS, tvOS, watchOS |
| GWYogaKit | UIKit 集成（YogaLayoutView, UIView 扩展） | iOS, macOS, tvOS |
| GWYogaKitObjCCore | Objective-C 桥接层 | iOS, macOS, tvOS |
| GWYogaKitAnimation | 布局动画与过渡 | iOS, tvOS |
| GWYogaKitAnimationObjCCore | 动画模块 ObjC 桥接 | iOS, tvOS |
| GWYogaKitLayoutCache | 预测量与缓存 | iOS, macOS, tvOS |
| GWYogaKitLayoutCacheObjCCore | 预测量 ObjC 桥接 | iOS, macOS, tvOS |
| GWYogaKitDSL | 声明式 DSL（VStack, HStack, ZStack） | iOS, macOS, tvOS |
| GWYogaKitDSLObjCCore | DSL ObjC 桥接 | iOS, macOS, tvOS |
| GWYogaKitStylesheet | CSS 样式表解析与应用 | iOS, macOS, tvOS |
| GWYogaKitStylesheetObjCCore | CSS ObjC 桥接 | iOS, macOS, tvOS |
| GWYogaKitHTML | HTML 标签 DSL（div, section, h1 等） | iOS, tvOS |
| GWYogaKitHTMLObjCCore | HTML ObjC 桥接 | iOS, tvOS |

## 系统要求

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.6+
- Xcode 14.0+

## 安装

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ltovem/GWYoga.git", from: "1.0.0")
]
```

按需引入模块：

```swift
.target(
    dependencies: [
        "GWYoga",                       // 核心引擎
        "GWYogaKit",                    // UIKit 集成
        "GWYogaKitDSL",                 // 声明式 DSL（可选）
        "GWYogaKitStylesheet",          // CSS 样式表（可选）
        "GWYogaKitObjCCore",            // ObjC 桥接（可选）
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

### Xcode 项目

打开 `Demo.xcworkspace` 即可运行 Swift 和 ObjC 两个示例 App。

## 快速开始

### Swift — UIKit 集成

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

### Swift — 链式 API

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

### CSS 内联样式

```swift
view.style.css("width: 100px; height: 100px; margin: 8px; padding: 12px; border-radius: 8px;")
```

### DSL 声明式布局

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

## 文档

- **[API 参考](API_REFERENCE.md)** — 完整 API 文档
- **[AI 指南](GWYogaKit_GUIDE.md)** — 面向开发者和 AI 的快速参考
- **[示例 App](Demo.xcworkspace)** — 59 个 Swift + 25 个 ObjC 示例页面

## 架构

```
GWYoga/
├── GWYoga/                  # 核心布局引擎（纯 Swift）
│   ├── GWYogaNode.swift     # 节点类
│   ├── GWStyle.swift        # Flexbox/grid 样式属性
│   ├── GWTypes.swift        # GWValue、单位、类型系统
│   └── GWYoga+Layout.swift  # 布局算法
├── GWYogaKit/               # UIKit 集成
│   ├── Core/                # YogaLayoutView、UIView 扩展
│   │   ├── Swift/           # Swift API
│   │   └── ObjC/            # Objective-C 桥接
│   ├── Animation/           # 动画与过渡
│   ├── LayoutCache/         # 预测量
│   ├── DSL/                 # 声明式 DSL
│   ├── Stylesheet/          # CSS 解析与应用
│   └── HTML/                # HTML 标签 DSL
├── GWYogaDemoApp/           # Swift 示例 App（59 页面）
├── GWYogaDemoAppObjC/       # ObjC 示例 App（25 页面）
└── Package.swift            # SPM manifest
```

## 许可证

GWYoga 基于 MIT 许可证开源。更多信息请查看 [LICENSE](LICENSE) 文件。
