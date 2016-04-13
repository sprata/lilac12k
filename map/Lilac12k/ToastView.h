//
//  ToastView.h
//  Lilac12k
//
//  Toasttext analog from: http://stackoverflow.com/a/20904416
//

#import <UIKit/UIKit.h>

@interface ToastView : UIView

@property (strong, nonatomic) NSString *text;

+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuration:(float)duration;
+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuration:(float)duration withColor:(UIColor *)color;

@end