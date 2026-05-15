@import GWYogaKitHTMLObjCCore;
@import GWYogaKitDSLObjCCore;
#import "ObjCHTMLDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCHTMLDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HTML";

    NSMutableArray *s = [NSMutableArray array];

    // div { h1, p }
    {
        YGKLayoutView *div = [YGKHTMLFactory makeDiv];
        div.yogaProperties.width = 300;
        [div addSubview:[YGKHTMLFactory makeHeading:@"Page Title" level:1]];
        [div addSubview:[YGKHTMLFactory makeParagraph:@"This is a paragraph of text."]];
        [div performYogaLayout];

        [s addObject:[self sectionWithTitle:@"div { h1, p }" preview:[self styleContainer:div]]];
    }

    // section { row }
    {
        YGKLayoutView *section = [YGKHTMLFactory makeSection];
        section.yogaProperties.width = 300;
        [section addSubview:[YGKHTMLFactory makeHeading:@"Section Title" level:2]];
        YGKLayoutView *row = [YGKHTMLFactory makeRow];
        [row addSubview:[[YGKText alloc] initWithText:@"Col 1"]];
        [row addSubview:[[YGKText alloc] initWithText:@"Col 2"]];
        [row addSubview:[[YGKText alloc] initWithText:@"Col 3"]];
        [section addSubview:row];
        [section performYogaLayout];

        [s addObject:[self sectionWithTitle:@"section { row { ... } }" preview:[self styleContainer:section]]];
    }

    // header + footer
    {
        YGKLayoutView *div = [YGKHTMLFactory makeDiv];
        div.yogaProperties.width = 300;

        YGKLayoutView *header = [YGKHTMLFactory makeHeader];
        [header addSubview:[YGKHTMLFactory makeHeading:@"Header Logo" level:3]];
        [div addSubview:header];

        [div addSubview:[YGKHTMLFactory makeParagraph:@"Main content area"]];

        YGKLayoutView *footer = [YGKHTMLFactory makeHeader];
        [footer addSubview:[YGKHTMLFactory makeParagraph:@"Copyright 2026"]];
        [div addSubview:footer];

        [div performYogaLayout];
        [s addObject:[self sectionWithTitle:@"header + footer" preview:[self styleContainer:div]]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

- (UIView *)styleContainer:(YGKLayoutView *)view {
    view.backgroundColor = UIColor.systemGray6Color;
    view.layer.borderWidth = 1;
    view.layer.borderColor = UIColor.systemBlueColor.CGColor;
    view.layer.cornerRadius = 4;
    view.translatesAutoresizingMaskIntoConstraints = false;
    return view;
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
