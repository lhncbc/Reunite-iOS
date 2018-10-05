//
// FaceRectView.h
//  ReUnite + TriagePic
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface FaceRectView : UIView

- (id) initWithFrame:(CGRect)frame borderwitdh:(CGFloat)borderWidth automatic:(BOOL) automatic editable:(BOOL)editable;
- (void)setSelect;
- (void)setDeselect;
@end
