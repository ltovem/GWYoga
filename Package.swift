// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "GWYoga",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // GWYoga 核心引擎
        .library(name: "GWYoga", targets: ["GWYoga"]),
        // GWYogaDemo 可视化演示 app
        .executable(name: "GWYogaDemo", targets: ["GWYogaDemo"]),

        // GWYogaKit 布局框架（含 Core + iOS/macOS 扩展）
        .library(name: "GWYogaKit", targets: ["GWYogaKit"]),

        // 扩展模块（按需引入）
        .library(name: "GWYogaKitLayoutCache", targets: ["GWYogaKitLayoutCache"]),
        .library(name: "GWYogaKitAnimation", targets: ["GWYogaKitAnimation"]),
        .library(name: "GWYogaKitAnimationObjCCore", targets: ["GWYogaKitAnimationObjCCore"]),
        .library(name: "GWYogaKitDSL", targets: ["GWYogaKitDSL"]),
        .library(name: "GWYogaKitStylesheet", targets: ["GWYogaKitStylesheet"]),
        .library(name: "GWYogaKitHTML", targets: ["GWYogaKitHTML"]),
        .library(name: "GWYogaKitObjCCore", targets: ["GWYogaKitObjCCore"]),
        .library(name: "GWYogaKitLayoutCacheObjCCore", targets: ["GWYogaKitLayoutCacheObjCCore"]),
        .library(name: "GWYogaKitDSLObjCCore", targets: ["GWYogaKitDSLObjCCore"]),
        .library(name: "GWYogaKitStylesheetObjCCore", targets: ["GWYogaKitStylesheetObjCCore"]),
        .library(name: "GWYogaKitHTMLObjCCore", targets: ["GWYogaKitHTMLObjCCore"]),
    ],
    targets: [
        // ── GWYoga 底层引擎 ──
        .target(
            name: "GWYoga",
            path: "GWYoga",
            exclude: ["GWYoga.h", "GWYoga.docc"]
        ),
        .testTarget(
            name: "GWYogaTests",
            dependencies: ["GWYoga"],
            path: "GWYogaTests"
        ),

        // ── GWYogaKit Core ──
        .target(
            name: "GWYogaKit",
            dependencies: ["GWYoga"],
            path: "GWYogaKit/Core/Swift"
        ),

        // ── LayoutCache 缓存模块 ──
        .target(
            name: "GWYogaKitLayoutCache",
            dependencies: ["GWYogaKit"],
            path: "GWYogaKit/LayoutCache/Swift"
        ),

        // ── Animation 动画模块 ──
        .target(
            name: "GWYogaKitAnimation",
            dependencies: ["GWYogaKit"],
            path: "GWYogaKit/Animation/Swift"
        ),

        // ── DSL 声明式布局模块 ──
        .target(
            name: "GWYogaKitDSL",
            dependencies: ["GWYogaKit"],
            path: "GWYogaKit/DSL/Swift"
        ),

        // ── Stylesheet CSS 样式表模块 ──
        .target(
            name: "GWYogaKitStylesheet",
            dependencies: ["GWYogaKit"],
            path: "GWYogaKit/Stylesheet/Swift"
        ),

        // ── HTML 标签 DSL 模块 ──
        .target(
            name: "GWYogaKitHTML",
            dependencies: ["GWYogaKitDSL", "GWYogaKitStylesheet"],
            path: "GWYogaKit/HTML/Swift"
        ),

        // ── ObjC Core 桥接 ──
        .target(
            name: "GWYogaKitObjCCore",
            dependencies: ["GWYogaKit"],
            path: "GWYogaKit/Core/ObjC"
        ),

        // ── ObjC Animation 桥接 ──
        .target(
            name: "GWYogaKitAnimationObjCCore",
            dependencies: ["GWYogaKit", "GWYogaKitAnimation"],
            path: "GWYogaKit/Animation/ObjC"
        ),

        // ── ObjC LayoutCache 桥接 ──
        .target(
            name: "GWYogaKitLayoutCacheObjCCore",
            dependencies: ["GWYogaKit", "GWYogaKitLayoutCache"],
            path: "GWYogaKit/LayoutCache/ObjC"
        ),

        // ── ObjC DSL 桥接 ──
        .target(
            name: "GWYogaKitDSLObjCCore",
            dependencies: ["GWYogaKit", "GWYogaKitDSL"],
            path: "GWYogaKit/DSL/ObjC"
        ),

        // ── ObjC Stylesheet 桥接 ──
        .target(
            name: "GWYogaKitStylesheetObjCCore",
            dependencies: ["GWYogaKit", "GWYogaKitStylesheet"],
            path: "GWYogaKit/Stylesheet/ObjC"
        ),

        // ── ObjC HTML 桥接 ──
        .target(
            name: "GWYogaKitHTMLObjCCore",
            dependencies: ["GWYogaKit", "GWYogaKitHTML"],
            path: "GWYogaKit/HTML/ObjC"
        ),

        // ── Stylesheet 测试 ──
        .testTarget(
            name: "GWYogaKitStylesheetTests",
            dependencies: ["GWYoga", "GWYogaKitStylesheet"],
            path: "GWYogaKitStylesheetTests"
        ),

        // ── API 演示 ──
        .testTarget(
            name: "GWYogaAPIDemo",
            dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitStylesheet"],
            path: "GWYogaAPIDemo"
        ),

        // ── 可视化 Demo App ──
        .executableTarget(
            name: "GWYogaDemo",
            dependencies: ["GWYoga", "GWYogaKit"],
            path: "GWYogaDemo"
        ),
    ]
)
