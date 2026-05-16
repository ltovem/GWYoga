@import GWYogaKitObjCCore;
#import "ObjCShadowDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCShadowDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"shadow(color:opacity:radius:offset:)";

    UIView *section = [ObjCYogaRenderer createInfoSectionWithTitle:@"Usage" text:@"view.layer.shadowColor = UIColor.blackColor.CGColor; view.layer.shadowOpacity = 0.3"];

    YGKLayoutView *demo = [ObjCYogaRenderer makeContainerWithWidth:120 height:80];
    demo.backgroundColor = UIColor.whiteColor;
    demo.layer.shadowColor = UIColor.blackColor.CGColor;
    demo.layer.shadowOpacity = 0.3;
    demo.layer.shadowRadius = 8;
    demo.layer.shadowOffset = CGSizeMake(2, 4);
    demo.layer.cornerRadius = 8;
    UIView *demoSection = [ObjCYogaRenderer createDemoSectionWithTitle:@"shadow" container:demo];

    [ObjCYogaRenderer setupStackWithSections:@[section, demoSection] inScrollView:self.scrollView];
}

@end
