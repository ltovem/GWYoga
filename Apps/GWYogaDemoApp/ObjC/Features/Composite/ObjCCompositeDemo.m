#import "ObjCCompositeDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCCompositeDemo ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCCompositeDemo

- (UIView *)makeAvatarWithColor:(UIColor *)color initials:(NSString *)text {
    UIView *avatar = [[UIView alloc] init];
    avatar.gwstyle.width = 48;
    avatar.gwstyle.height = 48;
    avatar.gwstyle.cornerRadius = 24;
    avatar.backgroundColor = color;

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.gwstyle.alignSelf = YGKAlignCenter;
    label.gwstyle.flexGrow = 1;
    [avatar addChild:label];
    return avatar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    // badge
    self.badge = [[UILabel alloc] init];
    self.badge.text = @"  属性+Block  ";
    self.badge.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium];
    self.badge.textColor = UIColor.systemBlueColor;
    self.badge.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    self.badge.layer.cornerRadius = 4;
    self.badge.clipsToBounds = YES;
    [self.view addSubview:self.badge];

    // scroll view
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];

    // container — property style for basics
    self.container = [[YogaLayoutView alloc] init];
    self.container.gwstyle.flexDirection = YGKFlexDirectionColumn;
    [self.container.gwstyle setPadding:YGKEdgeAll value:16];
    [self.scrollView addSubview:self.container];

    // title
    UILabel *title = [[UILabel alloc] init];
    title.text = @"Composite — 属性 + Block 混合";
    title.font = [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightSemibold];
    [title.gwstyle setMargin:YGKEdgeBottom value:16];
    title.gwstyle.alignSelf = YGKAlignCenter;
    [self.container addChild:title];

    // ── Card 1: Profile card using block style ──
    YogaLayoutView *card1 = [[YogaLayoutView alloc] init];
    [card1 gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionRow;
        p.alignItems = YGKAlignCenter;
        [p setPadding:YGKEdgeAll value:16];
        p.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
        [p setMargin:YGKEdgeBottom value:16];
        p.cornerRadius = 12;
    }];
    [self.container addChild:card1];

    [card1 addChild:[self makeAvatarWithColor:UIColor.systemBlueColor initials:@"YZ"]];

    // name column — property style
    YogaLayoutView *nameCol = [[YogaLayoutView alloc] init];
    nameCol.gwstyle.flexDirection = YGKFlexDirectionColumn;
    [nameCol.gwstyle setMargin:YGKEdgeLeft value:12];
    nameCol.gwstyle.flexGrow = 1;
    [card1 addChild:nameCol];

    UILabel *name = [[UILabel alloc] init];
    name.text = @"Yoga Zhang";
    name.font = [UIFont boldSystemFontOfSize:16];
    name.gwstyle.height = 22;
    [nameCol addChild:name];

    UILabel *bio = [[UILabel alloc] init];
    bio.text = @"Layout engineer · Flexbox enthusiast";
    bio.font = [UIFont systemFontOfSize:12];
    bio.textColor = UIColor.secondaryLabelColor;
    bio.gwstyle.height = 16;
    [nameCol addChild:bio];

    // ── Card 2: Stats row using block style ──
    YogaLayoutView *card2 = [[YogaLayoutView alloc] init];
    [card2 gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionRow;
        p.justifyContent = YGKJustifySpaceAround;
        [p setPadding:YGKEdgeAll value:16];
        p.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
        [p setMargin:YGKEdgeBottom value:16];
        p.cornerRadius = 12;
    }];
    [self.container addChild:card2];

    for (NSDictionary *stat in @[
        @{@"value": @"128", @"label": @"Posts"},
        @{@"value": @"3.2K", @"label": @"Followers"},
        @{@"value": @"64", @"label": @"Following"},
    ]) {
        YogaLayoutView *col = [[YogaLayoutView alloc] init];
        col.gwstyle.flexDirection = YGKFlexDirectionColumn;
        col.gwstyle.alignItems = YGKAlignCenter;
        [card2 addChild:col];

        UILabel *val = [[UILabel alloc] init];
        val.text = stat[@"value"];
        val.font = [UIFont boldSystemFontOfSize:18];
        val.gwstyle.height = 24;
        [col addChild:val];

        UILabel *lbl = [[UILabel alloc] init];
        lbl.text = stat[@"label"];
        lbl.font = [UIFont systemFontOfSize:11];
        lbl.textColor = UIColor.secondaryLabelColor;
        lbl.gwstyle.height = 16;
        [col addChild:lbl];
    }

    // ── Card 3: Tags using block style ──
    YogaLayoutView *card3 = [[YogaLayoutView alloc] init];
    [card3 gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionRow;
        p.flexWrap = YGKWrapWrap;
        p.alignItems = YGKAlignCenter;
        [p setPadding:YGKEdgeAll value:12];
        p.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
        p.cornerRadius = 12;
    }];
    [self.container addChild:card3];

    for (NSString *tag in @[@"ObjC", @"Yoga", @"Flexbox", @"Grid", @"Animation", @"CSS"]) {
        UIView *pill = [[UIView alloc] init];
        pill.backgroundColor = UIColor.systemBlueColor;
        pill.layer.cornerRadius = 10;
        [pill.gwstyle setMargin:YGKEdgeRight value:6];
        [pill.gwstyle setMargin:YGKEdgeBottom value:6];

        UILabel *tagLabel = [[UILabel alloc] init];
        tagLabel.text = tag;
        tagLabel.font = [UIFont systemFontOfSize:11];
        tagLabel.textColor = UIColor.whiteColor;
        [tagLabel.gwstyle setMargin:YGKEdgeLeft value:10];
        [tagLabel.gwstyle setMargin:YGKEdgeRight value:10];
        tagLabel.gwstyle.height = 20;
        [pill addChild:tagLabel];
        [card3 addChild:pill];
    }
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
    CGFloat h = self.view.bounds.size.height - top;
    self.scrollView.frame = CGRectMake(0, top, w, h);

    self.container.frame = CGRectMake(0, 0, self.scrollView.bounds.size.width, 0);
    [self.container performYogaLayout];
    CGFloat contentHeight = self.container.gwstyle.frame.size.height;
    self.container.frame = CGRectMake(0, 0, self.scrollView.bounds.size.width, contentHeight);
    [self.container performYogaLayout];
    self.scrollView.contentSize = CGSizeMake(w, contentHeight);
}

@end
