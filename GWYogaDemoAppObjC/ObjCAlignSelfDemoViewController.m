@import GWYogaKitObjCCore;
#import "ObjCAlignSelfDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCAlignSelfDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"alignSelf overrides alignItems on individual items";

    NSMutableArray *sections = [NSMutableArray array];

    // flexEnd on child 2
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:70];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        c.gwstyle.alignItems = YGKAlignFlexStart;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:60 height:35 index:i];
            if (i == 1) child.gwstyle.alignSelf = YGKAlignFlexEnd;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"alignSelf: .flexEnd on child 2" container:c]];
    }
    // center on child 1
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:70];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        c.gwstyle.alignItems = YGKAlignFlexStart;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:60 height:35 index:i];
            if (i == 0) child.gwstyle.alignSelf = YGKAlignCenter;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"alignSelf: .center on child 1" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
