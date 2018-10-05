//
//  DetailController.m
//  ReUnite + TriagePic
//


#import "DetailController.h"
#import "SVProgressHUD.h"

#define CUSTOM_VIEW_LABEL_IMAGE @"ImageRow"
#define CUSTOM_VIEW_LABEL_MAP @"MapRow"
#define CUSTOM_VIEW_LABEL_COMMENT @"CommentRow"

#define ALERT_TAG_DELETE_FROM_DEVICE 66
#define ALERT_TAG_DELETE_FROM_SERVER 67
#define ALERT_TAG_REPORT 68
#define ALERT_TAG_PERMISSION 69
#define ALERT_DELETE_SUCCESS 70

#define ACTION_TAG_MAP 75

@interface DetailController ()

@end

@implementation DetailController
{
    //main object
    PersonObject *_personObject;
    
    //Images
    UITableViewCell *_imageCell;
    ImageDisplayRowView *_imageDisplayRowView;
    
    //Maps
    UITableViewCell *_mapCell;
    MKMapView *_mapView;
    MKPointAnnotation *_mapAnnotation;
    
    //Comments
    NSMutableArray *_commenCellsArray;
    CommentInputController *_commentInputController;
    
    //Others
    UIActionSheet *_optionsActionSheet;
    UIBarButtonItem *shareBarButtonItem;
}

- (id)initWithPersonObject:(PersonObject *)personObject
{
    NSMutableArray *sectionArray = [DetailController personBTFilterArrayFromPersonObject:personObject];
    self = [super initWithStyle:UITableViewStylePlain itemArray:sectionArray selectionArray:nil];
    if (self) {
        self.delegate = self;
        
        _personObject = personObject;
        
        //status color
        if (IS_TRIAGEPIC) {
            UIColor *zoneColor = [PersonObject colorForZone:_personObject.zone];
            zoneColor = [CommonFunctions addLight:.96 ToColor:zoneColor];
            [self.tableView setBackgroundColor:zoneColor];
        } else {
            UIColor *statusColor = [PersonObject colorForStatus:_personObject.status];
            statusColor = [CommonFunctions addLight:.96 ToColor:statusColor];
            [self.tableView setBackgroundColor:statusColor];
        }
       
        
        [self loadMapCell];
        [self loadImageCell];
       

        if (personObject.location.hasAddress) {
            if (!personObject.location.hasGPS) {
                [self getAndDisplayGPS];
            }
        }
        
        _commenCellsArray = [NSMutableArray array];
        for (CommentObject *commentObject in _personObject.commentObjectArray) {
            CGFloat height = [CommentDisplayRowView estimateHeightForCommentObject:commentObject width:[UIScreen mainScreen].bounds.size.width];
            [self loadAndAddCommentCell:commentObject height:height];
        }
    }
    return self;
}

