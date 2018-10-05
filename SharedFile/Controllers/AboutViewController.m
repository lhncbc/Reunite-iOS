//
//  AboutViewController.m
//  ReUnite + TriagePic
//

#import "AboutViewController.h"
#define BAR_BUTTON_TAG_PRIVACY 30
#define BAR_BUTTON_TAG_BURDEN 31

#define LPF_BUTTON_TAG 10
#define NLM_BUTTON_TAG 12
#define NIH_BUTTON_TAG 13
#define HHS_BUTTON_TAG 14

#define TAKING_SCREEN_SHOT NO

@interface AboutViewController ()

@end

@implementation AboutViewController
{
    // making it dissapear for the landscape
    UILabel *_bodyText;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Navigation Bar Setting
    [self setTitle:NSLocalizedString(@"About", nil)];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"   " style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
    UIBarButtonItem *noticeBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"mail"] style:UIBarButtonItemStylePlain target:self action:@selector(contactUsTapped)];
    [self.navigationItem setRightBarButtonItem:noticeBarButtonItem];
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *logoImage = IS_TRIAGEPIC?[[UIImage imageNamed:@"triagepic"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]:[[UIImage imageNamed:@"reunite"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [logoButton setImage:logoImage forState:UIControlStateNormal];
    [logoButton setTintColor:[UIColor colorWithRed:.5 green:.6 blue:.9 alpha:1]];
    [logoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [logoButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [logoButton addTarget:self action:@selector(logoTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    if (TAKING_SCREEN_SHOT) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        return;
    }
    
    CGFloat fontDoubler = IS_IPAD?2:1;
    
    //Title
    UILabel *title = [[UILabel alloc]init];
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];
    [title setText:[NSString stringWithFormat:@"NLM %@®", [CommonFunctions appName]]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont fontWithName:@"Arial-BoldMT" size:25*fontDoubler]];
    [title setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.view addSubview:title];
    
    //Version
    UILabel *version = [[UILabel alloc]init];
    [version setTranslatesAutoresizingMaskIntoConstraints:NO];
    [version setText:[NSString stringWithFormat:@"V %@", [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]]];
    [version setTextAlignment:NSTextAlignmentCenter];
    [version setFont:[UIFont fontWithName:@"Verdana-Italic" size:IS_IPAD?17:12]];
    [self.view addSubview:version];
    
    //Body
    _bodyText = [[UILabel alloc] init];
    [_bodyText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_bodyText setText:[NSString stringWithFormat:NSLocalizedString(@"%@ is an R&D project of the Lister Hill National Center for Biomedical Communications, a division of the National Library of Medicine, part of the National Institutes of Health.", nil),[CommonFunctions appName]]];
    [_bodyText setLineBreakMode:NSLineBreakByWordWrapping];
    [_bodyText setNumberOfLines:0];
    [_bodyText setFont:[UIFont fontWithName:@"Arial" size:15*fontDoubler]];
    [_bodyText setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    UIView *_bodyTextBox = [[UIView alloc] init];
    [_bodyTextBox setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:_bodyTextBox];
    [_bodyTextBox addSubview:_bodyText];
    [_bodyTextBox addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bodyText]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_bodyText)]];
    [_bodyTextBox addConstraint:[NSLayoutConstraint constraintWithItem:_bodyTextBox attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bodyText attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    UIButton *NLMButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [NLMButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NLMButton setBackgroundImage:[[UIImage imageNamed:@"nlmButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [NLMButton addTarget:self action:@selector(iconButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    NLMButton.tag = NLM_BUTTON_TAG;
    [self.view addSubview:NLMButton];
    
    UIButton *NIHButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [NIHButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NIHButton setBackgroundImage:[[UIImage imageNamed:@"nihButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [NIHButton addTarget:self action:@selector(iconButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    NIHButton.tag = NIH_BUTTON_TAG;
    [self.view addSubview:NIHButton];
    
    UIButton *HHSButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [HHSButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [HHSButton setBackgroundImage:[[UIImage imageNamed:@"hhsButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [HHSButton addTarget:self action:@selector(iconButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    HHSButton.tag = HHS_BUTTON_TAG;
    [self.view addSubview:HHSButton];
    
    //Footer
    UILabel *OMBNumber = [[UILabel alloc]init];
    [OMBNumber setTranslatesAutoresizingMaskIntoConstraints:NO];
    [OMBNumber setText:[NSString stringWithFormat:NSLocalizedString(@"Burden Statement: %@", nil), STRING_BURDEN_OMB_NUMBER]];
    [OMBNumber setTextAlignment:NSTextAlignmentRight];
    [OMBNumber setFont:[UIFont fontWithName:@"Arial" size:12*fontDoubler]];
    [OMBNumber setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.view addSubview:OMBNumber];
    
    UILabel *footerLabel = [[UILabel alloc] init];
    [footerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [footerLabel setTextAlignment:NSTextAlignmentCenter];
    [footerLabel setNumberOfLines:0];
    NSString *fontName = @"Helvetica-BoldOblique";
    NSString *footerString = [NSString stringWithFormat:NSLocalizedString(@"%@, %@, and the LOST PERSON FINDER Design are trademarks of the U.S. Department of Health & Human Services (HHS).", nil), [CommonFunctions siteName], [CommonFunctions appName]];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:footerString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11*fontDoubler]}];
    [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontName size:11*fontDoubler] range:[footerString rangeOfString:[CommonFunctions siteName]]];
    [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontName size:11*fontDoubler] range:[footerString rangeOfString:[CommonFunctions appName]]];
    [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontName size:11*fontDoubler] range:[footerString rangeOfString:@"LOST PERSON FINDER"]];
    [footerLabel setAttributedText:attrString];
    [footerLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.view addSubview:footerLabel];

    // Toolbar
    if (IS_IPAD) {
        UIBarButtonItem *flexibleBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        flexibleBarSpace.width = 100;
        UIBarButtonItem *flexibleBarSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        flexibleBarSpace2.width = 100;
        UIBarButtonItem *burdenBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Burden & Privacy Statement", nil) style:UIBarButtonItemStylePlain target: self action: @selector(barItemClicked:)];
        burdenBarButtonItem.tag = BAR_BUTTON_TAG_BURDEN;
        
        self.toolbarItems = @[flexibleBarSpace,burdenBarButtonItem,flexibleBarSpace2];
    } else {
        UIBarButtonItem *privacyBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Privacy", nil) style:UIBarButtonItemStylePlain target: self action: @selector(barItemClicked:)];
        privacyBarButtonItem.tag = BAR_BUTTON_TAG_PRIVACY;
        UIBarButtonItem *flexibleBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        flexibleBarSpace.width = 100;
        UIBarButtonItem *burdenBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Burden", nil) style:UIBarButtonItemStylePlain target: self action: @selector(barItemClicked:)];
        burdenBarButtonItem.tag = BAR_BUTTON_TAG_BURDEN;
        
        self.toolbarItems = @[burdenBarButtonItem,flexibleBarSpace,privacyBarButtonItem];
    }
    
    
    id topLayoutGuide = self.topLayoutGuide;
    id botLayoutGuide = self.bottomLayoutGuide;
    
    NSDictionary *metrics = @{@"buttonWidth": @(IS_IPAD?160:120)};
    
    
    // Logo
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide]-[title]-[logoButton]-[_bodyTextBox]-[NLMButton]-[OMBNumber]-[footerLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(topLayoutGuide, title, logoButton, _bodyTextBox, NLMButton, OMBNumber, footerLabel)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    // Buttons
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[NLMButton(buttonWidth)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(NLMButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:NLMButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[NIHButton(NLMButton)]-[NLMButton]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(NLMButton, NIHButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[NLMButton]-[HHSButton(NLMButton)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(HHSButton, NLMButton)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:HHSButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:NLMButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:NIHButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:NLMButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:NLMButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:NLMButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:HHSButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:HHSButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:NIHButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:NIHButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    // Body
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_bodyTextBox]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_bodyTextBox)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bodyText attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:OMBNumber attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    // Footers
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:footerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[footerLabel]-[botLayoutGuide]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(footerLabel, botLayoutGuide)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[footerLabel]-(30)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(footerLabel)]];
    
    // Version
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[version]-(5)-[botLayoutGuide]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(version, botLayoutGuide)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[version]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(version)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (TAKING_SCREEN_SHOT) {
        [self.navigationController setNavigationBarHidden:YES];
        return;
    }
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return TAKING_SCREEN_SHOT;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (!(IS_IPAD)) {
        [UIView animateWithDuration:duration animations:^{
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
                [_bodyText setAlpha:0];
            } else {
                [_bodyText setAlpha:1];
            }
        }];
    }
   
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!(IS_IPAD)) {
        [_bodyText setAlpha:UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation]?1:0)];
    }
}

#pragma mark - User Interaction
#pragma mark Navbar
- (void)contactUsTapped{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailComposer  = [[MFMailComposeViewController alloc] init];
        
        mailComposer.mailComposeDelegate = self;
        [mailComposer setModalPresentationStyle:UIModalPresentationFormSheet];
        [mailComposer setSubject:[NSString stringWithFormat:NSLocalizedString(@"%@ Support", nil), [CommonFunctions appName]]];
        [mailComposer setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Support", nil), [CommonFunctions appName]]];
        [mailComposer setToRecipients:@[@"lpfsupport@mail.nih.gov"]];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
    }else{
        UIAlertView *noMailAccountAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"E-mail account required", nil) message:NSLocalizedString(@"Please set up your email account on the device before proceeding.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil];
        [noMailAccountAlert show];
    }
}

#pragma mark ToolBar
- (void)barItemClicked:(UIButton *)sender
{
    SplashSubScreenViewControlleriPhone *splash = [[SplashSubScreenViewControlleriPhone alloc] initWithAgreeButton:NO isFirstScreen:NO scrollsToPrivacy:sender.tag == BAR_BUTTON_TAG_PRIVACY delegate:nil];
    [self.navigationController pushViewController:splash animated:YES];
}

#pragma mark Buttons
- (void)iconButtonClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case LPF_BUTTON_TAG:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://lpf.nlm.nih.gov/"]];
            break;
        case NLM_BUTTON_TAG:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.nlm.nih.gov/"]];
            break;
        case NIH_BUTTON_TAG:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.nih.gov/"]];
            break;
        case HHS_BUTTON_TAG:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hhs.gov/"]];
            break;
        default:
            break;
    }
}

- (void)logoTapped
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://lpf.nlm.nih.gov/"]];
}

#pragma mark - Delegate
#pragma mark MFMailComposeViewController Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if(error){
        DLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    }else if (result == MFMailComposeResultSent){
        UIAlertView *sentComplete = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email Sent", nil)  message:NSLocalizedString(@"Thank you for contacting us.", nil)delegate:nil cancelButtonTitle:NSLocalizedString(@"Done", nil) otherButtonTitles: nil];
        [sentComplete show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];

    return;
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

@end
