@import GWYogaKitObjCCore;
#import "ObjCDisplayDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCDisplayDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"display: .flex / .grid / .none, overflow, boxSizing";

    NSMutableArray *sections = [NSMutableArray array];

    // .flex
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:200 height:80];
        c.gwstyle.display = YGKDisplayFlex;
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:50 height:30 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"display: .flex" container:c]];
    }
    // .grid 2x2
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:200 height:100];
        c.gwstyle.display = YGKDisplayGrid;
        [c.gwstyle setGridTemplateColumns:@[[YGKGridTrackSize points:80], [YGKGridTrackSize points:80]]];
        [c.gwstyle setGridTemplateRows:@[[YGKGridTrackSize points:40], [YGKGridTrackSize points:40]]];
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"display: .grid 2x2" container:c]];
    }
    // .none (hidden child)
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:200 height:80];
        c.gwstyle.display = YGKDisplayFlex;
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:50 height:30 index:i];
            if (i == 1) child.gwstyle.display = YGKDisplayNone;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"display: .none (child 2 hidden)" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
