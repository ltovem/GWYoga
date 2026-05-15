@import GWYogaKitLayoutCacheObjCCore;
@import GWYogaKitObjCCore;
#import "ObjCLayoutCacheDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCLayoutCacheDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Layout Cache";

    NSMutableArray *s = [NSMutableArray array];

    // Pre-measure
    {
        UILabel *testLabel = [[UILabel alloc] init];
        testLabel.text = @"Hello Layout Cache";
        testLabel.font = [UIFont systemFontOfSize:16];

        YGKPreLayout *pre = testLabel.yogaProperties.preLayout;
        CGSize size = [pre measureWithWidth:200];

        NSString *text = [NSString stringWithFormat:
            @"UILabel 测量 (width=200):\nwidth = %.1f\nheight = %.1f\n通过 yogaProperties.preLayout 获取\n不触发实际布局，结果被缓存",
            size.width, size.height];
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"预测量 (PreLayout)" text:text]];
    }

    // Cache invalidation
    {
        NSString *text = @"当视图内容变化时（如文本变更），调用:\n[view.yogaProperties.preLayout invalidateCache]\n下次 measure 将重新计算而非使用缓存结果。";
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"缓存失效" text:text]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

@end