- (void)fillWithPersonObject:(PersonObject *)personObject tableViewAnimation:(UITableViewRowAnimation)tableViewAnimation
{
    _optionsActionSheet = nil;
    _personObject = personObject;

    
    [_commenCellsArray removeAllObjects];
    for (CommentObject *commentObject in _personObject.commentObjectArray) {
        CGFloat height = [CommentDisplayRowView estimateHeightForCommentObject:commentObject width:[UIScreen mainScreen].bounds.size.width];
        [self loadAndAddCommentCell:commentObject height:height];
    }
    
    
    // This has to create a new cell for both since tableview animation hides it... No idea why but this works for now...
    [self loadMapCell];
    [self loadImageCell];
    // End note
    
    NSMutableArray *itemArray = [DetailController personBTFilterArrayFromPersonObject:personObject];
    [self setItemArray:itemArray selectionArray:nil withRowAnimation:tableViewAnimation];
    
    //status color
    if (IS_TRIAGEPIC) {
        UIColor *zoneColor = [PersonObject colorForZone:_personObject.zone];
        zoneColor = [CommonFunctions addLight:.96 ToColor:zoneColor];
        [self.tableView setBackgroundColor:zoneColor];
    } else {
        UIColor *statusColor = [PersonObject colorForStatus:_personObject.status];
        statusColor = [CommonFunctions addLight:.96 ToColor:statusColor];
        [self.tableView setBackgroundColor:statusColor];
    }
    
    if (personObject.location.hasAddress) {
        if (!personObject.location.hasGPS) {
            [self getAndDisplayGPS];
        }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setTitle:@"Detail"];
    
    UIBarButtonItem *actionBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(actionTapped)];
    //[self.navigationItem setRightBarButtonItem:actionBarButtonItem];
    
    
    UIBarButtonItem *tmpButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action: @selector(backAction)];
    
    self.navigationItem.leftBarButtonItem = tmpButtonItem;
    

   shareBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped)];
    [self.navigationItem setRightBarButtonItems:@[actionBarButtonItem]];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwiped:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwiped:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeLeft];
    
    if (IS_IPAD) {
        [self.navigationItem setHidesBackButton:YES animated:NO];
    }
}
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
/*
- (void)viewDidAppear:(BOOL)animated
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self getAndDisplayGPS];
    });
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (NSMutableArray *)personBTFilterArrayFromPersonObject:(PersonObject *)personObject
{
    NSMutableArray *array = [NSMutableArray array];
    if (!personObject) {
        return array;
    }
    
    NSString *displayAge;
    NSAttributedString *displayEventAttStr;
    NSAttributedString *displayAddressAttStr;
    NSAttributedString *displayGettingGPSAttStr;
    NSAttributedString *displayNoteAttStr;
    NSAttributedString *displayNoCommentStr;

    // **** DATA PREP ****
    if (IS_TRIAGEPIC) {
        if ([personObject.ageMax integerValue] <= 17){
            displayAge = @"Pediatric";
        } else {
            displayAge = @"Adult";
        }
        
    } else {
        if ([[NSString stringWithFormat:@"%@",personObject.ageMin] isEqualToString:@""]){
            displayAge = @"??";
        
        }else{
            displayAge = [NSString stringWithFormat:@"%@", personObject.ageMin];
        }
        
    }
    
    displayEventAttStr = [[NSAttributedString alloc] initWithString:personObject.event attributes:@{NSFontAttributeName:[CommonFunctions normalFont]}];

    if (personObject.location.hasAddress) {
        displayAddressAttStr = [[NSAttributedString alloc] initWithString:personObject.location.getLocationString attributes:@{NSFontAttributeName:[CommonFunctions normalFont]}];
    } else {
        displayAddressAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No Location Included", nil)  attributes:@{NSFontAttributeName:[CommonFunctions normalFont], NSForegroundColorAttributeName:[UIColor grayColor]}];
    }
    displayGettingGPSAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Obtaining GPS Coordinates...", nil) attributes:@{NSFontAttributeName:[CommonFunctions normalFont], NSForegroundColorAttributeName:[UIColor grayColor]}];
    
    if (personObject.additionalDetail && ![personObject.additionalDetail isEqualToString:@""] && ![personObject.additionalDetail isKindOfClass:[NSNull class]]) {
        displayNoteAttStr = [[NSAttributedString alloc] initWithString:personObject.additionalDetail attributes:@{NSFontAttributeName:[CommonFunctions normalFont]}];
    } else {
        displayNoteAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No Note Included", nil)  attributes:@{NSFontAttributeName:[CommonFunctions normalFont], NSForegroundColorAttributeName:[UIColor grayColor]}];
    }
    
    displayNoCommentStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"No Comments Available", nil)  attributes:@{NSFontAttributeName:[CommonFunctions normalFont], NSForegroundColorAttributeName:[UIColor grayColor]}];
    
    
    // image
    NSDictionary *imageRowDict;
    if (personObject.imageObjectArray.count == 0) {
        /*NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:@"No image" attributes:@{NSForegroundColorAttributeName: [UIColor redColor], NSFontAttributeName: [UIFont italicSystemFontOfSize:17]}];
        imageRowDict = [BTFilterController rowDisplayTextWithAttributeString:attributeString];*/
        imageRowDict = [BTFilterController rowDeleteActionWithLabel:NSLocalizedString(@"No Image", nil) defualtValue:@"no image"];
    } else {
        imageRowDict = [BTFilterController rowCustomCellWithHeight:250 label:CUSTOM_VIEW_LABEL_IMAGE];
    }
    NSDictionary *imageSectionDict = [BTFilterController sectionWithRowArray:@[imageRowDict] header:nil footer:nil];

    
    // info
    NSDictionary *givenNameRowDict = [BTFilterController rowDisplayKeyValueWithKey:NSLocalizedString(@"KEY_GIVEN_NAME", nil) value:personObject.givenName];
    //NSDictionary *familyNameRowDict = [BTFilterController rowDisplayKeyValueWithKey:NSLocalizedString(@"KEY_FAMILY_NAME", nil) value:personObject.familyName];
    NSDictionary *genderRowDict = [BTFilterController rowDisplayKeyValueWithKey:NSLocalizedString(@"KEY_GENDER", nil)value:personObject.gender];
    NSDictionary *ageRowDict = [BTFilterController rowDisplayKeyValueWithKey:NSLocalizedString(@"KEY_AGE", nil)value:displayAge];
    NSDictionary *infoSectionDict;
    if (IS_TRIAGEPIC) {
        NSDictionary *zoneRowDict = [BTFilterController rowDisplayKeyValueWithKey:KEY_ZONE  value:personObject.zone];
        NSDictionary *hospitalName = [BTFilterController rowDisplayKeyValueWithKey:KEY_HOSPITAL_NAME value:personObject.hospitalName];
        NSDictionary *patientID = [BTFilterController rowDisplayKeyValueWithKey:KEY_PATIENT_ID value:personObject.patientId];
        infoSectionDict = [BTFilterController sectionWithRowArray:@[givenNameRowDict, genderRowDict, zoneRowDict, ageRowDict, hospitalName, patientID] header:@"INFORMATION" footer:nil];

    } else {
        NSDictionary *statusRowDict = statusRowDict = [BTFilterController rowDisplayKeyValueWithKey:NSLocalizedString(@"KEY_CONDITION", nil)value:personObject.status];
        infoSectionDict = [BTFilterController sectionWithRowArray:@[givenNameRowDict, genderRowDict, statusRowDict, ageRowDict] header:NSLocalizedString(@"INFORMATION", nil)  footer:nil];
    }


    // event
    NSDictionary *eventRowDict = [BTFilterController rowDisplayTextWithAttributeString:displayEventAttStr];
    NSDictionary *eventSectionDict = [BTFilterController sectionWithRowArray:@[eventRowDict] header: NSLocalizedString(@"EVENT", nil) footer:nil];

    
    // Location
    NSMutableArray *locationSectionArray = [NSMutableArray array];
    NSDictionary *addressRowDict = [BTFilterController rowDisplayTextWithAttributeString:displayAddressAttStr];
    [locationSectionArray addObject:addressRowDict];
    if (personObject.location.hasAddress) {
        if (personObject.location.hasGPS) {
            // add map and show the place
            NSDictionary *mapRowDict = [BTFilterController rowCustomCellWithHeight:200 label:CUSTOM_VIEW_LABEL_MAP];
            [locationSectionArray addObject:mapRowDict];
        } else {
            // don't add map until the reverse GEO is done
            NSDictionary *mapRowDict = [BTFilterController rowDisplayTextWithAttributeString:displayGettingGPSAttStr];
            [locationSectionArray addObject:mapRowDict];
        }
    }
    NSDictionary *locationSectionDict = [BTFilterController sectionWithRowArray:locationSectionArray header:NSLocalizedString(@"LOCATION", nil)  footer:nil];

    
    // Note
    NSDictionary *noteRowDict = [BTFilterController rowDisplayTextWithAttributeString:displayNoteAttStr];
    NSDictionary *noteSectionDict = [BTFilterController sectionWithRowArray:@[noteRowDict] header:NSLocalizedString(@"NOTE", nil) footer:nil];

    
    // Comment
    NSMutableArray *commentSectionArray = [NSMutableArray array];
    if (personObject.commentObjectArray.count < 1) {
        NSDictionary *noCommentRowDict = [BTFilterController rowDisplayTextWithAttributeString:displayNoCommentStr];
        [commentSectionArray addObject:noCommentRowDict];
    } else {
        for (CommentObject *commentObject in personObject.commentObjectArray) {
            CGFloat height = [CommentDisplayRowView estimateHeightForCommentObject:commentObject width:[UIScreen mainScreen].bounds.size.width];
            NSDictionary *commentRowDict = [BTFilterController rowCustomCellWithHeight:height label:CUSTOM_VIEW_LABEL_COMMENT];
            [commentSectionArray addObject:commentRowDict];
        }
    }
    NSDictionary *commentSectionDict = [BTFilterController sectionWithRowArray:commentSectionArray header:[NSString stringWithFormat:NSLocalizedString(@"COMMENT (%i)", nil), (int)personObject.commentObjectArray.count] footer:nil];

    return [@[imageSectionDict, infoSectionDict, eventSectionDict, locationSectionDict, noteSectionDict, commentSectionDict] mutableCopy];
}

