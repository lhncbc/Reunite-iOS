//
//  SplashSubScreenViewControlleriPhone.m
//  ReUnite + TriagePic
//


#import "SplashSubScreenViewControlleriPhone.h"
#define INSET_PADDING 20
@interface SplashSubScreenViewControlleriPhone ()

@end

@implementation SplashSubScreenViewControlleriPhone{
    
    // autolayout
    UIScrollView *_scrollerBackground;
    UIView *_containerView;
    NSArray *_currentWidthConstraints;
    NSArray *_constraintsTopNormal;
    NSArray *_constraintsBotNormal;
    
    
    // not autolayout view
    BOOL _scrollsToPrivacy;
    
    // for keeping track of view location
    UILabel *_privacyTitleLabel;
    UILabel *_privacyLabel;
    UIButton *_agreeButton;
    
    // YES if this is the first time user open the app after install
    BOOL _isFirstScreen;
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithAgreeButton:(BOOL)hasAgreeButton isFirstScreen:(BOOL)isFirstScreen scrollsToPrivacy:(BOOL)scrollsToPrivacy delegate:(id)delegate{
    self = [super init];
    if (self) {
        // Custom initialization
        _hasAgreeButton = hasAgreeButton;
        _delegate = delegate;
        _isFirstScreen = isFirstScreen;
        _scrollsToPrivacy = scrollsToPrivacy;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Title
    self.title = NSLocalizedString(@"Burden & Privacy", nil);
    
    // Background
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *logoImageView;
    
    if (IS_TRIAGEPIC) {
        logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triagepic_big"]];
        [logoImageView setAlpha:.1];
    } else {
        logoImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"reunite_big"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [logoImageView setTintColor:[UIColor colorWithRed:.6 green:.7 blue:1 alpha:.1]];
    }
    
    [logoImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:logoImageView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    // Navigation Bar
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(emailMeClicked)];

    [self.navigationItem setRightBarButtonItem:shareButtonItem];
    
    
    NSDictionary *metrics = @{@"width":@(self.view.bounds.size.width - 40), @"sidePadding":@(20)};
    // Scrollview
    _scrollerBackground = [[UIScrollView alloc] init];
    [_scrollerBackground setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_scrollerBackground setDelegate:self];
    [self.view addSubview:_scrollerBackground];
    id topLayout = self.topLayoutGuide;
    id botLayout = self.bottomLayoutGuide;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollerBackground]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_scrollerBackground)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayout][_scrollerBackground][botLayout]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_scrollerBackground, topLayout, botLayout)]];

    // ContainerView
    _containerView = [[UIView alloc] init];
    [_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_scrollerBackground addSubview:_containerView];
    _currentWidthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_containerView(width)]-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_containerView)];
    [_scrollerBackground addConstraints: _currentWidthConstraints];
    [_scrollerBackground addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_containerView]-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_containerView)]];

    // burden
    UILabel *burdenTitleLabel = [[UILabel alloc]init];
    [burdenTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [burdenTitleLabel setText:NSLocalizedString(@"Burden Statement", nil)];
    [burdenTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [burdenTitleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [_containerView addSubview:burdenTitleLabel];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[burdenTitleLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(burdenTitleLabel)]];
    
    UILabel *burdenOMBLabel = [[UILabel alloc]init];
    [burdenOMBLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [burdenOMBLabel setNumberOfLines:0];
    [burdenOMBLabel setText:STRING_BURDEN_OMB_NUMBER];
    [burdenOMBLabel setTextAlignment:NSTextAlignmentJustified];
    [burdenOMBLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [_containerView addSubview:burdenOMBLabel];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[burdenOMBLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(burdenOMBLabel)]];

    UILabel *burdenLabel = [[UILabel alloc]init];
    [burdenLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [burdenLabel setText:NSLocalizedString(@"STRING_BURDEN_STATEMENT", nil)];
    //[burdenLabel setTextAlignment:NSTextAlignmentCenter];
    [burdenLabel setFont:[UIFont systemFontOfSize:16]];
    [burdenLabel setNumberOfLines:0];
    [_containerView addSubview:burdenLabel];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[burdenLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(burdenLabel)]];

    // separator
    UIView *separator = [[UIView alloc] init];
    [separator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [separator setBackgroundColor:[UIColor grayColor]];
    [_containerView addSubview:separator];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[separator]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(separator)]];

    // privacy
    _privacyTitleLabel = [[UILabel alloc]init];
    [_privacyTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_privacyTitleLabel setText:NSLocalizedString(@"Privacy Statement", nil)];
    [_privacyTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [_privacyTitleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [_containerView addSubview:_privacyTitleLabel];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_privacyTitleLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_privacyTitleLabel)]];

    _privacyLabel = [[UILabel alloc] init];
    [_privacyLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_privacyLabel setText:NSLocalizedString(@"STRING_PRIVACY_STATEMENT", nil)];
    [_privacyLabel setNumberOfLines:0];
    [_privacyLabel setTextAlignment:NSTextAlignmentJustified];
    [_privacyLabel setFont:[UIFont systemFontOfSize:16]];
    [_containerView addSubview:_privacyLabel];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_privacyLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_privacyLabel)]];

    // Vertical Spacing
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[burdenTitleLabel]-[burdenOMBLabel]-[burdenLabel]-[separator(1)]-[_privacyTitleLabel]-[_privacyLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(burdenTitleLabel, burdenOMBLabel, burdenLabel, separator, _privacyTitleLabel, _privacyLabel)]];

    if (_isFirstScreen) {
        // add "*available in about section"
        UILabel *availableLabel = [[UILabel alloc] init];
        [availableLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [availableLabel setNumberOfLines:0];
        availableLabel.text =   NSLocalizedString(@"* This page is accessible through About section", nil);
        availableLabel.font = [UIFont systemFontOfSize:14];
        //availableLabel.textColor = [UIColor whiteColor];
        availableLabel.backgroundColor = [UIColor clearColor];
        [_containerView addSubview:availableLabel];
        [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[availableLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(availableLabel)]];
        [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[availableLabel]-[burdenTitleLabel]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(availableLabel, burdenTitleLabel)]];
        
        if (!(IS_IPAD)) {
            
            // Animation tell the user to scroll up
            CGRect bounds = [[UIScreen mainScreen] bounds];
            
            UIView *opaqueBackground = [[UIView alloc] initWithFrame:bounds];
            [opaqueBackground setBackgroundColor:[UIColor colorWithWhite:0 alpha:.5]];
            [self.navigationController.view addSubview:opaqueBackground];
            
            UIImage *arrowImage = [[UIImage imageNamed:@"swipe up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
            [arrowImageView setTintColor:[UIColor whiteColor]];
            //[arrowImageView.layer setShadowOpacity:.8];
            //[arrowImageView.layer setShadowColor:[[UIColor whiteColor] CGColor]];
            [arrowImageView setFrame:CGRectOffset(arrowImageView.bounds, (bounds.size.width - arrowImageView.bounds.size.width)/2, (bounds.size.height - arrowImageView.bounds.size.height)*3/4)];
            //[arrowImageView setTransform:CGAffineTransformMakeRotation(M_PI)];
            //[self.navigationController.view addSubview:arrowImageView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController.view addSubview:arrowImageView];
                [UIView animateWithDuration:1.5 animations:^{
                    [arrowImageView setFrame:CGRectOffset(arrowImageView.frame, 0, -bounds.size.height*2/4)];
                } completion:^(BOOL finished) {
                    [arrowImageView removeFromSuperview];
                    [opaqueBackground removeFromSuperview];
                }];
            });
        }
        
        
    } else {
        [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[burdenTitleLabel]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(burdenTitleLabel)]];
    }

    // if needs to add agree button
    if (_hasAgreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_agreeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_agreeButton setTitle: NSLocalizedString(@"Agree", nil) forState:UIControlStateNormal];
        [_agreeButton.layer setCornerRadius:5];
        [_agreeButton addTarget:self action:@selector(dismissButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_agreeButton setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
        [_containerView addSubview:_agreeButton];
        [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_agreeButton]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_agreeButton)]];
        [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_privacyLabel]-[_agreeButton(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_privacyLabel, _agreeButton)]];
    } else {
        [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_privacyLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_privacyLabel)]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_scrollsToPrivacy) {
        [self scrollToPrivacy];
    }
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [_scrollerBackground removeConstraints:_currentWidthConstraints];
    
    NSDictionary *metrics = @{@"width":@(self.view.bounds.size.width - 40), @"sidePadding":@(20)};
    _currentWidthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_containerView(width)]-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_containerView)];
    [_scrollerBackground addConstraints: _currentWidthConstraints];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollToPrivacy{
    [_scrollerBackground setContentOffset:CGPointMake(0, _privacyTitleLabel.frame.origin.y) animated:YES];
}

