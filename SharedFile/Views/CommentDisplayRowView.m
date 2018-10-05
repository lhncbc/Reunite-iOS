//
//  CommentDisplayRowView.m
//  ReUnite + TriagePic
//


#import "CommentDisplayRowView.h"
#define HEIGHT_PADDING 5
#define HEIGHT_LABEL 26
#define WIDTH_PADDING 20
@implementation CommentDisplayRowView
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    UIView *_backgroundView;
    
    MKMapView *_mapView;
    MKPointAnnotation *_mapAnnotation;
    UILabel *_mapLabel;
    
    UIButton *_imageButton;
    
    UIButton *_leftButton;
    UIButton *_rightButton;
}

- (id)initWithCommentObject:(CommentObject *)commentObject size:(CGSize)size;
{
    self = [super init];
    if (self) {
        _commentObject = commentObject;
        
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setDelegate:self];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setAlwaysBounceHorizontal:YES];
        [_scrollView setAlwaysBounceVertical:NO];
        [_scrollView setScrollsToTop:NO];
        [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setClipsToBounds:NO];
        [self addSubview:_scrollView];
        
        _pageControl = [[UIPageControl alloc] init];
        [_pageControl setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_pageControl setPageIndicatorTintColor:[UIColor colorWithWhite:.85 alpha:1]];
        [_pageControl setCurrentPageIndicatorTintColor:[UIColor darkGrayColor]];
        [_pageControl setUserInteractionEnabled:NO];
        [self addSubview:_pageControl];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_scrollView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_scrollView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pageControl]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_pageControl)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl(20)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_pageControl)]];
        
        // side buttons
        [self createSideButtons];
        
        // Image
        int originPage = 0;
        int numberOfPage = 1;
        if ([_commentObject hasImage]) {
            
            _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_imageButton setFrame:CGRectMake(0, 0, size.width, size.height)];
            [_imageButton addTarget:self action:@selector(imageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            [_imageButton setImage:_commentObject.image forState:UIControlStateNormal];
            [_imageButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [_scrollView addSubview:_imageButton];
            
            //Add place to touch and tap
            UIView *touchableView = [[UIView alloc] init];
            [touchableView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [touchableView setBackgroundColor:[UIColor clearColor]];
            [touchableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightButtonTapped)]];
            [_imageButton addSubview:touchableView];
            [_imageButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[touchableView(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(touchableView)]];
            [_imageButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[touchableView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(touchableView)]];
            
            [_leftButton setAlpha:1];
            originPage = 1;
            numberOfPage++;
        }
        
        // Info
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(originPage * size.width, 0, size.width, size.height)];
        [_scrollView addSubview:_backgroundView];
        [self createMiddleSection];
        
        // Map
        if ([_commentObject hasLocation]) {
            _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(numberOfPage * size.width, 0, size.width, size.height)];
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPressed:)];
            [_mapView addGestureRecognizer:longPress];
            
            //Add place to touch and tap
            UIView *touchableView = [[UIView alloc] init];
            [touchableView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [touchableView setBackgroundColor:[UIColor clearColor]];
            [touchableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftButtonTapped)]];
            [_mapView addSubview:touchableView];
            [_mapView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[touchableView(44)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(touchableView)]];
            [_mapView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[touchableView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(touchableView)]];

            _mapAnnotation = [[MKPointAnnotation alloc] init];
            [_mapAnnotation setTitle:_commentObject.location.hasGPS?NSLocalizedString(@"GPS reported by the user", nil):NSLocalizedString(@"Possible GPS from the address", nil)];
            [_mapView addAnnotation:_mapAnnotation];
            [_mapView selectAnnotation:_mapAnnotation animated:NO];
            if ([_commentObject.location hasGPS]) {
                [_scrollView addSubview:_mapView];
                [_mapAnnotation setCoordinate:_commentObject.location.gpsCoordinates];
                [_mapView setRegion:MKCoordinateRegionMake(_commentObject.location.gpsCoordinates, _commentObject.location.span) animated:YES];
            } else {
                _mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(numberOfPage * size.width, 0, size.width, size.height)];
                [_mapLabel setText:NSLocalizedString(@"Obtaining GPS Coordinates...", nil)];
                [_mapLabel setNumberOfLines:0];
                [_mapLabel setTextAlignment:NSTextAlignmentCenter];
                [_scrollView addSubview:_mapLabel];
                
                [self getAndDisplayGPS];
            }
            
            [_rightButton setAlpha:1];
            numberOfPage++;
        }
        
        // offsets and pages
        [_scrollView setContentOffset:CGPointMake(originPage * size.width, 0)];
        [_scrollView setContentSize:CGSizeMake(numberOfPage * size.width, size.height - 1)];
        [_pageControl setNumberOfPages:numberOfPage];
        [_pageControl setCurrentPage:originPage];
        
        
    }
    return self;
}

