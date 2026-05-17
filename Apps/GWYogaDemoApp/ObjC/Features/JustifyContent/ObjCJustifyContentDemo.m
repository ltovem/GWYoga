#import "ObjCJustifyContentDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCJustifyContentDemo ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCJustifyContentDemo

- (UIView *)makeBoxWithColor:(UIColor *)color {
    UIView *box = [[UIView alloc] init];
    box.backgroundColor = color;
    box.layer.cornerRadius = 4;
    [box gwstyle:^(YGKLayoutProperties *p) {
        p.width = 40;
        p.height = 36;
    }];
    return box;
}

- (YogaLayoutView *)makeRowWithJustify:(YGKJustify)justify label:(NSString *)label {
    YogaLayoutView *section = [[YogaLayoutView alloc] init];
    [section gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionColumn;
        [p setMargin:YGKEdgeBottom value:20];
    }];

    UILabel *title = [[UILabel alloc] init];
    title.text = label;
    title.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium];
    title.textColor = UIColor.secondaryLabelColor;
    title.gwstyle.height = 16;
    [section addChild:title];

    YogaLayoutView *row = [[YogaLayoutView alloc] init];
    [row gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionRow;
        p.justifyContent = justify;
        [p setPadding:YGKEdgeAll value:8];
        p.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.08];
    }];
    row.layer.cornerRadius = 6;
    row.layer.borderWidth = 0.5;
    row.layer.borderColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.2].CGColor;

    [row addChild:[self makeBoxWithColor:UIColor.systemRedColor]];
    [row addChild:[self makeBoxWithColor:UIColor.systemGreenColor]];
    [row addChild:[self makeBoxWithColor:UIColor.systemBlueColor]];
    [section addChild:row];
    return section;
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

    // scroll view
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];

    // container
    self.container = [[YogaLayoutView alloc] init];
    [self.container gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionColumn;
        [p setPadding:YGKEdgeHorizontal value:16];
        [p setPadding:YGKEdgeTop value:8];
    }];
    [self.scrollView addSubview:self.container];

    // sections
    [self.container addChild:[self makeRowWithJustify:YGKJustifyFlexStart label:@"justifyContent: flex-start"]];
    [self.container addChild:[self makeRowWithJustify:YGKJustifyCenter label:@"justifyContent: center"]];
    [self.container addChild:[self makeRowWithJustify:YGKJustifyFlexEnd label:@"justifyContent: flex-end"]];
    [self.container addChild:[self makeRowWithJustify:YGKJustifySpaceBetween label:@"justifyContent: space-between"]];
    [self.container addChild:[self makeRowWithJustify:YGKJustifySpaceAround label:@"justifyContent: space-around"]];
    [self.container addChild:[self makeRowWithJustify:YGKJustifySpaceEvenly label:@"justifyContent: space-evenly"]];
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
