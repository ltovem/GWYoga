#import "ObjCDemoListViewController.h"

@interface ObjCDemoListViewController ()
@property (nonatomic, strong) NSArray<NSDictionary *> *sections;
@end

@implementation ObjCDemoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GWYoga Demos (ObjC)";
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];

    self.sections = @[
        @{@"title": @"基础布局",
          @"items": @[
                  @{@"title": @"Flexbox 方向", @"subtitle": @"属性 · flexDirection", @"class": @"ObjCFlexboxDirectionPropertyDemo"},
                  @{@"title": @"Flexbox 方向", @"subtitle": @"Block · style{}", @"class": @"ObjCFlexboxDirectionBlockDemo"},
                  @{@"title": @"主轴对齐", @"subtitle": @"Block · justifyContent", @"class": @"ObjCJustifyContentDemo"},
          ]},
        @{@"title": @"尺寸边距",
          @"items": @[
                  @{@"title": @"Margin & Padding", @"subtitle": @"属性 · margin/padding", @"class": @"ObjCMarginPaddingDemo"},
                  @{@"title": @"Position", @"subtitle": @"属性 · position", @"class": @"ObjCPositionDemo"},
                  @{@"title": @"Gap", @"subtitle": @"属性 · gap", @"class": @"ObjCGapDemo"},
          ]},
        @{@"title": @"高级布局",
          @"items": @[
                  @{@"title": @"Grid", @"subtitle": @"属性 · display:grid", @"class": @"ObjCGridDemo"},
                  @{@"title": @"YogaStack", @"subtitle": @"Block · stack", @"class": @"ObjCYogaStackDemo"},
          ]},
        @{@"title": @"视觉样式",
          @"items": @[
                  @{@"title": @"CornerRadius", @"subtitle": @"属性 · cornerRadius", @"class": @"ObjCCornerRadiusDemo"},
                  @{@"title": @"Shadow", @"subtitle": @"属性 · shadow", @"class": @"ObjCShadowDemo"},
          ]},
        @{@"title": @"CSS",
          @"items": @[
                  @{@"title": @"CSS 内联", @"subtitle": @"CSS · style=\"\"", @"class": @"ObjCCSSInlineDemo"},
          ]},
        @{@"title": @"动画",
          @"items": @[
                  @{@"title": @"Animation", @"subtitle": @"Block · animation", @"class": @"ObjCAnimationDemo"},
          ]},
        @{@"title": @"调试",
          @"items": @[
                  @{@"title": @"DebugPrint", @"subtitle": @"属性 · debugPrint", @"class": @"ObjCDebugPrintDemo"},
          ]},
        @{@"title": @"综合",
          @"items": @[
                  @{@"title": @"Composite", @"subtitle": @"属性+Block · 综合示例", @"class": @"ObjCCompositeDemo"},
          ]},
    ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section][@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *item = self.sections[indexPath.section][@"items"][indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"subtitle"];
    cell.detailTextLabel.textColor = UIColor.secondaryLabelColor;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.sections[indexPath.section][@"items"][indexPath.row];
    NSString *className = item[@"class"];
    UIViewController *vc = [[NSClassFromString(className) alloc] init];
    vc.title = item[@"title"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
