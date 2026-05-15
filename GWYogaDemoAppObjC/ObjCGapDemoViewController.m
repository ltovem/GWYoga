@import GWYogaKitObjCCore;
#import "ObjCGapDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCGapDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Gap";

    NSMutableArray *s = [NSMutableArray array];

    // columnGap=20 (Flexbox)
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:60];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        [c.yogaProperties setGap:YGKGutterColumn value:20];
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:30 index:i]];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"columnGap=20 (Flexbox)" container:c]];
    }

    // column=10, row=15 + flexWrap
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:140 height:200];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        c.yogaProperties.flexWrap = YGKWrapWrap;
        [c.yogaProperties setGap:YGKGutterColumn value:10];
        [c.yogaProperties setGap:YGKGutterRow value:15];
        for (int i = 0; i < 6; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:40 index:i]];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"column=10, row=15 + wrap" container:c]];
    }

    // Grid: columnGap=10, rowGap=20
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:170 height:110];
        c.yogaProperties.display = YGKDisplayGrid;
        [c.yogaProperties setGridTemplateColumns:@[[YGKGridTrackSize points:80], [YGKGridTrackSize points:80]]];
        [c.yogaProperties setGridTemplateRows:@[[YGKGridTrackSize points:40], [YGKGridTrackSize points:40]]];
        [c.yogaProperties setGap:YGKGutterColumn value:10];
        [c.yogaProperties setGap:YGKGutterRow value:20];
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Grid: columnGap=10, rowGap=20" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

@end
