@import GWYogaKitObjCCore;
#import "ObjCGridDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCGridDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"display: .grid, gridTemplateColumns, fr, minmax";

    NSMutableArray *sections = [NSMutableArray array];

    // Fixed 2x2
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:200];
        c.gwstyle.display = YGKDisplayGrid;
        [c.gwstyle setGridTemplateColumns:@[[YGKGridTrackSize points:100], [YGKGridTrackSize points:200]]];
        [c.gwstyle setGridTemplateRows:@[[YGKGridTrackSize points:50], [YGKGridTrackSize points:150]]];
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Fixed 2x2" container:c]];
    }
    // 1fr 2fr 1fr
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:100];
        c.gwstyle.display = YGKDisplayGrid;
        [c.gwstyle setGridTemplateColumns:@[[YGKGridTrackSize fr:1], [YGKGridTrackSize fr:2], [YGKGridTrackSize fr:1]]];
        for (int i = 0; i < 3; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"1fr 2fr 1fr" container:c]];
    }
    // gap
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:200 height:100];
        c.gwstyle.display = YGKDisplayGrid;
        [c.gwstyle setGridTemplateColumns:@[[YGKGridTrackSize points:80], [YGKGridTrackSize points:80]]];
        [c.gwstyle setGridTemplateRows:@[[YGKGridTrackSize points:40], [YGKGridTrackSize points:40]]];
        c.gwstyle.columnGap = 10;
        c.gwstyle.rowGap = 20;
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"gap 10/20" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
