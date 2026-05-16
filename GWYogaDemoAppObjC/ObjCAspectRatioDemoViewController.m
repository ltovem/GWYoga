@import GWYogaKitObjCCore;
#import "ObjCAspectRatioDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCAspectRatioDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"aspectRatio sizes one dimension from the other";

    NSMutableArray *sections = [NSMutableArray array];

    // aspectRatio=2, h=80 -> w=160
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:250 height:150];
        UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:0];
        child.gwstyle.height = 80;
        child.gwstyle.aspectRatio = 2;
        [c addSubview:child];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"aspectRatio=2, h=80 -> w=160" container:c]];
    }
    // aspectRatio=1.5, w=120 -> h=80
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:250 height:150];
        UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:1];
        child.gwstyle.width = 120;
        child.gwstyle.aspectRatio = 1.5;
        [c addSubview:child];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"aspectRatio=1.5, w=120 -> h=80" container:c]];
    }
    // aspectRatio=1 (square)
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:80];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 4; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:0 index:i];
            child.gwstyle.height = 60;
            child.gwstyle.aspectRatio = 1;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"aspectRatio=1 (square)" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
