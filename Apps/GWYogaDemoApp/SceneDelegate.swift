import UIKit

@objc(SceneDelegate) class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }

        let swiftNav = UINavigationController(rootViewController: SwiftDemoListViewController())
        swiftNav.tabBarItem = UITabBarItem(title: "Swift", image: UIImage(systemName: "swift"), tag: 0)

        let objcNav = UINavigationController(rootViewController: ObjCDemoListViewController())
        objcNav.tabBarItem = UITabBarItem(title: "ObjC", image: UIImage(systemName: "doc.text"), tag: 1)

        let tabBar = UITabBarController()
        tabBar.viewControllers = [swiftNav, objcNav]

        let w = UIWindow(windowScene: ws)
        w.rootViewController = tabBar
        window = w
        w.makeKeyAndVisible()
    }
}
