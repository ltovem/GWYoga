#import "ObjCDemoTabBarController.h"
#import "ObjCFlexboxDemoViewController.h"
#import "ObjCGridDemoViewController.h"
#import "ObjCMarginPaddingDemoViewController.h"
#import "ObjCPositionDemoViewController.h"
#import "ObjCGapDemoViewController.h"
#import "ObjCAspectRatioDemoViewController.h"
#import "ObjCCompositeDemoViewController.h"
#import "ObjCYogaKitDemoViewController.h"
#import "ObjCDSLDemoViewController.h"
#import "ObjCHTMLDemoViewController.h"
#import "ObjCAnimationDemoViewController.h"
#import "ObjCStylesheetDemoViewController.h"
#import "ObjCLayoutCacheDemoViewController.h"

@interface ObjCDemoTabBarController ()
@property (strong, nonatomic) NSArray<NSDictionary *> *demoConfigs;
@end

@implementation ObjCDemoTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.demoConfigs = @[
        @{@"title": @"Flexbox",   @"image": @"01.circle",         @"vc": [ObjCFlexboxDemoViewController class]},
        @{@"title": @"Grid",      @"image": @"02.circle",         @"vc": [ObjCGridDemoViewController class]},
        @{@"title": @"Margin",    @"image": @"03.circle",         @"vc": [ObjCMarginPaddingDemoViewController class]},
        @{@"title": @"Position",  @"image": @"04.circle",         @"vc": [ObjCPositionDemoViewController class]},
        @{@"title": @"Gap",       @"image": @"05.circle",         @"vc": [ObjCGapDemoViewController class]},
        @{@"title": @"Aspect",    @"image": @"06.circle",         @"vc": [ObjCAspectRatioDemoViewController class]},
        @{@"title": @"综合",      @"image": @"star",              @"vc": [ObjCCompositeDemoViewController class]},
        @{@"title": @"YogaKit",   @"image": @"square.stack.3d.up",@"vc": [ObjCYogaKitDemoViewController class]},
        @{@"title": @"DSL",       @"image": @"rectangle.3.group",  @"vc": [ObjCDSLDemoViewController class]},
        @{@"title": @"HTML",      @"image": @"textformat.alt",     @"vc": [ObjCHTMLDemoViewController class]},
        @{@"title": @"Animation", @"image": @"play.circle",        @"vc": [ObjCAnimationDemoViewController class]},
        @{@"title": @"Stylesheet",@"image": @"doc.text",           @"vc": [ObjCStylesheetDemoViewController class]},
        @{@"title": @"Cache",     @"image": @"bolt.circle",        @"vc": [ObjCLayoutCacheDemoViewController class]},
    ];

    NSMutableArray *vcs = [NSMutableArray array];
    for (NSDictionary *config in self.demoConfigs) {
        UIViewController *vc = [[config[@"vc"] alloc] init];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:config[@"title"]
                                                      image:[UIImage systemImageNamed:config[@"image"]]
                                                        tag:0];
        [vcs addObject:[[UINavigationController alloc] initWithRootViewController:vc]];
    }
    self.viewControllers = vcs;
}

@end
