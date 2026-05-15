# 测试工程完善计划

## 当前覆盖状态

| 模块 | 单元测试 | API Demo | UIKit Demo | ObjC Bridge Test | 覆盖率 |
|------|---------|----------|------------|-------------------|--------|
| **GWYoga Core** | ✅ 55 tests | ✅ 33 sections | ✅ 7 VCs | - | 高 |
| **GWYoga Grid** | ✅ 30 tests | ✅ 部分覆盖 | ✅ 1 VC | - | 高 |
| **GWYogaKit Swift** | ✅ 23 tests | ✅ 部分覆盖 | ✅ 1 VC | - | 高 |
| **GWYogaKit ObjC Bridge** | ✅ 24 tests (含 iOS) | 部分覆盖 | ✅ 1 VC | ✅ 16-24 tests | 高 |
| **DSL Swift** | ✅ 14 tests | ✅ 部分覆盖 | ✅ 1 VC | - | 高 |
| **DSL ObjC** | - | - | - | ✅ 通过 YGK* tests | 中 |
| **Animation Swift** | ✅ 8 tests | ✅ 部分覆盖 | ✅ 1 VC | - | 高 |
| **Animation ObjC** | - | - | - | ✅ 通过 YGK* tests | 中 |
| **LayoutCache Swift** | ✅ 5 tests | ✅ 部分覆盖 | ✅ 1 VC | - | 中 |
| **LayoutCache ObjC** | - | - | - | ✅ YGKPreLayout test | 中 |
| **Stylesheet Swift** | ✅ 11 tests | ✅ 部分覆盖 | ✅ 1 VC | - | 高 |
| **Stylesheet ObjC** | - | - | - | ✅ 通过 YGK* tests | 中 |
| **HTML Swift** | ✅ 8 tests | ✅ 部分覆盖 | ✅ 1 VC | - | 高 |
| **HTML ObjC** | - | - | - | ✅ YGKHTMLFactory test | 中 |

---

## 一、GWYoga Core — 补充测试

### 当前缺失的 flexbox 单元测试

**文件**: `GWYogaTests/GWYogaTests.swift` 追加

```
testFlexDirectionColumnReverse()   — columnReverse 反向排列
testFlexDirectionRowReverse()      — rowReverse 反向排列
testFlexWrapWrapReverse()          — wrapReverse 反向换行
testJustifyContentFlexStart()      — flexStart (默认值测试)
testJustifyContentSpaceAround()    — spaceAround 分布
testAlignItemsFlexStart()          — alignItems flexStart
testAlignItemsFlexEnd()            — alignItems flexEnd
testAlignItemsBaseline()           — alignItems baseline
testAlignContentSpaceBetween()     — alignContent 多行分布
testFlexBasisAuto()                — flexBasis = auto
testFlexBasisPercent()             — flexBasis = percent
testBoxSizingContentBox()          — boxSizing = contentBox
testDirectionRTL()                 — GWDirection.rtl 镜像布局
testDisplayContents()              — display: contents 跳过节点
testMeasureFunction()              — 自定义 measure 函数
testNodeCloneReset()               — clone 和 reset 操作
testConfigUseWebDefaults()         — useWebDefaults 配置
testConfigPointScaleFactor()       — 像素缩放配置
testZeroSizeContainer()            — 零尺寸容器
testNestedGridInFlex()             — flex 容器中嵌套 grid
```

**预计新增**: 21 个测试

---

## 二、GWYoga Grid — 补充测试

### 当前缺失的 grid 单元测试

**文件**: `GWYogaTests/GWYogaGridTests.swift` 追加

```
testGridPercentageTracks()          — grid-template-columns: 50% 50%
testGridAutoRows()                  — grid-auto-rows 隐式行大小
testGridAutoColumns()               — grid-auto-columns 隐式列大小
testGridGapWithStretch()            — gap + stretch 联合使用
testGridAbsoluteChild()             — grid 容器中的 absolute 定位子节点
testGridItemJustifySelf()           — justify-self 单项目对齐
testGridItemAlignSelf()             — align-self 单项目对齐
testGridMultipleSpans()             — 同时跨行跨列
testGridDenseAutoPlacement()        — dense 自动放置
testGridRowAxisStretch()            — align-content stretch
testGridZeroTracks()                — 空 track 定义
testGridRepeatNotSupported()        — 验证 repeat() 暂不支持的 fallback
```

