//
//  ImageDisplayRowView.m
//  ReUnite + TriagePic


#import "ImageDisplayRowView.h"
#define space 20

@implementation ImageDisplayRowView
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    UIView *_contentView;
    
    NSMutableArray *_buttonArray;
    
    CGFloat _buttonHeight;
    
    BOOL _animating;
    
    UIActionSheet *_noImageAction;
    UIActionSheet *_imageAction;
}

- (id)initWithImageObjectArray:(NSArray *)imageObjectArray editable:(BOOL)editable cellHeight:(CGFloat)cellHeight
{
    self = [super init];
    if (self) {
        _buttonHeight = cellHeight - 5 - 38; // 5 for top padding, 38 for the pageControl
        _imageObjectArray = imageObjectArray;
        
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setDelegate:self];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setAlwaysBounceHorizontal:YES];
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
        
        [self setupContentView];

        [self setImageObjectArray:_imageObjectArray];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[_scrollView][_pageControl]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_scrollView, _pageControl)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:2*space]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        UITapGestureRecognizer *tapGestRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestRec:)];
        [self addGestureRecognizer:tapGestRec];
    }
    return self;
}

#pragma mark - Image Buttons
- (void)setImageObjectArray:(NSArray *)imageObjectArray
{
    [self removeAllButtons];
    
    // setting up images
    int place = 0;
    for (ImageObject *imageObject in imageObjectArray) {
        place++;
        [self addImageButton:imageObject];
    }
    
    CGFloat widthWithSpace = _buttonHeight + 2*space;
    CGFloat allWidth = widthWithSpace * (_imageObjectArray.count == 0?1:_imageObjectArray.count);
    [_contentView setFrame:CGRectMake(0, 0, allWidth, _buttonHeight)];
    [_scrollView setContentSize:_contentView.frame.size];
    
    [_pageControl setNumberOfPages:place == 0?2:place];
    [_pageControl setCurrentPage:0];
}

- (void)setupContentView
{
    CGFloat widthWithSpace = _buttonHeight + 2*space;
    CGFloat allWidth = widthWithSpace * (_imageObjectArray.count == 0?1:_imageObjectArray.count);
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, allWidth, _buttonHeight)];
    [_scrollView addSubview:_contentView];
    [_scrollView setContentSize:_contentView.frame.size];
}

- (void)addImageButton:(ImageObject *)imageObject
{
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageButton addTarget:self action:@selector(imageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [imageButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageButton setTag:_buttonArray.count];
    [_contentView addSubview:imageButton];
    
    //image
    UIImage *buttonImage = imageObject.image;
    /*if (imageObject.faceRectAvailable){ //if contain faceRect
        buttonImage = [ImageObject imageForButtonWithRect:imageObject.faceRect image:buttonImage buttonSize:imageButton.frame.size.width * [[UIScreen mainScreen] scale]];
    }
    buttonImage = [ImageObject enlargeImage:buttonImage maxLengthToLength:imageButton.frame.size.width];*/
    [imageButton setImage:buttonImage forState:UIControlStateNormal];
    [imageButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageButton]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageButton)]];
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    if (_buttonArray.count > 0) {
        UIButton *prevButton = _buttonArray[_buttonArray.count - 1];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[prevButton]-(40)-[imageButton]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(prevButton, imageButton)]];
    } else {
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageButton]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageButton)]];
    }

    //add button into the array
    [_buttonArray addObject:imageButton];
}

- (void)addNoImageButton
{
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageButton addTarget:self action:@selector(imageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [imageButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageButton setTag:0];
    [imageButton setImage:[UIImage imageNamed:@"No Image Male"] forState:UIControlStateNormal];
    [_contentView addSubview:imageButton];
    
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageButton]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageButton)]];
    [_contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageButton]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageButton)]];
}

#pragma mark remove
- (void)removeAllButtons
{
    for (UIButton *imageButton in _buttonArray) {
        [imageButton removeFromSuperview];
    }
    [_buttonArray removeAllObjects];
}

#pragma mark Button Handler
- (void)imageButtonTapped:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(imageDisplayRowView:buttonNumberTapped:)]) {
        [_delegate imageDisplayRowView:self buttonNumberTapped:(int)sender.tag];
    }
}


#pragma mark - Delegate
#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentPage = scrollView.contentOffset.x / (_buttonHeight + 2*space) + .5;
    if (_pageControl.currentPage != currentPage) {
        [_pageControl setCurrentPage:currentPage];
    }
}

#pragma mark - Hit Test
- (UIView *)hitTest:(CGPoint) point withEvent:(UIEvent *)event
{
    NSTimeInterval system = [[NSProcessInfo processInfo] systemUptime];
    if (system - event.timestamp > 0.1) {
        return nil;
    }
    
    UIView *child = nil;
    if ((child = [super hitTest:point withEvent:event]) == self){
    	return _scrollView;
    }
    return child;
}

#pragma mark - Tap Handler
- (void)pageChangedWithPage:(int)page
{
    DLog(@"%i", page);
    CGFloat targetWidth = _buttonHeight + 2*space;
    [UIView animateWithDuration:.3 animations:^{
        [_scrollView setContentOffset:CGPointMake(page * targetWidth, 0)];
    }];
}

- (void)tapGestRec:(UITapGestureRecognizer *)sender
{
    CGPoint tappedPoint = [sender locationInView:self];
    // check for where the touch happens
    // moves the button into the middle
    if (!_animating) {
        _animating = YES;
        CGFloat lowThreshold = (self.frame.size.width - _scrollView.frame.size.width) / 2;
        CGFloat highThreshold = self.frame.size.width - lowThreshold;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tappedPoint.x <= lowThreshold && _pageControl.currentPage != 0) {
                [self pageChangedWithPage:(int)_pageControl.currentPage - 1];
            } else if (tappedPoint.x >= highThreshold && _pageControl.currentPage != _pageControl.numberOfPages - 1) {
                [self pageChangedWithPage:(int)_pageControl.currentPage + 1];
            }
            _animating = NO;
        });
    }
}

@end
