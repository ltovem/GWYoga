@import GWYogaKitObjCCore;
#import "ObjCFlexboxDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCFlexboxDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Flexbox";

    NSMutableArray *sections = [NSMutableArray array];

    // 1. flexDirection: row
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:70];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:70 height:40 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexDirection: .row" container:c]];
    }

    // 2. justifyContent: spaceBetween
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:60];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        c.yogaProperties.justifyContent = YGKJustifySpaceBetween;
        for (int i = 0; i < 3; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:70 height:30 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"justifyContent: .spaceBetween" container:c]];
    }

    // 3. alignItems: center
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:80];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        c.yogaProperties.alignItems = YGKAlignCenter;
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:25 + i * 12 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"alignItems: .center" container:c]];
    }

    // 4. flexGrow: 1:2:1
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:50];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        NSArray *grows = @[@1, @2, @1];
        for (int i = 0; i < grows.count; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:30 index:i];
            child.yogaProperties.flexGrow = [grows[i] floatValue];
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexGrow: 1:2:1" container:c]];
    }

    // 5. flexWrap: .wrap
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:180 height:160];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        c.yogaProperties.flexWrap = YGKWrapWrap;
        [c.yogaProperties setGap:YGKGutterColumn value:8];
        for (int i = 0; i < 6; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:80 height:50 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexWrap: .wrap" container:c]];
    }

    // 6. alignSelf
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:70];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        c.yogaProperties.alignItems = YGKAlignFlexStart;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:60 height:35 index:i];
            if (i == 1) child.yogaProperties.alignSelf = YGKAlignFlexEnd;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"alignSelf: child2 = .flexEnd" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
