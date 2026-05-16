@import GWYogaKitObjCCore;
#import "ObjCPaddingDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCPaddingDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"padding for all edges";

    NSMutableArray *sections = [NSMutableArray array];

    // padding all=20
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:120];
        [c.gwstyle setPadding:YGKEdgeAll value:20];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 2; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:80 height:40 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"padding: all=20" container:c]];
    }
    // padding horizontal=16
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:80];
        [c.gwstyle setPadding:YGKEdgeLeft value:16];
        [c.gwstyle setPadding:YGKEdgeRight value:16];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:30 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"padding: horizontal=16" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
