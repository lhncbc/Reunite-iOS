//
//  FindViewController.m
//  ReUnite + TriagePic
//


#import "FindViewController.h"
#define HEIGHT_TABLE_VIEW_CELL 100
#define DEFAULT_CELL_QUEUE @"cell"

@interface FindViewController ()

@end

@implementation FindViewController
{
    // result array
    NSMutableArray *_resultArray;
    
    // number of result found
    int _numberOfResult;
    BOOL _readyForUpdate;
    BOOL _isLoadingNextBatch;
    BOOL _isCurrentlyLoading;
    // keep context of the current term
    NSString *_currentSearchTerm;
    
    // blur view during search
    //BTBlurredView *_touchSensitiveBlurredView;
    
    //filter
    FilterViewController *_filterController;
    
    // loading cell
    UITableViewCell *_loadingCell;
    
    // Detail
    DetailController *_detailController;
    
    // Swipe transition pending for download more result
    NSIndexPath *_pendingIndexPathTransition;
    
    // For iPad
    UIPopoverController *_filterPopOver;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _currentSearchTerm = @"";
        _pendingIndexPathTransition = nil;
        _isLoadingNextBatch = NO;
        _isCurrentlyLoading = NO;
    }
    return self;
}

- (void)viewDidLoad
{
  
    [super viewDidLoad];
    
    
    [self setTitle:NSLocalizedString(@"Find", @"Find a person button or title")];
    [self setClearsSelectionOnViewWillAppear:NO];

    
    UIBarButtonItem *tmpButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action: @selector(backAction)];

    self.navigationItem.leftBarButtonItem = tmpButtonItem;
    // Bar button
    UIBarButtonItem *filterBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action: @selector(filterTapped)];
    
    UIBarButtonItem *shakeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SearchCamera"] style:UIBarButtonItemStylePlain target:self action: @selector(openFaceSearch)];
    
    [self.navigationItem setRightBarButtonItems:@[filterBarButtonItem,shakeBarButtonItem]];

   
    if (IS_IPAD) {
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action: @selector(backTapped)];
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    }
 
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar setDelegate:self];
    [searchBar sizeToFit];
    [searchBar setText:@""];
    // allows to search blanks
