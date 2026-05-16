@import GWYogaKitObjCCore;
#import "ObjCBaseDemoViewController.h"

@implementation ObjCBaseDemoViewController

- (void)loadView {
    self.rootView = [[YGKLayoutView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.rootView.gwstyle.flexDirection = YGKFlexDirectionColumn;
    [self.rootView.gwstyle setPadding:YGKEdgeLeft value:16];
    [self.rootView.gwstyle setPadding:YGKEdgeRight value:16];
    self.view = self.rootView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.gwstyle.flexGrow = 1;
    [self.view addSubview:self.scrollView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.rootView performYogaLayout];
}

@end
