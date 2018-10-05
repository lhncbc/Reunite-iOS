//
// PhotoImageView.m
//  ReUnite + TriagePic + TriagePic.iPad
//


#import "PhotoImageView.h"

@implementation PhotoImageView{
    float _borderWidth;
    BOOL _faceRectAvailable;
    CGRect _faceRect;
    BOOL _editable;
}
@synthesize viewArray,selectedFrame,delegate;

- (id)initWithImage:(UIImage *)image borderWidth:(float)borderWidth faceRectAvailable:(BOOL)faceRectAvailable faceRect:(CGRect)faceRect editable:(BOOL)editable{
    self = [super initWithImage:image];
    if (self){
        _borderWidth = borderWidth;
        _faceRectAvailable = faceRectAvailable;
        _faceRect = faceRect;
        _editable = editable;
    }
    return self;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    if (!_editable){
        ((UIScrollView *)[self superview]).scrollEnabled = YES;
        return self;
    }
    
    //check if it is the same as previous
    if (selectedFrame != -1){
        if ([viewArray[selectedFrame] pointInside:point withEvent:event]){
            ((UIScrollView *)[self superview]).scrollEnabled = NO;
            return viewArray[selectedFrame];
        }
    }
    
    int count = 0;
    for (FaceRectView* view in viewArray){
        if([view pointInside:point withEvent:event]){
            //deselect the previous if available
            if (selectedFrame >= 0 && selectedFrame <[viewArray count]) [((FaceRectView *)viewArray[selectedFrame]) setDeselect];
            
            [view setSelect];
            selectedFrame = count;
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"rectSelected" object:nil];
            [self.delegate didSelectBox];
            ((UIScrollView *)[self superview]).scrollEnabled = NO;
            return view;
        }
        count++;
    }
    ((UIScrollView *)[self superview]).scrollEnabled = YES;
    return self;
}


- (void)faceDetect{
    CGFloat unitLength = MAX(self.bounds.size.width, self.bounds.size.height)/100;

    NSArray *autoFaceRectArray = [ImageObject faceDetectionRectArrayFromImage:self.image];
    for (NSValue *rectValue in autoFaceRectArray){
        FaceRectView* faceRectView = [[FaceRectView alloc] initWithFrame:[rectValue CGRectValue] borderwitdh:unitLength/2 automatic:YES editable:_editable];
        [viewArray addObject:faceRectView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:faceRectView];
        });
    }

    BOOL hasValidResult = NO;
    UIAlertView* directionAlert;
    if ([autoFaceRectArray count] > 1){
        directionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Multiple faces detected", @"alert title when user have uploaded picture with 2 or more faces") message:NSLocalizedString(@"Please identify person to report", @"alert message when user have uploaded picture with 2 or more faces") delegate:self cancelButtonTitle:NSLocalizedString(@"Do not show again", @"alert option to stop showing this alert from now on") otherButtonTitles:NSLocalizedString(@"Dismiss", @"alert option to dismiss the alert"), nil];
        
    }else if ([autoFaceRectArray count] == 1){
        selectedFrame = 0;
        [((FaceRectView *)viewArray[selectedFrame]) setSelect];
        [self.delegate didSelectBox];
        hasValidResult = YES;
    }else  if (_editable){
        directionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no face detected", @"alert title when user have uploaded picture with no face detected (automatically)") message:NSLocalizedString(@"Please move rectangle to highlight the person to report", @"alert message when user have uploaded picture with no face detected (automatically)") delegate:self cancelButtonTitle:NSLocalizedString(@"Do not show again", @"alert option to stop showing this alert from now on") otherButtonTitles:NSLocalizedString(@"Dismiss", @"alert option to dismiss the alert"), nil];
        FaceRectView* faceRect = [[FaceRectView alloc] initWithFrame:CGRectMake(unitLength, unitLength, unitLength * 20, unitLength * 20) borderwitdh:unitLength/2 automatic:NO editable:_editable];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:faceRect];
        });
        [viewArray addObject:faceRect];
    }
    
    bool shouldShowWarnings = [[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_FACE_NOT_FOUND];
    if (_editable && shouldShowWarnings) [directionAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    //[self.delegate didEndFaceFindingWithValidResult:hasValidResult];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEndFaceFindingWithValidResult:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didEndFaceFindingWithValidResult:hasValidResult];
        });
    }
}


#pragma mark - handler

- (void)selectRect{
    int count = 0;
    for (FaceRectView* view in viewArray){
        if (count != selectedFrame){
            [view removeFromSuperview];
        }
        count++;
    }
}
/*
- (void)addRect{
    if (selectedFrame != -1){
        [((FaceRectView *)[viewArray objectAtIndex:selectedFrame]) setDeselect];
    }
    FaceRectView* faceRect = [[FaceRectView alloc] initWithFrame:CGRectMake([viewArray count]*10 + 10, [viewArray count]*10 + 10, 200, 200) automatic:NO];
    selectedFrame = [viewArray count];
    [faceRect setSelect];
    [self addSubview:faceRect];
    [viewArray addObject:faceRect];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rectSelected" object:nil];
}
*/

- (void)initRect{
    CGFloat unitLength = MAX(self.bounds.size.width, self.bounds.size.height)/100;

    selectedFrame = -1;
    viewArray = [[NSMutableArray alloc] init];
    //Initialize the views here
    if (_faceRectAvailable){
        FaceRectView *faceRectView = [[FaceRectView alloc]initWithFrame:_faceRect borderwitdh:_borderWidth automatic:NO editable:_editable];
        [faceRectView setSelect];
        [self addSubview:faceRectView];
        [viewArray addObject:faceRectView];
        selectedFrame = 0;
        [self.delegate didSelectBox];
    }else{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_FACE_DETECTION]) {
            [self.delegate didStartFaceFinding];
            [NSThread detachNewThreadSelector:@selector(faceDetect) toTarget:self withObject:nil];
        }else if(_editable){
            FaceRectView* faceRectView = [[FaceRectView alloc] initWithFrame:CGRectMake(unitLength, unitLength, unitLength * 20, unitLength * 20) borderwitdh:unitLength/2 automatic:NO editable:_editable];
            [self addSubview:faceRectView];
            [viewArray addObject:faceRectView];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_FACE_NOT_FOUND]) {
                UIAlertView *dragTheBoxAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Locate The Face", nil) message:NSLocalizedString(@"Please move and resize the red rectangle to cover the reportee's face", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)otherButtonTitles:nil];
                [dragTheBoxAlert show];
            }
        }
    }
}



- (void)removeRect{
    [((FaceRectView *)viewArray[selectedFrame]) removeFromSuperview];
    [viewArray removeObjectAtIndex:selectedFrame];
    selectedFrame = -1;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"rectDeselected" object:nil];
    [self.delegate didDeselectBox];
}


- (void)redoRect{
    int count = 0;
    for (FaceRectView* view in viewArray){
        if (selectedFrame != count){
            [self addSubview:view];
        }
        count++;
    }
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex){
        case 0:
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:GLOBAL_KEY_SETTINGS_FACE_NOT_FOUND];
            break;
        default:
            break;
    }
}
@end
