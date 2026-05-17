# GWYogaKit AI Guide

> 面向 AI coding agent 和开发者的库指南。帮助快速理解 GWYogaKit 并正确生成代码。
> 与 `API_REFERENCE.md` 互补：本文档是「速查 + 模板」，API_REFERENCE 是「完整参考」。

---

## 1. 一句话总结

GWYogaKit 是 **Yoga 布局引擎的 Swift/ObjC 封装层**。提供 `UIView.style` 属性读写 flexbox/grid 样式，支持链式调用、闭包配置、CSS 字符串三种写法，以及动画、数据绑定、调试工具等。所有布局由 Yoga 引擎计算，不依赖 Auto Layout。

---

## 2. 模块导入速查

| 需要什么 | 模块 (Package.swift / import) |
|----------|------------------------------|
| 核心布局引擎 | `import GWYoga` |
| UIView.style / YogaProperties | `import GWYogaKit` |
| DSL (VStack/HStack/ZStack) | `import GWYogaKitDSL` |
| HTML 标签 (div/h1/等) | `import GWYogaKitHTML` |
| 动画 | `import GWYogaKitAnimation` |
| CSS 样式表 | `import GWYogaKitStylesheet` |
| 布局缓存/预测量 | `import GWYogaKitLayoutCache` |
| ObjC 桥接 | `import GWYogaKitObjCCore` |
| ObjC DSL | `import GWYogaKitDSLObjCCore` |
| ObjC HTML | `import GWYogaKitHTMLObjCCore` |
| ObjC Animation | `import GWYogaKitAnimationObjCCore` |
| ObjC Stylesheet | `import GWYogaKitStylesheetObjCCore` |
| ObjC LayoutCache | `import GWYogaKitLayoutCacheObjCCore` |
| Combine 绑定 | `import Combine`（系统库） |

Swift 文件通常只需：
```swift
import GWYoga
import GWYogaKit
// + 按需再加：GWYogaKitDSL, GWYogaKitAnimation, GWYogaKitStylesheet, Combine
```

---

## 3. 核心类型速查

### 3.1 GWValue — 尺寸值

```swift
let v1: GWValue = 100         // .points(100) — ExpressibleByFloatLiteral
let v2: GWValue = 50%         // .percent(50) — postfix %
let v3 = GWValue.auto         // auto
let v4 = GWValue.maxContent() // max-content
let v5 = GWValue.fitContent() // fit-content
```

**ObjC (YGKLayoutValue):**
```objc
YGKLayoutValue *v1 = YGKLayoutValue.points(100);
YGKLayoutValue *v2 = YGKLayoutValue.percent(50);
YGKLayoutValue *v3 = YGKLayoutValue.autoValue;
// 便捷方法
YGKLayout.pts(100);
YGKLayout.pct(50);
YGKLayout.autoVal;
```

### 3.2 YogaProperties — 样式代理

每个 UIView 通过 `.style` 持有 `YogaProperties`。属性映射到底层 Yoga 节点：

```swift
view.style.width = 100
view.style.flexDirection = .row
view.style.justifyContent = .center
```

**闭包配置：**
```swift
view.style { style in
    style.width = 100
    style.height = 200
    style.flexDirection = .row
}
```

**链式调用：**
```swift
view.style
    .width(100).height(200)
    .flexDirection(.row)
    .justifyContent(.center)
    .alignItems(.center)
```

### 3.3 YogaLayoutView — 自动布局容器

```swift
let container = YogaLayoutView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
container.style.flexDirection = .row
container.style.justifyContent = .spaceEvenly
container.addSubview(child1)
container.addSubview(child2)
container.performYogaLayout()  // 触发布局计算
```

### 3.4 GWYogaNode — 底层节点（纯计算，无视图）

```swift
let node = GWYogaNode()
node.style.setWidth(300)
node.style.setHeight(200)
node.style.flexDirection = .row
node.calculateLayout(width: 300, height: 200)
let frame = node.layoutResult  // left, top, width, height
```

---

