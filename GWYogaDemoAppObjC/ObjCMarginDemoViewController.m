@import GWYogaKitObjCCore;
#import "ObjCMarginDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCMarginDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"margin for all edges";

    NSMutableArray *sections = [NSMutableArray array];

    // margin all=10
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:80];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:60 height:30 index:i];
            [child.gwstyle setMargin:YGKEdgeAll value:10];
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"margin: all=10" container:c]];
    }
    // marginLeft=20
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:60];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:70 height:25 index:i];
            if (i == 1) [child.gwstyle setMargin:YGKEdgeLeft value:20];
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"marginLeft=20 (child 2)" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