#pragma mark - Button
- (void)dismissButtonClicked:(UIButton *)sender{
    //BOOL agree = sender.tag;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_STATUS_PRIVACY_AGREE];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didDismissedSplashscreen)]){
        [_delegate didDismissedSplashscreen];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)emailMeClicked{
    {
        NSMutableArray *itemArray = [NSMutableArray array];
        [itemArray addObject:[NSString stringWithFormat:@"Burden:\n%@\n%@\n\nPrivacy:\n%@", STRING_BURDEN_OMB_NUMBER, STRING_BURDEN_STATEMENT, STRING_PRIVACY_STATEMENT]];
        //[itemArray addObject:[NSURL URLWithString:_personObject.webLink]];
        

        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemArray applicationActivities:nil];
        [activityViewController setValue:@"Burden and Privacy Statements" forKey:@"subject"];
        [activityViewController setExcludedActivityTypes:@[UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList]];
        //[self presentViewController:activityViewController animated:YES completion:nil];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            [self presentViewController:activityViewController animated:YES completion:nil];
        }
        //if iPad
        else
        {
            if ([activityViewController respondsToSelector:@selector(popoverPresentationController)])
            {
                // Change Rect to position Popover
                SplashSubScreenViewControlleriPhone *_detailCOntroller=[[SplashSubScreenViewControlleriPhone alloc]init];
                activityViewController.popoverPresentationController.sourceView = _detailCOntroller.view;
                [self presentViewController:activityViewController animated:YES completion:nil];
                
            }
            else
            {
                [self presentViewController:activityViewController animated:YES completion:nil];
                
            }
            
            
            
            
        }

    }
}

#pragma mark - MFMailComposeViewController Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if(error){
        DLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    }else if (result == MFMailComposeResultSent){
        UIAlertView *sentComplete = [[UIAlertView alloc] initWithTitle:@"Email Sent" message:nil delegate:nil cancelButtonTitle:@"Done" otherButtonTitles: nil];
        [sentComplete show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}



@end
