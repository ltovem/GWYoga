@import GWYogaKitObjCCore;
#import "ObjCOpacityClipsDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCOpacityClipsDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"opacity + clipsToBounds + isHidden";

    UIView *section = [ObjCYogaRenderer createInfoSectionWithTitle:@"Usage" text:@"view.gwstyle.opacity(0.5); view.clipsToBounds = YES; view.gwstyle.hidden(NO)"];

    YGKLayoutView *demo = [ObjCYogaRenderer makeContainerWithWidth:80 height:80];
    demo.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.3];
    UIView *demoSection = [ObjCYogaRenderer createDemoSectionWithTitle:@"opacity: 1.0" container:demo];

    YGKLayoutView *demo2 = [ObjCYogaRenderer makeContainerWithWidth:80 height:80];
    demo2.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.3];
    demo2.alpha = 0.5;
    UIView *demoSection2 = [ObjCYogaRenderer createDemoSectionWithTitle:@"opacity: 0.5" container:demo2];

    [ObjCYogaRenderer setupStackWithSections:@[section, demoSection, demoSection2] inScrollView:self.scrollView];
}

@end
