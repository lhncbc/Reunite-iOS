//
// PhotoEditViewController.m
//  ReUnite + TriagePic + TriagePic.iPad

#import "PhotoEditViewController.h"
#import "SVProgressHUD.h"
#define toolBarHeight 44
#define zoomPadding .1


@interface PhotoEditViewController ()

@end

@implementation PhotoEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        
    }
    return self;
}

/*
- (id)initWithImage:(UIImage *)imageValue faceRectAvailable:(BOOL)faceRectAvailable faceRect:(CGRect)faceRectValue editableValue:(BOOL)editableValue delegate:(id) delegate{
    
        //Custom initialization
        image = imageValue;
        //viewArray = [[NSMutableArray alloc] init];
        tagArray = [NSMutableArray array];
        editable = editableValue;
        
        CGFloat unitLength = MAX(image.size.width, image.size.height)/100;
        
        imageView = [[PhotoImageView alloc] initWithImage:image borderWidth:unitLength/2 faceRectAvailable:faceRectAvailable faceRect:faceRectValue editable:editableValue];
        self.delegate = delegate;
    }
    return self;
}
*/
- (id)initWithImageObject:(ImageObject *)imageObject editableValue:(BOOL)editableValue delegate:(id)delegate{
    self = [super init];
    if (self){
        _imageObject = imageObject;
        editable = editableValue;
        _delegate = delegate;
        //tagArray = _imageObject.faceRectAvailable?@[_imageObject.faceRect][NSMutableArray array]; // for handling more than 1 face rect returning from face detection

        CGFloat unitLength = MAX(_imageObject.image.size.width, _imageObject.image.size.height)/100;
        imageView = [[PhotoImageView alloc] initWithImage:_imageObject.image borderWidth:unitLength/2 faceRectAvailable:_imageObject.faceRectAvailable faceRect:_imageObject.faceRect editable:editable];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//Do any additional setup after loading the view.
    //[self.view addSubview:[BackgroundView background]];
    //BOOL isLandscape = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    //int width = isLandscape? 703: 447;
    //int height = isLandscape? 704: 960;
    faceRectVisibilityToggle = [[UIBarButtonItem alloc] initWithTitle:@"Hide Face Box" style:UIBarButtonItemStylePlain target: self action: @selector(boxToggle:)];
    faceRectVisibilityToggle.tag = 0;
    self.navigationItem.rightBarButtonItem = faceRectVisibilityToggle;
        
    int width = self.view.bounds.size.width;
    int height = editable? self.view.bounds.size.height - toolBarHeight: self.view.bounds.size.height;
    
    int shadowDimension = MIN(imageView.bounds.size.width/10,imageView.bounds.size.height/10)/2;
    imageView.center = CGPointMake(width/2, height/2);
    imageView.layer.borderWidth = 2;
    imageView.layer.shadowOpacity =.8;
    imageView.layer.shadowRadius = shadowDimension;
    imageView.layer.shadowOffset = CGSizeMake(shadowDimension,  shadowDimension);
    imageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:imageView.bounds]CGPath];
    imageView.delegate = self;
    imageView.userInteractionEnabled=YES;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    scrollView.delegate = self;
    float minZoomScale = MIN(width/(_imageObject.image.size.width + shadowDimension),height/(_imageObject.image.size.height + shadowDimension));
    scrollView.minimumZoomScale= minZoomScale;
    //scrollView.minimumZoomScale = 0.2;
    scrollView.maximumZoomScale = MAX(3*minZoomScale, 1);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.alwaysBounceVertical = YES;
    scrollView.scrollEnabled = NO;
    [self.view addSubview:scrollView];
    //[self scrollViewDidZoom:scrollView];
    
    [scrollView addSubview:imageView];
    //[scrollView setContentSize:image.size];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [scrollView addGestureRecognizer:tapGesture];
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, height, width, toolBarHeight)];
    toolbar.tintColor = [UIColor grayColor];
    
    //Toolbar
    cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target: self action: @selector(cancelClicked)];
    cancelBarButton.tintColor = [UIColor redColor];
    //cancelBarButton.enabled = editable? cancelBarButton.enabled:NO;

    //privacyBarButtonItem.tag = privacyBarButtonItemTag;
    flexibleBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flexibleBarSpace.width = 100;
    
    //addBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target: self action: @selector(addClicked)];
    removeBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Remove", nil) style:UIBarButtonItemStylePlain target: self action: @selector(removeClicked)];
    removeBarButton.enabled = NO;
    //removeBarButton.enabled = editable? removeBarButton.enabled:NO;
    cropBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", nil) style:UIBarButtonItemStylePlain target: self action: @selector(cropClicked)];
    cropBarButton.enabled = NO;
    //cropBarButton.enabled = editable? cropBarButton.enabled:NO;

    doneBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target: self action: @selector(doneClicked)];
    doneBarButton.tintColor = [UIColor blueColor];
    doneBarButton.enabled = NO;
    //doneBarButton.enabled = editable? doneBarButton.enabled:NO;

    //doneBarButton.enabled = NO;
    //burdenBarButtonItem.tag = burdenBarButtonItemTag;
    
    redoBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Redo", nil) style:UIBarButtonItemStylePlain target: self action: @selector(redoClicked)];
    
    toolbar.items = @[cancelBarButton,flexibleBarSpace/*,addBarButton*/,removeBarButton,cropBarButton,flexibleBarSpace,doneBarButton];
    
    if (editable) [self.view addSubview:toolbar];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    //[self willAnimateRotationToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0.3];
    
    

    /*
    if (showLoading){
        //loadingView = [LoadingView createAndSetUpInView:self.view];
        processingView = [ProcessingView loadingViewInView:self.view withMessage:@"Searching for Faces" withStyle:ProcessingViewStyleFull shouldShowCancelButton:NO withDelegate:nil];
        //[loadingView setLoadingText:@"Searching for faces... "];
    }*/
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [imageView initRect];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