## 4. 常用代码模板（按场景）

### 4.1 Flexbox 基础布局（链式）

```swift
import GWYoga
import GWYogaKit

// 容器
let container = UIView()
container.style
    .flexDirection(.row)
    .justifyContent(.spaceBetween)
    .alignItems(.center)
    .width(300).height(100)
    .padding(.all, 16)

// 子视图
let child = UILabel()
child.text = "Hello"
child.style
    .width(80).height(40)
    .margin(.right, 8)
    .flexGrow(1)

// 层级
container.addSubview(child)
```

### 4.2 Flexbox 基础布局（闭包）

```swift
let container = UIView()
container.style {
    $0.flexDirection = .row
    $0.justifyContent = .spaceBetween
    $0.alignItems = .center
    $0.width = 300
    $0.height = 100
    $0.padding = [.all: 16]
}

let child = UILabel()
child.text = "Hello"
child.style {
    $0.width = 80
    $0.height = 40
    $0.margin = [.right: 8]
    $0.flexGrow = 1
}
container.addSubview(child)
```

### 4.3 Flexbox 基础布局（CSS）

```swift
let container = UIView()
container.style.css("""
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    width: 300;
    height: 100;
    padding: 16;
""")

let child = UILabel()
child.text = "Hello"
child.style.css("width: 80; height: 40; margin-right: 8; flex-grow: 1;")
container.addSubview(child)
```

### 4.4 链式视觉样式

```swift
view.style
    .cornerRadius(12)
    .shadow(color: .black, opacity: 0.3, radius: 4, offset: CGSize(width: 0, height: 2))
    .borderWidth(1)
    .borderColor(.systemBlue)
    .opacity(0.8)

// 逐角圆角
view.style.cornerRadius([.topLeft: 12, .topRight: 12, .bottomLeft: 0, .bottomRight: 0])
```

### 4.5 背景渐变/图片

```swift
// 线性渐变
view.style.background(.linearGradient(
    colors: [.red, .blue],
    startPoint: CGPoint(x: 0, y: 0),
    endPoint: CGPoint(x: 1, y: 1)
))

// 背景图
view.style.background(.image(someUIImage, contentMode: .scaleAspectFill))

// 纯色背景
view.style.background(.color(.systemRed))
```

### 4.6 DSL 声明式布局

```swift
import GWYogaKitDSL

YogaVStack(spacing: 8, alignment: .center) {
    YogaText("Title").font(.boldSystemFont(ofSize: 18))
    YogaText("Subtitle")
    YogaButton("Tap Me") { print("tapped") }
    YogaImage(someImage)
    YogaDivider()
}.padding(.all, value: 16)
```

### 4.7 HTML 标签 DSL

```swift
import GWYogaKitHTML

div {
    h1("Page Title").padding(.all, value: 8)
    p("Paragraph text").padding(.horizontal, value: 8)
}

section {
    h2("Section")
    row {
        YogaText("Col 1")
        YogaText("Col 2")
    }
}

html {
    header { h3("Logo") }
    body { p("Content") }
    footer { p("Copyright") }
}
```

### 4.8 CSS 样式表

```swift
import GWYogaKitStylesheet

// 解析 CSS 字符串
let css = """
.container { display: flex; flex-direction: row; padding: 16px; }
.box { width: 100px; height: 50px; margin: 8px; }
"""
let sheet = try YogaStylesheet.parse(css)

// 应用到视图
view.style.cssID = "container"
sheet.apply(to: view.style)

// 内联 CSS
view.style.css("width: 100px; height: 50px; margin: 8px;")
```

### 4.9 选择器查找

```swift
view.style.cssID = "header"
childView.style.cssClass = "item"

// 递归查找
let found = view.find(byID: "header")
let items = view.findAll(byClass: "item")
```

### 4.10 动画

```swift
import GWYogaKitAnimation

// 便捷动画
view.style.animate(duration: 0.4, timingFunction: .easeOut) {
    $0.width = 200
    $0.height = 200
}

// 弹簧动画
view.style.animate(duration: 0.6, dampingRatio: 0.4, initialVelocity: 0.5) {
    $0.width = 80
    $0.height = 80
}
```

