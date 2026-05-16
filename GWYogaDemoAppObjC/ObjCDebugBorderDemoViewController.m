@import GWYogaKitObjCCore;
#import "ObjCDebugBorderDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCDebugBorderDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"debugBorder(color:width:) visual debugging";

    UIView *section = [ObjCYogaRenderer createInfoSectionWithTitle:@"Usage" text:@"[view.gwstyle debugBorder]; [view.gwstyle debugBorderWithColor:UIColor.redColor width:2]"];

    YGKLayoutView *demo = [ObjCYogaRenderer makeContainerWithWidth:260 height:60];
    demo.backgroundColor = [UIColor.systemGray6Color colorWithAlphaComponent:0.5];

    UIView *c1 = [[UIView alloc] init];
    c1.backgroundColor = [[UIColor systemRedColor] colorWithAlphaComponent:0.3];
    c1.gwstyle.width = 60; c1.gwstyle.height = 40;
    c1.layer.borderWidth = 2; c1.layer.borderColor = UIColor.systemRedColor.CGColor;
    [demo addSubview:c1];

    UIView *c2 = [[UIView alloc] init];
    c2.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.3];
    c2.gwstyle.width = 60; c2.gwstyle.height = 40;
    c2.layer.borderWidth = 1; c2.layer.borderColor = UIColor.systemBlueColor.CGColor;
    [demo addSubview:c2];

    UIView *c3 = [[UIView alloc] init];
    c3.backgroundColor = [[UIColor systemGreenColor] colorWithAlphaComponent:0.3];
    c3.gwstyle.width = 60; c3.gwstyle.height = 40;
    c3.layer.borderWidth = 1; c3.layer.borderColor = UIColor.systemGreenColor.CGColor;
    [demo addSubview:c3];

    UIView *demoSection = [ObjCYogaRenderer createDemoSectionWithTitle:@"debug borders on children" container:demo];
    [ObjCYogaRenderer setupStackWithSections:@[section, demoSection] inScrollView:self.scrollView];
}

@end