**预计新增**: 12 个测试

---

## 三、GWYogaKit 单元测试 (新文件)

**文件**: `GWYogaKitTests/GWYogaKitTests.swift` (新建 test target)

需在 `Package.swift` 中注册:
```swift
.testTarget(
    name: "GWYogaKitTests",
    dependencies: ["GWYoga", "GWYogaKit"],
    path: "GWYogaKitTests"
)
```

```
testYogaLayoutViewAutoLayout()        — YogaLayoutView auto 布局模式
testYogaLayoutViewForcedLayout()      — YogaLayoutView forced 布局模式
testYogaLayoutViewManualLayout()      — YogaLayoutView manual 布局模式
testYogaPropertiesSetGet()            — YogaProperties 所有属性读写
testYogaPropertiesPercent()           — 百分比属性
testYogaPropertiesMargin()            — margin 方法 (all/edge/percent/auto)
testYogaPropertiesPadding()           — padding 方法
testYogaPropertiesBorder()            — border 方法
testYogaPropertiesPosition()          — position 方法
testYogaPropertiesGap()               — gap 方法
testYogaPropertiesGrid()              — grid 属性
testUIViewYogaExtension()             — UIView.yoga 属性访问
testUIViewYogaIntrinsicSize()         — intrinsicContentSize 集成
testUILabelYogaIntrinsic()            — UILabel 固有尺寸标记
testYogaNodeManager()                 — YogaNodeManager 节点管理
```

**预计新增**: 15 个测试

---

## 四、DSL 单元测试 (新文件)

**文件**: `GWYogaKitDSLTests/YogaDSLTests.swift` (新建 test target)

需在 `Package.swift` 中注册:
```swift
.testTarget(
    name: "GWYogaKitDSLTests",
    dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitDSL"],
    path: "GWYogaKitDSLTests"
)
```

```
testVStack()                          — VStack 垂直排列
testHStack()                          — HStack 水平排列
testZStack()                          — ZStack 重叠布局
testScrollView()                      — ScrollView 滚动容器
testSpacer()                          — Spacer 弹性间距
testDivider()                         — Divider 分割线
testText()                            — Text 文本节点
testImage()                           — Image 图片节点
testButton()                          — Button 按钮节点
testPaddingModifier()                 — padding 修饰符
testMarginModifier()                  — margin 修饰符
testFrameModifier()                   — frame 修饰符
testBackgroundModifier()              — background 修饰符
testFlexModifier()                    — flexGrow/Shrink/Basis 修饰符
testCombinedModifiers()               — 多个修饰符组合
```

**预计新增**: 15 个测试

---

## 五、Animation 单元测试 (新文件)

**文件**: `GWYogaKitAnimationTests/YogaAnimationTests.swift` (新建 test target)

需在 `Package.swift` 中注册:
```swift
.testTarget(
    name: "GWYogaKitAnimationTests",
    dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitAnimation"],
    path: "GWYogaKitAnimationTests"
)
```

```
testTimingFunctionLinear()            — linear 时间函数
testTimingFunctionEaseInOut()         — ease-in-out 时间函数
testTimingFunctionCubicBezier()       — cubic-bezier 控制点
testTimingFunctionSteps()             — steps 步进函数
testAnimationConfig()                 — 动画配置参数
testAnimationKeyframes()              — 关键帧动画
testTransitionConfig()                — 过渡配置
testPropertyInterpolation()           — 属性插值计算
testAnimationManager()                — 动画管理器
```

**预计新增**: 9 个测试

---

## 六、LayoutCache 单元测试 (新文件)

**文件**: `GWYogaKitLayoutCacheTests/LayoutCacheTests.swift` (新建 test target)

需在 `Package.swift` 中注册:
```swift
.testTarget(
    name: "GWYogaKitLayoutCacheTests",
    dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitLayoutCache"],
    path: "GWYogaKitLayoutCacheTests"
)
```