### 4.11 数据绑定

```swift
import Combine

// 1. YogaState + YogaBinding
class ViewModel {
    @YogaState var title: String = ""
    @YogaState var count: Int = 0
}

let vm = ViewModel()
let binding = YogaBinding()

binding.bind(vm.$title, to: \.text, on: titleLabel)
    .bind(vm.$count) { [weak self] count in
        self?.updateLayout(count)
    }

vm.title = "New Title"  // 自动更新 titleLabel.text
binding.unbindAll()      // 解除所有绑定

// 2. 批量合并（同一 RunLoop 多次变更只触发一次 markDirty）
let mergedBinding = YogaBinding()
mergedBinding.coalesceLayout()

mergedBinding.bind(vm.$title) { [weak self] _ in
    self?.updateLayout()  // 多次调用合并为一次 markDirty
}
```

### 4.12 响应式布局

```swift
view.style.onTraitChange { traits, style in
    if traits.horizontalSizeClass == .compact {
        style.flexDirection = .column
    } else {
        style.flexDirection = .row
    }
}

// 清除
view.style.removeAllTraitHandlers()
```

### 4.13 调试

```swift
// 打印布局树
view.style.debugPrint()
// YogaLayoutView (300×600 @0,0)
//   ├─ UILabel   (300×44  @0,0)   "title"
//   └─ UIButton  (300×40  @0,560)

// 调试边框
view.style.debugBorder(color: .red, width: 2)

// Yoga 计算尺寸
let size = view.style.systemLayoutSize(width: 300, height: Float.nan)
```

### 4.14 yog() 代理链式

`yog()` 返回一个代理对象，在同一链式中同时配置 UIKit 属性和 Yoga 属性：

```swift
UILabel().yog()
    .text("Hello")                        // UIKit: UILabel.text
    .font(.boldSystemFont(ofSize: 18))    // UIKit: UILabel.font
    .color(.darkText)                     // UIKit: UILabel.textColor
    .alignment(.center)                   // UIKit: UILabel.textAlignment
    .numberOfLines(2)                     // UIKit: UILabel.numberOfLines
    .width(200).height(50)                // Yoga: width/height
    .backgroundColor(.white)              // UIKit: backgroundColor
    .cornerRadius(8)                      // UIKit: layer.cornerRadius
    .margin(.all, 16)                     // Yoga: margin
    .flexDirection(.row)                  // Yoga: flexDirection
    .view                                 // 取回原始 UIView
```

### 4.15 Grid 布局

```swift
view.style.display = .grid
view.style.gridTemplateColumns = [.fr(1), .fr(2), .fr(1)]
view.style.rowGap = 8
view.style.columnGap = 8
```

### 4.16 自绘制控件

```swift
// 遵循协议
class CustomCanvas: UIView, YogaCustomDrawing {
    func yogaContentSize(width: Float, height: Float, mode: YogaMeasurementMode) -> CGSize {
        return CGSize(width: 200, height: 100)
    }
}

// 注册测量
YogaMeasureRegistry.register(CustomCanvas())

// 自定义 handler
YogaMeasureRegistry.register(MyView.self) { node, width, mode in
    return CGSize(width: width, height: 50)
}
```

### 4.17 YogaScrollView

```swift
let scrollView = YogaScrollView()
scrollView.style.flexDirection(.column)
scrollView.addSubview(contentView)
scrollView.performYogaLayout()
```

---

## 5. Swift → ObjC 映射速查