/*- (void)getAndDisplayGPS
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *possibleLocationArray = [LocationObject getpossibleLocationFromString:[_personObject.location getLocationString]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([possibleLocationArray count]){ //if Google has suggestions
                LocationObject *tempLocationObject = ((LocationObject *)possibleLocationArray[0]);
                
                _personObject.location.gpsCoordinates = tempLocationObject.gpsCoordinates;
                _personObject.location.span =  tempLocationObject.span;

                NSDictionary *mapRowDict = [BTFilterController rowCustomCellWithHeight:200 label:@"MapRow"];
                [self removeRow:1 fromSection:3];
                [self addRowDict:mapRowDict toSection:3];
            } else {
                NSAttributedString *displayGettingGPSAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Unable to verify the address", nil) attributes:@{NSFontAttributeName:[CommonFunctions normalFont], NSForegroundColorAttributeName:[UIColor grayColor]}];
                NSDictionary *mapRowDict = [BTFilterController rowDisplayTextWithAttributeString:displayGettingGPSAttStr];
                [self removeRow:1 fromSection:3];
                [self addRowDict:mapRowDict toSection:3];
            }
        });
    });
}*/

- (void)getAndDisplayGPS
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *possibleLocationArray = [LocationObject getpossibleLocationFromString:[_personObject.location getLocationString]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([possibleLocationArray count]){ //if Google has suggestions
                LocationObject *tempLocationObject = ((LocationObject *)possibleLocationArray[0]);
                
                _personObject.location.gpsCoordinates = tempLocationObject.gpsCoordinates;
                _personObject.location.span =  tempLocationObject.span;
                
                
                NSDictionary *mapRowDict = [BTFilterController rowCustomCellWithHeight:200 label:@"MapRow"];
                [self removeRow:1 fromSection:3];
                [self addRowDict:mapRowDict toSection:3];
            } else {
                NSAttributedString *displayGettingGPSAttStr = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Unable to verify the address", nil) attributes:@{NSFontAttributeName:[CommonFunctions normalFont], NSForegroundColorAttributeName:[UIColor grayColor]}];
                NSDictionary *mapRowDict = [BTFilterController rowDisplayTextWithAttributeString:displayGettingGPSAttStr];
                [self removeRow:1 fromSection:3];
                [self addRowDict:mapRowDict toSection:3];
            }
        });
    });
}

