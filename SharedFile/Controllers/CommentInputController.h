//
//  CommentInputController.h
//  ReUnite + TriagePic
//


#import "BTFilterController.h"
#import "PersonObject.h"
#import "ImageViewer.h"
#import "WSCommon.h"



@interface CommentInputController : BTFilterController <BTFilterControllerDelegate, UITextViewDelegate, MKMapViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, WSCommonDelegate>
- (void)fillWithUUID:(NSString *)uuid;
@end

@interface HighlightButton : UIButton

@end
