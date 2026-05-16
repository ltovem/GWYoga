import Foundation

// MARK: - 断言工具（对应 C++ yoga/debug/AssertFatal.h 和 AssertFatal.cpp）

/// 带 node 的致命断言
internal func assertFatalWithNode(
    _ node: GWYogaNode?,
    _ condition: Bool,
    _ message: String = ""
) {
    if !condition {
        log(
            config: node?.config,
            node: node,
            level: .fatal,
            message: "断言失败: \(message)"
        )
        assertionFailure(message)
    }
}

/// 不带 node 的致命断言
internal func assertFatal(
    _ condition: Bool,
    _ message: String = ""
) {
    if !condition {
        assertionFailure(message)
    }
}

/// 致命错误消息（不返回）
internal func fatalWithMessage(_ message: String) -> Never {
    assertionFailure(message)
    // 在 release 模式下也终止
    preconditionFailure(message)
}