#pragma mark - Preload Cells
- (void)loadMapCell
{
    _mapCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CUSTOM_VIEW_LABEL_MAP];
    [_mapCell setSelectionStyle:UITableViewCellSelectionStyleNone];

    _mapView = [[MKMapView alloc] init];
    [_mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mapCell.contentView addSubview:_mapView];

    [_mapCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mapView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_mapView)]];
    [_mapCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mapView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_mapView)]];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapLongPressed:)];
    [_mapView addGestureRecognizer:longPress];
}

- (void)loadImageCell
{
    _imageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CUSTOM_VIEW_LABEL_IMAGE];
    [_imageCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_imageCell setBackgroundColor:[UIColor clearColor]];
    
    _imageDisplayRowView = [[ImageDisplayRowView alloc] initWithImageObjectArray:_personObject.imageObjectArray editable:NO cellHeight:250];
    [_imageDisplayRowView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_imageDisplayRowView setDelegate:self];
    
    [_imageCell.contentView addSubview:_imageDisplayRowView];
    // add constraints
    [_imageCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageDisplayRowView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_imageDisplayRowView)]];
    [_imageCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageDisplayRowView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_imageDisplayRowView)]];
}

- (void)loadAndAddCommentCell:(CommentObject *)commentObject height:(CGFloat)height;
{
    UITableViewCell *commentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CUSTOM_VIEW_LABEL_COMMENT];
    
    CommentDisplayRowView *commentDisplayRowView = [[CommentDisplayRowView alloc] initWithCommentObject:commentObject size:CGSizeMake([UIScreen mainScreen].bounds.size.width, height)];
    [commentDisplayRowView setDelegate:self];
    [commentDisplayRowView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [commentCell.contentView addSubview:commentDisplayRowView];
    
    [commentCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[commentDisplayRowView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(commentDisplayRowView)]];
    [commentCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[commentDisplayRowView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(commentDisplayRowView)]];
    [commentCell setBackgroundColor:[UIColor clearColor]];

    [_commenCellsArray addObject:commentCell];
}

#pragma mark - User Interaction Handler
- (void)actionTapped
{
    int type = [PersonObject tagForType:_personObject.type];
    if (!_optionsActionSheet && _optionsActionSheet.tag != type) {
        switch (type) {
            case TAG_FIND:
                if (_personObject.canEdit) {
                   _optionsActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Options", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"View in Safari", nil), NSLocalizedString(@"Comment", nil), NSLocalizedString(@"Save", nil), NSLocalizedString(@"Save and Edit", nil),nil];//@"Follow Record"
                } else {
                    _optionsActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Options", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Report Abuse", nil) otherButtonTitles:NSLocalizedString(@"View in Safari", nil), NSLocalizedString(@"Comment", nil), NSLocalizedString(@"Save", nil), nil];
                }
                break;
            case TAG_SAVED:
                if (_personObject.canEdit) {
                    _optionsActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Options", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"View in Safari", nil), NSLocalizedString(@"Comment", nil), NSLocalizedString(@"Edit", nil), nil];
                } else {
                    _optionsActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Options", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"View in Safari", nil), NSLocalizedString(@"Comment", nil), NSLocalizedString(@"Report Abuse", nil), nil];
                }
                break;
            case TAG_OUTBOX:
                _optionsActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Options", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"Upload", nil), nil];
                break;
            case TAG_SENT:
                _optionsActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Options", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"View in Safari", nil), NSLocalizedString(@"Comment", nil), NSLocalizedString(@"Edit", nil),nil];//
                break;
            default:
                break;
        }
        [_optionsActionSheet setTag:type];

    }
    if ([_optionsActionSheet isVisible]) {
        [_optionsActionSheet dismissWithClickedButtonIndex:10 animated:YES];
    } else {
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        [_optionsActionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    }
}

