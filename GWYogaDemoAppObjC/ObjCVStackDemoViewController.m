@import GWYogaKitObjCCore;
#import "ObjCVStackDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCVStackDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"YogaVStack / YogaHStack / YogaZStack for declarative stack layout";

    UIView *section = [ObjCYogaRenderer createInfoSectionWithTitle:@"Usage" text:@"// ObjC DSL: Use YGKLayoutView with flexDirection"];

    YGKLayoutView *demo = [ObjCYogaRenderer makeContainerWithWidth:200 height:160];
    demo.gwstyle.flexDirection = YGKFlexDirectionColumn;
    demo.gwstyle.rowGap = 8;
    demo.backgroundColor = [UIColor.systemGray6Color colorWithAlphaComponent:0.5];

    for (NSString *letter in @[@"A", @"B", @"C", @"D"]) {
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.3];
        v.gwstyle.width = 60; v.gwstyle.height = 24;
        v.layer.cornerRadius = 4;
        [demo addSubview:v];
    }

    UIView *demoSection = [ObjCYogaRenderer createDemoSectionWithTitle:@"VStack (spacing: 8)" container:demo];
    [ObjCYogaRenderer setupStackWithSections:@[section, demoSection] inScrollView:self.scrollView];
}

@end
