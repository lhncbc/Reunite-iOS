//
// PhotoEditViewController.h
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ImageViewer : UIViewController <UIScrollViewDelegate>
- (id)initWithImage:(UIImage *)image;
@property (nonatomic, strong) UIImage *image;
@end