- (void)shareTapped
{
    NSMutableArray *itemArray = [NSMutableArray array];
    [itemArray addObject:[NSString stringWithFormat:NSLocalizedString(@"Report from %@: %@ %@, %@", nil), [CommonFunctions appName], _personObject.givenName, _personObject.familyName, _personObject.status]];
    [itemArray addObject:[NSURL URLWithString:_personObject.webLink]];
    
    for (ImageObject *imageObject in _personObject.imageObjectArray) {
        [itemArray addObject:imageObject.image];
        break;
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemArray applicationActivities:nil];
    [activityViewController setExcludedActivityTypes:@[UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList]];
    
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
          //  DetailController *_detailCOntroller=[[DetailController alloc]init];
           // activityViewController.popoverPresentationController.sourceView = _detailCOntroller.view;
            activityViewController.popoverPresentationController.barButtonItem = shareBarButtonItem;

            
            [self presentViewController:activityViewController animated:YES completion:nil];
            

        }
        else
        {
            [self presentViewController:activityViewController animated:YES completion:nil];

        }

        
       

}
   // [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)mapLongPressed:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *mapTypeActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Map Type", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Standard", nil), NSLocalizedString(@"Satellite", nil), NSLocalizedString(@"Hybrid", nil), nil];
        [mapTypeActionSheet setTag:ACTION_TAG_MAP];
        [mapTypeActionSheet showFromRect:_mapView.frame inView:_mapView.superview animated:YES];
    }
}

- (void)didSwiped:(UISwipeGestureRecognizer *)sender
{
//#warning Removed for now because image cell is not loaded properly...
    
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didSwiped:)]) {
        [_detailDelegate didSwiped:sender];
    }
}

- (void)upload
{
    if ([CommonFunctions hasConnectivity]) {
       // [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading...", nil) maskType:SVProgressHUDMaskTypeBlack];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading...", nil)];
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [WSCommon reportPersonWithPersonObject:_personObject delegate:self];
            /*
            if (_personObject.uuid && ![_personObject.uuid isEqualToString:@""]) {
                [WSCommon rereportPersonWithPersonObject:_personObject delegate:self];
            } else {
                [WSCommon reportPersonWithPersonObject:_personObject delegate:self];
            }
             */
        });
        
    } else {
        [_personObject setType:PERSON_TYPE_OUTBOX];
        [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
        
        [self.navigationController popViewControllerAnimated:YES];
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Connection", nil) message:NSLocalizedString(@"The record has been saved in the outbox and will get uploaded to the server when the Internet connectivity has been restored", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil] show];
        if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(refreshRecordsForType:)]) {
            [_detailDelegate refreshRecordsForType:TAG_OUTBOX];
        }
    }
}

#pragma mark Edit
- (void)pushToEdit
{
    //[SVProgressHUD showWithStatus:NSLocalizedString(@"Fetching the latest record..", nil) maskType:SVProgressHUDMaskTypeBlack];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Fetching the latest record..", nil)];
    PLsearchRequestType *request = [FilterViewController requestForRefreshWithEvent:_personObject.event UUID:_personObject.uuid];
    [WSCommon searchWithSearchUuidRequestType:request delegate:self];
}

#pragma mark - Database
- (void)saveToDatabaseWithType:(NSString *)typeValue
{
    [self saveToDatabaseWithType:typeValue completionAction:nil];
}


- (void)saveToDatabaseWithType:(NSString *)typeValue completionAction:(dispatch_block_t)completion
{
    PersonObject *personObject = [_personObject copy];
    personObject.type = typeValue;
    [[PeopleDatabase database] addPersonWithPersonObject:personObject];
    if (self.detailDelegate && [self.detailDelegate respondsToSelector:@selector(didFinishSavingPerson)]){
        [self.detailDelegate didFinishSavingPerson];
    }
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), completion);
    }
}

#pragma mark - Datasource
#pragma mark UITableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *text = self.itemArray[section][KEY_1_HEADER];
    if (!text) {
        return nil;
    }
    HeaderView *headerView = [[HeaderView alloc] init];
    [headerView setText:text];
    return headerView;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *text = self.itemArray[section][KEY_1_HEADER];
    if (!text) {
        return 0;
    }
    return 26;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowDict = self.itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row];
    if ([rowDict[KEY_2_LABEL] isEqualToString:KEY_CONDITION]) {
        BTFilterCell *cell = (BTFilterCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell.cellValueLabel setTextColor:[PersonObject colorForStatus:rowDict[KEY_2X_DEFAULT]]];
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    } else if ([rowDict[KEY_2_LABEL] isEqualToString:KEY_ZONE]) {
        BTFilterCell *cell = (BTFilterCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell.cellValueLabel setTextColor:[PersonObject colorForZone:rowDict[KEY_2X_DEFAULT]]];
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    } else {
        BTFilterCell *cell = (BTFilterCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[BTFilterCell class]]) {
            [cell.cellValueLabel setTextColor:[UIColor blackColor]];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
}

