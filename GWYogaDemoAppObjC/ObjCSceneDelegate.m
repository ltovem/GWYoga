#import "ObjCSceneDelegate.h"
#import "ObjCDemoListViewController.h"

@implementation ObjCSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *ws = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:ws];
    ObjCDemoListViewController *listVC = [[ObjCDemoListViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:listVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

@end
