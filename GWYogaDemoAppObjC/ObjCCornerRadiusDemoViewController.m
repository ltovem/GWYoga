@import GWYogaKitObjCCore;
#import "ObjCCornerRadiusDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCCornerRadiusDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"cornerRadius with 3 overloads";

    UIView *section = [ObjCYogaRenderer createInfoSectionWithTitle:@"Usage" text:@"view.layer.cornerRadius = 12; view.gwstyle.cornerRadius(12)"];

    YGKLayoutView *demo = [ObjCYogaRenderer makeContainerWithWidth:80 height:80];
    demo.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.3];
    demo.layer.cornerRadius = 16;
    demo.layer.masksToBounds = YES;
    UIView *demoSection = [ObjCYogaRenderer createDemoSectionWithTitle:@"cornerRadius: 16" container:demo];

    YGKLayoutView *demo2 = [ObjCYogaRenderer makeContainerWithWidth:80 height:80];
    demo2.backgroundColor = [[UIColor systemGreenColor] colorWithAlphaComponent:0.3];
    demo2.layer.cornerRadius = 20;
    demo2.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    demo2.layer.masksToBounds = YES;
    UIView *demoSection2 = [ObjCYogaRenderer createDemoSectionWithTitle:@"top corners only" container:demo2];

    [ObjCYogaRenderer setupStackWithSections:@[section, demoSection, demoSection2] inScrollView:self.scrollView];
}

@end