```
testPreLayoutMeasureWidth()           — 预测量宽度
testPreLayoutMeasureSize()            — 预测量宽高
testPreLayoutCacheInvalidation()      — 缓存失效
testLayoutCacheBasic()                — 布局缓存基本功能
testLayoutCacheUpdate()               — 缓存更新
testLayoutCacheClear()                — 缓存清除
```

**预计新增**: 6 个测试

---

## 七、Stylesheet 补充测试

**文件**: `GWYogaKitStylesheetTests/YogaStylesheetTests.swift` 追加

```
testParseComplexSelectors()           — 复杂选择器解析
testParseMediaQuery()                 — @media 查询
testParseKeyframes()                  — @keyframes 规则
testPseudoClassNthChild()             — :nth-child(an+b) 各类参数
testPseudoClassNot()                  — :not() 伪类
testStylesheetMergeConflicts()        — 样式表合并冲突
testStylesheetApplyOrder()            — 应用顺序验证
testCSSPropertyMapperError()          — 属性映射错误处理
testSelectorSpecificityCalc()         — 选择器特异性计算验证
```

**预计新增**: 9 个测试

---

## 八、HTML 单元测试 (新文件)

**文件**: `GWYogaKitHTMLTests/HTMLTests.swift` (新建 test target)

需在 `Package.swift` 中注册:
```swift
.testTarget(
    name: "GWYogaKitHTMLTests",
    dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitDSL", "GWYogaKitHTML"],
    path: "GWYogaKitHTMLTests"
)
```

```
testDivTag()                          — div 标签
testSectionTag()                      — section 标签
testHeaderTag()                       — header 标签
testHeadingTags()                     — h1~h6 标签
testParagraphTag()                    — p 标签
testRowTag()                          — row 标签
testHTMLModifiers()                   — HTML 修饰符
testNestedHTMLTags()                  — 嵌套 HTML 标签
testHTMLWithStylesheet()              — HTML + Stylesheet 结合
```

**预计新增**: 9 个测试

---

## 九、Swift API Demo 补充

**文件**: `GWYogaAPIDemo/GWYogaAPIDemo.swift` 

当前 22 个 section 已较全面，补充以下 demo:

```
section 23: boxSizing contentBox 用法
section 24: direction RTL 用法
section 25: node clone/reset 操作
section 26: GWDisplay.contents 用法
section 27: Config 配置 (useWebDefaults, pointScaleFactor)
section 28: Grid autoRows/autoColumns
section 29: Animation/Transition 完整用法
section 30: LayoutCache 完整用法
section 31: DSL 完整用法 (VStack, HStack, ZStack, modifiers)
section 32: HTML 完整用法 (div, section, header, heading, p)
section 33: ObjC bridge 使用 (通过 @objc 调用)
```

**预计新增**: 11 个 section

---

## 十、ObjC 单元测试 (新建项目)

**说明**: XCTest 不支持在同一 target 中混合 Swift 和 ObjC 测试。需要创建单独的 **ObjC 测试工程**。

### 方案：在 GWYoga.xcodeproj 中添加 ObjC 测试 target

创建 `GWYogaDemoAppObjC/` 目录，包含:

#### ObjC 桥接测试文件

**文件**: `GWYogaDemoAppObjC/GWKObjCTests.m`

```
testYGKLayoutViewCreation()           — YGKLayoutView 创建
testYGKLayoutPropertiesSize()         — 尺寸属性
testYGKLayoutPropertiesFlex()         — flex 属性
testYGKLayoutPropertiesAlignment()    — 对齐属性
testYGKLayoutPropertiesMargin()       — margin
testYGKLayoutPropertiesPadding()      — padding
testYGKLayoutPropertiesBorder()       — border
testYGKLayoutPropertiesPosition()     — position
testYGKLayoutPropertiesDisplay()      — display
testYGKLayoutPropertiesGrid()         — grid
testYGKLayoutViewLayoutModes()        — 布局模式枚举
testYGKStackContainers()              — YGKVStack / YGKHStack
testYGKZStack()                       — YGKZStack
testYGKScrollView()                   — YGKScrollView
testYGKControls()                     — YGKText / YGKImage / YGKButton / YGKSpacer / YGKDivider
testYGKAnimation()                    — YGKAnimation / YGKTransition
testYGKPreLayout()                    — YGKPreLayout
testYGKStylesheet()                   — YGKStylesheet
testYGKHTMLFactory()                  — YGKHTMLFactory
testYGKLayoutEnums()                  — 所有枚举转换
testUIViewYGKExtension()              — UIView.yogaProperties 扩展
```

