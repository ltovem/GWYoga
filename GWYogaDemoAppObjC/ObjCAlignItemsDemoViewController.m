@import GWYogaKitObjCCore;
#import "ObjCAlignItemsDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCAlignItemsDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"alignItems: .flexStart, .center, .flexEnd, .stretch, .baseline";

    NSMutableArray *sections = [NSMutableArray array];

    NSArray *avNames = @[@"flexStart", @"center", @"flexEnd", @"stretch", @"baseline"];
    NSArray *avVals = @[@(YGKAlignFlexStart), @(YGKAlignCenter), @(YGKAlignFlexEnd),
                        @(YGKAlignStretch), @(YGKAlignBaseline)];
    for (NSUInteger i = 0; i < avNames.count; i++) {
        YGKLayoutView *c = [ObjCYogaRenderer makeContainerWithWidth:280 height:70];
        c.gwstyle.flexDirection = YGKFlexDirectionRow;
        c.gwstyle.alignItems = [avVals[i] integerValue];
        for (int j = 0; j < 3; j++) {
            UIView *child = [ObjCYogaRenderer coloredChildWithWidth:60 height:([avVals[i] integerValue] == YGKAlignStretch ? 0 : 25) index:j];
            [c addSubview:child];
        }
        [sections addObject:[ObjCYogaRenderer createDemoSectionWithTitle:[NSString stringWithFormat:@"· %@", avNames[i]] container:c]];
    }

    [ObjCYogaRenderer setupStackWithSections:sections inScrollView:self.scrollView];
}

@end
