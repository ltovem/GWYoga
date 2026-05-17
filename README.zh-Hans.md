> [English](README.md) | [中文](README.zh-Hans.md)

# GWYoga

基于 Meta [Yoga](https://yogalayout.com) flexbox/grid 布局引擎的 Swift 封装层，提供完整的 UIKit 集成。支持 **链式调用**、**闭包配置**、**CSS 字符串** 三种写法，底层统一由 Yoga C++ 引擎驱动。

![Platform](https://img.shields.io/badge/platform-iOS%2013%2B%20%7C%20macOS%2010.15%2B%20%7C%20tvOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/swift-5.6%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)

---

## 特性

- **三种写法** — 链式 DSL、闭包配置、CSS 字符串，同一引擎任意选择
- **Flexbox + Grid** — 完整 flexbox 11 步算法 + CSS Grid 布局
- **UIKit 集成** — `view.style` 属性直接操作任意 UIView，无需 Auto Layout
- **视觉样式** — 圆角（逐角）、阴影、边框、渐变、背景图、透明度
- **数据绑定** — `@YogaState` + `YogaBinding` 响应式更新布局
- **自动脏标记** — UILabel/UIButton 文本变化自动触发 Yoga 重排
- **动画** — 布局动画、弹簧动画、关键帧、过渡
- **CSS 样式表** — 运行时解析 CSS，支持文件加载
- **声明式 DSL** — VStack / HStack / ZStack（resultBuilder 语法）
- **ObjC 桥接** — 所有模块支持 Objective-C 属性风格调用
- **调试工具** — 布局树打印、调试边框、systemLayoutSize

---

## 模块

| 模块 | 说明 |
|------|------|
| `GWYoga` | Yoga C++ 核心引擎 + Swift 绑定 |
| `GWYogaKit` | UIKit 集成：`UIView.style`、`YogaLayoutView`、自动脏标记 |
| `GWYogaKitObjCCore` | Objective-C 属性风格桥接 |
| `GWYogaKitAnimation` | 布局动画与过渡 |
| `GWYogaKitDSL` | VStack / HStack / ZStack 声明式 DSL |
| `GWYogaKitStylesheet` | CSS 样式表解析与应用 |
| `GWYogaKitHTML` | HTML 标签 DSL（`div`、`h1`、`section` 等） |
| `GWYogaKitLayoutCache` | 预测量与缓存 |

---

## 系统要求

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+
- Swift 5.6+
- Xcode 14.0+

---

## 安装

### Swift Package Manager

```swift
dependencies: [
    .package(path: "path/to/GWYoga")
]
```

按需引入模块：

```swift
.target(
    dependencies: [
        "GWYoga",
        "GWYogaKit",
        "GWYogaKitDSL",        // 可选
        "GWYogaKitStylesheet", // 可选
        "GWYogaKitObjCCore",   // 可选，ObjC 需要
    ]
)
```

---

## 快速开始

### 链式调用

方法链直接配置样式：

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

// 触发布局
container.performYogaLayout()
```

### 闭包配置

通过闭包批量设置样式：

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

### CSS 内联样式

直接写 CSS 字符串：

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

### 属性风格

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

### Block 风格

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

## 视觉样式

```swift
view.style
    .cornerRadius(12)
    .shadow(color: .black, opacity: 0.3, radius: 4, offset: CGSize(width: 0, height: 2))
    .borderWidth(1)
    .borderColor(.systemBlue)
    .opacity(0.8)

// 逐角圆角
view.style.cornerRadius([.topLeft: 12, .topRight: 12, .bottomLeft: 0, .bottomRight: 0])

// 渐变背景
view.style.background(.linearGradient(
    colors: [.red, .blue],
    startPoint: CGPoint(x: 0, y: 0),
    endPoint: CGPoint(x: 1, y: 1)
))
```

## 布局动画

```swift
// 基础动画
view.style.animate(duration: 0.4) {
    $0.width = 200
    $0.height = 200
}

// 弹簧动画
view.style.animate(duration: 0.6, dampingRatio: 0.4) {
    $0.width = 80
    $0.height = 80
}
```

---

## 数据绑定

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

vm.width = 100  // 自动更新布局
```

---

## 文档

- **[API 参考](.docs/API_REFERENCE.md)** — 完整 API 文档
- **[框架指南](.docs/GWYogaKit_GUIDE.md)** — 详细使用指南与代码模板
- **[Demo App 计划](.docs/DEMO_APP_PLAN.md)** — Demo 应用架构与实现计划

---

## 架构

```
GWYoga/
├── GWYoga/                  # Yoga C++ 核心引擎 + Swift 绑定
├── GWYogaKit/               # UIKit 集成层
│   ├── Core/                # YogaLayoutView、UIView+style、样式属性
│   ├── Animation/           # 布局动画与过渡
│   ├── LayoutCache/         # 预测量与缓存
│   ├── DSL/                 # VStack / HStack / ZStack 声明式 DSL
│   ├── Stylesheet/          # CSS 解析与应用
│   └── HTML/                # HTML 标签 DSL
└── Apps/
    └── GWYogaDemoApp/       # Demo 应用
```

---

## 许可证

GWYoga 基于 MIT 许可证开源。
