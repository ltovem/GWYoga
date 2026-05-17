#import "ObjCFlexboxDirectionPropertyDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCFlexboxDirectionPropertyDemo ()
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCFlexboxDirectionPropertyDemo

- (UIView *)makeBoxWithColor:(UIColor *)color {
    UIView *box = [[UIView alloc] init];
    box.gwstyle.width = 60;
    box.gwstyle.height = 50;
    [box.gwstyle setMargin:YGKEdgeAll value:4];
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

    // title
    UILabel *title = [[UILabel alloc] init];
    title.text = @"属性 (property) — flexDirection / justifyContent / alignItems";
    title.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    title.textColor = UIColor.secondaryLabelColor;
    [self.view addSubview:title];
    title.gwstyle.width = 300;
    title.gwstyle.height = 20;

    // container — property-style configuration
    self.container = [[YogaLayoutView alloc] init];
    self.container.gwstyle.flexDirection = YGKFlexDirectionRow;
    self.container.gwstyle.justifyContent = YGKJustifyCenter;
    self.container.gwstyle.alignItems = YGKAlignCenter;
    [self.container.gwstyle setPadding:YGKEdgeAll value:12];
    [self.container.gwstyle setMargin:YGKEdgeAll value:16];
    self.container.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    self.container.layer.cornerRadius = 8;
    self.container.clipsToBounds = YES;
    [self.view addChild:self.container];

    [self.container addChild:[self makeBoxWithColor:UIColor.systemRedColor]];
    [self.container addChild:[self makeBoxWithColor:UIColor.systemGreenColor]];
    [self.container addChild:[self makeBoxWithColor:UIColor.systemBlueColor]];
    [self.container addChild:[self makeBoxWithColor:UIColor.systemOrangeColor]];
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
