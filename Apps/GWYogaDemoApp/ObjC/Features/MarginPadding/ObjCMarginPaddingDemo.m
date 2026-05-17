#import "ObjCMarginPaddingDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCMarginPaddingDemo ()
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCMarginPaddingDemo

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
    title.text = @"Margin & Padding (属性)";
    title.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightSemibold];
    title.gwstyle.height = 24;
    [self.view addChild:title];

    // container
    self.container = [[YogaLayoutView alloc] init];
    self.container.gwstyle.flexDirection = YGKFlexDirectionRow;
    self.container.gwstyle.justifyContent = YGKJustifyCenter;
    self.container.gwstyle.alignItems = YGKAlignCenter;
    [self.container.gwstyle setPadding:YGKEdgeAll value:24]; // padding inside container
    self.container.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.12];
    self.container.layer.cornerRadius = 8;
    [self.view addChild:self.container];

    // child 1 — margin all
    UIView *box1 = [[UIView alloc] init];
    box1.gwstyle.width = 70;
    box1.gwstyle.height = 60;
    [box1.gwstyle setMargin:YGKEdgeAll value:12];
    box1.backgroundColor = UIColor.systemBlueColor;
    box1.layer.cornerRadius = 6;
    [self.container addChild:box1];

    // child 2 — specific edge margins
    UIView *box2 = [[UIView alloc] init];
    box2.gwstyle.width = 70;
    box2.gwstyle.height = 60;
    [box2.gwstyle setMargin:YGKEdgeTop value:4];
    [box2.gwstyle setMargin:YGKEdgeBottom value:20];
    [box2.gwstyle setMargin:YGKEdgeLeft value:8];
    [box2.gwstyle setMargin:YGKEdgeRight value:8];
    box2.backgroundColor = UIColor.systemGreenColor;
    box2.layer.cornerRadius = 6;
    [self.container addChild:box2];

    // child 3 — horizontal/vertical margin
    UIView *box3 = [[UIView alloc] init];
    box3.gwstyle.width = 70;
    box3.gwstyle.height = 60;
    [box3.gwstyle setMargin:YGKEdgeHorizontal value:16];
    [box3.gwstyle setMargin:YGKEdgeVertical value:8];
    box3.backgroundColor = UIColor.systemOrangeColor;
    box3.layer.cornerRadius = 6;
    [self.container addChild:box3];
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

    CGFloat top = self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 36;
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height - top - 16;
    self.container.frame = CGRectMake(16, top, w - 32, h);
    [self.container performYogaLayout];
}

@end
