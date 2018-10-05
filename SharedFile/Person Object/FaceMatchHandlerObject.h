//
//  FaceMatchHandlerObject.h
//  ReUnite + TriagePic
//


#import <Foundation/Foundation.h>
#import "PhotoEditViewController.h"

@protocol FaceMatchHandlerObjectDelegate;

@interface FaceMatchHandlerObject : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, PhotoEditViewControllerDelegate>
+ (void)openCameraWithDelegate:(id)delegate;
- (void)openChoice;
@property (nonatomic, strong) id<FaceMatchHandlerObjectDelegate>delegate;
@end

@protocol FaceMatchHandlerObjectDelegate <NSObject>
- (void)haveFaceImageEncodedString:(NSString *)string;
@end
