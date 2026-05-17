#import "ObjCPositionDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCPositionDemo ()
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCPositionDemo

- (UIView *)makeBoxWithColor:(UIColor *)color size:(CGFloat)size {
    UIView *box = [[UIView alloc] init];
    box.gwstyle.width = size;
    box.gwstyle.height = size;
    [box.gwstyle setMargin:YGKEdgeRight value:8];
    box.backgroundColor = color;
    box.layer.cornerRadius = 6;
    return box;
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

    // container
    self.container = [[YogaLayoutView alloc] init];
    self.container.gwstyle.flexDirection = YGKFlexDirectionColumn;
    [self.container.gwstyle setPadding:YGKEdgeAll value:16];
    [self.view addChild:self.container];

    // — Relative section —
    UILabel *relLabel = [[UILabel alloc] init];
    relLabel.text = @"Relative (default flow)";
    relLabel.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightMedium];
    relLabel.textColor = UIColor.secondaryLabelColor;
    relLabel.gwstyle.height = 20;
    [relLabel.gwstyle setMargin:YGKEdgeBottom value:6];
    [self.container addChild:relLabel];

    YogaLayoutView *relRow = [[YogaLayoutView alloc] init];
    relRow.gwstyle.flexDirection = YGKFlexDirectionRow;
    [relRow.gwstyle setPadding:YGKEdgeAll value:12];
    relRow.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    relRow.layer.cornerRadius = 6;
    [relRow.gwstyle setMargin:YGKEdgeBottom value:24];
    relRow.gwstyle.height = 64;
    [self.container addChild:relRow];

    [relRow addChild:[self makeBoxWithColor:UIColor.systemRedColor size:40]];
    [relRow addChild:[self makeBoxWithColor:UIColor.systemGreenColor size:40]];
    [relRow addChild:[self makeBoxWithColor:UIColor.systemBlueColor size:40]];

    // — Absolute section —
    UILabel *absLabel = [[UILabel alloc] init];
    absLabel.text = @"Absolute — pinned to bottom-right";
    absLabel.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightMedium];
    absLabel.textColor = UIColor.secondaryLabelColor;
    absLabel.gwstyle.height = 20;
    [absLabel.gwstyle setMargin:YGKEdgeBottom value:6];
    [self.container addChild:absLabel];

    YogaLayoutView *absContainer = [[YogaLayoutView alloc] init];
    absContainer.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    absContainer.layer.cornerRadius = 6;
    absContainer.gwstyle.height = 160;
    [self.container addChild:absContainer];

    UIView *staticBox = [[UIView alloc] init];
    staticBox.gwstyle.width = 80;
    staticBox.gwstyle.height = 80;
    staticBox.backgroundColor = UIColor.systemYellowColor;
    staticBox.layer.cornerRadius = 6;
    [absContainer addChild:staticBox];

    UIView *absBox = [[UIView alloc] init];
    absBox.gwstyle.width = 60;
    absBox.gwstyle.height = 60;
    absBox.gwstyle.positionType = YGKPositionTypeAbsolute;
    // Position offsets via setPosition:value:
    [absBox.gwstyle setPosition:YGKEdgeBottom value:12];
    [absBox.gwstyle setPosition:YGKEdgeRight value:12];
    absBox.backgroundColor = UIColor.systemRedColor;
    absBox.layer.cornerRadius = 8;
    [absContainer addChild:absBox];

    UILabel *absText = [[UILabel alloc] init];
    absText.text = @"absolute";
    absText.font = [UIFont boldSystemFontOfSize:10];
    absText.textColor = UIColor.whiteColor;
    absText.textAlignment = NSTextAlignmentCenter;
    absText.gwstyle.alignSelf = YGKAlignCenter;
    absText.gwstyle.flexGrow = 1;
    [absBox addChild:absText];
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
    self.container.frame = CGRectMake(0, top, w, h);
    [self.container performYogaLayout];
}

@end
