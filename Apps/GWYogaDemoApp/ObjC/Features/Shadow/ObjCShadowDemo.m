#import "ObjCShadowDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCShadowDemo ()
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCShadowDemo

- (UIView *)makeShadowBoxWithColor:(UIColor *)color
                       shadowColor:(UIColor *)shadowColor
                     shadowOpacity:(float)opacity
                      shadowRadius:(CGFloat)radius
                      shadowOffset:(CGSize)offset
                             label:(NSString *)text {
    UIView *view = [[UIView alloc] init];
    view.gwstyle.width = 100;
    view.gwstyle.height = 80;
    [view.gwstyle setMargin:YGKEdgeAll value:12];
    view.backgroundColor = color;
    view.layer.cornerRadius = 8;

    // Shadow properties via gwstyle (maps to CALayer)
    view.gwstyle.shadowColor = shadowColor;
    view.gwstyle.shadowOpacity = opacity;
    view.gwstyle.shadowRadius = radius;
    view.gwstyle.shadowOffset = offset;

    // Need to set masksToBounds = NO for shadows to show
    view.clipsToBounds = NO;
    view.layer.masksToBounds = NO;

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:9];
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
    title.text = @"Shadow — property style";
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

    [self.container addChild:[self makeShadowBoxWithColor:UIColor.systemBlueColor
                                               shadowColor:UIColor.blackColor
                                             shadowOpacity:0.3
                                              shadowRadius:4
                                              shadowOffset:CGSizeMake(2, 2)
                                                     label:@"subtle"]];
    [self.container addChild:[self makeShadowBoxWithColor:UIColor.systemGreenColor
                                               shadowColor:UIColor.blackColor
                                             shadowOpacity:0.5
                                              shadowRadius:10
                                              shadowOffset:CGSizeMake(0, 6)
                                                     label:@"heavy"]];
    [self.container addChild:[self makeShadowBoxWithColor:UIColor.systemOrangeColor
                                               shadowColor:UIColor.redColor
                                             shadowOpacity:0.4
                                              shadowRadius:8
                                              shadowOffset:CGSizeMake(0, 4)
                                                     label:@"colored"]];
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
