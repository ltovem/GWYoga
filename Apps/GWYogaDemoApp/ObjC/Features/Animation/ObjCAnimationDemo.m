#import "ObjCAnimationDemo.h"
#import <GWYogaKit/GWYogaKit-Swift.h>
#import <GWYogaKitObjCCore/GWYogaKitObjCCore-Swift.h>

@interface ObjCAnimationDemo ()
@property (nonatomic, strong) YogaLayoutView *container;
@property (nonatomic, strong) UIView *box;
@property (nonatomic, strong) UILabel *badge;
@property (nonatomic, assign) BOOL expanded;
@end

@implementation ObjCAnimationDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.expanded = NO;

    // badge
    self.badge = [[UILabel alloc] init];
    self.badge.text = @"  Block  ";
    self.badge.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium];
    self.badge.textColor = UIColor.systemBlueColor;
    self.badge.backgroundColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.12];
    self.badge.layer.cornerRadius = 4;
    self.badge.clipsToBounds = YES;
    [self.view addSubview:self.badge];

    // container
    self.container = [[YogaLayoutView alloc] init];
    [self.container gwstyle:^(YGKLayoutProperties *p) {
        p.flexDirection = YGKFlexDirectionColumn;
        p.alignItems = YGKAlignCenter;
        p.justifyContent = YGKJustifyCenter;
    }];
    [self.view addChild:self.container];

    // animated box
    self.box = [[UIView alloc] init];
    self.box.backgroundColor = UIColor.systemBlueColor;
    self.box.layer.cornerRadius = 12;
    [self.box gwstyle:^(YGKLayoutProperties *p) {
        p.width = 100;
        p.height = 100;
        [p setMargin:YGKEdgeBottom value:24];
    }];
    [self.container addChild:self.box];

    UILabel *boxLabel = [[UILabel alloc] init];
    boxLabel.text = @"tap button";
    boxLabel.font = [UIFont boldSystemFontOfSize:14];
    boxLabel.textColor = UIColor.whiteColor;
    boxLabel.textAlignment = NSTextAlignmentCenter;
    [boxLabel gwstyle:^(YGKLayoutProperties *p) {
        p.alignSelf = YGKAlignCenter;
        p.flexGrow = 1;
    }];
    [self.box addChild:boxLabel];

    // description
    UILabel *desc = [[UILabel alloc] init];
    desc.text = @"UIView animateWithDuration + yoga";
    desc.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    desc.textColor = UIColor.secondaryLabelColor;
    [desc gwstyle:^(YGKLayoutProperties *p) {
        p.height = 20;
        [p setMargin:YGKEdgeBottom value:16];
    }];
    [self.container addChild:desc];

    // animate button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"Animate Layout" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    btn.backgroundColor = UIColor.systemBlueColor;
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.layer.cornerRadius = 12;
    [btn gwstyle:^(YGKLayoutProperties *p) {
        p.width = 180;
        p.height = 48;
    }];
    [btn addTarget:self action:@selector(animateTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.container addChild:btn];

    // reset button
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [resetBtn setTitle:@"Reset" forState:UIControlStateNormal];
    resetBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [resetBtn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    resetBtn.layer.cornerRadius = 8;
    resetBtn.layer.borderWidth = 1;
    resetBtn.layer.borderColor = UIColor.systemBlueColor.CGColor;
    [resetBtn gwstyle:^(YGKLayoutProperties *p) {
        p.width = 100;
        p.height = 36;
        [p setMargin:YGKEdgeTop value:12];
    }];
    [resetBtn addTarget:self action:@selector(resetTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.container addChild:resetBtn];
}

- (void)animateTapped {
    self.expanded = !self.expanded;
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        [self.box gwstyle:^(YGKLayoutProperties *p) {
            p.width = self.expanded ? 200 : 100;
            p.height = self.expanded ? 200 : 100;
            p.cornerRadius = self.expanded ? 50 : 12;
            p.backgroundColor = self.expanded ? UIColor.systemRedColor : UIColor.systemBlueColor;
        }];
        [self.container performYogaLayout];
    } completion:nil];
}

- (void)resetTapped {
    self.expanded = NO;
    [self.box gwstyle:^(YGKLayoutProperties *p) {
        p.width = 100;
        p.height = 100;
        p.cornerRadius = 12;
        p.backgroundColor = UIColor.systemBlueColor;
    }];
    [self.container performYogaLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [self.badge sizeToFit];
    self.badge.frame = CGRectMake(
        self.view.bounds.size.width - self.badge.frame.size.width - 16,
        self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 8,
        self.badge.frame.size.width,
        self.badge.frame.size.height
    );

    CGFloat top = self.view.safeAreaLayoutGuide.layoutFrame.origin.y + 40;
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height - top - 16;
    self.container.frame = CGRectMake(0, top, w, h);
    [self.container performYogaLayout];
}

@end