#pragma mark - Delegate
#pragma mark BTFilterController
- (UITableViewCell *)filterController:(BTFilterController *)filterController cellForIndexPath:(NSIndexPath *)indexPath label:(NSString *)label height:(CGFloat)height
{
    if ([label isEqualToString:CUSTOM_VIEW_LABEL_IMAGE]) {
        return _imageCell;
    }
    
    if ([label isEqualToString:CUSTOM_VIEW_LABEL_MAP]) {
        _mapAnnotation = [[MKPointAnnotation alloc] init];
        [_mapAnnotation setTitle:_personObject.location.hasGPS?NSLocalizedString(@"GPS reported by the user", nil):NSLocalizedString(@"Possible GPS from the address", nil)];
        [_mapAnnotation setCoordinate:_personObject.location.gpsCoordinates];
        [_mapView addAnnotation:_mapAnnotation];
        
        [_mapView selectAnnotation:_mapAnnotation animated:NO];
        [_mapView setRegion:MKCoordinateRegionMake(_personObject.location.gpsCoordinates, _personObject.location.span) animated:YES];
        return _mapCell;
    }
    
    if ([label isEqualToString:CUSTOM_VIEW_LABEL_COMMENT]) {
        return _commenCellsArray[indexPath.row];
    }
    
    DLog(@"Might contain error at cellForIndexPath");

    return nil;
    
}

- (void)filterController:(BTFilterController *)filterController didSelectAtIndexPath:(NSIndexPath *)indexPath rowDict:(NSDictionary *)rowDict
{
    if (indexPath == [NSIndexPath indexPathForRow:0 inSection:3]) {
        [_mapView setRegion:MKCoordinateRegionMake(_personObject.location.gpsCoordinates, _personObject.location.span) animated:YES];
    }
}

#pragma mark ImageDisplayRowView
- (void)imageDisplayRowView:(ImageDisplayRowView *)displayView buttonNumberTapped:(int)buttonNumber
{
    if (_personObject.imageObjectArray.count > 0) {
        ImageObject *imageObject = _personObject.imageObjectArray[buttonNumber];
        
        NSString *imageLargeURL = [imageObject.imageURL stringByReplacingOccurrencesOfString:@"thumb" withString:@"full"];
        UIImage *image = [ImageObject peopleRecordImageDictFind][imageLargeURL];
        
        ImageViewer *imageViewer = [[ImageViewer alloc] initWithImage:image?image:imageObject.image];
        [imageViewer setTitle:[NSString stringWithFormat:NSLocalizedString(@"Image #%i", nil), buttonNumber + 1]];
        [self.navigationController pushViewController:imageViewer animated:YES];
        
        // While the that is happening, in the background, try to obtain the better quality image
        if (!image) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *imageLarge = [ImageObject getPLImagesFromURLExtension:imageLargeURL];
                if (!imageLarge) {
                    return; // no larger image found!!
                }
                [ImageObject peopleRecordImageDictFind][imageLargeURL] = imageLarge; //store image

                dispatch_async(dispatch_get_main_queue(), ^{
                    // send message back to the imageViewer to display the bigger version
                    [imageViewer setImage:imageLarge];
                });
            });
        }
    }
}

