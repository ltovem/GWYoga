@import GWYogaKitObjCCore;
#import "ObjCYogaKitDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCYogaKitDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"YogaKit";

    NSMutableArray *s = [NSMutableArray array];

    // YogaProperties
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:80];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        c.yogaProperties.justifyContent = YGKJustifySpaceEvenly;
        c.yogaProperties.alignItems = YGKAlignCenter;
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:50 height:30 index:i]];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"YogaProperties" container:c]];
    }

    // YogaLayoutView auto layout
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:80];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        c.yogaProperties.justifyContent = YGKJustifySpaceBetween;
        c.yogaProperties.alignItems = YGKAlignCenter;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:70 height:40 index:i];
            [c addSubview:child];
        }
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"YogaLayoutView (Auto)" container:c]];
    }

    // Intrinsic content size
    {
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = @"Intrinsic Text";
        textLabel.yogaProperties.isIntrinsic = YES;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"Button" forState:UIControlStateNormal];
        button.yogaProperties.isIntrinsic = YES;

        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:50];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        c.yogaProperties.alignItems = YGKAlignCenter;
        [c addSubview:textLabel];
        [c addSubview:button];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Intrinsic 内容尺寸" container:c]];
    }

    // flex + gap + padding
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:130];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        c.yogaProperties.flexWrap = YGKWrapWrap;
        [c.yogaProperties setPadding:YGKEdgeAll value:8];
        [c.yogaProperties setGap:YGKGutterRow value:8];
        [c.yogaProperties setGap:YGKGutterColumn value:8];
        for (int i = 0; i < 6; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:80 height:40 index:i]];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flex + gap + padding" container:c]];
    }

    // Layout mode demo
    {
        YGKLayoutView *autoMode = [ObjCYogaRenderer makeContainerWithWidth:200 height:40];
        autoMode.yogaProperties.justifyContent = YGKJustifyCenter;
        autoMode.layoutMode = YGKLayoutModeAuto;
        [autoMode addSubview:[ObjCYogaRenderer coloredChildWithWidth:80 height:30 index:0]];

        YGKLayoutView *forcedMode = [ObjCYogaRenderer makeContainerWithWidth:200 height:40];
        forcedMode.yogaProperties.justifyContent = YGKJustifyCenter;
        forcedMode.layoutMode = YGKLayoutModeForced;
        [forcedMode addSubview:[ObjCYogaRenderer coloredChildWithWidth:80 height:30 index:1]];

        NSString *text = @"YGKLayoutMode: Auto — 仅 dirty 时重算\nYGKLayoutMode: Forced — 每次都重算\nYGKLayoutMode: Manual — 手动调用 performYogaLayout";
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"Layout Modes" text:text]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

@end
