@import GWYogaKitObjCCore;
#import "ObjCScrollDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCScrollDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"YogaScrollView for scrollable content";

    UIView *section = [ObjCYogaRenderer createInfoSectionWithTitle:@"Usage" text:@"// YGKScrollView not available in ObjC, use YGKLayoutView + UIScrollView"];
    [ObjCYogaRenderer setupStackWithSections:@[section] inScrollView:self.scrollView];
}

@end
