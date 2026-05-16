#import "ObjCFlexboxDirectionPropertyDemo.h"
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>
#import <GWYogaKitStylesheetObjCCore/GWYogaKitStylesheetObjCCore-Swift.h>

@interface ObjCFlexboxDirectionPropertyDemo ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCFlexboxDirectionPropertyDemo

- (UIView *)makeBoxWithColor:(UIColor *)color {
    UIView *box = [[UIView alloc] init];
    box.gwstyle.width = 50;
    box.gwstyle.height = 40;
    [box.gwstyle setMargin:YGKEdgeAll value:4];
    box.backgroundColor = color;
    box.layer.cornerRadius = 4;
    return box;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    // ── badge ──
    UILabel *badge = [[UILabel alloc] init];
    badge.text = @"  属性  链式  CSS卸载  ";
    badge.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium];
    badge.textColor = UIColor.systemBlueColor;
    badge.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    badge.layer.cornerRadius = 4;
    badge.clipsToBounds = YES;
    badge.tag = 999;
    [self.view addSubview:badge];
    self.badge = badge;

    // ── scroll view ──
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.showsVerticalScrollIndicator = YES;
    [self.view addSubview:scroll];
    self.scrollView = scroll;

    // ── container ──
    YogaLayoutView *container = [[YogaLayoutView alloc] init];
    container.gwstyle.flexDirection = YGKFlexDirectionColumn;
    container.gwstyle.rowGap = 24;
    [container.gwstyle setPadding:YGKEdgeAll value:16];
    container.gwstyle.backgroundColor = UIColor.systemBackgroundColor;
    [scroll addSubview:container];
    self.container = container;

    
    // ══════════════════════════════════════════
    // 1️⃣ 属性 — property assignment
    // ══════════════════════════════════════════
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"1. 属性 (property)";
    label1.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightSemibold];
    [container addChild:label1];

    YogaLayoutView *row1 = [[YogaLayoutView alloc] init];
    row1.gwstyle.flexDirection = YGKFlexDirectionRow;       // ← 属性 直接赋值
    row1.gwstyle.alignItems = YGKAlignCenter;
    [row1.gwstyle setPadding:YGKEdgeAll value:8];
    row1.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    row1.layer.cornerRadius = 6;
    [row1 addChild:[self makeBoxWithColor:UIColor.systemRedColor]];
    [row1 addChild:[self makeBoxWithColor:UIColor.systemGreenColor]];
    [row1 addChild:[self makeBoxWithColor:UIColor.systemBlueColor]];
    [container addChild:row1];

    // ══════════════════════════════════════════
    // 2️⃣ 链式 — block-based style grouping
    // ══════════════════════════════════════════
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"2. 链式 (block)";
    label2.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightSemibold];
    [container addChild:label2];

    YogaLayoutView *row2 = [[YogaLayoutView alloc] init];
    [row2 gwstyle:^(YGKLayoutProperties *p) {               // ← 链式 闭包内统一配置
        p.flexDirection = YGKFlexDirectionRow;
        p.alignItems = YGKAlignCenter;
        [p setPadding:YGKEdgeAll value:8];
    }];
    row2.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    row2.layer.cornerRadius = 6;
    [row2 addChild:[self makeBoxWithColor:UIColor.systemRedColor]];
    [row2 addChild:[self makeBoxWithColor:UIColor.systemGreenColor]];
    [row2 addChild:[self makeBoxWithColor:UIColor.systemBlueColor]];
    [container addChild:row2];

    // ══════════════════════════════════════════
    // 3️⃣ CSS卸载 — stylesheet CSS string
    // ══════════════════════════════════════════
    UILabel *label3 = [[UILabel alloc] init];
    label3.text = @"3. CSS卸载 (stylesheet)";
    label3.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightSemibold];
    [container addChild:label3];

    YogaLayoutView *row3 = [[YogaLayoutView alloc] init];
    NSError *cssError = nil;
    YGKStylesheet *sheet = [YGKStylesheet parse:              // ← CSS卸载 解析CSS字符串
        @".row { flex-direction: row; align-items: center; padding: 8px; }"
        error:&cssError
    ];
    if (cssError) {
        NSLog(@"[GWYoga] CSS parse error: %@", cssError);
    }
    [sheet applyTo:row3];
    row3.gwstyle.backgroundColor = [UIColor.systemGrayColor colorWithAlphaComponent:0.1];
    row3.layer.cornerRadius = 6;
    [row3 addChild:[self makeBoxWithColor:UIColor.systemRedColor]];
    [row3 addChild:[self makeBoxWithColor:UIColor.systemGreenColor]];
    [row3 addChild:[self makeBoxWithColor:UIColor.systemBlueColor]];
    [container addChild:row3];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat w = self.view.bounds.size.width;
    CGFloat top = self.view.safeAreaLayoutGuide.layoutFrame.origin.y;

    // badge
    UILabel *badge = [self.view viewWithTag:999];
    if (badge) {
        [badge sizeToFit];
        badge.frame = CGRectMake(
            w - badge.frame.size.width - 16,
            top + 8,
            badge.frame.size.width,
            badge.frame.size.height
        );
    }

    // scroll view — 全屏，避开 safe area
    self.scrollView.frame = CGRectMake(0, top + 40, w, self.view.bounds.size.height - top - 40);

    // yoga container — 宽度撑满 scroll，高度由 yoga 自动计算
    CGFloat contentWidth = self.scrollView.bounds.size.width - 32;
    self.container.frame = CGRectMake(0, 0, self.scrollView.bounds.size.width, 0);
    [self.container performYogaLayout];

    // 用 yoga 布局后的内容高度设置 scroll 的 contentSize
    CGFloat contentHeight = self.container.gwstyle.frame.size.height;
    self.container.frame = CGRectMake(0, 0, self.scrollView.bounds.size.width, contentHeight);
    [self.container performYogaLayout];
    

    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, contentHeight);
}

@end
