import UIKit

class SwiftDemoListViewController: UITableViewController {

    let sections: [(title: String, items: [(title: String, subtitle: String, vc: UIViewController.Type)])] = [
        ("基础布局", [
            ("Flexbox + 数据绑定", "链式 · flexDirection + @YogaState", FlexboxDirectionChainableDemo.self),
            ("Flexbox 方向", "闭包 · style {}", FlexboxDirectionClosureDemo.self),
            ("主轴对齐", "闭包 · justifyContent", JustifyContentDemo.self),
        ]),
        ("尺寸边距", [
            ("Margin & Padding", "链式 · margin/padding", MarginPaddingDemo.self),
            ("Position", "混合 · position", PositionDemo.self),
            ("Gap", "链式 · gap", GapDemo.self),
        ]),
        ("高级布局", [
            ("Grid", "链式 · display:grid", GridDemo.self),
            ("YogaStack", "闭包 · stack", YogaStackDemo.self),
        ]),
        ("视觉样式", [
            ("CornerRadius", "链式 · cornerRadius", CornerRadiusDemo.self),
            ("Shadow", "链式 · shadow", ShadowDemo.self),
        ]),
        ("CSS", [
            ("CSS 内联", "CSS · style=\"\"", CSSInlineDemo.self),
        ]),
        ("动画", [
            ("Animation", "链式 · animation", AnimationDemo.self),
        ]),
        ("调试", [
            ("DebugPrint", "混合 · debugPrint", DebugPrintDemo.self),
        ]),
        ("综合", [
            ("Composite", "混合 · 综合示例", CompositeDemo.self),
        ]),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GWYoga Demos (Swift)"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        var conf = cell.defaultContentConfiguration()
        conf.text = item.title
        conf.secondaryText = item.subtitle
        conf.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = conf
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        let vc = item.vc.init()
        vc.title = item.title
        navigationController?.pushViewController(vc, animated: true)
    }
}
