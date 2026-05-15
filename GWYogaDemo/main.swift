import AppKit
import SwiftUI

if #available(macOS 11.0, *) {
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)

    class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationDidFinishLaunching(_ notification: Notification) {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "GWYoga"
            window.contentView = NSHostingView(rootView: ContentView())
            window.center()
            window.makeKeyAndOrderFront(nil)
        }

        func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            true
        }
    }

    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
}
