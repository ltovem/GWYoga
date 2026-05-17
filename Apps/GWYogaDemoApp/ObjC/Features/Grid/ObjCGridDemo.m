#import "ObjCGridDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCGridDemo ()
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCGridDemo

- (UIView *)makeCellWithColor:(UIColor *)color label:(NSString *)text {
    UIView *cell = [[UIView alloc] init];
    cell.gwstyle.width = 80;
    cell.gwstyle.height = 60;
    cell.backgroundColor = color;
    cell.layer.cornerRadius = 6;

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.gwstyle.alignSelf = YGKAlignCenter;
    label.gwstyle.flexGrow = 1;
    [cell addChild:label];

    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    // badge
    self.badge = [[UILabel alloc] init];
    self.badge.text = @"  属性  ";
    self.badge.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium];
    self.badge.textColor = UIColor.systemBlueColor;
    self.badge.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    self.badge.layer.cornerRadius = 4;
    self.badge.clipsToBounds = YES;
    [self.view addSubview:self.badge];

    // title
    UILabel *title = [[UILabel alloc] init];
    title.text = @"Grid — display: grid";
    title.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightSemibold];
    [title.gwstyle setMargin:YGKEdgeBottom value:8];
    [self.view addChild:title];

    // grid container
    self.container = [[YogaLayoutView alloc] init];
    self.container.gwstyle.display = YGKDisplayGrid;
    // 3 equal columns using fractional units
    [self.container.gwstyle setGridTemplateColumns:@[
        [YGKGridTrackSize fr:1],
        [YGKGridTrackSize fr:1],
        [YGKGridTrackSize fr:1],
    ]];
    [self.container.gwstyle setGap:YGKGutterAll value:10];
    [self.container.gwstyle setPadding:YGKEdgeAll value:12];
    self.container.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    self.container.layer.cornerRadius = 8;
    [self.view addChild:self.container];

    // grid cells
    [self.container addChild:[self makeCellWithColor:UIColor.systemRedColor label:@"1"]];
    [self.container addChild:[self makeCellWithColor:UIColor.systemGreenColor label:@"2"]];
    [self.container addChild:[self makeCellWithColor:UIColor.systemBlueColor label:@"3"]];
    [self.container addChild:[self makeCellWithColor:UIColor.systemOrangeColor label:@"4"]];
    [self.container addChild:[self makeCellWithColor:UIColor.systemPurpleColor label:@"5"]];
    [self.container addChild:[self makeCellWithColor:UIColor.systemTealColor label:@"6"]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.badge sizeToFit];
    self.badge.frame = CGRectMake(
        self.view.bounds.size.width - self.badge.frame.size.width - 16,
        self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 8,
        self.badge.frame.size.width,
        self.badge.frame.size.height
    );

    CGFloat top = self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 40;
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height - top - 16;
    self.container.frame = CGRectMake(16, top, w - 32, h);
    [self.container performYogaLayout];
}

@end
