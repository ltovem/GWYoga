#import <UIKit/UIKit.h>

@class YGKLayoutView;

NS_ASSUME_NONNULL_BEGIN

@interface ObjCYogaRenderer : NSObject

/// Colored child view for layout previews.
+ (UIView *)coloredChildWithWidth:(CGFloat)w height:(CGFloat)h index:(int)idx;

/// Create a bordered YGKLayoutView container with forced layout mode.
+ (YGKLayoutView *)makeContainerWithWidth:(CGFloat)width height:(CGFloat)height;

/// Create a demo section with title, container preview, and info label.
+ (UIView *)createDemoSectionWithTitle:(NSString *)title container:(YGKLayoutView *)container;

/// Create an info-only section (title + monospaced text, no layout preview).
+ (UIView *)createInfoSectionWithTitle:(NSString *)title text:(NSString *)text;

/// Setup a vertical stack of sections in a scrollView.
+ (void)setupStackWithSections:(NSArray<UIView *> *)sections inScrollView:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