#pragma mark UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ACTION_TAG_MAP) {
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
        return;
    } else if (actionSheet.tag == TAG_FIND) {
        switch (buttonIndex) {
            case 0: // could be report abuse or delete
                if (_personObject.canEdit) { // Delete
                    UIAlertView *deleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete record", nil)  message:[NSString stringWithFormat:NSLocalizedString(@"You are about to delete this record from PL server", nil), IS_TRIAGEPIC? @"TriageTrak": @"People Locator"] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                    [deleteAlertView setTag:ALERT_TAG_DELETE_FROM_SERVER];
                    [deleteAlertView show];
                } else { // Report Abuse
                    UIAlertView *_reportAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Report Abuse", nil) message:NSLocalizedString(@"Please enter the reason", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Submit", nil), nil];
                    //UIAlertView *_reportAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Report Abuse", nil) message:NSLocalizedString(@"What would you like to Report", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"Spam",@"Sexually Explict",@"Hate Speech",@"Violence",@"Something Else", nil];
                    
                    [_reportAlert setTag:ALERT_TAG_REPORT];
                    [_reportAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [_reportAlert show];
                }
                break;
            case 1: // View on the Web
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_personObject.webLink]];
                break;
            case 2: // Comment
                if (!_commentInputController) {
                    _commentInputController = [[CommentInputController alloc] init];
                }
                [_commentInputController fillWithUUID:_personObject.uuid];
                [self.navigationController pushViewController:_commentInputController animated:YES];
                break;
            case 3: // Save
                [self saveToDatabaseWithType:PERSON_TYPE_SAVE completionAction:^{
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Saved", nil) message:NSLocalizedString(@"The record is added onto your device. To view, tap Report from the Home screen.", nil)delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil] show];
                }];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 4: // Save and Edit
                if (_personObject.canEdit) {
                    [self saveToDatabaseWithType:PERSON_TYPE_SAVE completionAction:^{
                        // this is a bit of a hack, so this will send home a message saying btw, u need to edit this. start popping and pushing!
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SAVE_AND_EDIT object:_personObject];
                    }];
                }
                break;
            case 5: // Cancel
                
               // NSLog(@"follow");
                //[WSCommon followRecord:_personObject.uuid sub:1 delegate:self];
                break;
            default:
                break;
        }
    } else if (actionSheet.tag == TAG_SAVED) {
        switch (buttonIndex) {
            case 0:{ // Delete
                UIAlertView *deleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete record", nil) message:NSLocalizedString(@"You are about to delete this record from PL server", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [deleteAlertView setTag:ALERT_TAG_DELETE_FROM_DEVICE];
                //[deleteAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [deleteAlertView show];
            }
                break;
            case 1: // View on the Web
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_personObject.webLink]];
                break;
            case 2: // Comment
                if (!_commentInputController) {
                    _commentInputController = [[CommentInputController alloc] init];
                }
                [_commentInputController fillWithUUID:_personObject.uuid];
                [self.navigationController pushViewController:_commentInputController animated:YES];
                break;
            case 3: // Edit or Report Abuse
                if (_personObject.canEdit) {
                    [self pushToEdit];
                } else {
                    UIAlertView *_reportAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Report Abuse", nil) message:NSLocalizedString(@"Please enter the reason", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Submit", nil), nil];
                    [_reportAlert setTag:ALERT_TAG_REPORT];
                    [_reportAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [_reportAlert show];
                }
                break;
                
            case 4: // Cancel
                break;
            default:
                break;
        }
    } if (actionSheet.tag == TAG_OUTBOX) {
        switch (buttonIndex) {
            case 0:{ // Delete
                UIAlertView *deleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete record", nil) message: NSLocalizedString(@"You are about to delete this record from your device", nil)delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [deleteAlertView setTag:ALERT_TAG_DELETE_FROM_DEVICE];
                //[deleteAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [deleteAlertView show];
            }
            case 1: // Upload
                [self upload];
                break;
            case 2: // Cancel
                break;
            default:
                break;
        }


    } else if (actionSheet.tag == TAG_SENT) {
        switch (buttonIndex) {
            case 0:{ // Delete
                UIAlertView *deleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete record", nil) message:NSLocalizedString(@"You are about to delete this record from your device", nil)delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
                [deleteAlertView setTag:ALERT_TAG_DELETE_FROM_DEVICE];
                //[deleteAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [deleteAlertView show];
            }
                break;
            case 2: // Comment
                if (!_commentInputController) {
                    _commentInputController = [[CommentInputController alloc] init];
                }
                [_commentInputController fillWithUUID:_personObject.uuid];
                [self.navigationController pushViewController:_commentInputController animated:YES];
                break;
            case 3: // Edit
                [self pushToEdit];
                break;
            case 1: // View on the Web
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_personObject.webLink]];
                break;
            /*case 4:{ // Report Abuse
                UIAlertView *_reportAlert = [[UIAlertView alloc] initWithTitle:@"Report Abuse" message:@"Please enter the reason" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
                [_reportAlert setTag:ALERT_TAG_REPORT];
                [_reportAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [_reportAlert show];
            }*/
                break;
            case 4: // Cancel
                break;
            default:
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
}

#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case ALERT_TAG_DELETE_FROM_SERVER:
            if (buttonIndex == 1) {
                // try to delete
                [WSCommon removeRecordFromServerWithPersonObject:_personObject reason:@""/*[alertView textFieldAtIndex:0].text*/ delegate:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteNotification" object:nil];

            }
            break;
        case ALERT_TAG_DELETE_FROM_DEVICE:
            if (buttonIndex == 1) {
                // try to delete
                if ([[PeopleDatabase database] deletePersonWithPersonID:_personObject.personID] && ([_personObject.type isEqualToString:PERSON_TYPE_SAVE] || [_personObject.type isEqualToString:PERSON_TYPE_SENT])) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Record removed", nil) message:[NSString stringWithFormat:NSLocalizedString(@"If you reported the person, you may delete it from the People Locator server.",nil)] delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:NSLocalizedString(@"Remove from server", nil), nil];
                    [alertView setTag:ALERT_TAG_DELETE_FROM_SERVER];
                    [alertView show];
                    [self.navigationController popViewControllerAnimated:YES];
                    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(refreshRecordsForType:)]) {
                        [_detailDelegate refreshRecordsForType:[PersonObject tagForType:_personObject.type]];
                    }
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                    [_detailDelegate refreshRecordsForType:[PersonObject tagForType:_personObject.type]];
                }
            }
            break;
        case ALERT_TAG_REPORT:
            if (buttonIndex == 1) {
                // submit the report
                [WSCommon reportAbuseWithUUID:_personObject.uuid reason:[alertView textFieldAtIndex:0].text delegate:self];
            }
            break;
        case ALERT_TAG_PERMISSION:
            if (buttonIndex == 1) {
                UIAlertView *_reportAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Report Abuse", nil) message: NSLocalizedString(@"Please enter the reason", nil)delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Submit", nil), nil];
                [_reportAlert setTag:ALERT_TAG_REPORT];
                [_reportAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [_reportAlert show];
            }
            break;
        case ALERT_DELETE_SUCCESS:
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GLOBAL_KEY_FIND_NEEDS_REFRESH];
                [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

#pragma mark CommentDisplayRowView
- (void)commentDisplayRowView:(CommentDisplayRowView *)displayView showImage:(UIImage *)image
{
    ImageViewer *imageViewer = [[ImageViewer alloc] initWithImage:image];
    [imageViewer setTitle:[NSString stringWithFormat:NSLocalizedString(@"Comment #%i Image", nil), displayView.commentObject.rank]];
    [self.navigationController pushViewController:imageViewer animated:YES];
}

#pragma mark WSCommon
- (void)wsRemoveRecordWithSuccess:(BOOL)success error:(id)error
{
    if (success) {
        //if (hasPermission) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Successfully Deleted", nil) message: NSLocalizedString(@"The record has been deleted", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
            [alert setTag:ALERT_DELETE_SUCCESS];
            [alert show];
        /*} else {
            UIAlertView *noPermissionAlert = [[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"Only the original owner can delete a record. Would you like the report abuse instead?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Report Abuse", nil];
            [noPermissionAlert setTag:ALERT_TAG_PERMISSION];
            [noPermissionAlert show];
        }*/
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable To Delete", nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil] show];
    }
}

- (void)wsReportAbuseWithSuccess:(BOOL)success error:(id)error
{
    if (success) {
        [self.navigationController popViewControllerAnimated:YES];
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Successfully Reported", nil) message: NSLocalizedString(@"Thank you for your report", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable To Delete", nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil] show];
    }
}
/*
- (void)wsfollowRecordWithSuccess:(BOOL)success error:(id)error
{
    if (success) {
        [[[UIAlertView alloc] initWithTitle:@"You are now following the Record" message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];

    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to follow" message:error delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
    }
}
*/