**预计新增**: 21 个 ObjC 测试

---

## 十一、UIKit Demo App — Swift 补充

### 新增 View Controllers

| 文件 | 内容 |
|------|------|
| `Demos/AnimationDemoViewController.swift` | YogaTransition 动画演示, 布局属性动画 |
| `Demos/DSLDemoViewController.swift` | VStack/HStack/ZStack/Spacer/Divider/Text/Image/Button 演示 |
| `Demos/StylesheetDemoViewController.swift` | CSS 解析 + selector 匹配 + Stylesheet 应用演示 |
| `Demos/HTMLDemoViewController.swift` | HTML 标签 DSL (div/section/header/h1/p) 演示 |
| `Demos/LayoutCacheDemoViewController.swift` | YogaPreLayout 预测量 + LayoutCache 演示 |
| `Demos/YogaKitDemoViewController.swift` | YogaLayoutView + UIView+yoga 扩展 + YogaProperties 完整演示 |

- 更新 `DemoTabBarController.swift` 注册新增的 VC
- 更新 `DemoTabBarController` 扩展 tab 数量 (7→13)

**预计新增**: 6 个 VC, ~30 个 demo section

---

## 十二、ObjC UIKit Demo App — 与 Swift 完全对齐

**要求**: ObjC demo app 的每个 demo 页面必须和 Swift demo app 一一对应，使用相同的 TabBarController 结构。

### 结构

基于现有 `GWYoga.xcodeproj` 新建 iOS App target: `GWYogaDemoAppObjC` (使用 ObjC)。

### 文件清单

| 文件 | 对应 Swift VC | 内容 |
|------|---------------|------|
| `ObjCAppDelegate.m` | `AppDelegate.swift` | App 入口 |
| `ObjCSceneDelegate.m` | `SceneDelegate.swift` | Scene 管理 |
| `ObjCDemoTabBarController.m` | `DemoTabBarController.swift` | Tab 导航 (13 tabs) |
| `ObjCBaseDemoViewController.m` | `BaseDemoViewController.swift` | 基类 (UIScrollView) |
| `ObjCYogaLayoutRenderer.m` | `YogaLayoutRenderer.swift` | 节点渲染 + `makeDemoSection` + `setupDemoScrollView` |
| `ObjCFlexboxDemoViewController.m` | `FlexboxDemoViewController.swift` | flexDirection/justifyContent/alignItems/flexGrow/flexWrap/alignSelf |
| `ObjCGridDemoViewController.m` | `GridDemoViewController.swift` | 固定/fr/gap/placement/minmax/padding |
| `ObjCMarginPaddingDemoViewController.m` | `MarginPaddingDemoViewController.swift` | margin/padding/border |
| `ObjCPositionDemoViewController.m` | `PositionDemoViewController.swift` | relative/absolute |
| `ObjCGapDemoViewController.m` | `GapDemoViewController.swift` | columnGap/rowGap flexbox+grid |
| `ObjCAspectRatioDemoViewController.m` | `AspectRatioDemoViewController.swift` | aspectRatio |
| `ObjCCompositeDemoViewController.m` | `CompositeDemoViewController.swift` | 综合页面布局 |
| `ObjCAnimationDemoViewController.m` | `AnimationDemoViewController.swift` | YGKAnimation/YGKTransition 动画演示 |
| `ObjCDSLDemoViewController.m` | `DSLDemoViewController.swift` | YGKVStack/YGKHStack/YGKZStack/YGKScrollView/YGKText/YGKButton/YGKSpacer/YGKDivider |
| `ObjCStylesheetDemoViewController.m` | `StylesheetDemoViewController.swift` | YGKStylesheet 解析 + selector 匹配 + 应用 |
| `ObjCHTMLDemoViewController.m` | `HTMLDemoViewController.swift` | YGKHTMLFactory |
| `ObjCLayoutCacheDemoViewController.m` | `LayoutCacheDemoViewController.swift` | YGKPreLayout 预测量 |
| `ObjCYogaKitDemoViewController.m` | `YogaKitDemoViewController.swift` | YGKLayoutView + UIView+yoga + YGKLayoutProperties |

