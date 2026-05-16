@import GWYogaKitObjCCore;
#import "ObjCFlexboxDirectionDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCFlexboxDirectionDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"flexDirection: .row / .column / .rowReverse / .columnReverse";

    NSMutableArray *sections = [NSMutableArray array];

    // .row
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:60];
        c.backgroundColor = UIColor.redColor;
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:30 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexDirection: .row" container:c]];
    }
    // .column
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:120 height:250];
        c.gwstyle.flexDirection = YGKFlexDirectionColumn;
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:80 height:40 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexDirection: .column" container:c]];
    }
    // .rowReverse
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:60];
        c.gwstyle.flexDirection = YGKFlexDirectionRowReverse;
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:30 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexDirection: .rowReverse" container:c]];
    }
    // .columnReverse
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:120 height:250];
        c.gwstyle.flexDirection = YGKFlexDirectionColumnReverse;
        for (int i = 0; i < 4; i++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:80 height:40 index:i]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"flexDirection: .columnReverse" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
