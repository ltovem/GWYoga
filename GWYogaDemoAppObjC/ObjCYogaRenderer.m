@import GWYogaKitObjCCore;
#import "ObjCYogaRenderer.h"

@implementation ObjCYogaRenderer

+ (NSArray<UIColor *> *)demoColors {
    static NSArray *colors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colors = @[
            [[UIColor systemRedColor] colorWithAlphaComponent:0.3],
            [[UIColor systemBlueColor] colorWithAlphaComponent:0.3],
            [[UIColor systemGreenColor] colorWithAlphaComponent:0.3],
            [[UIColor systemOrangeColor] colorWithAlphaComponent:0.3],
            [[UIColor systemPurpleColor] colorWithAlphaComponent:0.3],
            [[UIColor systemTealColor] colorWithAlphaComponent:0.3],
            [[UIColor systemPinkColor] colorWithAlphaComponent:0.3],
            [[UIColor systemIndigoColor] colorWithAlphaComponent:0.3],
        ];
    });
    return colors;
}

+ (UIView *)coloredChildWithWidth:(CGFloat)w height:(CGFloat)h index:(int)idx {
    NSArray<UIColor *> *colors = [self demoColors];
    UIColor *color = colors[idx % colors.count];
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = color;
    v.layer.borderWidth = 1;
    v.layer.borderColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.4].CGColor;
    v.layer.cornerRadius = 2;
    v.gwstyle.width = w;
    v.gwstyle.height = h;
    return v;
}

+ (YGKLayoutView *)makeContainerWithWidth:(CGFloat)width height:(CGFloat)height {
    YGKLayoutView *v = [[YGKLayoutView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    v.backgroundColor = [UIColor.systemGray6Color colorWithAlphaComponent:0.5];
    v.layer.borderColor = UIColor.systemBlueColor.CGColor;
    v.layer.borderWidth = 1;
    v.layer.cornerRadius = 4;
    v.layoutMode = YGKLayoutModeForced;
    return v;
}

+ (UIView *)createDemoSectionWithTitle:(NSString *)title container:(YGKLayoutView *)container {
    YGKLayoutView *section = [[YGKLayoutView alloc] init];
    section.gwstyle.flexDirection = YGKFlexDirectionColumn;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = UIColor.darkGrayColor;
    [titleLabel.gwstyle setMargin:YGKEdgeBottom value:6];

    [container performYogaLayout];

    UILabel *info = [[UILabel alloc] init];
    info.font = [UIFont monospacedSystemFontOfSize:10 weight:UIFontWeightRegular];
    info.textColor = UIColor.grayColor;
    info.numberOfLines = 0;
    [info.gwstyle setMargin:YGKEdgeTop value:4];
    info.text = [NSString stringWithFormat:@"%.0f×%.0f @(%.0f,%.0f)",
                  container.gwstyle.layoutWidth,
                  container.gwstyle.layoutHeight,
                  container.gwstyle.layoutLeft,
                  container.gwstyle.layoutTop];

    [section addSubview:titleLabel];
    [section addSubview:container];
    [section addSubview:info];
    return section;
}

+ (UIView *)createInfoSectionWithTitle:(NSString *)title text:(NSString *)text {
    YGKLayoutView *section = [[YGKLayoutView alloc] init];
    section.gwstyle.flexDirection = YGKFlexDirectionColumn;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [titleLabel.gwstyle setMargin:YGKEdgeBottom value:6];

    UILabel *info = [[UILabel alloc] init];
    info.text = text;
    info.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    info.numberOfLines = 0;

    [section addSubview:titleLabel];
    [section addSubview:info];
    return section;
}

+ (void)setupStackWithSections:(NSArray<UIView *> *)sections inScrollView:(UIScrollView *)scrollView {
    YGKLayoutView *stack = [[YGKLayoutView alloc] init];
    stack.gwstyle.flexDirection = YGKFlexDirectionColumn;
    [stack.gwstyle setPadding:YGKEdgeAll value:16];
    stack.gwstyle.rowGap = 32;
    stack.gwstyle.columnGap = 32;

    for (UIView *section in sections) {
        [stack addSubview:section];
    }

    [scrollView addSubview:stack];

    // Size the stack to match scrollView width
    scrollView.gwstyle.flexGrow = 1;
    stack.gwstyle.width = scrollView.bounds.size.width - 32;
}

@end