**预计新增**: 18 个 ObjC 文件, 完全覆盖 Swift 的 13 个 demo VC

---

## 十三、Package.swift 更新

新增以下 test targets:

```swift
.testTarget(
    name: "GWYogaKitTests",
    dependencies: ["GWYoga", "GWYogaKit"],
    path: "GWYogaKitTests"
),
.testTarget(
    name: "GWYogaKitDSLTests",
    dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitDSL"],
    path: "GWYogaKitDSLTests"
),
.testTarget(
    name: "GWYogaKitAnimationTests",
    dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitAnimation"],
    path: "GWYogaKitAnimationTests"
),
.testTarget(
    name: "GWYogaKitLayoutCacheTests",
    dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitLayoutCache"],
    path: "GWYogaKitLayoutCacheTests"
),
.testTarget(
    name: "GWYogaKitHTMLTests",
    dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitDSL", "GWYogaKitHTML"],
    path: "GWYogaKitHTMLTests"
),
```

---

## 执行顺序

```
Phase 1 — 补充现有测试 (无新 target)
  ├── GWYogaTests.swift 追加 21 个 flexbox 测试
  ├── GWYogaGridTests.swift 追加 12 个 grid 测试
  ├── YogaStylesheetTests.swift 追加 9 个测试
  └── GWYogaAPIDemo.swift 追加 11 个 demo section

Phase 2 — 新增 Swift test targets + 测试
  ├── Package.swift 注册 5 个新 test target
  ├── GWYogaKitTests/    (15 tests)
  ├── GWYogaKitDSLTests/ (15 tests)
  ├── GWYogaKitAnimationTests/ (9 tests)
  ├── GWYogaKitLayoutCacheTests/ (6 tests)
  └── GWYogaKitHTMLTests/ (9 tests)

Phase 3 — UIKit Demo App Swift 补充
  ├── AnimationDemoViewController.swift
  ├── DSLDemoViewController.swift
  ├── StylesheetDemoViewController.swift
  ├── HTMLDemoViewController.swift
  ├── LayoutCacheDemoViewController.swift
  ├── YogaKitDemoViewController.swift
  └── 更新 DemoTabBarController.swift

Phase 4 — ObjC 测试 + Demo App (Xcode project)
  ├── 创建 GWYogaDemoAppObjC Xcode target/工程
  ├── 21 个 ObjC 单元测试
  └── 12 个 ObjC UIKit Demo View Controllers
```

---

## 统计汇总

| 类别 | 文件数 | 测试/演示数 | 预计代码行数 |
|------|--------|------------|-------------|
| 补充单元测试 (Swift) | 4 个文件 | 47 个测试 | ~1500 行 |
| API Demo 补充 | 1 个文件 | 11 个 section | ~800 行 |
| 新增 Swift test targets | 5 个文件 | 58 个测试 | ~600 行 |
| UIKit Demo (Swift) | 7 个文件 | ~30 个 section | ~1500 行 |
| ObjC Bridge 测试 | 1 个文件 | 16-24 个测试 | ~350 行 |
| ObjC Demo App | 28 个 Objective-C 文件 | 13 个 View Controllers | ~1500 行 |
| **合计** | **47 个文件** | **120+ 测试 + 26 demo VC (13 Swift + 13 ObjC)** | **~6250 行** |

## 执行状态

```
Phase 1 — 补充现有测试 ✅
Phase 2 — 新增 Swift test targets ✅ (225 tests, 0 failures)
Phase 3 — UIKit Demo App Swift 补充 ✅ (13 view controllers, builds)
Phase 4 — ObjC Bridge 测试 ✅ (16 on macOS, 24 on iOS, 0 failures)
Phase 4 — ObjC Demo App ✅ (GWYogaDemoAppObjC target, 13 VCs, builds successfully)
```