//    [self findTextFieldsInSubviewHierarchyOfView:searchBar andExecuteBlock:^(UITextField *textField) {
//        [textField setEnablesReturnKeyAutomatically:NO];
//        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
//    }];
    self.tableView.tableHeaderView = searchBar;
    
    //tableview set up
    [self.tableView registerClass:[PersonTableViewCell class] forCellReuseIdentifier:DEFAULT_CELL_QUEUE];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    //[self.refreshControl setBackgroundColor:[UIColor colorWithRed:.5 green:.5 blue:.6 alpha:.7]];
    [self.refreshControl addTarget:self action:@selector(updateTable) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:self.view.tintColor];
    [self.refreshControl setAlpha:0.5];
    [self.refreshControl sizeToFit];
    
    
    // down ward swipe gesture
    UIView *bgView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    [bgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.tableView insertSubview:bgView atIndex:0];

    UIImageView *swipeDownImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"swipe down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [swipeDownImageView setTintColor:[UIColor lightGrayColor]];
    [swipeDownImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [swipeDownImageView setAlpha:.5];
    [bgView addSubview:swipeDownImageView];
    
    UILabel *pullToRefreshLabel = [[UILabel alloc] init];
    [pullToRefreshLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [pullToRefreshLabel setText:NSLocalizedString(@"Pull To Refresh/Search", nil)];
    [pullToRefreshLabel setFont:[CommonFunctions normalFont]];
    [pullToRefreshLabel setTextColor:[UIColor lightGrayColor]];
    [bgView addSubview:pullToRefreshLabel];
    
    [bgView addConstraint:[NSLayoutConstraint constraintWithItem:swipeDownImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bgView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [bgView addConstraint:[NSLayoutConstraint constraintWithItem:pullToRefreshLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bgView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(80)-[swipeDownImageView]-[pullToRefreshLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(swipeDownImageView, pullToRefreshLabel)]];
    
    // filter guide
    UIImageView *filterGuideView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [filterGuideView setTintColor:[UIColor lightGrayColor]];
    [filterGuideView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [filterGuideView setAlpha:.5];
    [bgView addSubview:filterGuideView];
    
    UILabel *filterGuideLabel = [[UILabel alloc] init];
    [filterGuideLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [filterGuideLabel setText:NSLocalizedString(@"Adjust Filters", nil)];
    [filterGuideLabel setFont:[CommonFunctions fontSmallDeviceSpecific:YES]];
    [filterGuideLabel setTextColor:[UIColor lightGrayColor]];
    [bgView addSubview:filterGuideLabel];
    
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[filterGuideView]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(filterGuideView, filterGuideLabel)]];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[filterGuideLabel]-(10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(filterGuideView, filterGuideLabel)]];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[filterGuideView][filterGuideLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(filterGuideView, filterGuideLabel)]];

   // [self.tableView setContentOffset:CGPointMake(0, 44)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    

    if ([[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_FIND_NEEDS_REFRESH]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:GLOBAL_KEY_FIND_NEEDS_REFRESH];
        [self updateTable];
    }
}
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Testing Face Match
- (void)openFaceSearch
{
    [FaceMatchHandlerObject openCameraWithDelegate:self];
}

#pragma mark - Testing Shake

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self openFaceSearch];
    }
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark - User Interaction
#pragma mark Searchbar Appearance Alteration
- (void)findTextFieldsInSubviewHierarchyOfView:(UIView *)rootView andExecuteBlock:(void (^)(UITextField *))block {
    BOOL found = NO;
    for (UIView *view in [rootView subviews]) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *searchBarTextField = (UITextField *)view;
            found = YES;
            block(searchBarTextField);
        }
    }
    if (!found) {
        for (UIView *view in [rootView subviews]) {
            [self findTextFieldsInSubviewHierarchyOfView:view andExecuteBlock:block];
        }
    }
}

#pragma mark Bar Button

- (void)filterTapped
{
    if (!_filterController) {
        NSArray *itemArray = [FilterViewController filterItemArray];
        _filterController = [[FilterViewController alloc] initWithStyle:UITableViewStyleGrouped itemArray:itemArray selectionArray:nil];
        [_filterController setTitle:NSLocalizedString(@"Search Filter", nil)];
        [_filterController setDelegate:self];
    }
    [_filterController.tableView setContentOffset:CGPointZero];
    
    if (IS_IPAD) {
        if (!_filterPopOver) {
            _filterPopOver = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:_filterController]];
        }
        [_filterPopOver presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self.navigationController pushViewController:_filterController animated:YES];
    }
}

- (void)backTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SPLIT_VIEW_BACK_NOTIFICATION object:nil];
}

#pragma mark - Update
- (void)updateTable
{
    [self showLoading:YES string:NSLocalizedString(@"Loading...", nil)];
    PLsearchRequestType *request=[FilterViewController requestFromUserDefualt];
   // [request setQuery:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_EXACT_STRING]?[NSString stringWithFormat:@"*%@*",_currentSearchTerm]:_currentSearchTerm];
    NSString *searchTerm=[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_EXACT_STRING]?[NSString stringWithFormat:@"*%@*",_currentSearchTerm]:_currentSearchTerm;
    [[NSUserDefaults standardUserDefaults] setValue:searchTerm forKey:@"searchTerm"];

    [_resultArray removeAllObjects];
    request.filters =[FilterViewController filterJsonString];
 
    _numberOfResult = 0;
    _readyForUpdate = NO;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
 //NSString * encodedString=[CommonFunctions escapeForXML:request.filters];
    //NSLog(@"%@encodedStringencodedString",encodedString);
    [self updateTableWithRequest:request];
}

- (void)updateTableWithRequest:(PLsearchRequestType *)request
{
    [WSCommon searchCountWithSearchRequestType:request delegate:self];
    [WSCommon searchWithSearchRequestType:request delegate:self];
}

