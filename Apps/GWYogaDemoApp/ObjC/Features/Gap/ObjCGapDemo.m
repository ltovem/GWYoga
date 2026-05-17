#import "ObjCGapDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCGapDemo ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCGapDemo

- (UIView *)makeBoxWithColor:(UIColor *)color {
    UIView *box = [[UIView alloc] init];
    box.gwstyle.width = 50;
    box.gwstyle.height = 44;
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

    // scroll view
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];

    // container
    self.container = [[YogaLayoutView alloc] init];
    [self.container.gwstyle setPadding:YGKEdgeAll value:16];
    [self.view addChild:self.container];

    // — Row Gap —
    UILabel *rgLabel = [[UILabel alloc] init];
    rgLabel.text = @"rowGap: 12, column direction (wrapping)";
    rgLabel.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightMedium];
    rgLabel.textColor = UIColor.secondaryLabelColor;
    rgLabel.gwstyle.height = 20;
    [rgLabel.gwstyle setMargin:YGKEdgeBottom value:6];
    [self.container addChild:rgLabel];

    YogaLayoutView *rowGapView = [[YogaLayoutView alloc] init];
    rowGapView.gwstyle.flexDirection = YGKFlexDirectionRow;
    rowGapView.gwstyle.flexWrap = YGKWrapWrap;
    rowGapView.gwstyle.rowGap = 12;
    rowGapView.gwstyle.columnGap = 8;
    [rowGapView.gwstyle setPadding:YGKEdgeAll value:12];
    rowGapView.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    rowGapView.layer.cornerRadius = 6;
    [rowGapView.gwstyle setMargin:YGKEdgeBottom value:24];
    [self.container addChild:rowGapView];

    for (int i = 0; i < 6; i++) {
        UIColor *color = [UIColor colorWithHue:(i / 6.0) saturation:0.7 brightness:0.9 alpha:1];
        [rowGapView addChild:[self makeBoxWithColor:color]];
    }

    // — Column Gap —
    UILabel *cgLabel = [[UILabel alloc] init];
    cgLabel.text = @"columnGap: 20, row direction";
    cgLabel.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightMedium];
    cgLabel.textColor = UIColor.secondaryLabelColor;
    cgLabel.gwstyle.height = 20;
    [cgLabel.gwstyle setMargin:YGKEdgeBottom value:6];
    [self.container addChild:cgLabel];

    YogaLayoutView *colGapView = [[YogaLayoutView alloc] init];
    colGapView.gwstyle.flexDirection = YGKFlexDirectionRow;
    colGapView.gwstyle.columnGap = 20;
    [colGapView.gwstyle setPadding:YGKEdgeAll value:12];
    colGapView.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    colGapView.layer.cornerRadius = 6;
    [colGapView.gwstyle setMargin:YGKEdgeBottom value:24];
    [self.container addChild:colGapView];

    for (int i = 0; i < 4; i++) {
        UIColor *color = [UIColor colorWithHue:(i / 4.0) saturation:0.6 brightness:0.85 alpha:1];
        [colGapView addChild:[self makeBoxWithColor:color]];
    }

    // — No gap comparison —
    UILabel *noLabel = [[UILabel alloc] init];
    noLabel.text = @"No gap (comparison)";
    noLabel.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightMedium];
    noLabel.textColor = UIColor.secondaryLabelColor;
    noLabel.gwstyle.height = 20;
    [noLabel.gwstyle setMargin:YGKEdgeBottom value:6];
    [self.container addChild:noLabel];

    YogaLayoutView *noGapView = [[YogaLayoutView alloc] init];
    noGapView.gwstyle.flexDirection = YGKFlexDirectionRow;
    [noGapView.gwstyle setPadding:YGKEdgeAll value:12];
    noGapView.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    noGapView.layer.cornerRadius = 6;
    [self.container addChild:noGapView];

    for (int i = 0; i < 4; i++) {
        UIColor *color = [UIColor colorWithHue:(i / 4.0) saturation:0.5 brightness:0.8 alpha:1];
        [noGapView addChild:[self makeBoxWithColor:color]];
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
