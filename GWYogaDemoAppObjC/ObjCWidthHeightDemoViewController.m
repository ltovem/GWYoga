@import GWYogaKitObjCCore;
#import "ObjCWidthHeightDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCWidthHeightDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"width/height, min/max, percentages";

    NSMutableArray *sections = [NSMutableArray array];

    // Fixed 100x50
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:100 height:50];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Fixed 100x50" container:c]];
    }
    // Min/Max
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:60];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:30 index:i];
            child.gwstyle.minWidth = 60;
            child.gwstyle.maxWidth = 120;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Min/Max: [60, 120]" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