- (void)loadMoreCell
{
    if (_isCurrentlyLoading) {
        return;
    }
    _isCurrentlyLoading = YES;
    PLsearchRequestType *request = [FilterViewController requestFromUserDefualt];
    //[request setQuery:_currentSearchTerm];
    
    request.filters =[FilterViewController filterJsonString];
//   // [request setPageStart:(int)_resultArray.count];
    _readyForUpdate = NO;
    [self updateTableWithRequest:request];
}

- (void)reloadCellsWhenPossible
{
    if (_readyForUpdate) {
        [self showLoading:NO string:nil];
        
        // Remove all the small images from the cache so that everything is made sure to be fresh
        [[ImageObject peopleRecordImageSmallDictFind] removeAllObjects];
        
        [self setTitle:[NSString stringWithFormat:NSLocalizedString(@"%i Results Found", nil),_numberOfResult]];
        if (_isLoadingNextBatch) {
            _isLoadingNextBatch = NO;
            NSIndexPath *ipath = [self.tableView indexPathForSelectedRow];
            [self.tableView reloadData];
            [self.tableView selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if (_pendingIndexPathTransition) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_pendingIndexPathTransition.row inSection:_pendingIndexPathTransition.section] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            [_detailController fillWithPersonObject:_resultArray[_pendingIndexPathTransition.row] tableViewAnimation:UITableViewRowAnimationLeft];
            [_detailController setTitle:[NSString stringWithFormat:NSLocalizedString(@"Detail #%li", nil),(long)_pendingIndexPathTransition.row + 1]];
            _pendingIndexPathTransition = nil;
        }
    } else {
        _readyForUpdate = YES;
    }
    _isCurrentlyLoading = NO;
   // [self setTitle:[NSString stringWithFormat:NSLocalizedString(@"%i Results Found", nil),_numberOfResult]];

}

- (void)showLoading:(BOOL)show string:(NSString *)string
{
    if (show) {
        if (string) {
            //[SVProgressHUD showWithStatus:string maskType:SVProgressHUDMaskTypeBlack];
            
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD showWithStatus:string];

        } else {
            //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            //[SVProgressHUD show];
           [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading...", nil)];

        }
        //show activity
        /*if (!_fetchingActivityIndicator) {
            _fetchingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [_fetchingActivityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_fetchingActivityIndicator setColor:[UIColor blackColor]];
            [self.navigationController.view addSubview:_fetchingActivityIndicator];
            [_fetchingActivityIndicator setAlpha:0];
            
            _fetchingLabel = [[UILabel alloc] init];
            [_fetchingLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_fetchingLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
            [_fetchingLabel setText:NSLocalizedString(@"Loading...", @"text indicator while fetching data from server")];
            [self.navigationController.view addSubview:_fetchingLabel];
            [_fetchingLabel setAlpha:0];
            
            [self.navigationController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_fetchingLabel]-[_fetchingActivityIndicator]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_fetchingLabel, _fetchingActivityIndicator)]];
            [self.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_fetchingLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            [self.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_fetchingLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [self.navigationController.view addConstraint:[NSLayoutConstraint constraintWithItem:_fetchingActivityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_fetchingLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        }
        [UIView animateWithDuration:.3 animations:^{
            [_fetchingLabel setAlpha:1];
            [_fetchingActivityIndicator setAlpha:1];
        } completion:^(BOOL finished) {
            [_fetchingActivityIndicator startAnimating];
        }];
        [_fetchingActivityIndicator startAnimating];*/
    } else {
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
        /*[UIView animateWithDuration:.3 animations:^{
            [_fetchingLabel setAlpha:0];
            [_fetchingActivityIndicator setAlpha:0];
        } completion:^(BOOL finished) {
            [_fetchingActivityIndicator stopAnimating];
        }];*/
    }
}

