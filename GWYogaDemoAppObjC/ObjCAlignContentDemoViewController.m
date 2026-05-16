@import GWYogaKitObjCCore;
#import "ObjCAlignContentDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCAlignContentDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"alignContent controls multi-line cross-axis alignment";

    NSMutableArray *sections = [NSMutableArray array];

    NSArray *acNames = @[@"flexStart", @"center", @"spaceBetween", @"spaceAround", @"stretch"];
    NSArray *acVals = @[@(YGKAlignFlexStart), @(YGKAlignCenter), @(YGKAlignSpaceBetween),
                        @(YGKAlignSpaceAround), @(YGKAlignStretch)];
    for (NSUInteger i = 0; i < acNames.count; i++) {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:300 height:160];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        c.gwstyle.flexWrap = YGKWrapWrap;
        c.gwstyle.alignContent = [acVals[i] integerValue];
        c.gwstyle.rowGap = 6;
        c.gwstyle.columnGap = 6;
        for (int j = 0; j < 6; j++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:120 height:40 index:j]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:[NSString stringWithFormat:@"· %@", acNames[i]] container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
