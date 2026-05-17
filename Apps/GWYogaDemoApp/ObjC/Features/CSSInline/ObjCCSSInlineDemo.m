#import "ObjCCSSInlineDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>
#import <GWYogaKitStylesheetObjCCore/GWYogaKitStylesheetObjCCore-Swift.h>

@interface ObjCCSSInlineDemo ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCCSSInlineDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    // badge
    self.badge = [[UILabel alloc] init];
    self.badge.text = @"  CSS  ";
    self.badge.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium];
    self.badge.textColor = UIColor.systemBlueColor;
    self.badge.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    self.badge.layer.cornerRadius = 4;
    self.badge.clipsToBounds = YES;
    [self.view addSubview:self.badge];

    // scroll view
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];

    // container
    self.container = [[YogaLayoutView alloc] init];
    [self.container.gwstyle setPadding:YGKEdgeAll value:16];
    [self.scrollView addSubview:self.container];

    // title
    UILabel *title = [[UILabel alloc] init];
    title.text = @"CSS Stylesheet — inline CSS";
    title.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightSemibold];
    title.gwstyle.height = 24;
    [title.gwstyle setMargin:YGKEdgeBottom value:12];
    [self.container addChild:title];

    // ── Example 1: Apply CSS to a box ──
    UILabel *desc1 = [[UILabel alloc] init];
    desc1.text = @"* { width: 80; height: 80; margin: 6px; }";
    desc1.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    desc1.textColor = UIColor.systemGreenColor;
    desc1.gwstyle.height = 18;
    [desc1.gwstyle setMargin:YGKEdgeBottom value:6];
    [self.container addChild:desc1];

    YogaLayoutView *row1 = [[YogaLayoutView alloc] init];
    row1.gwstyle.flexDirection = YGKFlexDirectionRow;
    [row1.gwstyle setPadding:YGKEdgeAll value:12];
    row1.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
    row1.layer.cornerRadius = 6;
    [row1.gwstyle setMargin:YGKEdgeBottom value:20];
    [self.container addChild:row1];

    for (UIColor *color in @[UIColor.systemRedColor, UIColor.systemGreenColor, UIColor.systemBlueColor]) {
        UIView *box = [[UIView alloc] init];
        box.backgroundColor = color;
        box.layer.cornerRadius = 4;
        NSError *err = nil;
        YGKStylesheet *sheet = [YGKStylesheet parse:@"* { width: 80; height: 80; margin: 6px; }" error:&err];
        if (!err) { [sheet applyTo:box]; }
        [row1 addChild:box];
    }

    // ── Example 2: Grid with CSS ──
    UILabel *desc2 = [[UILabel alloc] init];
    desc2.text = @"display: grid; grid-template-columns: 1fr 1fr; gap: 8px;";
    desc2.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    desc2.textColor = UIColor.systemGreenColor;
    desc2.gwstyle.height = 18;
    [desc2.gwstyle setMargin:YGKEdgeBottom value:6];
    [self.container addChild:desc2];

    YogaLayoutView *grid = [[YogaLayoutView alloc] init];
    NSError *gridErr = nil;
    YGKStylesheet *gridSheet = [YGKStylesheet parse:@"* { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; padding: 12px; }" error:&gridErr];
    if (!gridErr) { [gridSheet applyTo:grid]; }
    grid.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
    grid.layer.cornerRadius = 6;
    [grid.gwstyle setMargin:YGKEdgeBottom value:20];
    [self.container addChild:grid];

    for (UIColor *color in @[UIColor.systemRedColor, UIColor.systemGreenColor, UIColor.systemBlueColor, UIColor.systemOrangeColor]) {
        UIView *cell = [[UIView alloc] init];
        cell.backgroundColor = color;
        cell.layer.cornerRadius = 4;
        NSError *cellErr = nil;
        YGKStylesheet *cellSheet = [YGKStylesheet parse:@"* { height: 60; }" error:&cellErr];
        if (!cellErr) { [cellSheet applyTo:cell]; }
        [grid addChild:cell];
    }

    // ── Example 3: Flexbox with CSS ──
    UILabel *desc3 = [[UILabel alloc] init];
    desc3.text = @"flex-direction: row; justify-content: space-around;";
    desc3.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    desc3.textColor = UIColor.systemGreenColor;
    desc3.gwstyle.height = 18;
    [desc3.gwstyle setMargin:YGKEdgeBottom value:6];
    [self.container addChild:desc3];

    YogaLayoutView *flexRow = [[YogaLayoutView alloc] init];
    NSError *flexErr = nil;
    YGKStylesheet *flexSheet = [YGKStylesheet parse:@"* { flex-direction: row; justify-content: space-around; align-items: center; padding: 16px; }" error:&flexErr];
    if (!flexErr) { [flexSheet applyTo:flexRow]; }
    flexRow.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
    flexRow.layer.cornerRadius = 6;
    [flexRow.gwstyle setMargin:YGKEdgeBottom value:20];
    [self.container addChild:flexRow];

    for (UIColor *color in @[UIColor.systemRedColor, UIColor.systemGreenColor, UIColor.systemBlueColor]) {
        UIView *box = [[UIView alloc] init];
        box.backgroundColor = color;
        box.layer.cornerRadius = 6;
        NSError *bErr = nil;
        YGKStylesheet *bSheet = [YGKStylesheet parse:@"* { width: 60; height: 50; }" error:&bErr];
        if (!bErr) { [bSheet applyTo:box]; }
        [flexRow addChild:box];
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
