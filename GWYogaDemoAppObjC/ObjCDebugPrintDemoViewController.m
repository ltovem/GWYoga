@import GWYogaKitObjCCore;
#import "ObjCDebugPrintDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCDebugPrintDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"debugPrint() tree-formatted layout output";

    UIView *section = [ObjCYogaRenderer createInfoSectionWithTitle:@"Usage" text:@"[view.gwstyle debugPrint]"];
    [ObjCYogaRenderer setupStackWithSections:@[section] inScrollView:self.scrollView];
}

@end
