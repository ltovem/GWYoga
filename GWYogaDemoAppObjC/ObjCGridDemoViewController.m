@import GWYogaKitObjCCore;
#import "ObjCGridDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCGridDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Grid";

    NSMutableArray *sections = [NSMutableArray array];

    // 1. 固定 2×2
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:200];
        c.yogaProperties.display = YGKDisplayGrid;
        [c.yogaProperties setGridTemplateColumns:@[[YGKGridTrackSize points:100], [YGKGridTrackSize points:200]]];
        [c.yogaProperties setGridTemplateRows:@[[YGKGridTrackSize points:50], [YGKGridTrackSize points:150]]];
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"固定 2×2: [100,200]×[50,150]" container:c]];
    }

    // 2. 1fr 2fr 1fr
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:100];
        c.yogaProperties.display = YGKDisplayGrid;
        [c.yogaProperties setGridTemplateColumns:@[[YGKGridTrackSize fr:1], [YGKGridTrackSize fr:2], [YGKGridTrackSize fr:1]]];
        for (int i = 0; i < 3; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"1fr 2fr 1fr" container:c]];
    }

    // 3. 200pt + 1fr
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:400 height:100];
        c.yogaProperties.display = YGKDisplayGrid;
        [c.yogaProperties setGridTemplateColumns:@[[YGKGridTrackSize points:200], [YGKGridTrackSize fr:1]]];
        for (int i = 0; i < 2; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"200pt + 1fr" container:c]];
    }

    // 4. grid-column: 2/4
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:240 height:100];
        c.yogaProperties.display = YGKDisplayGrid;
        [c.yogaProperties setGridTemplateColumns:@[[YGKGridTrackSize points:80], [YGKGridTrackSize points:80], [YGKGridTrackSize points:80]]];
        [c.yogaProperties setGridTemplateRows:@[[YGKGridTrackSize points:50], [YGKGridTrackSize points:50]]];
        UIView *item = [ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:0];
        item.yogaProperties.gridColumnStart = [YGKGridLine line:2];
        item.yogaProperties.gridColumnEnd = [YGKGridLine line:4];
        [c addSubview:item];
        [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:1]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"grid-column: 2/4" container:c]];
    }

    // 5. columnGap=10, rowGap=20
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:170 height:110];
        c.yogaProperties.display = YGKDisplayGrid;
        [c.yogaProperties setGridTemplateColumns:@[[YGKGridTrackSize points:80], [YGKGridTrackSize points:80]]];
        [c.yogaProperties setGridTemplateRows:@[[YGKGridTrackSize points:40], [YGKGridTrackSize points:40]]];
        [c.yogaProperties setGap:YGKGutterColumn value:10];
        [c.yogaProperties setGap:YGKGutterRow value:20];
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"columnGap=10, rowGap=20" container:c]];
    }

    // 6. grid-row: 1/3
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:100 height:120];
        c.yogaProperties.display = YGKDisplayGrid;
        [c.yogaProperties setGridTemplateColumns:@[[YGKGridTrackSize points:100]]];
        [c.yogaProperties setGridTemplateRows:@[[YGKGridTrackSize points:40], [YGKGridTrackSize points:40], [YGKGridTrackSize points:40]]];
        UIView *item = [ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:0];
        item.yogaProperties.gridRowStart = [YGKGridLine line:1];
        item.yogaProperties.gridRowEnd = [YGKGridLine line:3];
        [c addSubview:item];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"grid-row: 1/3" container:c]];
    }

    // 7. Grid + padding
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:220 height:70];
        c.yogaProperties.display = YGKDisplayGrid;
        [c.yogaProperties setGridTemplateColumns:@[[YGKGridTrackSize points:100], [YGKGridTrackSize points:100]]];
        [c.yogaProperties setGridTemplateRows:@[[YGKGridTrackSize points:50]]];
        [c.yogaProperties setPadding:YGKEdgeAll value:10];
        for (int i = 0; i < 2; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Grid + padding:10" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
