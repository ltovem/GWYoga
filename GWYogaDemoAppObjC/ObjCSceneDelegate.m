#import "ObjCSceneDelegate.h"
#import "ObjCDemoTabBarController.h"

@implementation ObjCSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *ws = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:ws];
    self.window.rootViewController = [[ObjCDemoTabBarController alloc] init];
    [self.window makeKeyAndVisible];
}

@end
