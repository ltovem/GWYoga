# GWYoga API 参考文档

> GWYoga 是基于 Meta [Yoga](https://yogalayout.com) 布局引擎的纯 Swift 实现。
> 完整实现了 Flexbox（11 步算法）和 CSS Grid 网格布局算法。

---

## 目录

- [初始化](#初始化)
- [配置](#配置)
- [构建节点树](#构建节点树)
- [设置样式属性](#设置样式属性)
- [布局计算](#布局计算)
- [读取布局结果](#读取布局结果)
- [Flexbox 属性](#flexbox-属性)
- [CSS Grid 属性](#css-grid-属性)
- [绝对定位](#绝对定位)
- [自定义测量](#自定义测量)
- [值类型参考](#值类型参考)
- [集成 UIKit](#集成-uikit)
- [完整示例](#完整示例)

---

## 初始化

### 创建节点

```swift
import GWYoga

// 使用默认配置创建节点
let node = GWYogaNode()

// 使用自定义配置创建节点
let config = GWYogaConfig()
let node = GWYogaNode(config: config)
```

### 创建节点树

```swift
let root = GWYogaNode()
let child1 = GWYogaNode()
let child2 = GWYogaNode()

// 构建父子关系
root.insertChild(child1, at: 0)
root.insertChild(child2, at: 1)
```

---

## 配置

`GWYogaConfig` 控制节点树的全局布局行为。

```swift
let config = GWYogaConfig()

// Web 默认值：flexDirection = .row, alignContent = .stretch
config.useWebDefaults = true

// 像素网格对齐（0=禁用, 1.0=标准屏, 2.0=@2x, 3.0=@3x）
config.pointScaleFactor = 1.0

// 兼容性标志
config.errata = [.stretchFlexBasis]

// 实验性功能
config.setExperimentalFeature(.webFlexBasis, enabled: true)
```

### 配置属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `useWebDefaults` | `Bool` | `false` | 为 true 时，默认 flexDirection 为 `.row`，alignContent 为 `.stretch` |
| `pointScaleFactor` | `Float` | `1.0` | 像素网格缩放因子。设为 `0` 可禁用取整 |
| `errata` | `GWErrata` | `.none` | 已知规范偏差的兼容性标志 |
| `experimentalFeatures` | `Set<GWExperimentalFeature>` | `[]` | 可选实验性功能 |
| `context` | `Any?` | `nil` | 附加到配置的任意用户数据 |
| `logger` | `GWLogger?` | `nil` | 自定义日志回调 |

### 兼容性标志

```swift
config.errata = [.stretchFlexBasis]
// 可选值：.stretchFlexBasis, .absolutePositionWithoutInsetsExcludesPadding,
//         .absolutePercentAgainstInnerSize
```

### 实验性功能

```swift
config.setExperimentalFeature(.webFlexBasis, enabled: true)
// 可选值：.webFlexBasis, .fixFlexBasisFitContent
```

---

## 构建节点树

### 树管理

```swift
// 在指定索引插入子节点
root.insertChild(child, at: 0)

// 移除指定子节点
root.removeChild(child)

// 移除所有子节点
root.removeAllChildren()

// 替换指定索引的子节点
root.replaceChild(at: 0, with: newChild)

// 替换指定子节点
root.replaceChild(oldChild, with: newChild)

// 子节点数量
print(root.childCount)

// 遍历子节点
for child in root.children {
    // ...
}
```

### 节点属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `style` | `GWStyle` | 所有 CSS 样式属性 |
| `children` | `[GWYogaNode]` | 子节点列表（只读） |
| `owner` | `GWYogaNode?` | 父节点（弱引用） |
| `config` | `GWYogaConfig` | 创建节点时使用的配置 |
| `nodeType` | `GWNodeType` | `.default` 或 `.text` |
| `context` | `Any?` | 任意用户数据 |
| `isReferenceBaseline` | `Bool` | 是否作为基线参考 |
| `alwaysFormsContainingBlock` | `Bool` | 是否始终为绝对子节点形成包含块 |

---

## 设置样式属性

GWYoga 使用 `GWStyle` 值类型属性集合。通过节点的 `style` 属性访问。

### 直接属性设置

```swift
let node = GWYogaNode()

node.style.width = .points(100)
node.style.height = .auto
node.style.flexDirection = .row
node.style.justifyContent = .center
node.style.alignItems = .stretch
```

### 简写方式

```swift
node.style.margin = [.all: .points(10)]
node.style.padding = [.horizontal: .points(16), .vertical: .points(8)]
node.style.border = [.all: 1.0]
```

### 边索引

通过 `GWEdge` 原始值索引：

| GWEdge | 索引 | CSS 等效 |
|--------|------|----------|
| `.left` | 0 | `margin-left` |
| `.top` | 1 | `margin-top` |
| `.right` | 2 | `margin-right` |
| `.bottom` | 3 | `margin-bottom` |
| `.start` | 4 | `margin-inline-start` |
| `.end` | 5 | `margin-inline-end` |
| `.horizontal` | 6 | `margin-inline`（left + right） |
| `.vertical` | 7 | `margin-block`（top + bottom） |
| `.all` | 8 | `margin`（四边） |

---

## 布局计算

### 触发布局

```swift
// 基本布局
node.calculateLayout(
    width: .nan,       // 可用宽度（NaN = 未定义）
    height: .nan,      // 可用高度
    direction: .ltr    // 文字方向
)

// 固定可用尺寸
root.calculateLayout(
    width: 375,
    height: 812,
    direction: .ltr
)
```

### 参数说明

| 参数 | 类型 | 说明 |
|------|------|------|
| `width` | `Float` | 父节点提供的可用宽度。传 `nan` 或 `.nan` 表示未定义 |
| `height` | `Float` | 父节点提供的可用高度 |
| `direction` | `GWDirection` | 文字方向：`.ltr`、`.rtl` 或 `.inherit` |

### 脏标记

```swift
// 手动标记节点为脏（触发重新计算）
node.markDirty()
// 注意：样式属性变更时，节点会自动标记为脏。
```

---

## 读取布局结果

调用 `calculateLayout` 后，通过 `layoutResult` 获取结果：

```swift
root.calculateLayout(width: 500, height: 500, direction: .ltr)

let result = child.layoutResult
print("位置：(\(result.left), \(result.top))")
print("尺寸：\(result.width) x \(result.height)")
```

### GWLayoutResult 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `left` | `Float` | 相对父节点的 X 位置 |
| `top` | `Float` | 相对父节点的 Y 位置 |
| `right` | `Float` | 右边位置 |
| `bottom` | `Float` | 底部位置 |
| `width` | `Float` | 计算宽度 |
| `height` | `Float` | 计算高度 |
| `direction` | `GWDirection` | 解析后的方向（LTR/RTL） |
| `hadOverflow` | `Bool` | 内容是否溢出 |

### 计算后的度量值

```swift
// 计算后的外边距（百分比已解析）
let margin = node.computedMargin(for: .left)     // Float

// 计算后的边框
let border = node.computedBorder(for: .top)       // Float

// 计算后的内边距
let padding = node.computedPadding(for: .right)   // Float
```

---

## Flexbox 属性

### 主轴方向

```swift
node.style.flexDirection = .column      // 默认 - 从上到下
node.style.flexDirection = .columnReverse
node.style.flexDirection = .row         // 从左到右
node.style.flexDirection = .rowReverse
```

### 主轴对齐

```swift
node.style.justifyContent = .flexStart      // 默认
node.style.justifyContent = .flexEnd
node.style.justifyContent = .center
node.style.justifyContent = .spaceBetween
node.style.justifyContent = .spaceAround
node.style.justifyContent = .spaceEvenly
node.style.justifyContent = .start
node.style.justifyContent = .end
```

### 交叉轴对齐（容器级）

```swift
node.style.alignItems = .stretch         // 默认
node.style.alignItems = .flexStart
node.style.alignItems = .flexEnd
node.style.alignItems = .center
node.style.alignItems = .baseline
node.style.alignItems = .start
node.style.alignItems = .end
```

### 交叉轴对齐（子级覆盖）

```swift
child.style.alignSelf = .auto            // 继承父节点
child.style.alignSelf = .center
child.style.alignSelf = .stretch
child.style.alignSelf = .flexEnd
```

### 多行交叉轴对齐

```swift
node.style.alignContent = .flexStart     // 默认
node.style.alignContent = .flexEnd
node.style.alignContent = .center
node.style.alignContent = .stretch
node.style.alignContent = .spaceBetween
node.style.alignContent = .spaceAround
node.style.alignContent = .spaceEvenly
```

### 换行

```swift
node.style.flexWrap = .noWrap            // 默认
node.style.flexWrap = .wrap
node.style.flexWrap = .wrapReverse
```

### Flex Grow / Shrink / Basis

```swift
// 单独设置
child.style.flexGrow = 1.0
child.style.flexShrink = 1.0
child.style.flexBasis = .auto            // 默认
child.style.flexBasis = .points(100)
child.style.flexBasis = .percent(50)
child.style.flexBasis = .maxContent
child.style.flexBasis = .fitContent

// Flex 简写（flexGrow > 0 时，flexBasis 隐式设为 0）
child.style.flex = 1.0  // 等同于 flexGrow=1, flexShrink=1, flexBasis=0
```

### 间距

```swift
node.style.rowGap = .points(10)
node.style.columnGap = .points(16)
// 或
node.style.gap = [.points(10), .points(16), .undefined]
// 索引：0 = columnGap, 1 = rowGap, 2 = allGap
```

### 尺寸设置

```swift
node.style.width = .points(100)
node.style.height = .auto
node.style.minWidth = .points(50)
node.style.maxHeight = .percent(80)

// 可用单位：
// .points(x)       - 固定像素值
// .percent(x)      - 父节点百分比
// .auto            - 自动尺寸
// .undefined       - 未设置
// .maxContent      - 最大内容尺寸
// .fitContent      - 适合内容尺寸
// .stretch(x)      - flex / fr 单位（仅 Grid）
```

### 宽高比

```swift
node.style.aspectRatio = 16.0 / 9.0
// 宽度 = 高度 × aspectRatio，或 高度 = 宽度 / aspectRatio
// 支持 flexbox 和绝对定位
```

### 溢出

```swift
node.style.overflow = .visible     // 默认
node.style.overflow = .hidden
node.style.overflow = .scroll
```

### 显示模式

```swift
node.style.display = .flex         // 默认
node.style.display = .none         // 隐藏（不参与布局）
node.style.display = .contents     // 透明节点（子节点提升到父级）
node.style.display = .grid         // CSS 网格布局
```

### 盒模型

```swift
node.style.boxSizing = .borderBox      // 默认（CSS 标准）
node.style.boxSizing = .contentBox     // width/height 不包含 padding+border
```

### 自动外边距

```swift
// 自动外边距吸收剩余空间，适合居中
child.style.margin = [.horizontal: .auto]
// 或
child.style.margin[GWEdge.horizontal.rawValue] = .auto
```

### Flexbox 示例

```swift
let root = GWYogaNode()
root.style.width = .points(300)
root.style.height = .points(200)
root.style.flexDirection = .row
root.style.justifyContent = .center
root.style.alignItems = .center

let child = GWYogaNode()
child.style.width = .points(100)
child.style.height = .points(50)
child.style.flexGrow = 1

root.insertChild(child, at: 0)
root.calculateLayout(width: 300, height: 200, direction: .ltr)

print(child.layoutResult)
// => left: 0, top: 75, width: 300, height: 50
```

---

## CSS Grid 属性

### 定义网格轨道

```swift
// 固定轨道
node.style.gridTemplateColumns = [
    .points(100),
    .points(200)
]

// 混合 fr 单位
node.style.gridTemplateColumns = [
    .fr(1),     // 1fr
    .fr(2),     // 2fr
    .points(100) // 固定
]

// 百分比轨道
node.style.gridTemplateRows = [
    .percent(50),
    .percent(50)
]

// Minmax 轨道
node.style.gridTemplateColumns = [
    .minmax(min: .points(100), max: .fr(1))
]

// 自动轨道（用于自动放置或隐式轨道）
node.style.gridAutoColumns = [.points(100)]
node.style.gridAutoRows = [.auto()]
```

### 网格子项定位

```swift
// 显式定位（行号从 1 开始）
child.style.gridColumnStart = .init(type: .integer, value: 1)
child.style.gridColumnEnd = .init(type: .integer, value: 3)

// 跨列
child.style.gridColumnStart = .auto
child.style.gridColumnEnd = .init(type: .span, value: 2)  // 跨越 2 列

// 行定位
child.style.gridRowStart = .init(type: .integer, value: 1)
child.style.gridRowEnd = .init(type: .integer, value: 2)

// 自动定位（不设置 start/end，或设为 .auto）
child.style.gridColumnStart = .auto
child.style.gridColumnEnd = .auto
```

### 网格轨道尺寸类型

| 构造方法 | CSS 等效 | 说明 |
|----------|----------|------|
| `.points(n)` | `100px` | 固定长度轨道 |
| `.percent(n)` | `50%` | 网格容器百分比 |
| `.fr(n)` | `1fr` | 弹性单位（分配剩余空间） |
| `.auto()` | `auto` | 基于内容尺寸 |
| `.minmax(min:, max:)` | `minmax(100px, 1fr)` | 最小/最大约束 |

### Grid 示例

```swift
let grid = GWYogaNode()
grid.style.display = .grid
grid.style.width = .points(400)
grid.style.height = .points(300)
grid.style.gridTemplateColumns = [.fr(1), .fr(1)]  // 2 等宽列
grid.style.gridTemplateRows = [.fr(1), .fr(1)]      // 2 等高行
grid.style.columnGap = .points(10)
grid.style.rowGap = .points(10)

for i in 0..<4 {
    let item = GWYogaNode()
    grid.insertChild(item, at: i)
}

grid.calculateLayout(width: 400, height: 300, direction: .ltr)

for child in grid.children {
    print(child.layoutResult)
    // 每个子项：~195 x ~145（(400-10)/2, (300-10)/2）
}
```

---

## 绝对定位

```swift
let child = GWYogaNode()
child.style.positionType = .absolute

// 偏移属性（使用 CSS 逻辑属性）：
child.style.position = [
    GWEdge.left.rawValue: .points(10),
    GWEdge.top.rawValue: .points(20)
]
// 或者：
child.style.position[GWEdge.left.rawValue] = .points(10)
child.style.position[GWEdge.top.rawValue] = .points(20)

// 未定义偏移时，回退到父节点的 justify/align
child.style.positionType = .absolute
// 不设置 left/top → 由父节点的 justifyContent/alignItems 定位
```

### 定位类型

| 值 | 说明 |
|----|------|
| `.relative` | 默认流式定位 |
| `.absolute` | 脱离文档流，相对于包含块定位 |
| `.static` | 静态流（仍可作为包含块） |

### 偏移优先级

1. `start` / `end`（`inline-start`/`inline-end`，感知方向）
2. `left` / `right` / `top` / `bottom`
3. 回退到父节点 `justifyContent` / `alignItems`

---

## 自定义测量

对于有内在内容的节点（文本、图片），提供测量函数：

```swift
let textNode = GWYogaNode()
textNode.nodeType = .text
textNode.measureFunction = { node, width, widthMode, height, heightMode in
    // 返回内容的固有尺寸
    return GWSize(width: 100, height: 20)
}

// 基线函数（用于基线对齐）
textNode.baselineFunction = { node, width, height in
    return height  // 从顶部开始的基线
}

// 脏标记回调（节点被标记为脏时调用）
textNode.dirtiedHandler = { node in
    print("节点布局已脏，需要重新布局")
}
```

### 测量模式

| 模式 | 说明 |
|------|------|
| `.stretchFit` | 精确尺寸约束（节点必须完全匹配） |
| `.maxContent` | 最大为此尺寸（节点可以更小） |
| `.fitContent` | 在最小和最大内容之间 |

---

## 值类型参考

### GWValue

带单位的 CSS 属性值：

```swift
// 构造
GWValue(value: 100, unit: .point)
GWValue(value: 50, unit: .percent)

// 静态构造方法
GWValue.points(100)      // 100px
GWValue.percent(50)      // 50%
GWValue.auto             // auto
GWValue.undefined        // 未设置
GWValue.maxContent()     // max-content
GWValue.fitContent()     // fit-content
GWValue.stretch()        // stretch / fr 单位
GWValue.zero             // 0px
```

### GWFloatOptional

可为 `.undefined`（NaN）的浮点数：

```swift
GWFloatOptional(value: 100)     // 有值
GWFloatOptional.undefined       // NaN

let opt = GWFloatOptional(value: 100)
opt.isDefined      // true
opt.isUndefined    // false
opt.unwrap()       // 100
opt.unwrap(orDefault: 0)  // 100
```

### GWSize

简单的宽高对：

```swift
GWSize(width: 100, height: 200)
GWSize.zero
```

### GWLayoutResult

计算后的布局结果（参见[读取布局结果](#读取布局结果)）。

### GWInsets

支持逻辑属性的边距：

```swift
GWInsets(left: 0, top: 10, right: 0, bottom: 10, start: 0, end: 0)
GWInsets.zero
```

### GWGridLine

网格子项定位的行号：

```swift
GWGridLine(type: .integer, value: 1)   // 第 1 行
GWGridLine(type: .span, value: 2)      // 跨越 2 行
GWGridLine.auto
```

### GWGridTrackSize

网格轨道尺寸函数：

```swift
GWGridTrackSize.points(100)
GWGridTrackSize.fr(1)
GWGridTrackSize.percent(50)
GWGridTrackSize.minmax(min: .points(100), max: .fr(1))
GWGridTrackSize.auto()
```

---

## 集成 UIKit

GWYoga 与 UIKit `UIView` 的集成方式：

```swift
import UIKit
import GWYoga

extension UIView {
    /// 将计算后的布局应用到视图 frame
    func applyYogaLayout(_ node: GWYogaNode) {
        let result = node.layoutResult
        self.frame = CGRect(
            x: CGFloat(result.left),
            y: CGFloat(result.top),
            width: CGFloat(result.width),
            height: CGFloat(result.height)
        )
    }

    /// 便捷方法：创建节点、插入子节点、布局、应用 frame
    func yogaLayout(
        availableWidth: CGFloat,
        availableHeight: CGFloat,
        direction: GWDirection = .ltr,
        setup: (GWYogaNode) -> Void
    ) {
        let node = GWYogaNode()
        setup(node)
        node.calculateLayout(
            width: Float(availableWidth),
            height: Float(availableHeight),
            direction: direction
        )
        applyNodeLayout(node, parentView: self)
    }

    private func applyNodeLayout(_ node: GWYogaNode, parentView: UIView) {
        for (i, child) in node.children.enumerated() {
            if i < parentView.subviews.count {
                parentView.subviews[i].frame = CGRect(
                    x: CGFloat(child.layoutResult.left),
                    y: CGFloat(child.layoutResult.top),
                    width: CGFloat(child.layoutResult.width),
                    height: CGFloat(child.layoutResult.height)
                )
                applyNodeLayout(child, parentView: parentView.subviews[i])
            }
        }
    }
}

// 使用示例：
let container = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
let childView = UIView()
container.addSubview(childView)

let node = GWYogaNode()
node.style.width = .points(200)
node.style.height = .points(100)
node.style.margin = [.all: .points(16)]
node.calculateLayout(width: 375, height: 667, direction: .ltr)

childView.frame = CGRect(
    x: CGFloat(node.layoutResult.left),
    y: CGFloat(node.layoutResult.top),
    width: CGFloat(node.layoutResult.width),
    height: CGFloat(node.layoutResult.height)
)
```

---

## 完整示例

### Flexbox：居中卡片布局

```swift
import GWYoga

let root = GWYogaNode()
root.style.width = .points(375)
root.style.height = .points(667)
root.style.justifyContent = .center
root.style.alignItems = .center

let card = GWYogaNode()
card.style.width = .points(300)
card.style.flexDirection = .column
card.style.padding = [GWEdge.all.rawValue: .points(16)]
card.style.border = [GWEdge.all.rawValue: 1]
root.insertChild(card, at: 0)

let title = GWYogaNode()
title.style.width = .points(268)
title.style.height = .points(24)
title.style.margin = [GWEdge.bottom.rawValue: .points(8)]
card.insertChild(title, at: 0)

let body = GWYogaNode()
body.style.width = .points(268)
body.style.height = .points(60)
card.insertChild(body, at: 1)

root.calculateLayout(width: 375, height: 667, direction: .ltr)

// 读取结果
print("卡片：\(card.layoutResult)")
print("标题：\(title.layoutResult)")
print("正文：\(body.layoutResult)")
```

### Grid：相册布局

```swift
let gallery = GWYogaNode()
gallery.style.display = .grid
gallery.style.width = .points(400)
gallery.style.gridTemplateColumns = [.fr(1), .fr(1), .fr(1)]  // 3 列
gallery.style.gap = [.points(8), .points(8), .undefined]
// 索引：0 = columnGap, 1 = rowGap, 2 = allGap

// 添加 6 张照片（自动放置到网格中）
for i in 0..<6 {
    let photo = GWYogaNode()
    photo.style.aspectRatio = 1.0  // 正方形
    gallery.insertChild(photo, at: i)
}

gallery.calculateLayout(width: 400, height: .nan, direction: .ltr)

for (i, child) in gallery.children.enumerated() {
    print("照片 \(i + 1)：\(child.layoutResult)")
}
```

### Flexbox：导航栏

```swift
let nav = GWYogaNode()
nav.style.width = .points(375)
nav.style.height = .points(44)
nav.style.flexDirection = .row
nav.style.alignItems = .center
nav.style.padding = [GWEdge.horizontal.rawValue: .points(16)]

let backButton = GWYogaNode()
backButton.style.width = .points(60)
backButton.style.height = .points(32)

let titleLabel = GWYogaNode()
titleLabel.style.flexGrow = 1
titleLabel.style.height = .points(20)
titleLabel.style.margin = [GWEdge.horizontal.rawValue: .points(8)]

let actionButton = GWYogaNode()
actionButton.style.width = .points(40)
actionButton.style.height = .points(32)

nav.insertChild(backButton, at: 0)
nav.insertChild(titleLabel, at: 1)
nav.insertChild(actionButton, at: 2)

nav.calculateLayout(width: 375, height: 44, direction: .ltr)
// backButton:   left=16,  top=6,  width=60,  height=32
// titleLabel:   left=84,  top=12, width=239, height=20
// actionButton: left=331, top=6,  width=40,  height=32
```

### Flexbox + 绝对定位：角标叠加

```swift
let container = GWYogaNode()
container.style.width = .points(40)
container.style.height = .points(40)

let avatar = GWYogaNode()
avatar.style.width = .points(40)
avatar.style.height = .points(40)
container.insertChild(avatar, at: 0)

let badge = GWYogaNode()
badge.style.positionType = .absolute
badge.style.width = .points(16)
badge.style.height = .points(16)
badge.style.position = [
    GWEdge.right.rawValue: .points(-4),
    GWEdge.top.rawValue: .points(-4),
]
container.insertChild(badge, at: 1)

container.calculateLayout(width: 40, height: 40, direction: .ltr)
print("角标：\(badge.layoutResult)")
// 角标：left=28, top=-4, width=16, height=16
```

### 自定义测量：文本节点

```swift
let textNode = GWYogaNode()
textNode.nodeType = .text
textNode.measureFunction = { node, width, widthMode, height, heightMode in
    let text = (node.context as? String) ?? ""
    let font = UIFont.systemFont(ofSize: 14)
    let constraint = CGSize(
        width: widthMode == .undefined ? .greatestFiniteMagnitude : CGFloat(width),
        height: heightMode == .undefined ? .greatestFiniteMagnitude : CGFloat(height)
    )
    let size = (text as NSString).boundingRect(
        with: constraint,
        options: .usesLineFragmentOrigin,
        attributes: [.font: font],
        context: nil
    ).size
    return GWSize(width: Float(ceil(size.width)), height: Float(ceil(size.height)))
}
textNode.context = "Hello, GWYoga！"

textNode.calculateLayout(width: .nan, height: .nan, direction: .ltr)
print("文本尺寸：\(textNode.layoutResult.width) x \(textNode.layoutResult.height)")
```

---

## 枚举参考

### GWDirection

```swift
.inherit  // 继承父节点
.ltr      // 从左到右
.rtl      // 从右到左
```

### GWFlexDirection

```swift
.column        // 从上到下（默认）
.columnReverse // 从下到上
.row           // 从左到右
.rowReverse    // 从右到左
```

### GWJustify

```swift
.flexStart    .flexEnd    .center
.spaceBetween .spaceAround .spaceEvenly
.start        .end        .stretch
.auto
```

### GWAlign

```swift
.flexStart    .flexEnd    .center    .stretch
.baseline     .start      .end
.spaceBetween .spaceAround .spaceEvenly
.auto
```

### GWWrap / GWFlexWrap

```swift
.noWrap       .wrap       .wrapReverse
```

### GWDisplay

```swift
.flex         .none       .contents     .grid
```

### GWPositionType

```swift
.relative     .absolute     .static
```

### GWOverflow

```swift
.visible      .hidden       .scroll
```

### GWBoxSizing

```swift
.borderBox    .contentBox
```

### GWNodeType

```swift
.default      .text
```

### GWUnit

```swift
.undefined    .point      .percent      .auto
.maxContent   .fitContent .stretch
```

### GWDimension

```swift
.width        .height
```

### GWEdge

```swift
.left  .top  .right  .bottom
.start .end
.horizontal .vertical .all
```

### GWPhysicalEdge

```swift
.left  .top  .right  .bottom
```

### GWGridLineType

```swift
.auto     .integer     .span
```

---

> 更多信息请访问 [Yoga 布局引擎](https://yogalayout.com)
