//
// PhotoEditViewController.h
//  ReUnite + TriagePic + TriagePic.iPad
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FaceRectView.h"
#import "PhotoImageView.h"

@protocol PhotoEditViewControllerDelegate <NSObject>
@optional
//- (void)photoEditDonePicking:(UIImage *)image tagFrame:(CGRect) frame;
- (void)photoEditDonePickingWithImageObject:(ImageObject *)imageObject;
@end

@interface PhotoEditViewController : UIViewController <UIScrollViewDelegate, PhotoImageViewControllerDelegate>{
    //UIImage *image;
    //NSMutableArray *tagArray;
    //NSMutableArray *viewArray;
    PhotoImageView *imageView;
    UIScrollView *scrollView;
    
    UIToolbar *toolbar;
    BOOL editable;
    UIBarButtonItem *faceRectVisibilityToggle;
    BOOL showLoading;
    
    UIBarButtonItem *addBarButton;
    UIBarButtonItem *removeBarButton;
    UIBarButtonItem *cropBarButton;
    UIBarButtonItem *flexibleBarSpace;
    UIBarButtonItem *cancelBarButton;
    UIBarButtonItem *doneBarButton;
    UIBarButtonItem *redoBarButton;

}
//- (id)initWithImage:(UIImage *)imageValue faceRect:(CGRect)faceRect editableValue:(BOOL)editableValue delegate:(id) delegate;
//- (id)initWithImage:(UIImage *)imageValue faceRectAvailable:(BOOL)faceRectAvailable faceRect:(CGRect)faceRectValue editableValue:(BOOL)editableValue delegate:(id) delegate;
- (id)initWithImageObject:(ImageObject *)imageObject editableValue:(BOOL)editableValue delegate:(id)delegate;
- (void)setBorderColor:(CGColorRef) color;
@property (strong,nonatomic) ImageObject *imageObject;
@property (weak) id<PhotoEditViewControllerDelegate> delegate;

@end
