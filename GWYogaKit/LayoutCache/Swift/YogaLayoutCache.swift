import Foundation
import GWYoga

// MARK: - YogaCacheKey

internal struct YogaCacheKey: Hashable {
    let nodeIdentifier: ObjectIdentifier
    let width: Float
    let widthMode: GWMeasureMode
    let height: Float
    let heightMode: GWMeasureMode

    init(node: GWYogaNode, width: Float, widthMode: GWMeasureMode,
         height: Float, heightMode: GWMeasureMode) {
        self.nodeIdentifier = ObjectIdentifier(node)
        self.width = width
        self.widthMode = widthMode
        self.height = height
        self.heightMode = heightMode
    }
}

// MARK: - YogaLayoutCache

internal final class YogaLayoutCache {

    static let shared = YogaLayoutCache()

    private var cache: [YogaCacheKey: CGSize] = [:]
    private let lock = NSLock()

    var maximumCacheSize: Int = 1000

    func getCachedSize(for key: YogaCacheKey) -> CGSize? {
        lock.lock()
        defer { lock.unlock() }
        return cache[key]
    }

    func setCachedSize(_ size: CGSize, for key: YogaCacheKey) {
        lock.lock()
        if cache.count >= maximumCacheSize {
            cache.removeAll()
        }
        cache[key] = size
        lock.unlock()
    }

    func invalidate(for node: GWYogaNode) {
        let id = ObjectIdentifier(node)
        lock.lock()
        cache = cache.filter { $0.key.nodeIdentifier != id }
        lock.unlock()
    }

    func invalidateAll() {
        lock.lock()
        cache.removeAll()
        lock.unlock()
    }
}
