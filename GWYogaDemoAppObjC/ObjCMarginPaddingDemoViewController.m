@import GWYogaKitObjCCore;
#import "ObjCMarginPaddingDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCMarginPaddingDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Margin";

    NSMutableArray *s = [NSMutableArray array];

    // margin=10
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:100];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:60 height:30 index:i];
            [child.yogaProperties setMargin:YGKEdgeAll value:10];
            [c addSubview:child];
        }
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"margin=10 (全部)" container:c]];
    }

    // marginLeft=20 (child2)
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:70];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:70 height:25 index:i];
            if (i == 1) [child.yogaProperties setMargin:YGKEdgeLeft value:20];
            [c addSubview:child];
        }
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"marginLeft=20 (child2)" container:c]];
    }

    // padding=20
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:130];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        [c.yogaProperties setPadding:YGKEdgeAll value:20];
        for (int i = 0; i < 2; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:80 height:40 index:i]];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"padding=20 (容器)" container:c]];
    }

    // border=4
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:200 height:50];
        [c.yogaProperties setBorder:YGKEdgeAll width:4];
        [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:100 height:25 index:0]];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"border=4" container:c]];
    }

    // margin8+padding12+border2
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:350 height:120];
        [c.yogaProperties setPadding:YGKEdgeAll value:12];
        [c.yogaProperties setBorder:YGKEdgeAll width:2];

        UIView *inner = [ObjCYogaRenderer coloredChildWithWidth:100 height:50 index:0];
        [inner.yogaProperties setMargin:YGKEdgeAll value:8];
        [inner.yogaProperties setPadding:YGKEdgeAll value:6];
        [inner.yogaProperties setBorder:YGKEdgeAll width:1];
        [inner addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:20 index:1]];
        [c addSubview:inner];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"margin8+padding12+border2" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

@end