| Swift | ObjC | 备注 |
|-------|------|------|
| `import GWYogaKit` | `@import GWYogaKit;` | ObjC 用模块导入 |
| `view.style.width = 100` | `view.gwstyle.width = YGKLayoutValue.points(100)` | 属性访问 |
| `100`（隐式） | `YGKLayoutValue.points(100)` | 值创建 |
| `50%`（隐式） | `YGKLayoutValue.percent(50)` | 百分比 |
| `GWValue.auto` | `YGKLayoutValue.autoValue` | 自动 |
| `view.style.flexDirection(.row)` | `view.gwstyle.flexDirection = YGKFlexDirectionRow` | 枚举映射 |
| `style.width(100)` | `[view.gwstyle setWidth:YGKLayoutValue.points(100)]` | setter |
| `style.backgroundColor(.red)` | `view.gwstyle.backgroundColor = [UIColor redColor]` | UIKit 属性 |
| `view.style { s in s.width=100 }` | `[view gwstyle:^(YGKLayoutProperties *p) { p.width = ...; }]` | block 配置 |
| `YogaLayoutView` | `YGKLayoutView` | 容器视图 |
| `addSubview(_:)` | `[view addSubview:child]` | 层级构建 |
| `Container { Text() }` | `YGKVStack(8, YGKAlignCenter, ^{ ... })` | DSL（ObjC 用 block） |
| `animate(duration:changes:)` | 暂未桥接 | Swift-only |
| `Combine.bind(to:keyPath:)` | 不支持 | Swift-only |
| `YogaState` / `YogaBinding` | 不支持 | Swift-only |
| `onTraitChange` | 不支持 | Swift-only (UITraitCollection) |
| `yog()` 代理链 | 不支持 | Swift-only |
| `cssID` / `cssClass` | `view.yoga.cssTagName` | 命名不同 |

**ObjC 典型用法：**
```objc
@import GWYogaKit;
@import GWYogaKitDSLObjCCore;

// 值
view.gwstyle.width = YGKLayoutValue.points(100);
view.gwstyle.marginTop = YGKLayout.pct(10);

// 视觉属性
view.gwstyle.backgroundColor = [UIColor systemRedColor];
view.gwstyle.cornerRadius = 12;

// Block 配置
[view gwstyle:^(YGKLayoutProperties *p) {
    p.width = 100;
    p.backgroundColor = [UIColor redColor];
}];

// DSL
YGKVStack(8, YGKAlignCenter, ^{
    YGKText(@"Hello");
    YGKButton(@"Tap", ^{ NSLog(@"tapped"); });
});

// 查找
[view ygk_findByID:@"header"];
[view ygk_findAllByClass:@"item"];
```

---

## 6. 平台注意事项

| 特性 | iOS | macOS | tvOS |
|------|-----|-------|------|
| `import GWYogaKit` | ✅ | ✅ | ✅ |
| `UIView.style` 别名 | ✅ `.style` | ❌ 用 `.yoga` | ✅ `.style` |
| 视觉样式 (cornerRadius/shadow/border) | ✅ | ✅（需 layer） | ✅ |
| `background(.gradient)` | ✅ CAGradientLayer | ⚠️ NSView+layer | ✅ |
| `background(.image)` | ✅ CALayer | ⚠️ NSView+layer | ✅ |
| DSL | ✅ | ✅ | ✅ |
| HTML tags | ✅ | ❌ | ✅ |
| Animation | ✅ | ❌ | ✅ |
| Stylesheet | ✅ | ✅ | ✅ |
| LayoutCache | ✅ | ✅ | ✅ |
| `onTraitChange` | ✅ | ❌ | ✅ |
| Combine | ✅ (iOS 13+) | ✅ (10.15+) | ✅ |
| YogaState/Binding | ✅ | ✅ | ✅ |
| `yog()` proxy | ✅ | ❌ | ✅ |
| `addChild(_:)` | ✅ | ❌（用常规 addSubview） | ✅ |

**macOS 特殊处理：**
- `.style` 别名仅 iOS/tvOS，macOS 需用 `.yoga` 访问 `YogaProperties`
- `YogaLayoutView` 子类需设 `isFlipped = true` 保证 Y 轴方向正确

---

## 7. 最佳实践 & 常见错误

