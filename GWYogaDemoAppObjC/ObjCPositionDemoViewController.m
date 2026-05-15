@import GWYogaKitObjCCore;
#import "ObjCPositionDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCPositionDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Position";

    NSMutableArray *s = [NSMutableArray array];

    // Relative offset
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:90];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:80 height:40 index:i];
            if (i == 1) {
                [child.yogaProperties setPosition:YGKEdgeTop value:15];
                [child.yogaProperties setPosition:YGKEdgeLeft value:10];
            }
            [c addSubview:child];
        }
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Relative: child2 offset" container:c]];
    }

    // Absolute
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:130];
        [c.yogaProperties setPadding:YGKEdgeAll value:10];
        [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:100 height:40 index:0]];

        UIView *abs = [ObjCYogaRenderer coloredChildWithWidth:80 height:60 index:1];
        abs.yogaProperties.positionType = YGKPositionTypeAbsolute;
        [abs.yogaProperties setPosition:YGKEdgeTop value:20];
        [abs.yogaProperties setPosition:YGKEdgeLeft value:200];
        [c addSubview:abs];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Absolute: top=20, left=200" container:c]];
    }

    // Absolute bottom
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:150];
        UIView *abs = [ObjCYogaRenderer coloredChildWithWidth:80 height:40 index:0];
        abs.yogaProperties.positionType = YGKPositionTypeAbsolute;
        [abs.yogaProperties setPosition:YGKEdgeBottom value:10];
        [abs.yogaProperties setPosition:YGKEdgeEnd value:10];
        [c addSubview:abs];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Absolute: bottom=10, end=10" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

@end