#pragma mark - notification handler


- (void)viewDidUnload
{
    [super viewDidUnload];
    //Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotate{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - scrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollViewValue{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)? 
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)? 
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, 
                                   scrollView.contentSize.height * 0.5 + offsetY);
    
    DLog(@"%f",scrollViewValue.zoomScale);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, editable? self.view.bounds.size.height - toolBarHeight: self.view.bounds.size.height);
    
    int shadowDimension = MIN(imageView.bounds.size.width/10,imageView.bounds.size.height/10)/2;
    imageView.layer.shadowRadius = shadowDimension;
    imageView.layer.shadowOffset = CGSizeMake(shadowDimension,  shadowDimension);
    imageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:imageView.bounds]CGPath];
    //float minZoomScale = MIN(self.view.bounds.size.width/image.size.width,self.view.bounds.size.height/image.size.height) -zoomPadding;
    float minZoomScale = MIN(self.view.bounds.size.width/(_imageObject.image.size.width + shadowDimension),self.view.bounds.size.height/(_imageObject.image.size.height + shadowDimension));
    scrollView.minimumZoomScale= minZoomScale;

    toolbar.frame = CGRectMake(0, self.view.bounds.size.height - toolBarHeight, self.view.bounds.size.width, toolBarHeight);
    [scrollView setZoomScale:minZoomScale animated:YES];
}

#pragma mark - button handler
- (void)cancelClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneClicked{
   /* if ([toolbar.items count] == 7){
        [imageView selectRect];
        [doneBarButton setTitle:@"Done"];
        toolbar.items = [NSArray arrayWithObjects:cancelBarButton,flexibleBarSpace,addBarButton,removeBarButton,cropBarButton,flexibleBarSpace,redoBarButton,doneBarButton,nil];
    }else{
    */    //done choose
    [imageView selectRect];
    CGRect frame = ((FaceRectView *)(imageView.viewArray)[imageView.selectedFrame]).frame;
    _imageObject.faceRect = frame;
    _imageObject.faceRectAvailable = YES;
    [self.delegate photoEditDonePickingWithImageObject:_imageObject];
    [self dismissViewControllerAnimated:YES completion:nil];


    //}
   
    
}
/*
- (void)addClicked{
    [imageView addRect];
}
*/
- (void)removeClicked{
    [imageView removeRect];
}

- (void)cropClicked{
    CGRect rect = ((UIView *)(imageView.viewArray)[imageView.selectedFrame]).frame;
    CGImageRef imageRef = CGImageCreateWithImageInRect([_imageObject.image CGImage],rect);
    _imageObject.image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    PhotoEditViewController* croppedPhotoVC = [[PhotoEditViewController alloc] initWithImageObject:_imageObject editableValue:editable delegate:_delegate];
                                              // initWithImage:_imageObject.image faceRectAvailable:NO faceRect:CGRectMake(0, 0, _imageObject.image.size.width, _imageObject.image.size.height) editableValue:YES delegate:self.delegate];

    UIViewController *presentingViewController = self.presentingViewController;
    croppedPhotoVC.modalPresentationStyle=UIModalPresentationCustom;

    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [presentingViewController presentViewController:croppedPhotoVC animated:YES completion:nil];
    }];
}

