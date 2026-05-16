#import "ObjCCompositeDemo.h"

@interface ObjCCompositeDemo ()
@property (nonatomic, strong) UILabel *badge;
@end

@implementation ObjCCompositeDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    UILabel *badge = [[UILabel alloc] init];
    badge.text = [NSString stringWithFormat:@"  %@  ", @"属性+Block"];
    badge.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium];
    badge.textColor = UIColor.systemBlueColor;
    badge.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    badge.layer.cornerRadius = 4;
    badge.clipsToBounds = YES;
    badge.tag = 999;
    [self.view addSubview:badge];
    self.badge = badge;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UILabel *badge = [self.view viewWithTag:999];
    if (badge) {
        [badge sizeToFit];
        badge.frame = CGRectMake(
            self.view.bounds.size.width - badge.frame.size.width - 16,
            self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 8,
            badge.frame.size.width,
            badge.frame.size.height
        );
    }
}
@end
