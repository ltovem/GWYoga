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
    v.yogaProperties.width = w;
    v.yogaProperties.height = h;
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
    UIView *section = [[UIView alloc] init];
    section.translatesAutoresizingMaskIntoConstraints = false;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = UIColor.darkGrayColor;
    titleLabel.translatesAutoresizingMaskIntoConstraints = false;

    [container performYogaLayout];
    container.translatesAutoresizingMaskIntoConstraints = false;

    UILabel *info = [[UILabel alloc] init];
    info.font = [UIFont monospacedSystemFontOfSize:10 weight:UIFontWeightRegular];
    info.textColor = UIColor.grayColor;
    info.numberOfLines = 0;
    info.translatesAutoresizingMaskIntoConstraints = false;
    info.text = [NSString stringWithFormat:@"%.0f×%.0f @(%.0f,%.0f)",
                  container.yogaProperties.layoutWidth,
                  container.yogaProperties.layoutHeight,
                  container.yogaProperties.layoutLeft,
                  container.yogaProperties.layoutTop];

    [section addSubview:titleLabel];
    [section addSubview:container];
    [section addSubview:info];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:section.topAnchor],
        [titleLabel.leadingAnchor constraintEqualToAnchor:section.leadingAnchor],
        [titleLabel.trailingAnchor constraintEqualToAnchor:section.trailingAnchor],
        [container.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:6],
        [container.leadingAnchor constraintEqualToAnchor:section.leadingAnchor],
        [info.topAnchor constraintEqualToAnchor:container.bottomAnchor constant:4],
        [info.leadingAnchor constraintEqualToAnchor:section.leadingAnchor],
        [info.trailingAnchor constraintEqualToAnchor:section.trailingAnchor],
        [info.bottomAnchor constraintEqualToAnchor:section.bottomAnchor],
    ]];
    return section;
}

+ (UIView *)createInfoSectionWithTitle:(NSString *)title text:(NSString *)text {
    UIView *section = [[UIView alloc] init];
    section.translatesAutoresizingMaskIntoConstraints = false;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.translatesAutoresizingMaskIntoConstraints = false;

    UILabel *info = [[UILabel alloc] init];
    info.text = text;
    info.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    info.numberOfLines = 0;
    info.translatesAutoresizingMaskIntoConstraints = false;

    [section addSubview:titleLabel];
    [section addSubview:info];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:section.topAnchor],
        [titleLabel.leadingAnchor constraintEqualToAnchor:section.leadingAnchor],
        [titleLabel.trailingAnchor constraintEqualToAnchor:section.trailingAnchor],
        [info.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:6],
        [info.leadingAnchor constraintEqualToAnchor:section.leadingAnchor],
        [info.trailingAnchor constraintEqualToAnchor:section.trailingAnchor],
        [info.bottomAnchor constraintEqualToAnchor:section.bottomAnchor],
    ]];
    return section;
}

+ (void)setupStackWithSections:(NSArray<UIView *> *)sections inScrollView:(UIScrollView *)scrollView {
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:sections];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 32;
    stack.translatesAutoresizingMaskIntoConstraints = false;
    [scrollView addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:scrollView.topAnchor constant:16],
        [stack.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:scrollView.trailingAnchor constant:-16],
        [stack.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor constant:-16],
        [stack.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor constant:-32],
    ]];
}

@end
