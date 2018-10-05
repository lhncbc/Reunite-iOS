//
//  ImageViewerEditor.m
//  ReUnite + TriagePic
//

#import "ImageViewerEditor.h"

@interface ImageViewerEditor ()

@end

@implementation ImageViewerEditor{
    
}

- (id)initWithImageObject:(ImageObject *)imageObject;
{
    self = [super initWithImage:imageObject.image];
    if (self) {
        if (imageObject.faceRectAvailable) {
            [self showFaceRect:imageObject.faceRect];
        }
    }
    return self;
}


- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_FACE_DETECTION]) {
            // start with run a face detection
            [self detectFace];
        } else {
            // show the face rectangle
            [self showFaceRect:CGRectMake(20, 20, 100, 100)];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)detectFace
{
    
}

- (void)showFaceRect:(CGRect)rect
{
    
}
@end
