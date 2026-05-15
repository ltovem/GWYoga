@import GWYogaKitDSLObjCCore;
#import "ObjCDSLDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCDSLDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DSL";

    NSMutableArray *s = [NSMutableArray array];

    // VStack
    {
        YGKVStack *stack = [[YGKVStack alloc] initWithSpacing:8 alignment:YGKAlignCenter];
        stack.translatesAutoresizingMaskIntoConstraints = false;
        [stack addSubview:[[YGKText alloc] initWithText:@"Item A"]];
        [stack addSubview:[[YGKText alloc] initWithText:@"Item B"]];
        [stack addSubview:[[YGKText alloc] initWithText:@"Item C"]];
        [stack performYogaLayout];

        UIView *border = [self borderedPreview:stack];
        [s addObject:[self sectionWithTitle:@"YGKVStack" preview:border]];
    }

    // HStack
    {
        YGKHStack *stack = [[YGKHStack alloc] initWithSpacing:12 alignment:YGKAlignCenter];
        [stack addSubview:[[YGKText alloc] initWithText:@"Left"]];
        [stack addSubview:[[YGKText alloc] initWithText:@"Center"]];
        [stack addSubview:[[YGKText alloc] initWithText:@"Right"]];
        [stack performYogaLayout];

        UIView *border = [self borderedPreview:stack];
        [s addObject:[self sectionWithTitle:@"YGKHStack" preview:border]];
    }

    // ZStack
    {
        YGKZStack *zstack = [[YGKZStack alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
        [zstack addChild:[[YGKText alloc] initWithText:@"Back"] alignment:YGKAlignCenter];
        [zstack addChild:[[YGKText alloc] initWithText:@"Front"] alignment:YGKAlignCenter];
        [zstack performYogaLayout];
        UIView *border = [self borderedPreview:zstack];
        [s addObject:[self sectionWithTitle:@"YGKZStack" preview:border]];
    }

    // Controls
    {
        NSString *text = @"YGKText — 文本控件\nYGKImage — 图片控件\nYGKButton — 按钮控件\nYGKSpacer — 弹性空白\nYGKDivider — 分割线";
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"DSL Controls" text:text]];
    }

    // Divider example
    {
        YGKHStack *h = [[YGKHStack alloc] initWithSpacing:8 alignment:YGKAlignCenter];
        [h addSubview:[[YGKText alloc] initWithText:@"Left"]];
        [h addSubview:[[YGKDivider alloc] initWithColor:UIColor.lightGrayColor thickness:1]];
        [h addSubview:[[YGKText alloc] initWithText:@"Right"]];
        h.yogaProperties.width = 200;
        [h performYogaLayout];

        UIView *border = [self borderedPreview:h];
        [s addObject:[self sectionWithTitle:@"YGKHStack + YGKDivider" preview:border]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

- (UIView *)borderedPreview:(UIView *)content {
    UIView *border = [[UIView alloc] init];
    border.translatesAutoresizingMaskIntoConstraints = false;
    border.layer.borderWidth = 1;
    border.layer.borderColor = UIColor.systemBlueColor.CGColor;
    border.layer.cornerRadius = 4;

    content.translatesAutoresizingMaskIntoConstraints = false;
    [border addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:border.topAnchor constant:4],
        [content.leadingAnchor constraintEqualToAnchor:border.leadingAnchor constant:4],
        [content.trailingAnchor constraintEqualToAnchor:border.trailingAnchor constant:-4],
        [content.bottomAnchor constraintEqualToAnchor:border.bottomAnchor constant:-4],
    ]];
    return border;
}

- (UIView *)sectionWithTitle:(NSString *)title preview:(UIView *)preview {
    UIView *section = [[UIView alloc] init];
    section.translatesAutoresizingMaskIntoConstraints = false;

    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:14];
    label.translatesAutoresizingMaskIntoConstraints = false;

    preview.translatesAutoresizingMaskIntoConstraints = false;

    [section addSubview:label];
    [section addSubview:preview];

    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:section.topAnchor],
        [label.leadingAnchor constraintEqualToAnchor:section.leadingAnchor],
        [preview.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:6],
        [preview.leadingAnchor constraintEqualToAnchor:section.leadingAnchor],
        [preview.bottomAnchor constraintEqualToAnchor:section.bottomAnchor],
    ]];
    return section;
}

@end
