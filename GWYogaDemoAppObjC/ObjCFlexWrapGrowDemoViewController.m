@import GWYogaKitObjCCore;
#import "ObjCFlexWrapGrowDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCFlexWrapGrowDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"flexWrap + flexGrow + flexShrink";

    NSMutableArray *sections = [NSMutableArray array];

    // .wrap
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:180 height:160];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        c.gwstyle.flexWrap = YGKWrapWrap;
        c.gwstyle.columnGap = 8;
        for (int i = 0; i < 6; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:80 height:50 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexWrap: .wrap" container:c]];
    }
    // flexGrow 1:2:1
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:50];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            float g = (i == 1) ? 2.0 : 1.0;
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:30 index:i];
            child.gwstyle.flexGrow = g;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexGrow: 1:2:1" container:c]];
    }
    // flexShrink
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:200 height:50];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            float s = (i == 1) ? 1.0 : 0.0;
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:120 height:30 index:i];
            child.gwstyle.flexShrink = s;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexShrink: child2=1" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
