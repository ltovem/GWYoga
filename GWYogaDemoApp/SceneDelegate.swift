import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        DemoRegistry.registerAll()
        let w = UIWindow(windowScene: ws)
        let nav = UINavigationController(rootViewController: CategoryListViewController())
        w.rootViewController = nav
        window = w
        w.makeKeyAndVisible()
    }
}
