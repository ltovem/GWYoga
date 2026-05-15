@import GWYogaKitObjCCore;
@import GWYogaKitStylesheetObjCCore;
#import "ObjCStylesheetDemoViewController.h"
#import "ObjCYogaRenderer.h"

@implementation ObjCStylesheetDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Stylesheet";

    NSMutableArray *s = [NSMutableArray array];

    // CSS Parse
    {
        NSString *css = @".container { display: flex; flex-direction: row; padding: 16px; }";
        NSString *result = @"nil";
        NSError *error = nil;
        YGKStylesheet *sheet = [YGKStylesheet parse:css error:&error];
        if (sheet) result = [NSString stringWithFormat:@"已解析，规则数待查"];

        NSString *text = [NSString stringWithFormat:@"输入 CSS:\n%@\n结果: %@", css, result];
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"CSS 解析" text:text]];
    }

    // CSS Property Mapper
    {
        YGKLayoutView *preview = [ObjCYogaRenderer makeContainerWithWidth:200 height:60];
        preview.yogaProperties.width = 200;
        preview.yogaProperties.flexDirection = YGKFlexDirectionRow;
        preview.backgroundColor = UIColor.systemGray6Color;

        UILabel *inner = [[UILabel alloc] init];
        inner.text = @"Mapped";
        inner.font = [UIFont systemFontOfSize:12];
        [preview addSubview:inner];

        NSString *text = @"通过 YogaCSSPropertyMapper 将 CSS 属性映射到 YogaProperties:\napply(property: @\"width\", value: @\"100px\")";
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"CSS 属性映射" text:text]];
    }

    // Selector Specificity
    {
        NSString *text = @".container — class: specificity=1000\n#header — id: specificity=1000000\ndiv.container — type+class: specificity=1001";
        [s addObject:[ObjCYogaRenderer createInfoSectionWithTitle:@"Selector 特异性" text:text]];
    }

    [ObjCYogaRenderer setupStackWithSections:s inScrollView:self.scrollView];
}

@end
