@import GWYogaKitObjCCore;
#import "ObjCBorderDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCBorderDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"borderWidth + borderColor";

    UIView *section = [ObjCYogaRenderer createInfoSectionWithTitle:@"Usage" text:@"view.gwstyle.borderWidth(2); view.gwstyle.borderColor(UIColor.redColor)"];

    YGKLayoutView *demo = [ObjCYogaRenderer makeContainerWithWidth:120 height:80];
    demo.backgroundColor = [[UIColor systemYellowColor] colorWithAlphaComponent:0.3];
    demo.layer.borderWidth = 2;
    demo.layer.borderColor = UIColor.systemRedColor.CGColor;
    demo.layer.cornerRadius = 4;
    UIView *demoSection = [ObjCYogaRenderer createDemoSectionWithTitle:@"2px red border" container:demo];

    [ObjCYogaRenderer setupStackWithSections:@[section, demoSection] inScrollView:self.scrollView];
}

@end