- (void)redoClicked{
    [imageView redoRect];
    [doneBarButton setTitle:@"Select"];
    toolbar.items = @[cancelBarButton,flexibleBarSpace,addBarButton,removeBarButton,cropBarButton,flexibleBarSpace,doneBarButton];
}

/*
- (void)showOrRemoveLoadingView:(BOOL)shouldShow
{
    if(shouldShow)
   {   
        if(!processingView)
       {
            //loadingView = [LoadingView createAndSetUpInView:self.modalViewController.view];
            
            showLoading = YES;
        }
    }
    else
   {   
        [UIView animateWithDuration:0.2f animations:^{
            processingView.alpha = 0.0f;
        } completion:^(BOOL finished){
            if(finished)
           {
                if(processingView)
                    [processingView removeFromSuperview];
                processingView = nil;
            }
        }];
    }
}
*/

#pragma mark - PhotoImageViewDelegate
- (void)didStartFaceFinding{
    //processingView = [ProcessingView loadingViewInView:self.view withMessage:@"Searching for Faces..." withStyle:ProcessingViewStyleFull shouldShowCancelButton:NO withDelegate:nil];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching for Faces", nil)];
    faceRectVisibilityToggle.enabled = NO;
    faceRectVisibilityToggle.tintColor = [UIColor grayColor];
}

- (void)didEndFaceFindingWithValidResult:(BOOL)hasValidResult{
    [SVProgressHUD dismiss];
    
    
    if (hasValidResult) {
        cropBarButton.enabled = YES;
        doneBarButton.enabled = YES;
        faceRectVisibilityToggle.enabled = YES;
        faceRectVisibilityToggle.tintColor = nil;
    }
    

}

- (void)didSelectBox{
    //if (!editable) return;
    
    if ([imageView.viewArray count] > 1){
        removeBarButton.enabled = YES;
    }
    cropBarButton.enabled = YES;
    doneBarButton.enabled = YES;
}

- (void)didDeselectBox{
    //if (!editable) return;

    removeBarButton.enabled = NO;
    cropBarButton.enabled = NO;
    doneBarButton.enabled = NO;
}

#pragma mark - box visibility toggle
- (void)boxToggle:(UIBarButtonItem *)sender{
    sender.tag = sender.tag? 0:1;
    if (sender.tag){
        sender.title = @"Show Face Box";
    }else{
        sender.title = @"Hide Face Box";
    }
    [UIView animateWithDuration:.3 animations:^{
        for (FaceRectView *tempRect in imageView.viewArray){
            tempRect.alpha = sender.tag? 0:1;
        }
    }];
}

- (void)setBorderColor:(CGColorRef )color{
    imageView.layer.borderColor = color;
}

#pragma mark - doubleTapped
- (void)doubleTapped:(UITapGestureRecognizer *)doubleTapped{
    //float highZoomScale = (scrollView.maximumZoomScale + scrollView.minimumZoomScale)/4;
    float highZoomScale = 2*scrollView.minimumZoomScale;
    if (scrollView.zoomScale < 1.9*scrollView.minimumZoomScale) {
        //change in zoom
        CGPoint tappedPointRaw = [doubleTapped locationInView:imageView];
        
        //convert to true tap - to adjust location
        CGPoint tappedPointZoomed = CGPointMake((tappedPointRaw.x * highZoomScale) , (tappedPointRaw.y * highZoomScale));
        CGPoint offsetPoint = CGPointMake(tappedPointZoomed.x - self.view.bounds.size.width/2, tappedPointZoomed.y - self.view.bounds.size.height/2);
        [scrollView setZoomScale:highZoomScale animated:YES];
        
        
        
        if (offsetPoint.x + self.view.frame.size.width > imageView.image.size.width * highZoomScale) {
            offsetPoint.x = imageView.image.size.width * highZoomScale - self.view.frame.size.width;
        }
        if (offsetPoint.y + self.view.frame.size.height > imageView.image.size.height * highZoomScale) {
            offsetPoint.y = imageView.image.size.height * highZoomScale - self.view.frame.size.height;
        }
        
        if (offsetPoint.x < 0) {
            offsetPoint.x = 0;
        }
        if (offsetPoint.y < 0) {
            offsetPoint.y = 0;
        }
        
        [scrollView setContentOffset:offsetPoint];
    }else{
        [scrollView setZoomScale:scrollView.minimumZoomScale animated:YES];
    }
    DLog(@"doubleTapped - %@", doubleTapped);
}

@end
