import XCTest
import GWYoga
#if canImport(GWYogaKitStylesheet)
import GWYogaKitStylesheet
#endif
#if canImport(GWYogaKit)
import GWYogaKit
#endif

// ============================================================
// GWYoga API 完整演示
//
// 运行方式: swift test --filter GWYogaAPIDemo
//
// 每个测试方法演示一组 API 的用法，包含:
//   1. 实例代码（带中文注释）
//   2. 运行布局计算
//   3. 打印布局结果 + ASCII 可视化
// ============================================================

final class GWYogaAPIDemoTests: XCTestCase {

    // MARK: - 辅助方法

    /// 绘制单个节点的布局信息
    private func printNode(_ node: GWYogaNode, label: String = "", indent: Int = 0) {
        let pad = String(repeating: "  ", count: indent)
        let r = node.layoutResult
        let labelStr = label.isEmpty ? "" : " (\(label))"
        print("\(pad)├─ \(node.nodeType == .text ? "Text" : "Node")\(labelStr)")
        print("\(pad)│  left=\(r.left, spec: "0.0") top=\(r.top, spec: "0.0")")
        print("\(pad)│  width=\(r.width, spec: "0.0") height=\(r.height, spec: "0.0")")
        if r.hadOverflow {
            print("\(pad)│  ⚠️ overflow")
        }
        for child in node.children {
            printNode(child, indent: indent + 1)
        }
    }

    /// 绘制简单的 ASCII 盒图（仅一层的容器）
    private func printBox(_ root: GWYogaNode, title: String) {
        let r = root.layoutResult
        let w = Int(min(r.width, 80))
        let h = Int(min(r.height, 20))
        guard w > 0, h > 0 else {
            print("  [empty or zero-sized]")
            return
        }
        print("  ┌" + String(repeating: "─", count: max(w, 1)) + "┐")
        // 把子节点画在盒子里
        var childLines: [String] = []
        for c in root.children {
            let cr = c.layoutResult
            let cl = Int(cr.left)
            let cw = Int(cr.width)
            let ct = Int(cr.top)
            _ = Int(cr.height)
            let name = c.nodeType == .text ? "Tx" : "C\(childLines.count+1)"
            let content = "\(name) \(Int(cr.width))×\(Int(cr.height))"
            if ct < h && cl < w {
                let line = String(repeating: " ", count: max(0, cl))
                    + content.prefix(max(1, cw))
                childLines.append(line)
            }
        }
        // 简化: 只画前几行
        for line in childLines.prefix(3) {
            print("  │\(line.prefix(w))│")
        }
        print("  └" + String(repeating: "─", count: max(w, 1)) + "┘")
    }

    /// 打印分隔线
    private func section(_ name: String) {
        print("\n══════════════════════════════════════════════")
        print("  \(name)")
        print("══════════════════════════════════════════════\n")
    }

    private func subsection(_ name: String) {
        print("\n─── \(name) ───\n")
    }

    // ============================================================
    // 1. 节点创建与树管理
    // ============================================================

    func testDemoNodeCreation() {
        section("1. 节点创建与树管理 (Node Creation & Tree Management)")

        // --- 创建节点 ---
        // GWYogaNode 是布局树的基本单元，每个节点代表一个矩形区域
        subsection("创建节点")
        let root = GWYogaNode()
        root.style.setWidth(.points(400))    // 设置宽度 400pt
        root.style.setHeight(.points(300))   // 设置高度 300pt
        print("  ✅ root 节点已创建: width=400, height=300")

        // --- 插入子节点 ---
        subsection("插入子节点 (insertChild)")
        let child1 = GWYogaNode()
        child1.style.setWidth(.points(100))
        child1.style.setHeight(.points(100))
        root.insertChild(child1, at: 0)
        print("  ✅ child1 插入到位置 0: 100×100")

        let child2 = GWYogaNode()
        child2.style.setWidth(.points(100))
        child2.style.setHeight(.points(100))
        root.insertChild(child2, at: 1)
        print("  ✅ child2 插入到位置 1: 100×100")

        // --- 节点属性 ---
        subsection("节点属性")
        print("  childCount = \(root.childCount)")           // 子节点数量
        print("  isDirty = \(root.isDirty)")                  // 是否需要重新布局
        print("  hasNewLayout = \(root.hasNewLayout)")        // 是否有新布局结果
        print("  owner = \(root.owner == nil ? "nil (root)" : "has owner")")

        // --- 替换子节点 ---
        subsection("替换子节点 (replaceChild)")
        let replacement = GWYogaNode()
        replacement.style.setWidth(.points(150))
        replacement.style.setHeight(.points(80))
        root.replaceChild(at: 0, with: replacement)
        print("  ✅ 替换位置 0 为 150×80 的新节点")
        print("  childCount after replace = \(root.childCount)")

        // 把原来的 child1 加回来
        root.insertChild(child1, at: 0)
        print("  ✅ 重新插入 child1 到位置 0")
        print("  childCount = \(root.childCount)")

        // --- 删除节点 ---
        subsection("删除节点 (removeChild)")
        root.removeChild(replacement)
        print("  ✅ 删除 replacement 节点")
        print("  childCount after remove = \(root.childCount)")

        // --- 布局计算 ---
        root.calculateLayout(width: 400, height: 300, direction: .ltr)
        print("\n📊 布局结果:")
        printNode(root)
    }

    // ============================================================
    // 2. 尺寸 (Dimensions) — width, height, min/max
    // ============================================================

    func testDemoDimensions() {
        section("2. 尺寸设置 (Dimensions)")

        let root = GWYogaNode()
        root.style.flexDirection = .row
        root.style.setWidth(.points(500))
        root.style.setHeight(.points(200))

        // --- 固定尺寸 ---
        subsection("固定尺寸: .points(value)")
        let fixed = GWYogaNode()
        fixed.style.setWidth(.points(200))    // 固定 200pt 宽
        fixed.style.setHeight(.points(100))   // 固定 100pt 高
        root.insertChild(fixed, at: 0)
        print("  ✅ 固定尺寸: width=200, height=100")

        // --- 百分比尺寸 ---
        subsection("百分比尺寸: .percent(value)")
        let pct = GWYogaNode()
        pct.style.setWidth(.percent(50))      // 父容器宽度的 50%
        pct.style.setHeight(.percent(100))    // 父容器高度的 100%
        root.insertChild(pct, at: 1)
        print("  ✅ 百分比尺寸: width=50%, height=100%")

        // --- 最小/最大尺寸 ---
        subsection("最小/最大尺寸: minWidth / maxHeight")
        let clamped = GWYogaNode()
        clamped.style.setWidth(.points(100))
        clamped.style.setHeight(.points(50))
        clamped.style.minWidth = .points(150)      // 最小宽 150pt（覆盖 width）
        clamped.style.maxHeight = .points(200)     // 最大高 200pt
        root.insertChild(clamped, at: 2)
        print("  ✅ minWidth=150 (覆盖 width=100) → 最终 150")
        print("  ✅ maxHeight=200 (height=50 < 200) → 最终 50")

        // --- 自动尺寸 ---
        subsection("自动尺寸: .auto")
        let auto = GWYogaNode()
        auto.style.setWidth(.auto)    // flexbox 中 auto 表示由内容决定
        auto.style.setHeight(.points(100))
        root.insertChild(auto, at: 3)
        print("  ✅ auto 宽度: 由 flexbox 分配")

        // --- 快捷方式 ---
        subsection("快捷属性")
        let shortcut = GWYogaNode()
        shortcut.width = .points(80)     // 通过便捷属性设置
        shortcut.height = .points(80)
        root.insertChild(shortcut, at: 4)
        print("  ✅ 使用快捷属性: node.width = .points(80)")

        root.calculateLayout(width: 500, height: 200, direction: .ltr)
        print("\n📊 布局结果:")
        printBox(root, title: "Dimensions Demo")
        printNode(root)
    }

    // ============================================================
    // 3. 弹性盒 (Flexbox)
    // ============================================================

    func testDemoFlexbox() {
        section("3. 弹性盒布局 (Flexbox)")

        // --- flexDirection: 主轴方向 ---
        subsection("flexDirection")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(400))
            root.style.setHeight(.points(200))
            root.style.flexDirection = .row   // 水平布局（默认是 column）

            for i in 0..<3 {
                let c = GWYogaNode()
                c.style.setWidth(.points(100))
                c.style.setHeight(.points(100))
                root.insertChild(c, at: i)
            }

