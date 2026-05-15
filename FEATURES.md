# GWYoga — 功能文档

GWYoga 是 Meta [Yoga](https://yogalayout.com) 布局引擎的纯 Swift 实现，
完整实现了 Flexbox 和 CSS Grid 布局算法。

---

## 一、Flexbox 布局（11 步算法）

完整实现 Yoga C++ 的 11 步 flexbox 算法，通过 90 个 Yoga 兼容性对比测试。

| 步骤 | 功能 | 对应文件 |
|------|------|----------|
| 1 | 确定容器可用内容空间（`calculateAvailableInnerDimension`） | `CalculateLayout` |
| 2 | 确定主轴父级尺寸（百分比基准） | `CalculateLayout` |
| 3 | 计算子元素 flex basis（`computeFlexBasisForChildren`） | `FlexBasis` |
| 4 | 收集子元素到 flex 行（`calculateFlexLine`），含 gap 感知换行 | `FlexLine` |
| 5 | 两遍弹性长度解析（`resolveFlexibleLength`）：min/max 约束触发检测 + 空间分配 | `FlexLine` |
| 6 | 主轴对齐（`justifyMainAxis`）：支持 8 种 justify-content + auto margins | `JustifyAlign` |
| 7 | 交叉轴对齐：stretch / baseline / flex-start / flex-end / center | `CalculateLayout` |
| 8 | 多行 align-content 分布 | `CalculateLayout` |
| 9 | 计算最终容器尺寸，应用 min/max 约束 | `CalculateLayout` |
| 10 | wrap-reverse 翻转 + reverse 方向的 trailing 位置 | `CalculateLayout` |
| 11 | 布局 absolute 后代 | `AbsoluteLayout` |

### Flexbox 支持属性

| 属性 | 支持的值 |
|------|----------|
| `flexDirection` | `column` / `columnReverse` / `row` / `rowReverse`（含 RTL 解析） |
| `justifyContent` | `flexStart` / `flexEnd` / `center` / `spaceBetween` / `spaceAround` / `spaceEvenly` / `start` / `end` |
| `alignItems` / `alignSelf` | `auto` / `flexStart` / `flexEnd` / `center` / `baseline` / `stretch` / `start` / `end` / `spaceBetween` / `spaceAround` / `spaceEvenly` |
| `alignContent` | 同上（控制多行交叉轴分布） |
| `flexWrap` | `noWrap` / `wrap` / `wrapReverse` |
| `flex`（简写） | 支持 `flexGrow` > 0 时 basis = 0 |
| `flexGrow` / `flexShrink` / `flexBasis` | points, percent, auto, max-content, fit-content |

### Flexbox 高级特性
- **auto margins**：吸收主轴剩余空间，实现居中/右对齐
- **gap 支持**：row-gap / column-gap（points, percent），已计入换行判断
- **baseline 对齐**：跨行基线跟踪，递归基线计算
- **单 flex 子元素优化**：stretch-fit 容器中只有一个弹性子元素时跳过测量
- **sizeBasedOnContent**：非 stretch-fit 模式下的内容驱动尺寸
- **overflow 检测**：主轴/交叉轴溢出传播（`hadOverflow`）

---

## 二、CSS Grid 布局

完整的 CSS Grid 布局算法（纯 Swift 实现，Yoga C++ 无此实现）。

| 阶段 | 功能 | 对应文件 |
|------|------|----------|
| 1 | 解析网格模板轨道：固定 / 百分比 / `minmax()` / `auto` | `GridLayout` |
| 2 | 元素放置：确定位置 + auto-placement（row-major 稀疏） | `GridLayout` |
| 3 | 间隙解析（column-gap / row-gap） | `GridLayout` |
| 4 | 轨道尺寸算法：初始化 → 固有尺寸 → fr 分布 → 拉伸 | `GridLayout` |
| 5 | 计算轨道位置（前缀和） | `GridLayout` |
| 6 | 定位网格项 + justify-self / align-self 对齐 | `GridLayout` |
| 7 | 容器尺寸 + min/max 约束 | `GridLayout` |
| 8 | Absolute 子元素布局 | `GridLayout` |

### Grid 支持属性

| 属性 | 说明 |
|------|------|
| `gridTemplateColumns` / `gridTemplateRows` | 显式轨道定义列表 |
| `gridAutoColumns` / `gridAutoRows` | 隐式轨道尺寸 |
| `gridColumnStart` / `gridColumnEnd` | 列线位置（`auto` / `integer` / `span N`） |
| `gridRowStart` / `gridRowEnd` | 行线位置（同上） |
| `columnGap` / `rowGap` | 轨道间距 |

### Grid 轨道类型

| 类型 | 说明 |
|------|------|
| `.points(n)` | 固定尺寸 |
| `.percent(n)` | 百分比尺寸 |
| `.fr(n)` | 弹性单位（按比例分配剩余空间） |
| `.auto()` | 自动尺寸 |
| `.minmax(min, max)` | 最小/最大尺寸限制 |

### Grid 高级特性
- **Auto-placement**：先放置确定位置的元素，再基于 cursor 自动放置
- **fr 分布**：`spacePerFr = available / sum(fr)`，按比例分配
- **间隙处理**：间隙计入学空间，不在轨道中嵌入
- **隐式轨道**：超出显式轨道数量时自动生成
- **轨道状态**：baseSize / growthLimit / infinitelyGrowable（用于跨轨道分配）

---

## 三、定位系统

| 定位模式 | 说明 | 文件 |
|----------|------|------|
| `static` | 默认流式定位 | — |
| `relative` | 相对偏移（inline-start/end） | `YogaNode` |
| `absolute` | 绝对定位（脱离流，相对于 containing block） | `AbsoluteLayout` |

### Absolute 布局特性
- inset 属性：`top` / `left` / `right` / `bottom` / `start` / `end`
- inline-start 优先于 inline-end 定位
- 未定义 inset 时回退到父节点 justify-content / align-items
- flex-start / flex-end / center 三种定位模式
- containing block 边框/内边距处理
- RTL 支持
- 递归 absolute 后代遍历
- Errata 兼容标记

---

## 四、CSS 属性支持

### 尺寸属性
- `width` / `height` — points, percent, auto, max-content, fit-content
- `minWidth` / `minHeight` / `maxWidth` / `maxHeight`

### 盒模型
- `margin` — 9 边：left / top / right / bottom / start / end / horizontal / vertical / all
- `padding` — 同上
- `border` — 同上
- `boxSizing` — `borderBox` / `contentBox`

### 其他属性
- `overflow` — `visible` / `hidden` / `scroll`
- `display` — `flex` / `none` / `contents` / `grid`
- `direction` — `inherit` / `ltr` / `rtl`
- `aspectRatio` — 比例推导（flexbox + absolute）
- `position` — `static` / `relative` / `absolute`

### 逻辑属性
完整的 CSS 逻辑属性解析：
- `start` / `end` → 根据 direction (LTR/RTL) 映射到物理边
- `horizontal` → left + right
- `vertical` → top + bottom
- `all` → 四边统一设置

---

## 五、单位系统

| 单位 | 枚举值 | 说明 |
|------|--------|------|
| `.undefined` | `GWUnit.undefined` | 未定义（NaN） |
| `.point` | `GWUnit.point` | 固定像素值 |
| `.percent` | `GWUnit.percent` | 百分比（参考父容器对应尺寸） |
| `.auto` | `GWUnit.auto` | 自动（flex-basis、margin 等） |
| `.maxContent` | `GWUnit.maxContent` | 最大内容尺寸 |
| `.fitContent` | `GWUnit.fitContent` | 适应内容尺寸 |
| `.stretch` | `GWUnit.stretch` | 弹性尺寸（fr 单位） |

---

## 六、特性功能

### 像素网格对齐
- 按 `pointScaleFactor` 递归取整布局结果
- 强制向上/向下取整
- 文本节点特殊处理（不向下取整防止截断）

### 缓存系统
- 基于 generation 的缓存失效
- 1 个主缓存布局条目 + 8 个测量条目环形缓冲区
- margin-aware 缓存比较（含取整）
- 固定尺寸提前退出优化

### Errata 兼容
- `stretchFlexBasis` — 旧版 stretch 行为
- `absolutePositionWithoutInsetsExcludesPadding` — 绝对定位排除内边距
- `absolutePercentAgainstInnerSize` — 百分比相对于内部尺寸

### 实验特性
- `webFlexBasis` — Web 标准的 flex-basis 行为
- `fixFlexBasisFitContent` — fitContent 模式下 flex-basis 修复

### 事件系统
- 布局生命周期事件：`layoutPassStart` / `layoutPassEnd`
- 节点事件：`nodeLayout` / `nodeAllocation` / `nodeDeallocation`
- 测量回调事件
- 布局统计（`GWLayoutData`）：布局次数 / 缓存命中率 / 测量次数

### display: contents
- 在布局遍历中提升 contents 子元素的子元素
- 清零 contents 节点的布局输出

---

## 七、Swift API

### GWYogaNode（引用类型）
- 树管理：`insertChild` / `removeChild` / `replaceChild` / `removeAllChildren`
- 布局：`calculateLayout(width:height:direction:)`
- 结果：`layoutResult` / `computedMargin` / `computedBorder` / `computedPadding`
- 回调：`measureFunction` / `baselineFunction` / `dirtiedHandler`
- 便捷属性：所有 CSS 属性的 setter/getter（自动触发 `markDirty`）

### GWStyle（值类型）
- 所有 CSS 属性的值类型容器
- `sendable` / `equatable`
- `useWebDefaults()` 方法

### GWYogaConfig
- `useWebDefaults` / `pointScaleFactor` / `errata` / `experimentalFeatures`
- 自动版本号递增

### 辅助类型
- `GWFloatOptional` — NaN 表示未定义的浮点包装
- `GWValue` — 公共 CSS 值类型（value + unit）
- `GWLayoutResult` — 布局结果
- `GWGridTrackSize` / `GWGridLine` — 网格类型

---

## 八、对比测试

通过 **95/95** Yoga C 库对比测试，覆盖：

| 类别 | 测试数 | 覆盖范围 |
|------|--------|----------|
| 基础尺寸 | 6 | 固定、分数、auto、百分比、max-content、fit-content |
| Flex 方向 | 3 | column、column-reverse、row-reverse |
| Justify | 5 | flex-start、flex-end、space-around、space-evenly、center |
| Align items | 4 | flex-start、flex-end、baseline、stretch |
| Align self | 4 | center、flex-end、stretch、baseline |
| Align content | 7 | flex-start、center、flex-end、stretch、space-between、around、evenly |
| Flex grow/shrink/basis | 9 | 分数增长/收缩、column、basis points/percent/auto/max-content/fit-content |
| Margin | 4 | 全边、auto、双 auto、百分比 |
| Padding | 2 | 固定、百分比 |
| Border | 2 | 统一、不同边 |
| Position / Absolute | 5 | 位置点、auto 尺寸、百分比、static、嵌套 |
| Min / Max | 5 | min/max width/height、百分比 |
| Wrap / Gap | 5 | wrap-reverse、row/column/percent gap、wrap+gap |
| Aspect ratio | 4 | 宽度/高度推导、非整数、flex-grow |
| Display / Overflow | 3 | none、hidden、scroll |
| Box sizing | 2 | content-box、content-box+border |
| Direction RTL | 3 | 基本 RTL、margin start/end、padding start |
| 复杂/边界 | 7 | web 默认、深层嵌套、多子元素、混合、combined、auto margin、align+wrap |
| 扩展布局 | 2 | margin/border/padding、RTL |
| 自动尺寸 + 其他 | 8 | auto width/height、百分比 basis、百分比 absolute、overflow、intrinsic、嵌套百分比、static-in-absolute |
| CSS Grid | 5 | 2x2、fr 单位、间隙、混合 fixed+fr、auto-placement |

---

## 九、项目结构

```
GWYoga/
├── GWYoga+Layout.swift          # 入口：enum 声明、calculateLayout、像素网格、缓存层
├── GWYoga+CalculateLayout.swift # 11 步 flexbox 算法
├── GWYoga+FlexLine.swift        # Flex 行收集、弹性长度解析（两遍分布）
├── GWYoga+JustifyAlign.swift    # 主轴对齐
├── GWYoga+FlexBasis.swift       # Flex basis 计算（含内容测量）
├── GWYoga+LayoutHelpers.swift   # 辅助函数：bound、baseline、缓存检查、约束
├── GWYoga+AbsoluteLayout.swift  # Absolute 子元素布局
├── GWYoga+GridLayout.swift      # CSS Grid 布局算法
├── GWEnums.swift                # 枚举定义
├── GWStyle.swift                # 样式系统
├── GWGrid.swift                 # 网格类型
├── GWTypes.swift                # 值类型（GWValue、GWStyleLength）
├── GWLayoutResult.swift         # 布局结果
├── GWLayoutCache.swift          # 缓存结构
├── GWYogaNode.swift             # 节点类
├── GWYogaConfig.swift           # 配置
├── GWComparison.swift           # 数值比较函数
├── GWEvent.swift                # 事件系统
├── GWFloatOptional.swift        # 可选浮点类型
├── GWAssertFatal.swift          # 断言
└── GWLog.swift                  # 日志
```