### DO
- ✅ 使用 `view.style` 配置布局，提供比 `view.yoga` 更好的可读性
- ✅ 使用链式 API 或闭包集中配置属性（`view.style { ... }` 或 `view.style.flexDirection(.row)...`）
- ✅ 使用 `addSubview(_:)` 添加子视图（Yoga 树通过 `YogaNodeManager` 自动同步）
- ✅ 对于 UILabel/UIImageView 设 `isIntrinsic = true` 自动测量内容尺寸
- ✅ 用 `coalesceLayout()` + `YogaBinding` 批量更新多个样式属性
- ✅ CSS 字符串适合动态样式，链式 API / 闭包适合静态布局
- ✅ 用 `debugPrint()` 在开发阶段验证布局树结构
- ✅ 数据变化通过 `@YogaState` 驱动，自动触发重新布局

### DON'T
- ❌ 不要在设置多个样式属性时反复触发布局——用链式或闭包集中设置
- ❌ 不要忘记在普通 UIView 上调用 `performYogaLayout()`（`YogaLayoutView` 会在 `layoutSubviews` 中自动调用）
- ❌ 不要在 ObjC 中使用 Swift-only API（Combine、YogaState、yog() 等）
- ❌ 不要在 macOS 上使用 `.style` 别名（用 `.yoga`）

### 布局触发规则
1. 设置 `width`/`height` 等样式属性 → 自动调用 `node.markDirty()`
2. 调用 `container.performYogaLayout()` → 计算整个子树
3. `YogaLayoutView` 在 `layoutSubviews()` 中自动触发 yoga 布局
4. 批量绑定用 `coalesceLayout()` 避免频繁 markDirty
5. UILabel/UIButton 文本变化自动触发脏标记（method swizzling）

---

## 8. 完整 API 索引

详细文档见 `API_REFERENCE.md`，按编号索引：

| # | 分类 | 文件 | 主要 API |
|---|------|------|----------|
| 一 | 值系统 | GWTypes.swift | `GWValue`, `ExpressibleByFloatLiteral`, `%` 运算符 |
| 二 | UIView.style | UIView+Yoga.swift | `.style` 别名 |
| 三 | 链式方法 | YogaProperties.swift | 所有 `func xxx() -> Self` |
| 四 | 闭包配置 | YogaProperties.swift | `callAsFunction(_:)` |
| 五 | 百分比运算符 | GWTypes.swift | `postfix func %` |
| 六 | CSS 字符串 | YogaProperties+CSS.swift | `.css(_:)` |
| 七 | CSS 文件加载 | YogaProperties+Stylesheet.swift | `loadStylesheet(_:bundle:)` |
| 八 | ID/Class 选择器 | YogaProperties+Selector.swift | `cssID`, `find(byID:)` |
| 九 | 富文本 | YogaProperties+RichText.swift | `attributedText`, `attributedText { }` |
| 十 | 自绘制控件 | YogaCustomDrawing.swift | `YogaCustomDrawing` 协议, `YogaMeasureRegistry` |
| 十一 | 视觉样式 | YogaProperties+Visual.swift | `cornerRadius`, `shadow`, `border`, `background`, `opacity` |
| 十二 | addChild | UIView+Yoga.swift | `addChild(_:)`, `removeFromParent()` |
| 十三 | yog() 代理 | YogaConfigProxy.swift | `yog()` UIKit 属性链式配置 |
| 十四 | 数据绑定 | YogaState.swift, YogaBinding.swift | `@YogaState`, `bind(_:to:)`, `coalesceLayout()` |
| 十五 | 平台适配 | NSView+Yoga.swift | macOS `isFlipped`, tvOS 条件编译 |
| 十六 | 调试工具 | YogaProperties+Debug.swift | `debugPrint()`, `debugBorder()`, `systemLayoutSize()` |
| 十七 | 动画 | YogaProperties+Animation.swift | `animate(duration:changes:)`, `animate(duration:dampingRatio:changes:)` |
| 十八 | CSS 文件加载 | YogaProperties+Stylesheet.swift | `loadStylesheet`, `YogaCSSConfig.registerDefault()` |
| 十九 | Combine 绑定 | YogaProperties+Combine.swift | `Publisher.bind(to:keyPath:)` |
| 二十 | 响应式布局 | YogaProperties+Trait.swift | `onTraitChange(_:)` |
| 廿一 | ObjC 桥接 | YGKLayoutValue, YGKLayoutProperties | `YGKLayoutValue`, `gwstyle:`, `YogaLayoutView` |
| — | DSL 容器 | YogaDSLContainers.swift | `YogaVStack`, `YogaHStack`, `YogaZStack` |
| — | DSL 控件 | YogaDSLControls.swift | `YogaText`, `YogaButton`, `YogaImage` |
| — | HTML 标签 | YogaHTMLTags.swift | `div`, `h1`, `p`, `section`, `header`, `footer` |
| — | CSS 引擎 | YogaStylesheet.swift | `YogaStylesheet.parse()`, `YogaSelector`, `YogaCSSPropertyMapper` |
| — | 预测量 | YogaPreLayout.swift | `measure(width:)`, `measureAll(_:width:)`, `invalidateCache()` |
| — | 关键帧 | YogaKeyframes.swift | `YogaKeyframes`, `YogaKeyframeStyle` |

