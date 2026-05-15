import UIKit

class DemoTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let demos: [(String, String, UIViewController)] = [
            ("Flexbox", "01.circle", FlexboxDemoViewController()),
            ("Grid", "02.circle", GridDemoViewController()),
            ("Margin", "03.circle", MarginPaddingDemoViewController()),
            ("Position", "04.circle", PositionDemoViewController()),
            ("Gap", "05.circle", GapDemoViewController()),
            ("Aspect", "06.circle", AspectRatioDemoViewController()),
            ("综合", "star", CompositeDemoViewController()),
        ]
        viewControllers = demos.map { t, i, vc in
            vc.tabBarItem = UITabBarItem(title: t, image: UIImage(systemName: i), tag: 0)
            return UINavigationController(rootViewController: vc)
        }
    }
}