- (void)createMiddleSection
{
    // keep track for what is on top for auto layout
    UIView *topView;
    UIColor *separatorColor = [UIColor colorWithWhite:.9 alpha:1];
    
    // name
    UILabel *nameLabel = [[UILabel alloc] init];
    [nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [nameLabel setText:_commentObject.commenterName];
    [_backgroundView addSubview:nameLabel];
    
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[nameLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(nameLabel)]];
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[nameLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(nameLabel)]];
    topView = nameLabel;
    
    //place
    UILabel *placeLabel = [[UILabel alloc] init];
    [placeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [placeLabel setText:@(_commentObject.rank).stringValue];
    [placeLabel setTextAlignment:NSTextAlignmentCenter];
    [_backgroundView addSubview:placeLabel];
    
    
    UIView *placeSeparator = [[UIView alloc] init];
    [placeSeparator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [placeSeparator setBackgroundColor:separatorColor];
    [_backgroundView addSubview:placeSeparator];
    
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[placeSeparator(1)]-[placeLabel]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(placeSeparator, placeLabel)]];
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[placeSeparator(nameLabel)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(placeSeparator, nameLabel)]];
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[placeLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(placeLabel)]];
    
    // status
    if ([_commentObject hasStatus]) {
        
        UIView *separator = [[UIView alloc] init];
        [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [separator setBackgroundColor:separatorColor];
        [_backgroundView addSubview:separator];
        
        UILabel *statusLabel = [[UILabel alloc] init];
        [statusLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [statusLabel setText:_commentObject.status];
        [statusLabel setTextAlignment:NSTextAlignmentCenter];
        [_backgroundView addSubview:statusLabel];
        
        [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[separator]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(separator)]];
        [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[statusLabel]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(statusLabel)]];
        [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView]-(5)-[separator(1)]-(5)-[statusLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(topView, separator, statusLabel)]];
        topView = statusLabel;
    }
    
    // location
    if ([_commentObject hasLocation]) {
        UIView *separator = [[UIView alloc] init];
        [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [separator setBackgroundColor:separatorColor];
        [_backgroundView addSubview:separator];
        
        UILabel *locationLabel = [[UILabel alloc] init];
        [locationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [locationLabel setText:[_commentObject.location getLocationString]];
        [locationLabel setNumberOfLines:0];
        [_backgroundView addSubview:locationLabel];
        
        [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[separator]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(separator)]];
        [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[locationLabel]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(locationLabel)]];
        [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView]-(5)-[separator(1)]-(5)-[locationLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(topView, separator, locationLabel)]];
        topView = locationLabel;
    }
   
    // comment
    UIView *separator = [[UIView alloc] init];
    [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [separator setBackgroundColor:separatorColor];
    [_backgroundView addSubview:separator];
    
    UILabel *commentLabel = [[UILabel alloc] init];
    [commentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [commentLabel setText:_commentObject.text];
    [commentLabel setNumberOfLines:0];
    [_backgroundView addSubview:commentLabel];
    
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[separator]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(separator)]];
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[commentLabel]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(commentLabel)]];
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topView]-(5)-[separator(1)]-(5)-[commentLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(topView, separator, commentLabel)]];
    
    //Add place to touch and tap
    UIView *touchableViewL = [[UIView alloc] init];
    [touchableViewL setTranslatesAutoresizingMaskIntoConstraints:NO];
    [touchableViewL setBackgroundColor:[UIColor clearColor]];
    [touchableViewL addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftButtonTapped)]];
    [_backgroundView addSubview:touchableViewL];
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[touchableViewL(44)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(touchableViewL)]];
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[touchableViewL]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(touchableViewL)]];
    
    //Add place to touch and tap
    UIView *touchableViewR = [[UIView alloc] init];
    [touchableViewR setTranslatesAutoresizingMaskIntoConstraints:NO];
    [touchableViewR setBackgroundColor:[UIColor clearColor]];
    [touchableViewR addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightButtonTapped)]];
    [_backgroundView addSubview:touchableViewR];
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[touchableViewR(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(touchableViewR)]];
    [_backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[touchableViewR]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(touchableViewR)]];
}

- (void)createSideButtons
{
    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_leftButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(leftButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_leftButton setUserInteractionEnabled:NO];
    [_leftButton setAlpha:0];
    [self addSubview:_leftButton];
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_rightButton setImage:[UIImage imageNamed:@"ArrowRight"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(rightButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton setUserInteractionEnabled:NO];
    [_rightButton setAlpha:0];
    [self addSubview:_rightButton];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftButton(20)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_leftButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_leftButton]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_leftButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightButton(20)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_rightButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_rightButton]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_rightButton)]];
}

- (void)getAndDisplayGPS
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *possibleLocationArray = [LocationObject getpossibleLocationFromString:[_commentObject.location getLocationString]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([possibleLocationArray count]){ //if Google has suggestions
                LocationObject *tempLocationObject = ((LocationObject *)possibleLocationArray[0]);
                _commentObject.location.gpsCoordinates = tempLocationObject.gpsCoordinates;
                _commentObject.location.span =  tempLocationObject.span;
                
                
                [_scrollView addSubview:_mapView];
                [_mapAnnotation setCoordinate:_commentObject.location.gpsCoordinates];
                [_mapView setRegion:MKCoordinateRegionMake(_commentObject.location.gpsCoordinates, _commentObject.location.span) animated:YES];
            } else {
                [_mapLabel setText:NSLocalizedString(@"Unable to verify the address", nil)];
            }
        });
    });}

