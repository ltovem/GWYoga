#import "ObjCCornerRadiusDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCCornerRadiusDemo ()
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCCornerRadiusDemo

- (UIView *)makeRoundedViewWithColor:(UIColor *)color radius:(CGFloat)radius label:(NSString *)text {
    UIView *view = [[UIView alloc] init];
    view.gwstyle.width = 90;
    view.gwstyle.height = 80;
    view.gwstyle.cornerRadius = radius;
    [view.gwstyle setMargin:YGKEdgeAll value:8];
    view.backgroundColor = color;
    view.clipsToBounds = YES;

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.gwstyle.alignSelf = YGKAlignCenter;
    label.gwstyle.flexGrow = 1;
    [view addChild:label];

    return view;
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
    title.text = @"cornerRadius — property style";
    title.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightSemibold];
    [title.gwstyle setMargin:YGKEdgeBottom value:8];
    [self.view addChild:title];

    // container
    self.container = [[YogaLayoutView alloc] init];
    self.container.gwstyle.flexDirection = YGKFlexDirectionRow;
    self.container.gwstyle.justifyContent = YGKJustifyCenter;
    self.container.gwstyle.alignItems = YGKAlignCenter;
    self.container.gwstyle.flexWrap = YGKWrapWrap;
    [self.container.gwstyle setPadding:YGKEdgeAll value:12];
    self.container.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    self.container.layer.cornerRadius = 8;
    [self.view addChild:self.container];

    [self.container addChild:[self makeRoundedViewWithColor:UIColor.systemRedColor radius:0 label:@"radius: 0"]];
    [self.container addChild:[self makeRoundedViewWithColor:UIColor.systemGreenColor radius:8 label:@"radius: 8"]];
    [self.container addChild:[self makeRoundedViewWithColor:UIColor.systemBlueColor radius:16 label:@"radius: 16"]];
    [self.container addChild:[self makeRoundedViewWithColor:UIColor.systemOrangeColor radius:40 label:@"radius: 40\n(capsule)"]];
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
