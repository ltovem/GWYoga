@import GWYogaKitObjCCore;
#import "ObjCCompositeDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCCompositeDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"综合";

    NSMutableArray *s = [NSMutableArray array];

    // Header + Grid + Footer
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:375 height:450];
        c.yogaProperties.flexDirection = YGKFlexDirectionColumn;
        [c.yogaProperties setPadding:YGKEdgeAll value:12];

        // Header row
        YGKLayoutView *header = [ObjCYogaRenderer makeContainerWithWidth:0 height:44];
        header.yogaProperties.flexDirection = YGKFlexDirectionRow;
        header.yogaProperties.justifyContent = YGKJustifySpaceBetween;
        header.yogaProperties.alignItems = YGKAlignCenter;
        [header.yogaProperties setMargin:YGKEdgeBottom value:12];
        [header addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:32 index:0]];
        [header addSubview:[ObjCYogaRenderer coloredChildWithWidth:120 height:20 index:1]];
        [header addSubview:[ObjCYogaRenderer coloredChildWithWidth:32 height:32 index:2]];
        [c addSubview:header];

        // Grid area
        YGKLayoutView *grid = [ObjCYogaRenderer makeContainerWithWidth:0 height:0];
        grid.yogaProperties.flexDirection = YGKFlexDirectionRow;
        grid.yogaProperties.flexWrap = YGKWrapWrap;
        [grid.yogaProperties setGap:YGKGutterColumn value:10];
        [grid.yogaProperties setGap:YGKGutterRow value:10];
        grid.yogaProperties.flexGrow = 1;
        for (int i = 0; i < 6; i++) {
            YGKLayoutView *card = [ObjCYogaRenderer makeContainerWithWidth:(375-24-10)/2 height:80];
            [card.yogaProperties setPadding:YGKEdgeAll value:8];
            [card.yogaProperties setBorder:YGKEdgeAll width:1];
            [card addSubview:[ObjCYogaRenderer coloredChildWithWidth:0 height:20 index:i]];
            // Make card width relative to parent
            card.yogaProperties.width = (375-24-10)/2;
            [grid addSubview:card];
        }
        [c addSubview:grid];

        // Footer
        YGKLayoutView *footer = [ObjCYogaRenderer makeContainerWithWidth:0 height:44];
        footer.yogaProperties.flexDirection = YGKFlexDirectionRow;
        footer.yogaProperties.justifyContent = YGKJustifySpaceAround;
        footer.yogaProperties.alignItems = YGKAlignCenter;
        [footer.yogaProperties setMargin:YGKEdgeTop value:12];
        for (int i = 0; i < 4; i++)
            [footer addSubview:[ObjCYogaRenderer coloredChildWithWidth:36 height:36 index:i]];
        [c addSubview:footer];

        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Header + Grid(卡片6) + Footer" container:c]];
    }

    // 居中布局
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:150];
        c.yogaProperties.justifyContent = YGKJustifyCenter;
        c.yogaProperties.alignItems = YGKAlignCenter;

        YGKLayoutView *box = [ObjCYogaRenderer makeContainerWithWidth:120 height:80];
        [box.yogaProperties setPadding:YGKEdgeAll value:8];
        [box addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:30 index:0]];
        [c addSubview:box];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"居中: center + center" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

@end