#pragma mark - Button
- (void)leftButtonTapped
{
    if (_scrollView.contentOffset.x == 0) {
        return;
    }
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentOffset.x - _scrollView.frame.size.width, 0, _scrollView.frame.size.width, 1) animated:YES];
}

- (void)rightButtonTapped
{
    if (_scrollView.contentOffset.x + _scrollView.frame.size.width == _scrollView.contentSize.width) {
        return;
    }
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.contentOffset.x + _scrollView.frame.size.width, 0, _scrollView.frame.size.width, 1) animated:YES];
}

- (void)imageButtonTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentDisplayRowView:showImage:)]) {
        [_delegate commentDisplayRowView:self showImage:_commentObject.image];
    }
}

- (void)mapLongPressed:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *mapTypeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Map Type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Standard", nil), NSLocalizedString(@"Satellite", nil), NSLocalizedString(@"Hybrid", nil), nil];
        [mapTypeActionSheet showFromRect:_mapView.frame inView:_mapView.superview animated:YES];
    }
}

#pragma mark - Delegate
#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!CGRectEqualToRect(scrollView.frame, CGRectZero) && (scrollView.contentOffset.x > 0) && (scrollView.contentOffset.x + scrollView.frame.size.width < scrollView.contentSize.width)) {
        [_leftButton setAlpha:scrollView.contentOffset.x / scrollView.frame.size.width];
        [_rightButton setAlpha:(scrollView.contentSize.width - scrollView.contentOffset.x) / scrollView.frame.size.width - 1];
    }
    
    int currentPage = scrollView.contentOffset.x / scrollView.frame.size.width + .5;
    if (_pageControl.currentPage != currentPage) {
        [_pageControl setCurrentPage:currentPage];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_pageControl.currentPage == _pageControl.numberOfPages - 1) {
        [_mapView setRegion:MKCoordinateRegionMake(_commentObject.location.gpsCoordinates, _commentObject.location.span) animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_pageControl.currentPage == _pageControl.numberOfPages - 1) {
        [_mapView setRegion:MKCoordinateRegionMake(_commentObject.location.gpsCoordinates, _commentObject.location.span) animated:YES];
    }
}

#pragma mark UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // standard
            [_mapView setMapType:MKMapTypeStandard];
            break;
        case 1:
            // statellite
            [_mapView setMapType:MKMapTypeSatellite];
            break;
        case 2:
            // hybrid
            [_mapView setMapType:MKMapTypeHybrid];
            break;
        default:
            break;
    }
}

#pragma mark - Static
+ (CGFloat)estimateHeightForCommentObject:(CommentObject *)commentObject width:(CGFloat)width
{
    CGFloat height = 0;
    
    // name and place
    height += 3*HEIGHT_PADDING + [self heightForString:commentObject.commenterName width:width];
    
    // status
    if ([commentObject hasStatus]) {
        height += 2*HEIGHT_PADDING + [self heightForString:commentObject.status width:width];
    }
    
    // comment
    height += 3*HEIGHT_PADDING + [self heightForString:commentObject.text width:width];
    
    // pageControl
    height += 25;
    
    // location
    if ([commentObject hasLocation]) {
        height += 2*HEIGHT_PADDING + [self heightForString:[commentObject.location getLocationString] width:width];
        
        // since there is location, there might be GPS provided by the user or looked up on Google, give extra area for the map
        height = MAX(height, 240);
    }
    
    return height;
}

+ (CGFloat)heightForString:(NSString *)string width:(CGFloat)width
{
    if (!string || [string isKindOfClass:[NSNull class]]) return 0;
    CGRect stringRect = [string boundingRectWithSize:CGSizeMake(width - 2*WIDTH_PADDING, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[CommonFunctions normalFont]} context:Nil];
    return stringRect.size.height;
}


#pragma mark - Frame Change
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if (_backgroundView.bounds.size.width == bounds.size.width) {
        return;
    }
    
    [CommonFunctions printCGRect:bounds];
    CGSize size = bounds.size;
    int originPage = 0;
    int numberOfPage = 1;
    
    if ([_commentObject hasImage]) {
        [_imageButton setFrame:CGRectMake(0, 0, size.width, size.height)];
        originPage = 1;
        numberOfPage++;
    }
    
    // Info
    [_backgroundView setFrame:CGRectMake(originPage * bounds.size.width, 0, bounds.size.width, bounds.size.height)];

    // Map
    if ([_commentObject hasLocation]) {
        [_mapView setFrame:CGRectMake(numberOfPage * size.width, 0, size.width, size.height)];
        numberOfPage++;
    }
    
    // scroll to middle
    [_scrollView setContentSize:CGSizeMake(numberOfPage * size.width, size.height - 1)];
    [_scrollView setContentOffset:CGPointMake(originPage * size.width, 0)];
    
    // correct button alpha
    [_leftButton setAlpha:originPage];
    [_rightButton setAlpha:[_commentObject hasLocation]];
}


@end
