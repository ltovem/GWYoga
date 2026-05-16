@import GWYogaKitObjCCore;
#import "ObjCPositionDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCPositionDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"positionType: .relative / .absolute";

    NSMutableArray *sections = [NSMutableArray array];

    // Relative: child2 offset top=15
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:70];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:80 height:40 index:i];
            if (i == 1) { [child.gwstyle setPosition:YGKEdgeTop value:15]; [child.gwstyle setPosition:YGKEdgeLeft value:10]; }
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Relative: child2 offset top=15" container:c]];
    }
    // Absolute: top=20, left=200
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:120];
        [c.gwstyle setPadding:YGKEdgeAll value:10];
        [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:100 height:40 index:0]];
        UIView *ab = [ObjCYogaRenderer coloredChildWithWidth:80 height:60 index:1];
        ab.gwstyle.positionType = YGKPositionTypeAbsolute;
        [ab.gwstyle setPosition:YGKEdgeTop value:20];
        [ab.gwstyle setPosition:YGKEdgeLeft value:200];
        [c addSubview:ab];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Absolute: top=20, left=200" container:c]];
    }
    // Absolute: bottom=10
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:150];
        UIView *ab = [ObjCYogaRenderer coloredChildWithWidth:80 height:40 index:0];
        ab.gwstyle.positionType = YGKPositionTypeAbsolute;
        [ab.gwstyle setPosition:YGKEdgeBottom value:10];
        [ab.gwstyle setPosition:YGKEdgeRight value:10];
        [c addSubview:ab];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Absolute: bottom=10, right=10" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
