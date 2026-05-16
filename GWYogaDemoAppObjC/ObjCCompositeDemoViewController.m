@import GWYogaKitObjCCore;
#import "ObjCCompositeDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCCompositeDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Complex Header+Grid+Footer layout";

    NSMutableArray *sections = [NSMutableArray array];

    // Header+Grid+Footer
    {
        YGKLayoutView *page = [ObjCYogaRenderer makeContainerWithWidth:375 height:450];
        page.gwstyle.flexDirection = YGKFlexDirectionColumn;
        [page.gwstyle setPadding:YGKEdgeAll value:12];

        YGKLayoutView *h = [ObjCYogaRenderer makeContainerWithWidth:0 height:44];
        h.gwstyle.flexDirection = YGKFlexDirectionRow;
        h.gwstyle.justifyContent = YGKJustifySpaceBetween;
        h.gwstyle.alignItems = YGKAlignCenter;
        [h addSubview:[ObjCYogaRenderer coloredChildWithWidth:60 height:32 index:0]];
        [h addSubview:[ObjCYogaRenderer coloredChildWithWidth:120 height:20 index:1]];
        [h addSubview:[ObjCYogaRenderer coloredChildWithWidth:32 height:32 index:2]];
        [page addSubview:h];

        YGKLayoutView *g = [ObjCYogaRenderer makeContainerWithWidth:0 height:0];
        g.gwstyle.flexDirection = YGKFlexDirectionRow;
        g.gwstyle.flexWrap = YGKWrapWrap;
        g.gwstyle.columnGap = 10;
        g.gwstyle.rowGap = 10;
        g.gwstyle.flexGrow = 1;
        for (int i = 0; i < 6; i++)
            [g addSubview:[ObjCYogaRenderer coloredChildWithWidth:165 height:80 index:i]];
        [page addSubview:g];

        YGKLayoutView *f = [ObjCYogaRenderer makeContainerWithWidth:0 height:44];
        f.gwstyle.flexDirection = YGKFlexDirectionRow;
        f.gwstyle.justifyContent = YGKJustifySpaceAround;
        for (int i = 0; i < 4; i++)
            [f addSubview:[ObjCYogaRenderer coloredChildWithWidth:36 height:36 index:i]];
        [page addSubview:f];

        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"Header+Grid+Footer" container:page]];
    }
    // Centered: justify+align center
    {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:150];
        c.gwstyle.justifyContent = YGKJustifyCenter;
        c.gwstyle.alignItems = YGKAlignCenter;
        UIView *box = [ObjCYogaRenderer coloredChildWithWidth:120 height:80 index:0];
        [c addSubview:box];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:@"居中: justify+align center" container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
