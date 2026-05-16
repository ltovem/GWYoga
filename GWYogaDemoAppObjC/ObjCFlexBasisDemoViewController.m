@import GWYogaKitObjCCore;
#import "ObjCFlexBasisDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCFlexBasisDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"flexBasis sets initial main-axis size";

    NSMutableArray *sections = [NSMutableArray array];

    // flexBasis 100 on child 2
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:60];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:30 index:i];
            if (i == 1) child.gwstyle.flexBasis = 100;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexBasis: 100 on child 2" container:c]];
    }
    // flex: 1 on all
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:50];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 3; i++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:0 height:30 index:i];
            child.gwstyle.flexGrow = 1;
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flex: 1 on all" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
