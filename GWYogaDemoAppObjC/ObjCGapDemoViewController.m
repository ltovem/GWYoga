@import GWYogaKitObjCCore;
#import "ObjCGapDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCGapDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"rowGap + columnGap";

    NSMutableArray *sections = [NSMutableArray array];

    // columnGap=20
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:60];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        c.gwstyle.columnGap = 20;
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:30 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"columnGap=20" container:c]];
    }
    // column=10, row=15 + wrap
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:140 height:200];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        c.gwstyle.flexWrap = YGKWrapWrap;
        c.gwstyle.columnGap = 10;
        c.gwstyle.rowGap = 15;
        for (int i = 0; i < 6; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:40 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"column=10, row=15 + wrap" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