#pragma mark - Datasouce
#pragma mark UITableViewCell
- (UITableViewCell *)tableView:(UITableView *)tableView  cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Display loading cell
    if (indexPath.row == _resultArray.count) {
        if (!_loadingCell) {
            _loadingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"none"];
            [_loadingCell.textLabel setText:NSLocalizedString(@"Loading...", nil)];
            UIActivityIndicatorView *spinningIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinningIndicator startAnimating];
            [_loadingCell setAccessoryView:spinningIndicator];
        }
        return _loadingCell;
    }
    
    
    //return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_CELL_QUEUE forIndexPath:indexPath];
    [cell fillWithPersonObject:_resultArray[indexPath.row]];
    [cell.personRankLabel setText:@(indexPath.row+1).stringValue];
    
    
    
    if (!_isLoadingNextBatch) {
        if (indexPath.row >= _resultArray.count - 1) {
            if (_resultArray.count < _numberOfResult) {
                _isLoadingNextBatch = YES;
                [self loadMoreCell];
            }
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // if there is more to load, then add loading cells
    return _resultArray.count + (_resultArray.count < _numberOfResult ? 1:0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
#pragma mark - Delegate

#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _resultArray.count) {
        return;
    }
    
    if (!_detailController) {
        _detailController = [[DetailController alloc] initWithPersonObject:_resultArray[indexPath.row]];
        [_detailController setDetailDelegate:self];
    } else {
        [_detailController fillWithPersonObject:_resultArray[indexPath.row] tableViewAnimation:UITableViewRowAnimationFade];
    }
    [_detailController setTitle:[NSString stringWithFormat:NSLocalizedString(@"Detail #%li", nil),(long)indexPath.row + 1]];
    
    if (IS_IPAD) {
        NSDictionary *actionDict = @{SPLIT_KEY_ACTION_TYPE: @(ActionTypePushIfNotExist), SPLIT_KEY_ANIMATE: @YES, SPLIT_KEY_VIEW_CONTROLLER:_detailController};
        [[NSNotificationCenter defaultCenter] postNotificationName:SPLIT_VIEW_ACTION_DETAIL object:actionDict];
    } else {
        self.navigationItem.hidesBackButton = NO;

        [self.navigationController pushViewController:_detailController animated:YES];
    }
}

#pragma mark UISearchBar
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _currentSearchTerm = searchBar.text;
    [searchBar setShowsCancelButton:YES animated:YES];
    
    /*if (!_touchSensitiveBlurredView) {
        _touchSensitiveBlurredView = [[BTBlurredView alloc] initWithFrame:CGRectMake(0, self.tableView.contentInset.top + self.tableView.tableHeaderView.frame.size.height, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
        [_touchSensitiveBlurredView setBackgroundView:self.navigationController.view];
        [self.navigationController.view addSubview:_touchSensitiveBlurredView];
    }
    [_touchSensitiveBlurredView setFrame:CGRectMake(0, self.tableView.contentInset.top + self.tableView.tableHeaderView.frame.size.height, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    [_touchSensitiveBlurredView refreshBackground];
    [_touchSensitiveBlurredView setAlpha:0];
    [_touchSensitiveBlurredView setUserInteractionEnabled:YES];
    [UIView animateWithDuration:.3 animations:^{
        [_touchSensitiveBlurredView setAlpha:1];
    }];
    
    //turn off scrolling for the moment
    [self.tableView setScrollEnabled:NO];*/
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
   // [searchBar setText:_currentSearchTerm];
    _currentSearchTerm=nil;
    [searchBar resignFirstResponder];
    [searchBar setText:nil];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self updateTable];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _currentSearchTerm = searchBar.text;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [self updateTable];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    /*[_touchSensitiveBlurredView setUserInteractionEnabled:NO];
    [self.tableView setScrollEnabled:YES];
    [UIView animateWithDuration:.3 animations:^{
        [_touchSensitiveBlurredView setAlpha:0];
    }];*/
}


#pragma mark PersonObject
- (void)didFinishedDownloadImagesForPersonObject:(id)personObject{
    NSString *uuid = ((PersonObject *)personObject).uuid;
    int place = 0;
    for (PersonObject *personObjectFromArray in _resultArray){
        //serach through all recrod for the uuid and reload that cell
        if ([personObjectFromArray.uuid isEqualToString:uuid]){
            dispatch_async(dispatch_get_main_queue(), ^{
                PersonTableViewCell *cell = (PersonTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:place inSection:0]];
                if (cell && [cell isKindOfClass:[PersonTableViewCell class]]){
                    cell.personImageView.image = personObjectFromArray.smallDisplayImage;
                    [cell.activityIndicatorView stopAnimating];
                    
                    // in case the cell has already been selected, then the images loaded
                     if (cell.isSelected){
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [_detailController fillWithPersonObject:personObject tableViewAnimation:UITableViewRowAnimationFade];
                         });
                    }
                }
            });
            break;
        }
        place++;
    }
}