---

## 9. 三种写法对照

同一个布局用三种风格分别实现：

### 链式

```swift
container.style
    .flexDirection(.row)
    .justifyContent(.center)
    .alignItems(.center)
    .padding(.all, 16)
    .backgroundColor(.systemGray6)

child.style
    .width(60).height(60)
    .margin(.all, 8)
    .backgroundColor(.systemBlue)
    .cornerRadius(8)
```

### 闭包

```swift
container.style {
    $0.flexDirection = .row
    $0.justifyContent = .center
    $0.alignItems = .center
    $0.padding = [.all: 16]
    $0.backgroundColor = .systemGray6
}

child.style {
    $0.width = 60
    $0.height = 60
    $0.margin = [.all: 8]
    $0.backgroundColor = .systemBlue
    $0.cornerRadius = 8
}
```

### CSS

```swift
container.style.css("""
    flex-direction: row;
    justify-content: center;
    align-items: center;
    padding: 16px;
    background-color: #f0f0f0;
""")

child.style.css("width: 60; height: 60; margin: 8px; border-radius: 8px; background-color: #007AFF;")
```

---

## 10. 依赖关系

```
                                                    ┌──────────────────┐
                                                    │   GWYoga (core)  │
                                                    │   YGNode C API   │
                                                    └────────┬─────────┘
                                                             │
                                                    ┌────────▼─────────┐
                                                    │   GWYogaKit      │
                                                    │   YogaProperties │
                                                    │   UIView.style   │
                                                    └──┬────┬────┬─────┘
                                                       │    │    │
                                    ┌──────────────────┘    │    └──────────────────┐
                                    │                       │                       │
                          ┌─────────▼──────┐    ┌───────────▼──────┐   ┌─────────────▼──────┐
                          │ GWYogaKitDSL   │    │ GWYogaKitAnimation│   │ GWYogaKitStylesheet│
                          │ VStack/HStack  │    │ animate/damping   │   │ CSS.parse/load     │
                          └─────────┬──────┘    └───────────────────┘   └─────────────┬──────┘
                                    │                                                 │
                          ┌─────────▼──────┐                                          │
                          │ GWYogaKitHTML  │                                          │
                          │ div/h1/section │                                          │
                          └────────────────┘                                          │
                                                                                      │
                                                           ┌──────────────────────────┘
                                                           ▼
                                                  ┌──────────────────┐
                                                  │GWYogaKitLayoutCache│
                                                  │PreLayout/measure  │
                                                  └──────────────────┘
```

每个模块的 **ObjC 桥接** 对应 `*ObjCCore` 版本（如 `GWYogaKitStylesheetObjCCore`），依赖其 Swift 父模块。

---

*文档版本：2026-05-17 · 与 GWYogaKit 代码同步更新*
