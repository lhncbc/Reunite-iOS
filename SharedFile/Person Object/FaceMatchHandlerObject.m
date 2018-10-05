//
//  FaceMatchHandlerObject.m
//  ReUnite + TriagePic
//

#import "FaceMatchHandlerObject.h"
#import "ImageObject.h"


#define TAG_ACTION_IMAGE_SOURCE 13

static FaceMatchHandlerObject *FMOBJECT;

@implementation FaceMatchHandlerObject
{
    UIActionSheet *_imageActionSheet;
}

+ (void)openCameraWithDelegate:(id)delegate
{
    if (!FMOBJECT) {
        FMOBJECT = [[FaceMatchHandlerObject alloc] init];
    }
    [FMOBJECT setDelegate:delegate];
    [FMOBJECT openChoice];
}

- (void)openChoice
{
    _imageActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Image Source", nil)delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", nil), NSLocalizedString(@"Gallery", nil), nil];
    [_imageActionSheet setTag:TAG_ACTION_IMAGE_SOURCE];
    [_imageActionSheet showInView:[self topMostController].view];
}


- (UIViewController*) topMostController
{
    
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == TAG_ACTION_IMAGE_SOURCE) {
        switch (buttonIndex) {
            case 0:
                //check if camera exists, if it does go ahead and use it
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                    UIImagePickerController* cameraPickerController = [[UIImagePickerController alloc] init];
                    [cameraPickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
                    [cameraPickerController setDelegate:self];
                    cameraPickerController.modalPresentationStyle=UIModalPresentationCustom;

                    [(UIViewController *)_delegate presentViewController:cameraPickerController animated:YES completion:nil];
                } else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Unavailable" message:@"Your Device does not support Cameras" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                }
                break;
            case 1:
            {
                UIImagePickerController *galleryPickerController = [[UIImagePickerController alloc] init];
                [galleryPickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [galleryPickerController setDelegate:self];
                galleryPickerController.modalPresentationStyle=UIModalPresentationCustom;

                [(UIViewController *)_delegate presentViewController:galleryPickerController animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    image = [ImageObject fixOrientation:image toSize:CGSizeMake(1280, 1280)];
    DLog(@"%f,%f",image.size.width,image.size.height);
    ImageObject *imageObject = [[ImageObject alloc] initWithImage:image imageURL:@"" faceRect:CGRectZero faceRectAvailable:NO primary:NO delegate:self];
    PhotoEditViewController *photoEditViewController = [[PhotoEditViewController alloc] initWithImageObject:imageObject editableValue:YES delegate:self];
    
    photoEditViewController.modalPresentationStyle=UIModalPresentationCustom;
    
    [picker dismissViewControllerAnimated:YES completion:^{

        [(UIViewController *)_delegate presentViewController:photoEditViewController animated:YES completion:nil];
    }];
}

#pragma mark PhotoEditViewController
- (void)photoEditDonePickingWithImageObject:(ImageObject *)imageObject
{
    UIImage *croppedImage = [ImageObject cropImage:imageObject.image atRect:imageObject.faceRect];
    NSString *encodedFace = [ImageObject base64EncodingImageWithImage:croppedImage];
    
    if (_delegate && [_delegate respondsToSelector:@selector(haveFaceImageEncodedString:)]) {
        [_delegate haveFaceImageEncodedString:encodedFace];
    }
}
@end
