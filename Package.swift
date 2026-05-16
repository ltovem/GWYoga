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

        // GWYogaKit 布局框架（含 Core + iOS/macOS 扩展）
        .library(name: "GWYogaKit", targets: ["GWYogaKit"]),

        // 扩展模块（按需引入）
        .library(name: "GWYogaKitLayoutCache", targets: ["GWYogaKitLayoutCache"]),
        .library(name: "GWYogaKitAnimation", targets: ["GWYogaKitAnimation"]),
        .library(name: "GWYogaKitAnimationObjCCore", targets: ["GWYogaKitAnimationObjCCore"]),
        .library(name: "GWYogaKitDSL", targets: ["GWYogaKitDSL"]),
        .library(name: "GWYogaKitStylesheet", targets: ["GWYogaKitStylesheet"]),
        .library(name: "GWYogaKitObjCCore", targets: ["GWYogaKitObjCCore"]),
        .library(name: "GWYogaKitLayoutCacheObjCCore", targets: ["GWYogaKitLayoutCacheObjCCore"]),
        .library(name: "GWYogaKitDSLObjCCore", targets: ["GWYogaKitDSLObjCCore"]),
        .library(name: "GWYogaKitStylesheetObjCCore", targets: ["GWYogaKitStylesheetObjCCore"]),
    ],
    targets: [
        // ── GWYoga 底层引擎 ──
        .target(
            name: "GWYoga",
            path: "Sources/GWYoga",
            exclude: ["GWYoga.h", "GWYoga.docc"]
        ),
        .testTarget(
            name: "GWYogaTests",
            dependencies: ["GWYoga"],
            path: "Tests/GWYogaTests"
        ),

        // ── GWYogaKit Core ──
        .target(
            name: "GWYogaKit",
            dependencies: ["GWYoga"],
            path: "Sources/GWYogaKit/Core/Swift"
        ),

        // ── LayoutCache 缓存模块 ──
        .target(
            name: "GWYogaKitLayoutCache",
            dependencies: ["GWYoga", "GWYogaKit"],
            path: "Sources/GWYogaKit/LayoutCache/Swift"
        ),

        // ── Animation 动画模块 ──
        .target(
            name: "GWYogaKitAnimation",
            dependencies: ["GWYoga", "GWYogaKit"],
            path: "Sources/GWYogaKit/Animation/Swift"
        ),

        // ── DSL 声明式布局模块 ──
        .target(
            name: "GWYogaKitDSL",
            dependencies: ["GWYoga", "GWYogaKit"],
            path: "Sources/GWYogaKit/DSL/Swift"
        ),

        // ── Stylesheet CSS 样式表模块 ──
        .target(
            name: "GWYogaKitStylesheet",
            dependencies: ["GWYoga", "GWYogaKit"],
            path: "Sources/GWYogaKit/Stylesheet/Swift"
        ),

        // ── ObjC Core 桥接 ──
        .target(
            name: "GWYogaKitObjCCore",
            dependencies: ["GWYogaKit"],
            path: "Sources/GWYogaKit/Core/ObjC"
        ),

        // ── ObjC Animation 桥接 ──
        .target(
            name: "GWYogaKitAnimationObjCCore",
            dependencies: ["GWYogaKit", "GWYogaKitAnimation"],
            path: "Sources/GWYogaKit/Animation/ObjC"
        ),

        // ── ObjC LayoutCache 桥接 ──
        .target(
            name: "GWYogaKitLayoutCacheObjCCore",
            dependencies: ["GWYogaKit", "GWYogaKitLayoutCache", "GWYogaKitObjCCore"],
            path: "Sources/GWYogaKit/LayoutCache/ObjC"
        ),

        // ── ObjC DSL 桥接 ──
        .target(
            name: "GWYogaKitDSLObjCCore",
            dependencies: ["GWYogaKit", "GWYogaKitDSL", "GWYogaKitObjCCore"],
            path: "Sources/GWYogaKit/DSL/ObjC"
        ),

        // ── ObjC Stylesheet 桥接 ──
        .target(
            name: "GWYogaKitStylesheetObjCCore",
            dependencies: ["GWYogaKit", "GWYogaKitStylesheet"],
            path: "Sources/GWYogaKit/Stylesheet/ObjC"
        ),

        // ── Stylesheet 测试 ──
        .testTarget(
            name: "GWYogaKitStylesheetTests",
            dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitStylesheet"],
            path: "Tests/GWYogaKitStylesheetTests"
        ),

        // ── GWYogaKit 测试 ──
        .testTarget(
            name: "GWYogaKitTests",
            dependencies: ["GWYoga", "GWYogaKit"],
            path: "Tests/GWYogaKitTests"
        ),

        // ── DSL 测试 ──
        .testTarget(
            name: "GWYogaKitDSLTests",
            dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitDSL"],
            path: "Tests/GWYogaKitDSLTests"
        ),

        // ── Animation 测试 ──
        .testTarget(
            name: "GWYogaKitAnimationTests",
            dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitAnimation"],
            path: "Tests/GWYogaKitAnimationTests"
        ),

        // ── LayoutCache 测试 ──
        .testTarget(
            name: "GWYogaKitLayoutCacheTests",
            dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitLayoutCache"],
            path: "Tests/GWYogaKitLayoutCacheTests"
        ),

        // ── ObjC Bridge 测试 ──
        .testTarget(
            name: "GWYogaKitObjCTests",
            dependencies: ["GWYoga", "GWYogaKit", "GWYogaKitObjCCore", "GWYogaKitDSLObjCCore", "GWYogaKitLayoutCacheObjCCore"],
            path: "Tests/GWYogaKitObjCTests"
        ),
    ]
)
