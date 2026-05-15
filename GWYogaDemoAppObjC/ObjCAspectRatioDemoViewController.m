@import GWYogaKitObjCCore;
#import "ObjCAspectRatioDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCAspectRatioDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Aspect";

    NSMutableArray *s = [NSMutableArray array];

    // aspectRatio=2, height=80
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:250 height:150];
        UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:80 index:0];
        child.yogaProperties.aspectRatio = 2;
        [c addSubview:child];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"aspectRatio=2, height=80" container:c]];
    }

    // aspectRatio=1.5, width=120
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:250 height:150];
        UIView *child = [ObjCYogaRenderer coloredChildWithWidth:120 height:0 index:0];
        child.yogaProperties.aspectRatio = 1.5;
        [c addSubview:child];
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"aspectRatio=1.5, width=120" container:c]];
    }

    // aspectRatio=1 (正方形)
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:80];
        c.yogaProperties.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 4; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:60 index:i];
            child.yogaProperties.aspectRatio = 1;
            [c addSubview:child];
        }
        [s addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"aspectRatio=1 (正方形)" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

@end
