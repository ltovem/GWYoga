import Foundation

// MARK: - 日志系统（对应 C++ yoga/debug/Log.h 和 Log.cpp）

/// 日志回调类型
public typealias GWLogger = (GWYogaConfig?, GWYogaNode?, GWLogLevel, String) -> Void

/// 默认日志回调
internal let defaultLog: GWLogger = { _, _, level, message in
    switch level {
    case .error, .fatal:
        fputs("GWYoga [\(level)]: \(message)\n", stderr)
    case .warn:
        fputs("GWYoga [\(level)]: \(message)\n", stderr)
    default:
        print("GWYoga [\(level)]: \(message)")
    }
}

/// 日志输出
internal func log(
    config: GWYogaConfig?,
    node: GWYogaNode?,
    level: GWLogLevel,
    message: String
) {
    // 尝试使用 config 的自定义 logger，否则用默认
    if let config = config, let logger = config.logger {
        logger(config, node, level, message)
    } else {
        defaultLog(config, node, level, message)
    }
}

/// 带格式的日志
internal func logWithFormat(
    config: GWYogaConfig?,
    node: GWYogaNode?,
    level: GWLogLevel,
    _ message: String
) {
    log(config: config, node: node, level: level, message: message)
}
