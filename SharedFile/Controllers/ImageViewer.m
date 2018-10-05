//
// PhotoEditViewController.m
//

#import "ImageViewer.h"
#include <math.h>

@interface ImageViewer ()

@end
@implementation ImageViewer{
    UIImageView *_imageView;
    UIScrollView *_scrollView;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self){
        _image = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    UILabel *direction1Label = [[UILabel alloc] init];
    //[direction1Label setText:@"Zooming is available"];
    [direction1Label setTextAlignment:NSTextAlignmentCenter];
    [direction1Label setTextColor:[UIColor lightGrayColor]];
    [direction1Label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:direction1Label];
    
    UILabel *direction2Label = [[UILabel alloc] init];
    //[direction2Label setText:@"Tap To Show/Hide Navigation Bar"];
    [direction2Label setTextAlignment:NSTextAlignmentCenter];
    [direction2Label setTextColor:[UIColor lightGrayColor]];
   [direction2Label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:direction2Label];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[direction1Label]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(direction1Label)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[direction1Label]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(direction1Label)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[direction2Label]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(direction2Label)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[direction2Label]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(direction2Label)]];

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.scrollEnabled = YES;
    [self.view addSubview:_scrollView];
    
    _scrollView.userInteractionEnabled=NO;
    _imageView = [[UIImageView alloc] initWithImage:_image];
    [_scrollView addSubview:_imageView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    //[_scrollView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    [doubleTapGesture setNumberOfTapsRequired:1];
    [doubleTapGesture setNumberOfTouchesRequired:1];
    [_scrollView addGestureRecognizer:doubleTapGesture];
    //[tapGesture requireGestureRecognizerToFail:doubleTapGesture];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self resetZoom:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Delegate
#pragma mark UIScrollView
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollViewValue{
    CGFloat offsetX = (_scrollView.bounds.size.width > _scrollView.contentSize.width)?(_scrollView.bounds.size.width - _scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (_scrollView.bounds.size.height > _scrollView.contentSize.height)?(_scrollView.bounds.size.height - _scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}


#pragma mark - Rotation
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self resetZoom:YES];
}

#pragma mark - Tap gesture
- (void)singleTapped:(UITapGestureRecognizer *)singleTapped
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

- (void)doubleTapped:(UITapGestureRecognizer *)doubleTapped
{
    float highZoomScale = 2*_scrollView.minimumZoomScale;
    if (_scrollView.zoomScale < 1.9*_scrollView.minimumZoomScale) {
        //change in zoom
        CGPoint tappedPointRaw = [doubleTapped locationInView:_imageView];
        
        //convert to true tap - to adjust location
        CGPoint tappedPointZoomed = CGPointMake((tappedPointRaw.x * highZoomScale) , (tappedPointRaw.y * highZoomScale));
        CGPoint offsetPoint = CGPointMake(tappedPointZoomed.x - self.view.bounds.size.width/2, tappedPointZoomed.y - self.view.bounds.size.height/2);
        [_scrollView setZoomScale:highZoomScale animated:YES];
        
        if (offsetPoint.x + self.view.frame.size.width > _imageView.image.size.width * highZoomScale) {
            offsetPoint.x = _imageView.image.size.width * highZoomScale - self.view.frame.size.width;
        }
        if (offsetPoint.y + self.view.frame.size.height > _imageView.image.size.height * highZoomScale) {
            offsetPoint.y = _imageView.image.size.height * highZoomScale - self.view.frame.size.height;
        }
        
        if (offsetPoint.x < 0) {
            offsetPoint.x = 0;
        }
        if (offsetPoint.y < 0) {
            offsetPoint.y = 0;
        }
        
        [_scrollView setContentOffset:offsetPoint];
    }else{
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }
}
#pragma mark - Setter
- (void)setImage:(UIImage *)image
{
    _image = image;
    [_imageView setImage:_image];
    [_imageView setBounds:CGRectMake(0, 0, _image.size.width, _image.size.height)];

    if(_image.size.width==0 || _image.size.height ==0) {
        UIAlertView *registerFailedAlert = [[UIAlertView alloc] initWithTitle:@"Reunite" message:@"Loading" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil, nil];
        [registerFailedAlert show];
        return;
    }
    CGPoint currentOffSetRatio = CGPointMake(_scrollView.contentOffset.x/_scrollView.contentSize.width, _scrollView.contentOffset.y/_scrollView.contentSize.height);
    CGFloat currentZoomRatio = (_scrollView.zoomScale - _scrollView.minimumZoomScale) / (_scrollView.maximumZoomScale - _scrollView.minimumZoomScale);
    //CGFloat zoom = _scrollView.zoomScale;
    
    [self resetZoom:NO];
    
    CGFloat zoom = currentZoomRatio * (_scrollView.maximumZoomScale - _scrollView.minimumZoomScale) + _scrollView.minimumZoomScale;
    [_scrollView setZoomScale:zoom animated:NO];
    
    CGPoint offset = CGPointMake(currentOffSetRatio.x * _scrollView.contentSize.width, currentOffSetRatio.y * _scrollView.contentSize.height);
    [_scrollView setContentOffset:offset];
}

#pragma mark - Helper
- (void)resetZoom:(BOOL)animated
{
    CGFloat width = self.view.bounds.size.width;//[UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.view.bounds.size.height;//[UIScreen mainScreen].bounds.size.height;
    
    // Prevent Not-a-Number exception: (dividing 0)
    width = (width == 0)? 1.0f : width;
    height = (height == 0)? 1.0f : height;
if(_image.size.width==0 || _image.size.height ==0) {
    UIAlertView *registerFailedAlert = [[UIAlertView alloc] initWithTitle:@"Reunite" message:@"Loading" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil, nil];
    [registerFailedAlert show];
    return;
}
    
    CGFloat minZoomScale = MIN(width/_image.size.width, height/_image.size.height);
    _scrollView.frame = CGRectMake(0, 0, width, height);
    _scrollView.minimumZoomScale = minZoomScale;
    _scrollView.maximumZoomScale = 4*minZoomScale;//MAX(4*minZoomScale, 1);
    
    if(minZoomScale == INFINITY) {
        minZoomScale=0.46;
    }
    [_scrollView setZoomScale:minZoomScale animated:animated];
    
    _imageView.center = CGPointMake(width/2, height/2);
}

@end
