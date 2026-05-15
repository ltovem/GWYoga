@import GWYogaKitAnimationObjCCore;
#import "ObjCAnimationDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCAnimationDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Animation";

    NSMutableArray *s = [NSMutableArray array];

    // Timing Functions
    {
        NSString *text = @"• YGKTimingFunction.linear — 匀速\n• YGKTimingFunction.ease — 缓入缓出\n• YGKTimingFunction.easeIn — 缓入\n• YGKTimingFunction.easeOut — 缓出\n• YGKTimingFunction.easeInOut — 缓入缓出\n• YGKTimingFunction.cubicBezier(0.25,0.1,0.25,1) — 贝塞尔\n• YGKTimingFunction.steps(4, position: .end) — 步进";
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"Timing Functions" text:text]];
    }

    // Animation Config
    {
        YGKAnimation *anim = [[YGKAnimation alloc] initWithName:@"fadeIn" duration:0.3 timingFunction:[YGKTimingFunction easeInOut] delay:0.1 direction:YGKAnimationDirectionNormal fillMode:YGKAnimationFillModeForwards];
        NSString *text = [NSString stringWithFormat:@"name: %@\nduration: %.1fs\ndelay: %.1fs\ndirection: .normal\nfillMode: .forwards", anim.name, anim.duration, anim.delay];
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"YGKAnimation 配置" text:text]];
    }

    // Transition Config
    {
        YGKTransition *trans = [[YGKTransition alloc] initWithDuration:0.25 timingFunction:[YGKTimingFunction ease] delay:0 propertyFilter:YGKPropertyFilterLayout];
        NSString *text = [NSString stringWithFormat:@"duration: %.2fs\ndelay: %.1fs\npropertyFilter: .layout", trans.duration, trans.delay];
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"YGKTransition 配置" text:text]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

@end