- (void)wsReportPersonWithSuccess:(BOOL)success uuid:(NSString *)uuid error:(id)error
{
    if (success) {
        // save it in sent
        [_personObject setType:PERSON_TYPE_SENT];
        [_personObject setUuid:uuid];
        [_personObject setWebLink:[NSString stringWithFormat:@"%@%@/edit?puuid=%@",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_HTTP],[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_NAME],uuid]];
        [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
        
        [self.navigationController popViewControllerAnimated:YES];
        if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(refreshRecordsForType:)]) {
            [_detailDelegate refreshRecordsForType:TAG_SENT];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to Upload", nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
        [alertView show];
    }
    
    [SVProgressHUD dismiss];
}
- (void)wsReReportPersonWithSuccess:(BOOL)success error:(id)error
{
    if (success) {
        // save it in sent
        [_personObject setType:PERSON_TYPE_SENT];
        [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
        
        
        [self.navigationController popViewControllerAnimated:YES];
        if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(refreshRecordsForType:)]) {
            [_detailDelegate refreshRecordsForType:TAG_SENT];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to Upload", nil)message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
        [alertView show];
    }
    [SVProgressHUD dismiss];
}

- (void)wsGetSearchResultWithSuccess:(BOOL)success resultArray:(NSArray *)resultArray error:(id)error
{
    if (success) {
        if (resultArray.count == 1) {
    
            // update the _personobject
        // NSArray*resultArray1 = [resultArray valueForKey:@"results"];
            PersonObject *personObject = [[PersonObject alloc] initWithPersonDictionary:resultArray[0] type:_personObject.type event:_personObject.event backgroundDownload:NO delegate:self];
            [personObject setPersonID:_personObject.personID]; // Transfer the ID
            _personObject = personObject;
            [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
        }
    }
    
    [SVProgressHUD dismiss];
    
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(editPersonObject:)]) {
        [self.navigationController setDelegate:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UINavigationController
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // check if the view controller it shows is the organizer
    // Or if it is the rootViewController of the Navigation stack in iPad case
    if ((viewController == (UIViewController *)_detailDelegate) || (viewController == navigationController.viewControllers[0])) {
        [navigationController setDelegate:nil];
        [_detailDelegate editPersonObject:_personObject];
    }
}
@end

@implementation HeaderView

- (id)init
{
    if (self = [super init]) {
        [self setFont:[UIFont boldSystemFontOfSize:14]];
        [self setFrame:CGRectMake(0, 0, 100, 26)];
        [self setBackgroundColor:[UIColor colorWithWhite:.9 alpha:.95]];

        UIView *topLine = [[UIView alloc] init];
        [topLine setTranslatesAutoresizingMaskIntoConstraints:NO];
        [topLine setBackgroundColor:[UIColor colorWithWhite:.2 alpha:.2]];
        [self addSubview:topLine];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topLine]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(topLine)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLine(1)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(topLine)]];
        
        /*UIView *botLine = [[UIView alloc] init];
        [botLine setTranslatesAutoresizingMaskIntoConstraints:NO];
        [botLine setBackgroundColor:[UIColor blackColor]];
        [self addSubview:botLine];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[botLine]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(botLine)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[botLine(1)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(botLine)]];*/
    }
    return self;
}

/*
- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 4.0;
    self.layer.borderWidth = 1;
    
    [super drawRect:rect];
}*/

- (void) drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {0,10,0,5};
    
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end
