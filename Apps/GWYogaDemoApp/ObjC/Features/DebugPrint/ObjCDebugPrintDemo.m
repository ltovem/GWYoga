#import "ObjCDebugPrintDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCDebugPrintDemo ()
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCDebugPrintDemo

- (void)printTreeForView:(UIView *)view indent:(NSString *)indent isLast:(BOOL)isLast {
    NSString *branch = isLast ? @"└─ " : @"├─ ";
    NSString *frameStr = [NSString stringWithFormat:@"%.0f×%.0f @%.0f,%.0f",
                          view.frame.size.width, view.frame.size.height,
                          view.frame.origin.x, view.frame.origin.y];
    NSLog(@"%@%@ %@ (%@)", indent, branch, NSStringFromClass([view class]), frameStr);

    NSArray *subviews = view.subviews;
    for (NSUInteger i = 0; i < subviews.count; i++) {
        BOOL childIsLast = (i == subviews.count - 1);
        NSString *childIndent = [indent stringByAppendingString:isLast ? @"    " : @"   │"];
        [self printTreeForView:subviews[i] indent:childIndent isLast:childIsLast];
    }
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
    title.text = @"Debug Print — Yoga tree console output";
    title.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightMedium];
    title.textColor = UIColor.secondaryLabelColor;
    [title.gwstyle setMargin:YGKEdgeBottom value:8];
    [self.view addChild:title];

    // container with nested structure
    self.container = [[YogaLayoutView alloc] init];
    self.container.gwstyle.flexDirection = YGKFlexDirectionColumn;
    [self.container.gwstyle setPadding:YGKEdgeAll value:16];
    self.container.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.12];
    self.container.layer.cornerRadius = 8;
    [self.view addChild:self.container];

    // row 1
    YogaLayoutView *row1 = [[YogaLayoutView alloc] init];
    row1.gwstyle.flexDirection = YGKFlexDirectionRow;
    row1.gwstyle.justifyContent = YGKJustifySpaceAround;
    [row1.gwstyle setPadding:YGKEdgeAll value:8];
    row1.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
    row1.layer.cornerRadius = 6;
    [row1.gwstyle setMargin:YGKEdgeBottom value:8];
    [self.container addChild:row1];

    for (UIColor *color in @[UIColor.systemRedColor, UIColor.systemGreenColor, UIColor.systemBlueColor]) {
        UIView *box = [[UIView alloc] init];
        box.gwstyle.width = 50;
        box.gwstyle.height = 50;
        box.backgroundColor = color;
        box.layer.cornerRadius = 4;
        [row1 addChild:box];
    }

    // row 2
    YogaLayoutView *row2 = [[YogaLayoutView alloc] init];
    row2.gwstyle.flexDirection = YGKFlexDirectionRow;
    row2.gwstyle.justifyContent = YGKJustifyCenter;
    [row2.gwstyle setPadding:YGKEdgeAll value:8];
    row2.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
    row2.layer.cornerRadius = 6;
    [row2.gwstyle setMargin:YGKEdgeBottom value:8];
    [self.container addChild:row2];

    for (UIColor *color in @[UIColor.systemOrangeColor, UIColor.systemPurpleColor]) {
        UIView *box = [[UIView alloc] init];
        box.gwstyle.width = 60;
        box.gwstyle.height = 40;
        box.backgroundColor = color;
        box.layer.cornerRadius = 4;
        [box.gwstyle setMargin:YGKEdgeHorizontal value:8];
        [row2 addChild:box];
    }

    // single child
    UIView *single = [[UIView alloc] init];
    single.gwstyle.width = 100;
    single.gwstyle.height = 30;
    single.backgroundColor = UIColor.systemTealColor;
    single.layer.cornerRadius = 4;
    single.gwstyle.alignSelf = YGKAlignCenter;
    [self.container addChild:single];

    // info label
    UILabel *info = [[UILabel alloc] init];
    info.text = @"Check Xcode console for tree output";
    info.font = [UIFont systemFontOfSize:13];
    info.textColor = UIColor.systemGrayColor;
    info.textAlignment = NSTextAlignmentCenter;
    [info.gwstyle setMargin:YGKEdgeTop value:16];
    info.gwstyle.alignSelf = YGKAlignCenter;
    [self.view addChild:info];

    // Print tree after layout
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"╔═══════════════════════════════════════");
        NSLog(@"║  GWYoga Debug Tree");
        NSLog(@"╚═══════════════════════════════════════");
        [self printTreeForView:self.container indent:@"" isLast:YES];
    });
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
    self.container.frame = CGRectMake(16, top, w - 32, 0);
    [self.container performYogaLayout];
    CGFloat ch = self.container.gwstyle.frame.size.height;
    self.container.frame = CGRectMake(16, top, w - 32, ch);
    [self.container performYogaLayout];
}

@end