            root.calculateLayout(width: 400, height: 200, direction: .ltr)
            print("  flexDirection = .row → 子节点水平排列")
            for (i, c) in root.children.enumerated() {
                print("    child\(i+1): left=\(c.layoutResult.left, spec: "0.0")")
            }
            printBox(root, title: "flexDirection: row")
        }

        // --- justifyContent: 主轴对齐 ---
        subsection("justifyContent")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(400))
            root.style.setHeight(.points(100))
            root.style.flexDirection = .row
            root.style.justifyContent = .spaceBetween  // 两端对齐

            for i in 0..<3 {
                let c = GWYogaNode()
                c.style.setWidth(.points(80))
                c.style.setHeight(.points(60))
                root.insertChild(c, at: i)
            }

            root.calculateLayout(width: 400, height: 100, direction: .ltr)
            print("  justifyContent = .spaceBetween → 子节点两端分布")
            for (i, c) in root.children.enumerated() {
                print("    child\(i+1): left=\(c.layoutResult.left, spec: "0.0")")
            }
        }

        // --- alignItems: 交叉轴对齐 ---
        subsection("alignItems")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(300))
            root.style.setHeight(.points(150))
            root.style.flexDirection = .row
            root.style.alignItems = .center    // 交叉轴居中

            for i in 0..<3 {
                let c = GWYogaNode()
                c.style.setWidth(.points(60))
                c.style.setHeight(i == 1 ? .points(100) : .points(60))
                root.insertChild(c, at: i)
            }

            root.calculateLayout(width: 300, height: 150, direction: .ltr)
            print("  alignItems = .center → 子节点在交叉轴居中")
            for (i, c) in root.children.enumerated() {
                print("    child\(i+1): top=\(c.layoutResult.top, spec: "0.0") height=\(c.layoutResult.height, spec: "0.0")")
            }
        }

        // --- flexGrow / flexShrink ---
        subsection("flexGrow / flexShrink")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(300))
            root.style.setHeight(.points(100))
            root.style.flexDirection = .row

            let g1 = GWYogaNode()
            g1.style.setWidth(.points(50))
            g1.style.setHeight(.points(50))
            g1.flexGrow = 1     // 按比例占据剩余空间
            root.insertChild(g1, at: 0)

            let g2 = GWYogaNode()
            g2.style.setWidth(.points(50))
            g2.style.setHeight(.points(50))
            g2.flexGrow = 2     // g1:g2 = 1:2 分配 200pt 剩余空间
            root.insertChild(g2, at: 1)
            // g1 最终宽 = 50 + 200*1/3 ≈ 116.7
            // g2 最终宽 = 50 + 200*2/3 ≈ 183.3

            root.calculateLayout(width: 300, height: 100, direction: .ltr)
            print("  flexGrow: g1=1, g2=2 (剩余 200pt 按 1:2 分配)")
            print("    g1.width=\(g1.layoutResult.width, spec: "0.1")")
            print("    g2.width=\(g2.layoutResult.width, spec: "0.1")")
        }

        // --- flexWrap: 换行 ---
        subsection("flexWrap")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(200))
            root.style.setHeight(.points(200))
            root.style.flexDirection = .row
            root.style.flexWrap = .wrap    // 允许换行

            for i in 0..<5 {
                let c = GWYogaNode()
                c.style.setWidth(.points(80))
                c.style.setHeight(.points(80))
                root.insertChild(c, at: i)
            }

            root.calculateLayout(width: 200, height: 200, direction: .ltr)
            print("  flexWrap = .wrap → 超宽自动换行")
            for (i, c) in root.children.enumerated() {
                let r = c.layoutResult
                print("    child\(i+1): left=\(r.left, spec: "0.0") top=\(r.top, spec: "0.0") \(r.width, spec: "0.0")×\(r.height, spec: "0.0")")
            }
        }

        // --- alignSelf: 单个子节点覆盖 alignItems ---
        subsection("alignSelf")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(300))
            root.style.setHeight(.points(100))
            root.style.flexDirection = .row
            root.style.alignItems = .flexStart  // 默认顶部对齐

            for i in 0..<3 {
                let c = GWYogaNode()
                c.style.setWidth(.points(60))
                c.style.setHeight(.points(40))
                if i == 1 {
                    c.style.alignSelf = .flexEnd  // 第二个子节点底部对齐
                }
                root.insertChild(c, at: i)
            }

            root.calculateLayout(width: 300, height: 100, direction: .ltr)
            print("  alignSelf: child2 使用 .flexEnd 覆盖父级的 .flexStart")
            for (i, c) in root.children.enumerated() {
                print("    child\(i+1): top=\(c.layoutResult.top, spec: "0.0")")
            }
        }
    }

    // ============================================================
    // 4. Margin / Padding / Border
    // ============================================================

    func testDemoEdgeProperties() {
        section("4. Margin / Padding / Border")

        let root = GWYogaNode()
        root.style.setWidth(.points(400))
        root.style.setHeight(.points(200))
        root.style.setPadding(for: .all, .points(20))  // 内边距 20pt
        root.style.flexDirection = .row

        // --- Margin ---
        subsection("Margin (外边距)")
        let child = GWYogaNode()
        child.style.setWidth(.points(100))
        child.style.setHeight(.points(100))
        child.style.setMargin(for: .all, .points(10))   // 四边 margin 10pt
        root.insertChild(child, at: 0)
        print("  ✅ margin = 10 (all sides)")
        print("     → 子节点占用空间 = 100 + 10*2 = 120pt")

        // --- Padding ---
        subsection("Padding (内边距)")
        print("  ✅ root padding = 20 (all sides)")
        print("     → 内容区从 (20, 20) 开始")

        // --- Border ---
        subsection("Border (边框宽度)")
        root.style.setBorder(for: .all, 2)  // 边框 2pt
        print("  ✅ border = 2 (all sides)")

        // --- 单边设置 ---
        subsection("单边设置")
        let specific = GWYogaNode()
        specific.style.setWidth(.points(80))
        specific.style.setHeight(.points(80))
        specific.style.setMargin(for: .left, .points(5))   // 左边距 5
        specific.style.setMargin(for: .top, .points(15))    // 上边距 15
        specific.style.setPadding(for: .right, .points(8))  // 右内边距 8
        root.insertChild(specific, at: 1)
        print("  ✅ margin.left=5, margin.top=15, padding.right=8")

        // --- 逻辑属性 (start/end) ---
        subsection("逻辑属性 (start/end)")
        logicalEdgeDemo()

        root.calculateLayout(width: 400, height: 200, direction: .ltr)
        print("\n📊 布局结果:")
        printNode(root)
    }

    /// 演示 CSS 逻辑属性 (start/end 根据 direction 自动切换)
    private func logicalEdgeDemo() {
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(100))
        root.style.flexDirection = .row

        let ltr_child = GWYogaNode()
        ltr_child.style.setWidth(.points(100))
        ltr_child.style.setHeight(.points(50))
        ltr_child.style.setMargin(for: .start, .points(20))  // LTR 下 = margin-left
        ltr_child.style.setMargin(for: .end, .points(10))    // LTR 下 = margin-right
        root.insertChild(ltr_child, at: 0)

        root.calculateLayout(width: 300, height: 100, direction: .ltr)
        print("  LTR direction: margin-start=20 (left), margin-end=10 (right)")
        print("  left=\(ltr_child.layoutResult.left, spec: "0.0") (受 margin-start=20 影响)")
    }

    // ============================================================
    // 5. 定位 (Position) — relative / absolute
    // ============================================================

    func testDemoPosition() {
        section("5. 定位 (Position)")

        // --- Relative 定位 ---
        subsection("Relative 定位 (position: .relative)")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(400))
            root.style.setHeight(.points(200))
            root.style.flexDirection = .row

            let normal = GWYogaNode()
            normal.style.setWidth(.points(100))
            normal.style.setHeight(.points(100))
            root.insertChild(normal, at: 0)

            let relative = GWYogaNode()
            relative.style.setWidth(.points(100))
            relative.style.setHeight(.points(100))
            relative.style.setPosition(for: .top, .points(20))   // 相对偏移 +20pt
            relative.style.setPosition(for: .left, .points(10))  // 相对偏移 +10pt
            root.insertChild(relative, at: 1)
            print("  ✅ relative 定位: top=20, left=10 (不影响兄弟节点)")

            let normal2 = GWYogaNode()
            normal2.style.setWidth(.points(100))
            normal2.style.setHeight(.points(100))
            root.insertChild(normal2, at: 2)

            root.calculateLayout(width: 400, height: 200, direction: .ltr)
            for (i, c) in root.children.enumerated() {
                print("    child\(i+1): left=\(c.layoutResult.left, spec: "0.0") top=\(c.layoutResult.top, spec: "0.0")")
            }
        }

        // --- Absolute 定位 ---
        subsection("Absolute 定位 (position: .absolute)")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(400))
            root.style.setHeight(.points(250))
            root.style.setPadding(for: .all, .points(20))

            // 正常流中的子节点
            let normal = GWYogaNode()
            normal.style.setWidth(.points(100))
            normal.style.setHeight(.points(100))
            root.insertChild(normal, at: 0)

            // 绝对定位子节点（脱离文档流）
            let absolute = GWYogaNode()
            absolute.style.positionType = .absolute
            absolute.style.setWidth(.points(80))
            absolute.style.setHeight(.points(80))
            absolute.style.setPosition(for: .top, .points(30))    // 距离容器顶部 30
            absolute.style.setPosition(for: .left, .points(250))  // 距离容器左边 250
            root.insertChild(absolute, at: 1)
            print("  ✅ absolute 定位: top=30, left=250 (脱离文档流)")

            root.calculateLayout(width: 400, height: 250, direction: .ltr)
            for (i, c) in root.children.enumerated() {
                let r = c.layoutResult
                print("    child\(i+1): left=\(r.left, spec: "0.0") top=\(r.top, spec: "0.0") \(r.width, spec: "0.0")×\(r.height, spec: "0.0") posType=\(c.style.positionType)")
            }
        }
    }

    // ============================================================
    // 6. Gap（间距）
    // ============================================================

    func testDemoGap() {
        section("6. Gap（间距）")

        let root = GWYogaNode()
        root.style.setWidth(.points(350))
        root.style.setHeight(.points(100))
        root.style.flexDirection = .row
        root.style.setGap(for: .column, .points(20))  // 子节点间水平间距 20
        root.style.setGap(for: .row, .points(10))     // 子节点间垂直间距 10

        for i in 0..<3 {
            let c = GWYogaNode()
            c.style.setWidth(.points(80))
            c.style.setHeight(.points(60))
            root.insertChild(c, at: i)
        }

        root.calculateLayout(width: 350, height: 100, direction: .ltr)
        print("  columnGap=20, rowGap=10")
        print("  公式: 第一个子节点在 0, 之后每个 + width + gap")
        for (i, c) in root.children.enumerated() {
            print("    child\(i+1): left=\(c.layoutResult.left, spec: "0.0") (期望: \(i * 100))")
        }
        print("  总宽: 80 + 20 + 80 + 20 + 80 = 280")
    }

    // ============================================================
    // 7. Aspect Ratio（宽高比）
    // ============================================================

    func testDemoAspectRatio() {
        section("7. Aspect Ratio（宽高比）")

        // 宽高比: width / height = aspectRatio
        // 设置 aspectRatio = 2 → 宽度是高度的 2 倍
        subsection("aspectRatio = 2 (宽:高 = 2:1)")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(200))
            root.style.setHeight(.points(200))

            let child = GWYogaNode()
            child.style.setHeight(.points(80))    // 固定高度
            child.style.aspectRatio = .init(value: 2)  // width = 80 * 2 = 160
            root.insertChild(child, at: 0)

            root.calculateLayout(width: 200, height: 200, direction: .ltr)
            print("  aspectRatio=2, height=80 → width=\(child.layoutResult.width, spec: "0.0") (期望 160)")
        }

        // 另一种用法: 根据宽度推高度
        subsection("aspectRatio = 1.5 (根据宽推高)")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(200))
            root.style.setHeight(.points(200))

            let child = GWYogaNode()
            child.style.setWidth(.points(120))     // 固定宽度
            child.style.aspectRatio = .init(value: 1.5)  // height = 120 / 1.5 = 80
            root.insertChild(child, at: 0)

            root.calculateLayout(width: 200, height: 200, direction: .ltr)
            print("  aspectRatio=1.5, width=120 → height=\(child.layoutResult.height, spec: "0.0") (期望 80)")
        }
    }

    // ============================================================
    // 8. Display
    // ============================================================

    func testDemoDisplay() {
        section("8. Display 属性")

        // --- display: .none ---
        subsection("display: .none → 节点隐藏，不参与布局")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(300))
            root.style.setHeight(.points(100))
            root.style.flexDirection = .row

            for i in 0..<3 {
                let c = GWYogaNode()
                c.style.setWidth(.points(80))
                c.style.setHeight(.points(60))
                if i == 1 {
                    c.style.display = .none     // 隐藏，不占空间
                }
                root.insertChild(c, at: i)
            }

            root.calculateLayout(width: 300, height: 100, direction: .ltr)
            print("  child2 被隐藏 (display: .none)")
            for (i, c) in root.children.enumerated() {
                let r = c.layoutResult
                print("    child\(i+1): display=\(c.style.display) left=\(r.left, spec: "0.0") width=\(r.width, spec: "0.0")")
            }
        }

        // --- display: .grid ---
        subsection("display: .grid → CSS 网格布局")
        gridDemo()

        // --- display: .contents ---
        subsection("display: .contents → 节点自身不渲染，子节点提升")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(300))
            root.style.setHeight(.points(100))
            root.style.flexDirection = .row

            // contents 容器自身不产生盒子，子节点直接成为父级的子节点
            let wrapper = GWYogaNode()
            wrapper.style.display = .contents
            root.insertChild(wrapper, at: 0)

            let c1 = GWYogaNode()
            c1.style.setWidth(.points(100))
            c1.style.setHeight(.points(60))
            wrapper.insertChild(c1, at: 0)

            let c2 = GWYogaNode()
            c2.style.setWidth(.points(100))
            c2.style.setHeight(.points(60))
            root.insertChild(c2, at: 1)

            root.calculateLayout(width: 300, height: 100, direction: .ltr)
            print("  display: .contents → wrapper 不产生盒子")
            // contents 子节点会被提升到父级 flex 容器中
            print("  c1 (in contents wrapper): left=\(c1.layoutResult.left, spec: "0.0")")
            print("  c2: left=\(c2.layoutResult.left, spec: "0.0")")
        }
    }

    /// 网格布局演示
    private func gridDemo() {
        let root = GWYogaNode()
        root.style.display = .grid
        root.style.setWidth(.points(400))
        root.style.gridTemplateColumns = [.fr(1), .fr(2), .fr(1)]  // 1:2:1
        root.style.gridTemplateRows = [.points(60)]
        root.style.setGap(for: .column, .points(10))

        for i in 0..<3 {
            let c = GWYogaNode()
            c.style.setHeight(.points(50))
            root.insertChild(c, at: i)
        }

        root.calculateLayout(width: 400, height: 100, direction: .ltr)
        print("  grid-template-columns: 1fr 2fr 1fr (gap=10)")
        print("  可用宽度 = 400, 总 fr = 4, 每 fr = 100")
        print("  各列: 100pt | 200pt | 100pt + gap(10)×2 = 420 > 400")
        print("  实际: fr 分配在扣除 gap 后进行")
        print("  可用宽度(减 gap) = 400 - 20 = 380, 每 fr = 95")
        for (i, c) in root.children.enumerated() {
            print("    col\(i+1): left=\(c.layoutResult.left, spec: "0.0") width=\(c.layoutResult.width, spec: "0.0")")
        }
    }

    // ============================================================
    // 9. 网格布局 (Grid Layout)
    // ============================================================

    func testDemoGrid() {
        section("9. 网格布局 (Grid Layout)")

        // --- 固定列宽 + 自动行高 ---
        subsection("固定列宽: grid-template-columns: 100px 200px")
        do {
            let root = GWYogaNode()
            root.style.display = .grid
            root.style.gridTemplateColumns = [.points(100), .points(200)]
            root.style.gridTemplateRows = [.points(50), .points(80)]

            for _ in 0..<4 {
                root.insertChild(GWYogaNode(), at: root.children.count)
            }

            root.calculateLayout(width: .nan, height: .nan, direction: .ltr)
            print("  2×2 固定大小网格")
            print("  容器: \(root.layoutResult.width, spec: "0.0")×\(root.layoutResult.height, spec: "0.0")")
            for (i, c) in root.children.enumerated() {
                print("    item\(i+1): left=\(c.layoutResult.left, spec: "0.0") top=\(c.layoutResult.top, spec: "0.0") size=\(c.layoutResult.width, spec: "0.0")×\(c.layoutResult.height, spec: "0.0")")
            }
        }

        // --- fr 单位 ---
        subsection("fr 单位: 1fr 1fr 1fr")
        do {
            let root = GWYogaNode()
            root.style.display = .grid
            root.style.setWidth(.points(300))
            root.style.gridTemplateColumns = [.fr(1), .fr(1), .fr(1)]

            for _ in 0..<3 {
                root.insertChild(GWYogaNode(), at: root.children.count)
            }

            root.calculateLayout(width: 300, height: .nan, direction: .ltr)
            print("  三等分容器: 每列 100pt")
            for (i, c) in root.children.enumerated() {
                print("    col\(i+1): left=\(c.layoutResult.left, spec: "0.0") width=\(c.layoutResult.width, spec: "0.0")")
            }
        }

        // --- 显式放置 ---
        subsection("显式放置 (grid-column-start/end)")
        do {
            let root = GWYogaNode()
            root.style.display = .grid
            root.style.gridTemplateColumns = [.points(80), .points(80), .points(80)]
            root.style.gridTemplateRows = [.points(50), .points(50)]

            let item = GWYogaNode()
            item.style.gridColumnStart = GWGridLine(type: .integer, value: 2)
            item.style.gridColumnEnd = GWGridLine(type: .integer, value: 4)
            root.insertChild(item, at: 0)

            root.calculateLayout(width: .nan, height: .nan, direction: .ltr)
            print("  grid-column: 2 / 4 → 跨越第 2~3 列")
            print("  left=\(item.layoutResult.left, spec: "0.0") width=\(item.layoutResult.width, spec: "0.0") (期望 left=80, width=160)")
        }

        // --- minmax ---
        subsection("minmax: 最小/最大轨道尺寸")
        do {
            let root = GWYogaNode()
            root.style.display = .grid
            root.style.setWidth(.points(200))
            root.style.gridTemplateColumns = [
                .minmax(min: .points(50), max: .points(100)),
                .minmax(min: .points(50), max: .points(100))
            ]

            for _ in 0..<2 {
                root.insertChild(GWYogaNode(), at: root.children.count)
            }

            root.calculateLayout(width: 200, height: .nan, direction: .ltr)
            print("  两列 minmax(50px, 100px), 容器宽 200pt")
            print("  无 stretch → 使用 min 值")
            for (i, c) in root.children.enumerated() {
                print("    col\(i+1): width=\(c.layoutResult.width, spec: "0.0") (期望 50)")
            }
        }

        // --- auto 轨道 ---
        subsection("auto 轨道填充剩余空间 (需 justifyContent: .stretch)")
        do {
            let root = GWYogaNode()
            root.style.display = .grid
            root.style.setWidth(.points(300))
            root.style.gridTemplateColumns = [.points(100), .auto(), .auto()]
            root.style.justifyContent = .stretch

            for _ in 0..<3 {
                root.insertChild(GWYogaNode(), at: root.children.count)
            }

            root.calculateLayout(width: 300, height: .nan, direction: .ltr)
            print("  列: 100px | auto | auto, justifyContent: stretch")
            for (i, c) in root.children.enumerated() {
                print("    col\(i+1): width=\(c.layoutResult.width, spec: "0.1")")
            }
        }

        // --- 显式行放置 ---
        subsection("grid-row-start/end (行跨度)")
        do {
            let root = GWYogaNode()
            root.style.display = .grid
            root.style.gridTemplateColumns = [.points(100)]
            root.style.gridTemplateRows = [.points(40), .points(40), .points(40)]

            let span = GWYogaNode()
            span.style.gridRowStart = GWGridLine(type: .integer, value: 1)
            span.style.gridRowEnd = GWGridLine(type: .integer, value: 3)
            root.insertChild(span, at: 0)

            root.calculateLayout(width: .nan, height: .nan, direction: .ltr)
            print("  grid-row: 1 / 3 → 跨越第 1~2 行")
            print("  top=\(span.layoutResult.top, spec: "0.0") height=\(span.layoutResult.height, spec: "0.0") (期望 top=0, height=80)")
        }

        // --- span 关键字 ---
        subsection("span 关键字: grid-column-end: span N")
        do {
            let root = GWYogaNode()
            root.style.display = .grid
            root.style.gridTemplateColumns = [.points(80), .points(80), .points(80)]

            let span = GWYogaNode()
            span.style.gridColumnEnd = GWGridLine(type: .span, value: 3)  // 跨越 3 列
            root.insertChild(span, at: 0)

            root.calculateLayout(width: .nan, height: .nan, direction: .ltr)
            print("  span 3 → 跨越全部 3 列")
            print("  width=\(span.layoutResult.width, spec: "0.0") (期望 240)")
        }
    }

    // ============================================================
    // 10. Measure Function（自定义测量函数）
    // ============================================================

    func testDemoMeasureFunction() {
        section("10. Measure Function（自定义测量函数）")

        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(100))
        root.style.flexDirection = .row

        // measure function 用于文本等需要自定尺寸的节点
        let text = GWYogaNode()
        text.nodeType = .text
        text.measureFunction = { node, width, widthMode, height, heightMode in
            // 模拟文本测量: "Hello World" 宽约 80pt, 高 20pt
            return GWSize(width: 80, height: 20)
        }
        text.style.setMargin(for: .all, .points(8))
        root.insertChild(text, at: 0)
        print("  ✅ 设置 measureFunction → 模拟文本 'Hello World'")

        let text2 = GWYogaNode()
        text2.nodeType = .text
        text2.measureFunction = { node, width, widthMode, height, heightMode in
            // 支持约束: widthMode 指示可用宽度
            let actualWidth: Float
            switch widthMode {
            case .exactly: actualWidth = width        // 固定宽度
            case .atMost:  actualWidth = min(width, 120) // 最大宽度限制
            case .undefined: actualWidth = 120         // 无限制
            }
            return GWSize(width: actualWidth, height: 20)
        }
        root.insertChild(text2, at: 1)

        root.calculateLayout(width: 300, height: 100, direction: .ltr)
        print("📊 文本节点布局:")
        print("  text1: width=\(text.layoutResult.width, spec: "0.0") height=\(text.layoutResult.height, spec: "0.0")")
        print("  text2: width=\(text2.layoutResult.width, spec: "0.0") height=\(text2.layoutResult.height, spec: "0.0")")
    }

    // ============================================================
    // 11. 布局结果查询
    // ============================================================

    func testDemoLayoutResults() {
        section("11. 布局结果查询 (Layout Results)")

        let root = GWYogaNode()
        root.style.setWidth(.points(400))
        root.style.setHeight(.points(200))
        root.style.setPadding(for: .all, .points(15))
        root.style.setMargin(for: .all, .points(10))
        root.style.setBorder(for: .all, 2)
        root.style.flexDirection = .row
        root.style.justifyContent = .center

        let c = GWYogaNode()
        c.style.setWidth(.points(100))
        c.style.setHeight(.points(80))
        c.style.setMargin(for: .all, .points(5))
        root.insertChild(c, at: 0)

        root.calculateLayout(width: 420, height: 220, direction: .ltr)
        print("  📊 layoutResult: 直接获取布局结果")
        let r = c.layoutResult
        print("    left=\(r.left, spec: "0.0") top=\(r.top, spec: "0.0")")
        print("    width=\(r.width, spec: "0.0") height=\(r.height, spec: "0.0")")
        print("    right=\(r.right, spec: "0.0") bottom=\(r.bottom, spec: "0.0")")
        print("    direction=\(r.direction)")
        print("    hadOverflow=\(r.hadOverflow)")

        print("\n  📊 computedMargin: 计算后的 margin")
        print("    marginLeft=\(c.computedMargin(for: .left), spec: "0.0")")
        print("    marginTop=\(c.computedMargin(for: .top), spec: "0.0")")

        print("\n  📊 computedPadding: 计算后的 padding")
        print("    paddingLeft=\(c.computedPadding(for: .left), spec: "0.0")")

        print("\n  📊 computedBorder:")
        print("    borderLeft=\(c.computedBorder(for: .left), spec: "0.0")")
    }

    // ============================================================
    // 12. 配置 (Config)
    // ============================================================

    func testDemoConfig() {
        section("12. 配置 (Config)")

        // --- 使用 Web 默认值 ---
        subsection("Web 默认值: useWebDefaults")
        let webConfig = GWYogaConfig()
        webConfig.useWebDefaults = true
        let webNode = GWYogaNode(config: webConfig)
        print("  ✅ useWebDefaults = true")
        print("     flexDirection = \(webNode.style.flexDirection) (web: row, 非 web: column)")
        print("     alignContent = \(webNode.style.alignContent) (web: stretch, 非 web: flexStart)")

        // --- 点缩放 ---
        subsection("点缩放: pointScaleFactor")
        let retinaConfig = GWYogaConfig()
        retinaConfig.pointScaleFactor = 2  // @2x 屏幕
        let retinaNode = GWYogaNode(config: retinaConfig)
        retinaNode.style.setWidth(.points(100))
        retinaNode.style.setHeight(.points(50))

        let retinaChild = GWYogaNode()
        retinaChild.style.setWidth(.points(37.5))  // 半像素
        retinaChild.style.setHeight(.points(25))
        retinaNode.insertChild(retinaChild, at: 0)

        retinaNode.calculateLayout(width: 100, height: 50, direction: .ltr)
        print("  ✅ pointScaleFactor = 2 (@2x)")
        print("     37.5pt → 75.0px → 取整 75px → \(retinaChild.layoutResult.width, spec: "0.0")pt")

        // --- Errata ---
        subsection("Errata 错误修复标记")
        let config = GWYogaNode().config
        print("  config errata = \(config.errata)")
        print("  config useWebDefaults = \(config.useWebDefaults)")
    }

    // ============================================================
    // 13. 空节点 & 单节点
    // ============================================================

    func testDemoSpecialCases() {
        section("13. 特殊情况")

        subsection("空容器（无子节点）")
        do {
            let root = GWYogaNode()
            root.style.setWidth(.points(200))
            root.style.setHeight(.points(100))
            root.calculateLayout(width: 200, height: 100, direction: .ltr)
            print("  容器尺寸: \(root.layoutResult.width, spec: "0.0")×\(root.layoutResult.height, spec: "0.0")")
        }

        subsection("measure function 叶节点")
        do {
            let leaf = GWYogaNode()
            leaf.measureFunction = { _, _, _, _, _ in
                GWSize(width: 100, height: 50)
            }
            leaf.calculateLayout(width: .nan, height: .nan, direction: .ltr)
            print("  measure leaf: \(leaf.layoutResult.width, spec: "0.0")×\(leaf.layoutResult.height, spec: "0.0")")
        }

        subsection("节点重置 (reset)")
        do {
            let node = GWYogaNode()
            node.style.setWidth(.points(100))
            node.context = "some context"
            print("  重置前: width=\(node.style.width)")
            node.reset()
            print("  重置后: width=\(node.style.width) (应为 auto)")
            print("  context=\(node.context as? String ?? "nil") (应为 nil)")
        }
    }

    // ============================================================
    // 14. CSS 选择器 (Selector)
    // ============================================================

    func testDemoSelector() {
        section("14. CSS 选择器 (YogaSelector)")
#if canImport(GWYogaKitStylesheet)
        // 选择器是 CSS 样式匹配的核心，支持各种 CSS 选择器语法

        subsection("通用选择器: *")
        let universal = try! YogaSelector.parse("*")
        print("  \(universal) → matches anything: \(universal.matches(tag: "div", classes: [], id: nil))")

        subsection("类型选择器: div, span, p")
        let type = try! YogaSelector.parse("div")
        print("  \(type) → matches 'div': \(type.matches(tag: "div", classes: [], id: nil))")
        print("  \(type) → matches 'span': \(type.matches(tag: "span", classes: [], id: nil))")

        subsection("类选择器: .container, .active")
        let cls = try! YogaSelector.parse(".active")
        print("  \(cls) → has 'active' class: \(cls.matches(tag: "div", classes: ["active"], id: nil))")
        print("  \(cls) → has 'inactive' class: \(cls.matches(tag: "div", classes: ["inactive"], id: nil))")

        subsection("ID 选择器: #header, #main")
        let id = try! YogaSelector.parse("#header")
        print("  \(id) → id='header': \(id.matches(tag: "div", classes: [], id: "header"))")
        print("  \(id) → id='footer': \(id.matches(tag: "div", classes: [], id: "footer"))")

        subsection("复合选择器: div.active#main")
        let compound = try! YogaSelector.parse("div.active#main")
        print("  \(compound)")
        print("  specificity = \(compound.specificity) → value=\(compound.specificityValue)")

        subsection("后代选择器: .parent .child")
        let descendant = try! YogaSelector.parse(".parent .child")
        print("  \(descendant)")

        subsection("子代选择器: .parent > .child")
        let child = try! YogaSelector.parse(".parent > .child")
        print("  \(child)")

        subsection("伪类: :hover, :first-child, :last-child, :nth-child(n)")
        let hover = try! YogaSelector.parse("button:hover")
        print("  \(hover)")
        let nth = try! YogaSelector.parse("li:nth-child(2)")
        print("  \(nth)")

        subsection("优先级 (Specificity)")
        print("  div          → \(try! YogaSelector.parse("div").specificityValue)")
        print("  .active      → \(try! YogaSelector.parse(".active").specificityValue)")
        print("  #main        → \(try! YogaSelector.parse("#main").specificityValue)")
        print("  div.active   → \(try! YogaSelector.parse("div.active").specificityValue)")
        print("  #main .a     → \(try! YogaSelector.parse("#main .a").specificityValue)")
        print("  div#main.a   → \(try! YogaSelector.parse("div#main.a").specificityValue)")
#else
        print("  [GWYogaKitStylesheet 不可用]")
#endif
    }

    // ============================================================
    // 15. CSS 解析 (CSS Parser & Stylesheet)
    // ============================================================

    func testDemoCSSParser() {
        section("15. CSS 解析与应用")
#if canImport(GWYogaKitStylesheet)
        subsection("解析 CSS 文本")
        let css = """
        /* 网格容器 */
        .container {
            width: 100%;
            padding: 16px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }
        .card {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 12px;
        }
        #header {
            height: 60px;
            background-color: #333;
        }
        div.content {
            margin: 10px;
        }
        """
        let rules = try! YogaCSSParser.parse(css)
        print("  解析 \(css.components(separatedBy: "\n").count) 行 CSS")
        print("  得到 \(rules.count) 条规则:")
        for (i, rule) in rules.enumerated() {
            print("    [\(i)] \"\(rule.selector)\" → \(rule.declarations.count) 个声明")
        }

        subsection("Stylesheet 创建与合并")
        let sheet1 = try! YogaStylesheet.parse(".a { width: 100px }")
        let sheet2 = try! YogaStylesheet.parse(".b { height: 200px }")
        let merged = YogaStylesheet.merge(sheet1, sheet2)
        print("  sheet1: \(sheet1.rules.count) 条规则")
        print("  sheet2: \(sheet2.rules.count) 条规则")
        print("  合并后: \(merged.rules.count) 条规则")

        subsection("按优先级排序")
        let css2 = """
        div { margin: 5px }
        .special { margin: 10px }
        #unique { margin: 15px }
        """
        let sheet = try! YogaStylesheet.parse(css2)
        print("  规则按 specificity 升序:")
        for rule in sheet.rules {
            print("    \"\(rule.selector)\" → specificity=\(rule.specificity)")
        }

        subsection("CSS 属性映射")
        let mapper = YogaCSSPropertyMapper.self

        // 长度值
        print("  '16px' → \(String(describing: mapper.parseLength("16px")!))")
        print("  '50%'  → \(String(describing: mapper.parseLength("50%")!))")
        print("  'auto' → \(String(describing: mapper.parseLength("auto")!))")
        print("  '1fr'  → \(String(describing: mapper.parseLength("1fr")!))")

        // Flexbox
        print("  'row' → \(mapper.parseFlexDirection("row")!)")
        print("  'wrap' → \(mapper.parseFlexWrap("wrap")!)")
        print("  'center'(justify) → \(mapper.parseJustifyContent("center")!)")

        // 网格轨道
        print("  '1fr 1fr' → \(mapper.parseTrackList("1fr 1fr")?.count ?? 0) tracks")
        print("  '100px auto 1fr' → \(mapper.parseTrackList("100px auto 1fr")?.count ?? 0) tracks")
#else
        print("  [GWYogaKitStylesheet 不可用]")
#endif
    }

    // ============================================================
    // 16. 数值类型演示
    // ============================================================

    func testDemoValueTypes() {
        section("16. 数值类型 (Value Types)")

        subsection("GWValue: 带单位的值")
        print("  .points(100) → value=100, unit=point")
        print("  .percent(50) → value=50, unit=percent")
        print("  .auto        → unit=auto")
        print("  .undefined   → unit=undefined")

        subsection("GWFloatOptional: 可空的 Float")
        let defined = GWFloatOptional(value: 42)
        let undef = GWFloatOptional.undefined
        print("  defined(42): isDefined=\(defined.isDefined), unwrap=\(defined.unwrap())")
        print("  undefined:   isDefined=\(undef.isDefined), orDefault=\(undef.unwrap(orDefault: 0))")

        subsection("GWStyleSizeLength: 尺寸长度")
        let pt = GWStyleSizeLength.points(100)
        let pct = GWStyleSizeLength.percent(50)
        let auto = GWStyleSizeLength.auto
        print("  .points(100) → \(pt)")
        print("  .percent(50) → \(pct)")
        print("  .auto        → \(auto)")

        subsection("GWGridLine: 网格线")
        let line = GWGridLine(type: .integer, value: 3)
        print("  integer(3) → type=\(line.type), value=\(line.value)")
        print("  .auto      → type=\(GWGridLine.auto.type)")
        print("  span(2)    → type=\(GWGridLine(type: .span, value: 2).type), value=2")

        subsection("GWGridTrackSize: 网格轨道")
        let fixed = GWGridTrackSize.points(100)
        let flex = GWGridTrackSize.fr(1)
        let minmax = GWGridTrackSize.minmax(min: .points(50), max: .points(100))
        print("  points(100) → isFixedMax=\(fixed.isFixedMax)")
        print("  fr(1)       → isMaxFlex=\(flex.isMaxFlex)")
        print("  minmax(50,100) → min=\(minmax.minSizingFunction), max=\(minmax.maxSizingFunction)")
    }

    // ============================================================
    // 17. 综合示例: 典型页面布局
    // ============================================================

    func testDemoCompositeLayout() {
        section("17. 综合示例：典型页面布局")

        // 模拟一个典型的移动端页面布局
        let page = GWYogaNode()
        page.style.flexDirection = .column
        page.style.setWidth(.points(375))   // iPhone 宽度
        page.style.setHeight(.points(812))  // iPhone 高度
        page.style.setPadding(for: .all, .points(16))

        // --- Header ---
        let header = GWYogaNode()
        header.style.flexDirection = .row
        header.style.justifyContent = .spaceBetween
        header.style.alignItems = .center
        header.style.setHeight(.points(44))
        header.style.setMargin(for: .bottom, .points(16))

        let backBtn = GWYogaNode()
        backBtn.style.setWidth(.points(60))
        backBtn.style.setHeight(.points(32))

        let title = GWYogaNode()
        title.style.setWidth(.points(150))
        title.style.setHeight(.points(20))

        let menuBtn = GWYogaNode()
        menuBtn.style.setWidth(.points(32))
        menuBtn.style.setHeight(.points(32))

        header.insertChild(backBtn, at: 0)
        header.insertChild(title, at: 1)
        header.insertChild(menuBtn, at: 2)
        page.insertChild(header, at: 0)

        // --- Content Grid ---
        let grid = GWYogaNode()
        grid.style.flexDirection = .row
        grid.style.flexWrap = .wrap
        grid.style.setGap(for: .column, .points(12))
        grid.style.setGap(for: .row, .points(12))
        grid.style.flexGrow = GWFloatOptional(value: 1)

        for i in 0..<6 {
            let card = GWYogaNode()
            card.style.setWidth(.points((375 - 16*2 - 12) / 2))  // 两列
            card.style.setHeight(.points(120))
            card.style.setBorder(for: .all, 1)
            card.style.setBorder(for: .all, 1)
            card.style.setPadding(for: .all, .points(12))
            grid.insertChild(card, at: i)

            // 卡片内部
            let cardTitle = GWYogaNode()
            cardTitle.style.setWidth(.percent(100))
            cardTitle.style.setHeight(.points(20))
            cardTitle.style.setMargin(for: .bottom, .points(8))
            card.insertChild(cardTitle, at: 0)

            let cardBody = GWYogaNode()
            cardBody.style.setWidth(.percent(100))
            cardBody.style.flexGrow = GWFloatOptional(value: 1)
            card.insertChild(cardBody, at: 1)
        }
        page.insertChild(grid, at: 1)

        // --- Footer ---
        let footer = GWYogaNode()
        footer.style.flexDirection = .row
        footer.style.justifyContent = .spaceAround
        footer.style.alignItems = .center
        footer.style.setHeight(.points(60))
        footer.style.setPadding(for: .all, .points(8))
        footer.style.setMargin(for: .top, .points(16))

        for i in 0..<4 {
            let tab = GWYogaNode()
            tab.style.setWidth(.points(40))
            tab.style.setHeight(.points(40))
            footer.insertChild(tab, at: i)
        }
        page.insertChild(footer, at: 2)

        page.calculateLayout(width: 375, height: 812, direction: .ltr)
        print("📱 页面布局 (375×812)")
        print("  Header: height=\(header.layoutResult.height, spec: "0.0")")
        print("  Content Grid: 6 张卡片, 2 列, gap=12")
        for (i, c) in grid.children.enumerated() {
            let r = c.layoutResult
            let col = i % 2 + 1
            print("    Card\(i+1) [col\(col)]: (\(r.left, spec: "0.0"), \(r.top, spec: "0.0")) \(r.width, spec: "0.0")×\(r.height, spec: "0.0")")
        }
        print("  Footer: height=\(footer.layoutResult.height, spec: "0.0")")
        print("  总高度: header(\(header.layoutResult.height, spec: "0.0")) + grid + footer(\(footer.layoutResult.height, spec: "0.0"))")
        print("  页面总高: \(page.layoutResult.height, spec: "0.0")")
    }

    // ============================================================
    // 18. YogaKit: UIView 扩展（仅 iOS/macOS）
    // ============================================================

    func testDemoYogaKit() {
        section("18. YogaKit (UIView/NSView 集成)")
#if canImport(GWYogaKit)
        // YogaKit 提供 UIView/NSView 扩展，让原生视图直接使用 Yoga 布局
        //
        // 基本用法:
        //
        //   import GWYogaKit
        //
        //   let container = UIView()
        //   container.yoga.isEnabled = true
        //   container.yoga.flexDirection = .row
        //   container.yga_padding = 16
        //
        //   let child = UIView()
        //   child.yoga.width = 100
        //   child.yoga.height = 100
        //   container.addSubview(child)
        //
        //   container.yoga.applyLayout()
        //
        // 支持的属性:
        //
        //   YogaProperties 提供类型安全的属性访问:
        //
        //   view.yoga.flexDirection = .row
        //   view.yga_flexDirection = 2       // ObjC 兼容
        //
        //   view.yoga.justifyContent = .center
        //   view.yoga.alignItems = .center
        //   view.yoga.flexGrow = 1
        //   view.yoga.margin = 10
        //   view.yoga.padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        //   view.yoga.width = 100
        //   view.yoga.height = .percent(50)
        //   view.yoga.minWidth = 50
        //   view.yoga.aspectRatio = 16.0 / 9.0
        //   view.yoga.display = .none          // 隐藏
        //
        // YogaLayoutView: 自动管理 Yoga 节点树的 UIView 子类:
        //
        //   let container = YogaLayoutView()
        //   container.yogaProperties.flexDirection = .row
        //
        //   let child = YogaLayoutView()
        //   child.yogaProperties.width = 100
        //   container.addSubview(child)
        //
        //   container.performYogaLayout()
        //
        //   // 或者使用自动布局模式:
        //   container.yogaLayoutMode = .auto  // 自动在 layoutSubviews 中触发
        //   container.yogaLayoutMode = .manual // 手动触发
        //   container.yogaLayoutMode = .forced // 每次 layoutSubviews 都触发

        print("""
        ✅ YogaKit API 示例:

        --- UIView+Yoga 扩展 ---

        // 启用 Yoga
        view.yoga.isEnabled = true

        // Flexbox 属性
        view.yoga.flexDirection = .row
        view.yoga.justifyContent = .center
        view.yoga.alignItems = .center
        view.yoga.flexWrap = .wrap
        view.yoga.flexGrow = 1
        view.yoga.flexShrink = 1
        view.yoga.flexBasis = 100

        // 尺寸
        view.yoga.width = 200
        view.yoga.height = 100
        view.yoga.minWidth = 50
        view.yoga.maxHeight = 300
        view.yoga.aspectRatio = 1.5

        // 边距
        view.yoga.margin = 16                          // 全部
        view.yoga.marginLeft = 8
        view.yoga.marginTop = 12
        view.yoga.marginStart = 10                     // 逻辑属性
        view.yoga.marginHorizontal = 20

        // 内边距
        view.yoga.padding = 16
        view.yoga.paddingTop = 8
        view.yoga.paddingHorizontal = 24

        // 定位
        view.yoga.position = .absolute
        view.yoga.positionTop = 20
        view.yoga.positionLeft = 20

        // 显示
        view.yoga.display = .none                      // 隐藏
        view.yoga.overflow = .hidden

        // 网格 (Grid)
        view.yoga.display = .grid
        view.yoga.gridTemplateColumns = [.fr(1), .fr(1)]
        view.yoga.gridTemplateRows = [.auto()]
        view.yoga.columnGap = 10

        // 布局
        view.yoga.applyLayout()                        // 触发布局
        view.yoga.applyLayoutPreservingOrigin(true)    // 保留原点

        --- YogaLayoutView ---

        let container = YogaLayoutView()
        container.yogaProperties.flexDirection = .row
        container.yogaLayoutMode = .auto               // 自动模式
        container.performYogaLayout()

        --- Grid 网格容器 ---

        let grid = YogaLayoutView()
        grid.yogaProperties.display = .grid
        grid.yogaProperties.gridTemplateColumns = [.fr(1), .fr(2), .fr(1)]
        """)
#else
        print("  [GWYogaKit 不可用]")
#endif
    }

    // ============================================================
    // 19. DSL 声明式布局（仅 iOS/macOS）
    // ============================================================

    func testDemoDSL() {
        section("19. DSL 声明式布局")
#if canImport(GWYogaKit)
        print("""
        ✅ DSL API 示例:

        --- VStack / HStack / ZStack ---

        // 使用 @YogaDSLBuilder 构建布局树
        let view = YogaLayoutView {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    UILabel().yoga.width(50).height(50)
                    UILabel().yoga.width(100).height(50)
                }
                .padding(16)
                .backgroundColor(.systemBlue)

                ZStack {
                    UILabel().yoga.width(200).height(100)
                    UILabel().yoga.width(100).height(50)
                }

                UILabel()
                    .yoga.width(.percent(100))
                    .yoga.height(40)
                    .cornerRadius(8)
            }
            .justifyContent(.center)
            .alignItems(.center)
        }
        view.performYogaLayout()

        --- 支持的 Modifier ---
        //  .padding(16)           → 内边距
        //  .paddingHorizontal(8)  → 水平内边距
        //  .margin(10)           → 外边距
        //  .width(100)           → 宽度
        //  .height(50)           → 高度
        //  .minWidth(50)         → 最小宽度
        //  .maxHeight(200)       → 最大高度
        //  .aspectRatio(1.5)     → 宽高比
        //  .flexGrow(1)          → 弹性增长
        //  .flexShrink(1)        → 弹性收缩
        //  .flexBasis(100)       → 弹性基准
        //  .justifyContent(.center) → 主轴对齐
        //  .alignItems(.center)  → 交叉轴对齐
        //  .alignSelf(.flexEnd)  → 自身对齐
        //  .backgroundColor(.red) → 背景色
        //  .cornerRadius(8)      → 圆角
        //  .opacity(0.5)         → 透明度
        //  .display(.none)       → 隐藏

        --- 条件构建 ---
        //  let showExtra = true
        //  let view = YogaLayoutView {
        //      if showExtra {
        //          UILabel().yoga.width(100).height(50)
        //      }
        //      UILabel().yoga.width(200).height(50)
        //  }
        """)
#else
        print("  [GWYogaKit 不可用]")
#endif
    }

    // ============================================================
    // 20. HTML 标签 DSL（仅 iOS/macOS）
    // ============================================================

    func testDemoHTML() {
        section("20. HTML 标签 DSL")
#if canImport(GWYogaKit)
        print(#"""
        ✅ HTML 标签 API 示例:

        // 使用 @YogaHTMLBuilder 构建 HTML 风格的布局
        let view = YogaLayoutView {
            html {
                head {
                    // 样式表可以在这里注入
                }
                body {
                    div {
                        h1 { "标题" }
                        p  { "段落文本" }
                        img(src: "image.png")
                    }
                    .class("container")
                    .id("main")

                    section {
                        row {
                            col { card1 }
                            col { card2 }
                        }
                        footer {
                            button("确认")
                            button("取消")
                        }
                    }
                    .style("background-color: #f5f5f5; padding: 16px;")

                    nav {
                        ul {
                            li { "首页" }
                            li { "产品" }
                            li { "关于" }
                        }
                    }
                }
            }
        }

        --- 支持的标签 ---
        //  html, head, body, div, section, header, footer
        //  main, nav, aside, row (flexDirection: .row)
        //  h1...h6, p, span, strong, em
        //  img, a, button, ul, ol, li
        //  spacer, divider

        --- HTML 修饰符 ---
        //  .class("foo bar")   → 设置 CSS 类名（空格分隔）
        //  .id("main")         → 设置 CSS ID
        //  .style("color:red") → 内联样式（CSS 解析）
        //  .display(.none)     → 隐藏
        //  .cornerRadius(8)    → 圆角
        //  .backgroundColor(.red) → 背景色
        //  .opacity(0.5)       → 透明度

        --- CSS 样式表应用 ---

        // 定义样式
        let css = """
        .card {
            padding: 16px;
            border-radius: 8px;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .card-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 8px;
        }
        #featured {
            background-color: #007aff;
        }
        """

        // 解析并应用到视图
        let stylesheet = try YogaStylesheet.parse(css)
        let card = UIView()
        card.cssTagName = "div"
        card.cssClasses = ["card"]
        card.stylesheet = stylesheet

        // 递归应用
        card.applyStylesheet()
        """#)
#else
        print("  [GWYogaKit 不可用]")
#endif
    }

    // ============================================================
    // 21. 动画 & 缓存（仅 iOS/macOS）
    // ============================================================

    func testDemoAnimationAndCache() {
        section("21. 动画 & 缓存")
#if canImport(GWYogaKit)
        print("""
        ✅ 动画 API 示例:

        --- YogaTransition: 过渡动画 ---

        UIView.animate(withDuration: 0.3) {
            view.yoga.width = 200
            view.yoga.height = 300
            view.yoga.applyLayout()
        }

        --- YogaAnimation: 关键帧动画 ---

        let animation = YogaAnimation(
            target: view,
            duration: 0.5,
            animations: [
                .spring(damping: 0.8, stiffness: 100) {
                    $0.width = 200
                    $0.height = 300
                }
            ]
        )
        animation.start()

        --- 插值 (Interpolation) ---
        //  支持对任意 YogaProperty 做插值动画:
        //  宽度、高度、边距、内边距、位置、透明度等

        --- 关键帧 (Keyframes) ---
        //  let keyframes = YogaKeyframes {
        //      YogaKeyframe(at: 0) { $0.width = 100; $0.height = 100 }
        //      YogaKeyframe(at: 0.5) { $0.width = 200; $0.height = 200 }
        //      YogaKeyframe(at: 1.0) { $0.width = 150; $0.height = 150 }
        //  }
        //  YogaAnimation(target: view, keyframes: keyframes, duration: 1.0).start()

        --- 过渡 (Transition) ---
        //  view.yoga_transition = .all(0.3, easeInOut)
        //  view.yoga.width = 200  // 自动带动画切换

        ✅ 布局缓存 API 示例:

        --- YogaLayoutCache: 预渲染缓存 ---

        // 缓存测量结果，避免重复计算
        let cache = YogaLayoutCache()
        cache.invalidate()          // 失效
        cache.isStale               // 检查是否过期

        // 预布局测量
        let preLayout = YogaPreLayout()
        // 在后台线程测量，主线程应用
        """)
#else
        print("  [GWYogaKit 不可用]")
#endif
    }

    // ============================================================
    // 22. ObjC 桥接（仅 iOS/macOS）
    // ============================================================

    func testDemoObjCBridge() {
        section("22. Objective-C 桥接")
#if canImport(GWYogaKit)
        print("""
        ✅ ObjC 桥接 API (YGKLayout* 前缀):

        --- YGKLayoutView: ObjC 兼容的布局视图 ---

        // 使用 @objc 属性暴露给 Objective-C:
        //
        //   YGKLayoutView *container = [[YGKLayoutView alloc] init];
        //   container.yogaProperties.flexDirection = YGKFlexDirectionColumn;
        //   container.yogaProperties.padding = 16;
        //
        //   UIView *child = [[UIView alloc] init];
        //   child.yogaProperties.width = 100;
        //   child.yogaProperties.height = 100;
        //   [container addSubview:child];
        //
        //   [container performYogaLayout];

        --- YGKLayoutProperties: ObjC 布局属性 ---

        //  container.yogaProperties.width = 200
        //  container.yogaProperties.height = 100
        //  container.yogaProperties.flexDirection = YGKFlexDirectionRow
        //  container.yogaProperties.justifyContent = YGKJustifyCenter
        //  container.yogaProperties.alignItems = YGKAlignCenter
        //  container.yogaProperties.padding = YGKEdgeAll, 16
        //  container.yogaProperties.margin = YGKEdgeTop, 8
        //  container.yogaProperties.display = YGKDisplayGrid
        //  container.yogaLayoutModeRaw = 1  // forced mode

        --- YGKLayoutEnums: ObjC 枚举 ---

        //  YGKFlexDirectionRow       = 2    (GWFlexDirection.row)
        //  YGKFlexDirectionColumn    = 0    (GWFlexDirection.column)
        //  YGKJustifyCenter          = 2    (GWJustify.center)
        //  YGKAlignStretch           = 4    (GWAlign.stretch)
        //  YGKDisplayGrid            = 3    (GWDisplay.grid)
        //  YGKPositionAbsolute       = 2    (GWPositionType.absolute)
        //  YGKOverflowHidden         = 1    (GWOverflow.hidden)
        //  YGKWrapWrap               = 1    (GWWrap.wrap)
        //  YGKEdgeAll                = 8    (GWEdge.all)
        //  YGKGutterColumn           = 0    (GWGutter.column)
        """)
#else
        print("  [GWYogaKit 不可用]")
#endif
    }

    // ============================================================
    // 23. boxSizing contentBox
    // ============================================================

    func testDemoBoxSizing() {
        section("23. boxSizing: contentBox / borderBox")
        subsection("默认 borderBox: width=200, padding=10, border=5 → 内容区=170")
        let node1 = GWYogaNode()
        node1.style.boxSizing = .borderBox
        node1.style.setWidth(.points(200))
        node1.style.setHeight(.points(100))
        node1.style.setPadding(for: .all, .points(10))
        node1.style.setBorder(for: .all, 5)
        node1.calculateLayout(width: 200, height: 100, direction: .ltr)
        print("  borderBox 总宽=\(node1.layoutResult.width, spec: "0.0") 内容宽=\(node1.layoutResult.width - 10*2 - 5*2, spec: "0.0")")

        subsection("contentBox: width=200, padding=10, border=5 → 总宽=230")
        let node2 = GWYogaNode()
        node2.style.boxSizing = .contentBox
        node2.style.setWidth(.points(200))
        node2.style.setHeight(.points(100))
        node2.style.setPadding(for: .all, .points(10))
        node2.style.setBorder(for: .all, 5)
        node2.calculateLayout(width: 200, height: 100, direction: .ltr)
        print("  contentBox 总宽=\(node2.layoutResult.width, spec: "0.0") (200+20+10=230)")
    }

    // ============================================================
    // 24. Direction RTL
    // ============================================================

    func testDemoDirectionRTL() {
        section("24. Direction RTL (右向左)")
        let root = GWYogaNode()
        root.style.direction = .rtl
        root.style.setWidth(.points(400))
        root.style.setHeight(.points(60))
        root.style.flexDirection = .row
        for i in 0..<3 {
            let c = GWYogaNode()
            c.style.setWidth(.points(80))
            c.style.setHeight(.points(30))
            root.insertChild(c, at: i)
        }
        root.calculateLayout(width: 400, height: 60, direction: .rtl)
        print("  RTL row 布局:")
        for (i, c) in root.children.enumerated() {
            print("    child\(i+1): left=\(c.layoutResult.left, spec: "0.0") (从右往左排列)")
        }
    }

    // ============================================================
    // 25. Node Clone / Reset
    // ============================================================

    func testDemoNodeCloneReset() {
        section("25. 节点克隆与重置 (Clone & Reset)")
        let node = GWYogaNode()
        node.style.setWidth(.points(200))
        node.style.setHeight(.points(100))
        let child = GWYogaNode()
        child.style.setWidth(.points(80))
        child.style.setHeight(.points(50))
        node.insertChild(child, at: 0)
        print("  原节点: \(node.children.count) 个子节点")

        // 创建新节点并复制样式
        let cloned = GWYogaNode()
        cloned.copyStyle(from: node)
        print("  样式复制: width=\(node.style.width.value.value, spec: "0.0") → \(cloned.style.width.value.value, spec: "0.0")")

        cloned.reset()
        print("  重置后: \(cloned.children.count) 个子节点")
    }

    // ============================================================
    // 26. Display: Contents
    // ============================================================

    func testDemoDisplayContents() {
        section("26. Display: contents")
        let root = GWYogaNode()
        root.style.setWidth(.points(300))
        root.style.setHeight(.points(100))
        root.style.flexDirection = .row

        let wrapper = GWYogaNode()
        wrapper.style.display = .contents
        root.insertChild(wrapper, at: 0)

        let item = GWYogaNode()
        item.style.setWidth(.points(100))
        item.style.setHeight(.points(50))
        wrapper.insertChild(item, at: 0)

        root.calculateLayout(width: 300, height: 100, direction: .ltr)
        print("  wrapper 不占空间: left=\(wrapper.layoutResult.left, spec: "0.0"), width=\(wrapper.layoutResult.width, spec: "0.0")")
        print("  item 作为 root 的直接子节点排列: left=\(item.layoutResult.left, spec: "0.0")")
    }

    // ============================================================
    // 27. Config 配置
    // ============================================================

    func testDemoConfigAdvanced() {
        section("27. Config 配置 (useWebDefaults / pointScaleFactor)")
        let config1 = GWYogaConfig()
        config1.useWebDefaults = true
        let root1 = GWYogaNode(config: config1)
        root1.style.setWidth(.points(300))
        root1.style.setHeight(.points(50))
        root1.style.flexDirection = .row
        let c1 = GWYogaNode(config: config1)
        c1.style.setHeight(.points(30))
        root1.insertChild(c1, at: 0)
        root1.calculateLayout(width: 300, height: 50, direction: .ltr)
        print("  useWebDefaults: 子节点 width=\(c1.layoutResult.width, spec: "0.0") (flexBasis 默认为 0%)")

        let config2 = GWYogaConfig()
        config2.pointScaleFactor = 3.0
        let root2 = GWYogaNode(config: config2)
        root2.style.setWidth(.points(100))
        root2.style.setHeight(.points(50))
        root2.calculateLayout(width: 100, height: 50, direction: .ltr)
        print("  pointScaleFactor=3: width=\(root2.layoutResult.width, spec: "0.0") (按 1/3 四舍五入)")
    }

    // ============================================================
    // 28. Grid: autoRows/autoColumns
    // ============================================================

    func testDemoGridAuto() {
        section("28. Grid autoRows / autoColumns")
        subsection("autoRows=80, 4 个子节点在 1 列中")
        let r1 = GWYogaNode()
        r1.style.display = .grid
        r1.style.setWidth(.points(200))
        r1.style.gridTemplateColumns = [.points(200)]
        r1.style.gridAutoRows = [.points(80)]
        for _ in 0..<4 { r1.insertChild(GWYogaNode(), at: r1.children.count) }
        r1.calculateLayout(width: 200, height: .nan, direction: .ltr)
        print("  容器高度=\(r1.layoutResult.height, spec: "0.0") (4*80=320)")

        subsection("autoColumns=100, 3 个子节点在 1 行中")
        let r2 = GWYogaNode()
        r2.style.display = .grid
        r2.style.gridTemplateRows = [.points(50)]
        r2.style.gridAutoColumns = [.points(100)]
        for _ in 0..<3 { r2.insertChild(GWYogaNode(), at: r2.children.count) }
        r2.calculateLayout(width: .nan, height: .nan, direction: .ltr)
        print("  容器宽度=\(r2.layoutResult.width, spec: "0.0") (3*100=300)")
    }

    // ============================================================
    // 29. Animation / Transition 完整用法
    // ============================================================

    func testDemoAnimation() {
        section("29. Animation & Transition 完整用法")
        print("""
        ✅ Animation API:

        --- YogaTimingFunction: 时间函数 ---
        let linear = YogaTimingFunction.linear()
        let ease = YogaTimingFunction.ease()
        let easeIn = YogaTimingFunction.easeIn()
        let easeOut = YogaTimingFunction.easeOut()
        let easeInOut = YogaTimingFunction.easeInOut()
        let cubic = YogaTimingFunction.cubicBezier(0.25, 0.1, 0.25, 1.0)
        let stepFunc = YogaTimingFunction.steps(4, position: .end)

        --- YogaAnimation: 动画配置 ---
        let anim = YogaAnimation(
            name: "fadeIn",
            duration: 0.3,
            timingFunction: .easeInOut(),
            delay: 0.1,
            direction: .normal,
            fillMode: .forwards
        )

        --- YogaTransition: 过渡配置 ---
        let transition = YogaTransition(
            duration: 0.3,
            timingFunction: .ease(),
            delay: 0,
            propertyFilter: .layout
        )

        --- 插值 (Interpolation) ---
        //  YogaInterpolation.interpolate(from: 100, to: 200, progress: 0.5)
        //  → 150.0

        --- 关键帧 (Keyframes) ---
        //  let frames = YogaKeyframes {
        //      YogaKeyframe(at: 0.0) { $0.width = 100 }
        //      YogaKeyframe(at: 0.5) { $0.width = 200 }
        //      YogaKeyframe(at: 1.0) { $0.width = 150 }
        //  }
        """)
    }

    // ============================================================
    // 30. LayoutCache 完整用法
    // ============================================================

    func testDemoLayoutCache() {
        section("30. LayoutCache 预测量 & 缓存")
        print("""
        ✅ LayoutCache API:

        --- YogaPreLayout: 预测量 ---
        //  let preLayout = YogaPreLayout(for: someView)
        //  let size = preLayout.measure(width: 200)      // 给定宽度测量
        //  let exact = preLayout.measure(width: 200, height: 100) // 精确测量
        //  preLayout.invalidateCache()                    // 使缓存失效

        --- YogaLayoutCache: 缓存管理器 ---
        //  let cache = YogaLayoutCache()
        //  cache.invalidate()     // 失效
        //  let stale = cache.isStale  // 检查是否过期

        --- 预渲染缓存 ---
        //  在后台线程测量布局，在主线程应用结果，避免阻塞 UI
        //  结合 PreLayoutManager 使用，适用于列表/滚动视图场景
        """)
    }

    // ============================================================
    // 31. DSL 完整用法
    // ============================================================

    func testDemoDSLAdvanced() {
        section("31. DSL 声明式布局完整用法")
        print("""
        ✅ DSL API (声明式布局):

        --- 容器 ---
        //  VStack {          // 垂直排列 (flexDirection: column)
        //      Text("A")      // 文本节点
        //      Text("B")
        //  }
        //
        //  HStack {          // 水平排列 (flexDirection: row)
        //      Text("A")
        //      Text("B")
        //  }
        //
        //  ZStack {          // 重叠布局 (absolute 定位)
        //      Text("背景")
        //      Text("前景")
        //  }

        --- 控件 ---
        //  Text("Hello")               // UILabel 封装
        //  Image(UIImage(named: "x"))  // UIImageView 封装
        //  Button("Tap") { }           // UIButton 封装
        //  Spacer()                    // 弹性间距 (flexGrow: 1)
        //  Divider()                   // 分割线

        --- 修饰符 ---
        //  Text("Hello")
        //      .padding(16)            // 内边距
        //      .margin(.top(8))        // 外边距
        //      .frame(width: 100, height: 50)  // 尺寸
        //      .background(.blue)      // 背景色
        //      .flex(grow: 1, shrink: 0) // flex 属性

        --- 滚动容器 ---
        //  ScrollView(.vertical) {
        //      VStack { ... }
        //  }
        """)
    }

    // ============================================================
    // 32. HTML 标签 DSL
    // ============================================================

    func testDemoHTMLAdvanced() {
        section("32. HTML 标签 DSL")
        print("""
        ✅ HTML 标签 API:

        --- 标签 ---
        //  div { ... }          // block 容器
        //  section { ... }      // 区块容器 (flexDirection: column)
        //  header { ... }       // 头部 (flexDirection: row, alignItems: center)
        //  row { ... }          // 行容器 (flexDirection: row)
        //  h1("标题") ... h6("标题")  // 标题 (size 28~14)
        //  p("段落文本")         // 段落

        --- 修饰符 ---
        //  div {
        //      h1("大标题")
        //          .padding(8)
        //          .margin(.bottom(4))
        //      p("说明文字")
        //  }
        //  .backgroundColor(.systemGray6)

        --- 结合 Stylesheet ---
        //  let css = try YogaStylesheet.parse("div { margin: 10px }")
        //  css.apply(to: view)
        """)
    }

    // ============================================================
    // 33. Grid 高级用法
    // ============================================================

    func testDemoGridAdvanced() {
        section("33. Grid 高级用法")
        subsection("minmax + stretch 分布")
        let r1 = GWYogaNode()
        r1.style.display = .grid
        r1.style.setWidth(.points(300))
        r1.style.gridTemplateColumns = [
            .minmax(min: .points(50), max: .points(100)),
            .minmax(min: .points(80), max: .points(200))
        ]
        r1.style.justifyContent = .stretch
        for _ in 0..<2 { r1.insertChild(GWYogaNode(), at: r1.children.count) }
        r1.calculateLayout(width: 300, height: .nan, direction: .ltr)
        print("  minmax+stretch: col0=\(r1.children[0].layoutResult.width, spec: "0.0") col1=\(r1.children[1].layoutResult.width, spec: "0.0")")

        subsection("explicit row+column placement")
        let r2 = GWYogaNode()
        r2.style.display = .grid
        r2.style.gridTemplateColumns = [.points(60), .points(60), .points(60)]
        r2.style.gridTemplateRows = [.points(40), .points(40), .points(40)]
        let span = GWYogaNode()
        span.style.gridColumnStart = GWGridLine(type: .integer, value: 1)
        span.style.gridColumnEnd = GWGridLine(type: .integer, value: 3)
        span.style.gridRowStart = GWGridLine(type: .integer, value: 1)
        span.style.gridRowEnd = GWGridLine(type: .integer, value: 3)
        r2.insertChild(span, at: 0)
        for _ in 0..<3 { r2.insertChild(GWYogaNode(), at: r2.children.count) }
        r2.calculateLayout(width: .nan, height: .nan, direction: .ltr)
        print("  跨2列2行: width=\(span.layoutResult.width, spec: "0.0") height=\(span.layoutResult.height, spec: "0.0") (期望 120×80)")
    }
}

// MARK: - Float 格式化扩展

extension Float {
    /// 格式化为指定小数位数
    func format(_ spec: String) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = spec.components(separatedBy: ".").last?.count ?? 1
        formatter.decimalSeparator = "."
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension String.StringInterpolation {
    /// 格式化 Float 输出的插值方法
    mutating func appendInterpolation(_ value: Float, spec: String) {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        let digits = spec.components(separatedBy: ".").last?.count ?? 1
        formatter.maximumFractionDigits = digits
        formatter.decimalSeparator = "."
        appendLiteral(formatter.string(from: NSNumber(value: value)) ?? "\(value)")
    }
}