#pragma mark BTFilterController
- (void)filterController:(BTFilterController *)filterController didFinishSelectionArray:(NSMutableArray *)selectionArray hasChangedSelection:(BOOL)hasChangedSelection
{
    if (hasChangedSelection) {
        [FilterViewController saveSettingIntoUserDefualt:selectionArray];
        [self updateTable];
    }
}

#pragma mark WSCommon
- (void)wsGetSearchResultWithSuccess:(BOOL)success resultArray:(NSArray *)resultArray error:(id)error
{
    if (!success) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to Obtain Records", nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
        [errorAlert show];
        
        [self showLoading:NO string:nil];
        return;
    }
    
    NSMutableArray *personObjectArray = [NSMutableArray array];
    NSString *eventFullName = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT];
 // NSArray*resultArray1 = [resultArray valueForKey:@"results"];

  //  resultArray=resultArray1;
    for (NSDictionary *personDict in resultArray) {
        
        PersonObject *personObject = [[PersonObject alloc] initWithPersonDictionary:personDict type:PERSON_TYPE_FIND event:eventFullName backgroundDownload:YES delegate:self];
        [personObjectArray addObject:personObject];
    }
    
    if (_resultArray.count > 0) {
        [_resultArray addObjectsFromArray:personObjectArray];
    } else {
        _resultArray = personObjectArray;
    }
    
    [self reloadCellsWhenPossible];
}

- (void)wsGetSearchCountResultWithSuccess:(BOOL)success count:(int)count error:(id)error
{
    if (success) {
        _numberOfResult = count;
    } else {
        _numberOfResult = 0;
    }
    [self reloadCellsWhenPossible];
}

#pragma mark DetailControllerDelegate
- (void)didSwiped:(UISwipeGestureRecognizer *)gesture
{
    NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        // go to next
        long newRow = selectedIndex.row + 1;
        //NSLog(@"%li",newRow);
        if (newRow < _numberOfResult) {
            if (_resultArray.count == newRow) {
                // The result has yet to be loaded, load it
                _pendingIndexPathTransition = [NSIndexPath indexPathForRow:newRow inSection:selectedIndex.section];
                [self loadMoreCell];
                return;
            }
            
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:newRow inSection:selectedIndex.section] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            [_detailController fillWithPersonObject:_resultArray[newRow] tableViewAnimation:UITableViewRowAnimationLeft];
            [_detailController setTitle:[NSString stringWithFormat:NSLocalizedString(@"Detail #%li", nil),(long)newRow + 1]];
        }
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        long newRow = selectedIndex.row - 1;
        if (newRow >= 0) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:newRow inSection:selectedIndex.section] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            [_detailController fillWithPersonObject:_resultArray[newRow] tableViewAnimation:UITableViewRowAnimationRight];
            [_detailController setTitle:[NSString stringWithFormat:NSLocalizedString(@"Detail #%li", nil),(long)newRow + 1]];
        }
    }
}

#pragma mark FaceMatchHandlerObject
- (void)haveFaceImageEncodedString:(NSString *)string
{
    [self showLoading:YES string:NSLocalizedString(@"Loading...", nil)];
    PLsearchRequestType *request = [FilterViewController requestFromUserDefualt];
    //[request setQuery:@""];
    [request setPhoto:string];
    [[NSUserDefaults standardUserDefaults] setValue:string forKey:@"Person"];

    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setBool:YES forKey:@"AuON"];
    
    //NSLog(@"%@stringstringstringstringstringstringstringstringstring",string);
    //[request setPageStart:0];
   // [request setSortBy:@"similarity desc"];
    [_resultArray removeAllObjects];
    _numberOfResult = 0;
    _readyForUpdate = NO;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self updateTableWithRequest:request];
}


@end
