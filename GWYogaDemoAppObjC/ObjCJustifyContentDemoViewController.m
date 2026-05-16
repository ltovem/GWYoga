@import GWYogaKitObjCCore;
#import "ObjCJustifyContentDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCJustifyContentDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"justifyContent: .flexStart, .center, .spaceBetween, etc.";

    NSMutableArray *sections = [NSMutableArray array];

    NSArray *jvNames = @[@"flexStart", @"center", @"flexEnd", @"spaceBetween", @"spaceAround", @"spaceEvenly"];
    NSArray *jvVals = @[@(YGKJustifyFlexStart), @(YGKJustifyCenter), @(YGKJustifyFlexEnd),
                        @(YGKJustifySpaceBetween), @(YGKJustifySpaceAround), @(YGKJustifySpaceEvenly)];
    for (NSUInteger i = 0; i < jvNames.count; i++) {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:280 height:50];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        c.gwstyle.justifyContent = [jvVals[i] integerValue];
        for (int j = 0; j < 3; j++)
            [c addSubview:[ObjCYogaRenderer coloredChildWithWidth:55 height:25 index:j]];
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:[NSString stringWithFormat:@"· %@", jvNames[i]] container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
