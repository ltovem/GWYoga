#import "ObjCYogaStackDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCYogaStackDemo ()
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCYogaStackDemo

- (UIView *)makePillWithColor:(UIColor *)color label:(NSString *)text {
    UIView *pill = [[UIView alloc] init];
    pill.backgroundColor = color;
    pill.layer.cornerRadius = 12;
    [pill gwstyle:^(YGKLayoutProperties *p) {
        p.width = 80;
        p.height = 36;
        [p setMargin:YGKEdgeAll value:4];
    }];

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    [label gwstyle:^(YGKLayoutProperties *p) {
        p.alignSelf = YGKAlignCenter;
        p.flexGrow = 1;
    }];
    [pill addChild:label];
    return pill;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    // badge
    self.badge = [[UILabel alloc] init];
    self.badge.text = @"  Block  ";
    self.badge.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium];
    self.badge.textColor = UIColor.systemBlueColor;
    self.badge.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    self.badge.layer.cornerRadius = 4;
    self.badge.clipsToBounds = YES;
    [self.view addSubview:self.badge];

    // container — column (VStack)
    self.container = [[YogaLayoutView alloc] init];
    [self.container gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionColumn;
        p.alignItems = YGKAlignCenter;
        [p setPadding:YGKEdgeAll value:16];
    }];
    [self.view addChild:self.container];

    // title
    UILabel *title = [[UILabel alloc] init];
    title.text = @"YogaStack — VStack (column) & HStack (row)";
    title.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightMedium];
    title.textColor = UIColor.secondaryLabelColor;
    [title gwstyle:^(YGKLayoutProperties *p) {
        p.height = 20;
        [p setMargin:YGKEdgeBottom value:12];
    }];
    [self.container addChild:title];

    // — VStack section —
    UILabel *vLabel = [[UILabel alloc] init];
    vLabel.text = @"VStack (flexDirection: column)";
    vLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    [vLabel gwstyle:^(YGKLayoutProperties *p) {
        p.height = 18;
        [p setMargin:YGKEdgeBottom value:6];
        p.alignSelf = YGKAlignFlexStart;
    }];
    [self.container addChild:vLabel];

    YogaLayoutView *vStack = [[YogaLayoutView alloc] init];
    [vStack gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionColumn;
        p.alignItems = YGKAlignCenter;
        [p setPadding:YGKEdgeAll value:12];
        p.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
    }];
    vStack.layer.cornerRadius = 8;
    [vStack.gwstyle setMargin:YGKEdgeBottom value:24];
    [self.container addChild:vStack];

    [vStack addChild:[self makePillWithColor:UIColor.systemRedColor label:@"Item A"]];
    [vStack addChild:[self makePillWithColor:UIColor.systemGreenColor label:@"Item B"]];
    [vStack addChild:[self makePillWithColor:UIColor.systemBlueColor label:@"Item C"]];

    // — HStack section —
    UILabel *hLabel = [[UILabel alloc] init];
    hLabel.text = @"HStack (flexDirection: row)";
    hLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    [hLabel gwstyle:^(YGKLayoutProperties *p) {
        p.height = 18;
        [p setMargin:YGKEdgeBottom value:6];
        p.alignSelf = YGKAlignFlexStart;
    }];
    [self.container addChild:hLabel];

    YogaLayoutView *hStack = [[YogaLayoutView alloc] init];
    [hStack gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionRow;
        p.justifyContent = YGKJustifyCenter;
        [p setPadding:YGKEdgeAll value:12];
        p.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
    }];
    hStack.layer.cornerRadius = 8;
    [self.container addChild:hStack];

    [hStack addChild:[self makePillWithColor:UIColor.systemRedColor label:@"A"]];
    [hStack addChild:[self makePillWithColor:UIColor.systemGreenColor label:@"B"]];
    [hStack addChild:[self makePillWithColor:UIColor.systemBlueColor label:@"C"]];
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
