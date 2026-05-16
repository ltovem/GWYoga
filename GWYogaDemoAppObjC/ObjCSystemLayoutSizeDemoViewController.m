@import GWYogaKitObjCCore;
#import "ObjCSystemLayoutSizeDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCSystemLayoutSizeDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"systemLayoutSize() Yoga-calculated size";

    NSMutableArray *sections = [NSMutableArray array];

    // Info section
    [sections addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"Usage" text:@"CGSize size = [view.gwstyle systemLayoutSizeWithWidth:200 height:300]"]];

    // Demo layout with dimensions
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:200 height:60];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        c.gwstyle.justifyContent = YGKJustifySpaceEvenly;
        c.gwstyle.alignItems = YGKAlignCenter;
        for (int i = 0; i < 4; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:30 height:40 index:i];
            [c addSubview:child];
        }
        [c performYogaLayout];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"4 children 30×40 in 200pt row" container:c]];
    }

    // Taller container with calculated height
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:150 height:150];
        c.gwstyle.flexDirection = YGKFlexDirectionColumn;
        c.gwstyle.justifyContent = YGKJustifySpaceAround;
        c.gwstyle.alignItems = YGKAlignCenter;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:100 height:30 index:i];
            [c addSubview:child];
        }
        [c performYogaLayout];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"3 children stacked (150pt wide)" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
