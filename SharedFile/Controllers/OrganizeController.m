//
//  OrganizeController.m
//  ReUnite + TriagePic
//


#import "OrganizeController.h"
#define HEIGHT_TABLE_VIEW_CELL 100
#define DEFAULT_CELL_QUEUE @"cell"

@interface OrganizeController ()

@end

@implementation OrganizeController
{
    // keep context of the current term
    NSString *_currentSearchTerm;
    
    // result array
    NSMutableArray *_resultArray;
    
    // filter
    FilterViewController *_filterController;
    
    // Tab bar
    UITabBar *_tabBar;
    UITabBarItem *_savedTabBarItem;
    UITabBarItem *_draftTabBarItem;
    UITabBarItem *_outboxTabBarItem;
    UITabBarItem *_sentTabBarItem;
        
    // Detail
    DetailController *_detailController;
    ReportController *_reportController;
    
    // Async
    dispatch_queue_t _databaseQue;

    // For iPad
    UIPopoverController *_filterPopOver;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _databaseQue = dispatch_queue_create("databaseQ", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setTitle:NSLocalizedString(@"My Reports", @"Report a person button or title")];
    [self setTitle:NSLocalizedString(@"My Reports", nil)];
    [self setClearsSelectionOnViewWillAppear:NO];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"   " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
   
    // Bar button
//    UIBarButtonItem *filterBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action: @selector(filterTapped)];
//    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped)];
//    [self.navigationItem setRightBarButtonItems:@[addBarButtonItem, filterBarButtonItem]];
//    
   // UIBarButtonItem *filterBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action: @selector(filterTapped)];
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTapped)];
    [self.navigationItem setRightBarButtonItems:@[addBarButtonItem]];
    
    if (IS_IPAD) {
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action: @selector(backTapped)];
        [self.navigationItem setLeftBarButtonItem:backBarButtonItem];
    }
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar setDelegate:self];
    [searchBar sizeToFit];
    [searchBar setText:@""];
    // allows to search blanks
    [self findTextFieldsInSubviewHierarchyOfView:searchBar andExecuteBlock:^(UITextField *textField) {
        [textField setEnablesReturnKeyAutomatically:NO];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    }];
    self.tableView.tableHeaderView = searchBar;
    
    //tableview set up
    [self.tableView registerClass:[PersonTableViewCell class] forCellReuseIdentifier:DEFAULT_CELL_QUEUE];
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
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
    [pullToRefreshLabel setText:NSLocalizedString(@"Pull To Search", nil)];
    [pullToRefreshLabel setFont:[CommonFunctions normalFont]];
    [pullToRefreshLabel setTextColor:[UIColor lightGrayColor]];
    [bgView addSubview:pullToRefreshLabel];
    
    [bgView addConstraint:[NSLayoutConstraint constraintWithItem:swipeDownImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bgView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [bgView addConstraint:[NSLayoutConstraint constraintWithItem:pullToRefreshLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bgView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(110)-[swipeDownImageView]-[pullToRefreshLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(swipeDownImageView, pullToRefreshLabel)]];
    
    // filter guide
    UIImageView *filterGuideView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [filterGuideView setTintColor:[UIColor lightGrayColor]];
    [filterGuideView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [filterGuideView setAlpha:.5];
    [bgView addSubview:filterGuideView];
    
   
    UILabel *filterGuideLabel = [[UILabel alloc] init];
    [filterGuideLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    //[filterGuideLabel setText:NSLocalizedString(@"Adjust Filters", nil)];
    [filterGuideLabel setFont:[CommonFunctions fontSmallDeviceSpecific:YES]];
    [filterGuideLabel setTextColor:[UIColor lightGrayColor]];
    [bgView addSubview:filterGuideLabel];
    
    // filter guide
    UIImageView *addGuideView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [addGuideView setTintColor:[UIColor lightGrayColor]];
    [addGuideView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [addGuideView setAlpha:.5];
    [bgView addSubview:addGuideView];
    
    UILabel *addGuideLabel = [[UILabel alloc] init];
    [addGuideLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [addGuideLabel setText:NSLocalizedString(@"New Report", nil)];
    [addGuideLabel setFont:[CommonFunctions fontSmallDeviceSpecific:YES]];
    [addGuideLabel setTextColor:[UIColor lightGrayColor]];
    [bgView addSubview:addGuideLabel];
    
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[filterGuideView]-(50)-[addGuideView]-(5)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(filterGuideView, addGuideView)]];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[filterGuideLabel]-[addGuideLabel]-(10)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(filterGuideLabel, addGuideLabel)]];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(45)-[filterGuideView]-(-5)-[filterGuideLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(filterGuideView, filterGuideLabel)]];
    [bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[addGuideView][addGuideLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(addGuideView, addGuideLabel)]];
    
    _tabBar = [[UITabBar alloc] init];
    [_tabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    _savedTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Saved", nil) image:[UIImage imageNamed:@"saved"] selectedImage:[UIImage imageNamed:@"saved filled"]];
    [_savedTabBarItem setTag:TAG_SAVED];
    _draftTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Draft", nil) image:[UIImage imageNamed:@"draft"] selectedImage:[UIImage imageNamed:@"draft filled"]];
    [_draftTabBarItem setTag:TAG_DRAFT];
    _outboxTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Outbox", nil) image:[UIImage imageNamed:@"outbox"] selectedImage:[UIImage imageNamed:@"outbox filled"]];
    [_outboxTabBarItem setTag:TAG_OUTBOX];
    _sentTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Sent", nil) image:[UIImage imageNamed:@"sent"] selectedImage:[UIImage imageNamed:@"sent filled"]];
    [_sentTabBarItem setTag:TAG_SENT];
    [_tabBar setItems:@[_savedTabBarItem, _draftTabBarItem, _outboxTabBarItem, _sentTabBarItem]];
    [_tabBar setDelegate:self];
    [_tabBar setSelectedItem:_savedTabBarItem];
    
    // hides search bar
    [self.tableView setContentOffset:CGPointMake(0, 44)];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipedRight)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipedLeft)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeLeft];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.view addSubview:_tabBar];
    [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 49, 0)];
    [self.navigationController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tabBar]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_tabBar)]];
    [self.navigationController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tabBar]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_tabBar)]];
    
    [self reloadDataForCategory: (int)_tabBar.selectedItem.tag withRowAnimation:UITableViewRowAnimationAutomatic];
    [self reloadCount];
    
    // Add notification to refresh the record to sync up display with the background upload
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable) name:NOTIFICATION_UPDATE_TABLE object:nil];
    //[self reloadDataForCategory:(int)_tabBar.selectedItem.tag withRowAnimation:UITableViewRowAnimationNone];
  
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_tabBar removeFromSuperview];
    
    // Remove the refresh record notificaiton
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_TABLE object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DEFAULT_CELL_QUEUE forIndexPath:indexPath];
    [cell fillWithPersonObject:_resultArray[indexPath.row]];
    [cell.personRankLabel setText:@(indexPath.row+1).stringValue];
    return cell;
}

#pragma mark - User Interaction
#pragma mark Selection
- (void)editPersonObject:(PersonObject *)personObject
{
    if (!_reportController) {
        _reportController = [[ReportController alloc] initWithPersonObject:personObject];
        [_reportController setReportDelegate:self];
    } else {
        
        //_reportController=[[ReportController alloc]init];
        _reportController = [[ReportController alloc] initWithPersonObject:personObject];

        [_reportController fillWithPersonObject:personObject];
    }
    [_reportController setTitle:NSLocalizedString(@"Edit", nil)];
    
    if (IS_IPAD) {
        NSDictionary *actionDict = @{SPLIT_KEY_ACTION_TYPE: @(ActionTypePushIfNotExist), SPLIT_KEY_ANIMATE: @YES, SPLIT_KEY_VIEW_CONTROLLER:_reportController};
        [[NSNotificationCenter defaultCenter] postNotificationName:SPLIT_VIEW_ACTION_DETAIL object:actionDict];
    } else {
        if (self.navigationController.topViewController != _reportController) {

            [self.navigationController pushViewController:_reportController animated:YES];
            
        }
    }
}

- (void)viewPersonObject:(PersonObject *)personObject atIndexPath:(NSIndexPath *)indexPath;
{
    if (!_detailController) {
        _detailController = [[DetailController alloc] initWithPersonObject:personObject];
        [_detailController setDetailDelegate:self];
    } else {
        [_detailController fillWithPersonObject:personObject tableViewAnimation:UITableViewRowAnimationNone];
    }
    [_detailController setTitle:[NSString stringWithFormat:NSLocalizedString(@"Detail #%li", nil),(long)indexPath.row + 1]];
    
    if (IS_IPAD) {
        NSDictionary *actionDict = @{SPLIT_KEY_ACTION_TYPE: @(ActionTypePushIfNotExist), SPLIT_KEY_ANIMATE: @YES, SPLIT_KEY_VIEW_CONTROLLER:_detailController};
        [[NSNotificationCenter defaultCenter] postNotificationName:SPLIT_VIEW_ACTION_DETAIL object:actionDict];
    } else {
        if (self.navigationController.topViewController != _detailController) {
            [self.navigationController pushViewController:_detailController animated:YES];
        }
    }
}

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
        [_filterController setDisableEventSelection:YES];
    }
    [_filterController.tableView setContentOffset:CGPointZero];
    
    if (IS_IPAD) {
        if (!_filterPopOver) {
            _filterPopOver = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:_filterController]];
        }
        [_filterPopOver presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItems[1] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self.navigationController pushViewController:_filterController animated:YES];
    }
}
- (void)backTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SPLIT_VIEW_BACK_NOTIFICATION" object:nil];
}

- (void)addTapped
{
    if (!_reportController) {
        _reportController = [[ReportController alloc] initWithPersonObject:[PersonObject emptyPersonObject]];
        [_reportController setReportDelegate:self];
    } else {
      //  _reportController=[[ReportController alloc]init];
       // [_reportController fillWithPersonObject:[PersonObject emptyPersonObject]];
        
        _reportController = [[ReportController alloc] initWithPersonObject:[PersonObject emptyPersonObject]];
        [_reportController setReportDelegate:self];


    }
    
    [_reportController setTitle:NSLocalizedString(@"New Report", nil)];
    
    if (IS_IPAD) {
        NSDictionary *actionDict = @{SPLIT_KEY_ACTION_TYPE: @(ActionTypePopThenPush), SPLIT_KEY_ANIMATE: @YES, SPLIT_KEY_VIEW_CONTROLLER:_reportController};
        [[NSNotificationCenter defaultCenter] postNotificationName:SPLIT_VIEW_ACTION_DETAIL object:actionDict];
    } else {
        [self.navigationController pushViewController:_reportController animated:YES];
    }
}

#pragma mark - Swipes
- (void)didSwipedLeft
{
    UITabBarItem *item;
    
    if (_tabBar.selectedItem == _savedTabBarItem) {
        item = _draftTabBarItem;
    } else if (_tabBar.selectedItem == _draftTabBarItem) {
        item = _outboxTabBarItem;
    } else if (_tabBar.selectedItem == _outboxTabBarItem) {
        item = _sentTabBarItem;
    } else if (_tabBar.selectedItem == _sentTabBarItem) {
        item = _savedTabBarItem;
    }
    
    [_tabBar setSelectedItem:item];
    [self reloadDataForCategory:(int)_tabBar.selectedItem.tag withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)didSwipedRight
{
    UITabBarItem *item;
    
    if (_tabBar.selectedItem == _sentTabBarItem) {
        item = _outboxTabBarItem;
    } else if (_tabBar.selectedItem == _outboxTabBarItem) {
        item = _draftTabBarItem;
    } else if (_tabBar.selectedItem == _draftTabBarItem) {
        item = _savedTabBarItem;
    } else if (_tabBar.selectedItem == _savedTabBarItem) {
        item = _sentTabBarItem;
    }
    
    [_tabBar setSelectedItem:item];
    [self reloadDataForCategory:(int)_tabBar.selectedItem.tag withRowAnimation:UITableViewRowAnimationRight];
}
#pragma mark - Update
- (void)updateTable
{
    [self reloadDataForCategory: (int)_tabBar.selectedItem.tag withRowAnimation:UITableViewRowAnimationAutomatic];
    [self reloadCount];
  

}


- (void)reloadDataForCategory:(int)categoryTag withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    dispatch_async(_databaseQue, ^{
        _currentSearchTerm = _currentSearchTerm?_currentSearchTerm:@"";
        NSString *personType = [PersonObject typeForTag:categoryTag];
        _resultArray = [[[PeopleDatabase database] getPersonObjectArrayWithName:_currentSearchTerm type:personType includeFilters:NO] mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:rowAnimation];
        });
    });
  
}

- (void)reloadCount
{
    dispatch_async(_databaseQue, ^{

    _currentSearchTerm = _currentSearchTerm?_currentSearchTerm:@"";
    int count = TAG_SAVED;
    for (UITabBarItem *tabBarItem in _tabBar.items) {
        NSString *personType = [PersonObject typeForTag:count++];
    
        int matching = (int) [[PeopleDatabase database] getPersonObjectArrayWithName:_currentSearchTerm type:personType includeFilters:NO].count;
        int total = (int) [[PeopleDatabase database] getPersonObjectArrayWithName:@"%%" type:personType includeFilters:NO].count;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [tabBarItem setBadgeValue:[NSString stringWithFormat:@"%i/%i", matching, total]];
        });
    }
    });
  
}

#pragma mark - Delegate
#pragma mark UISearchBar
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _currentSearchTerm = searchBar.text;
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:_currentSearchTerm];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _currentSearchTerm = searchBar.text;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [self updateTable];
}


#pragma mark BTFilterController
- (void)filterController:(BTFilterController *)filterController didFinishSelectionArray:(NSMutableArray *)selectionArray hasChangedSelection:(BOOL)hasChangedSelection
{
    if (hasChangedSelection) {
        [FilterViewController saveSettingIntoUserDefualt:selectionArray];
        [self reloadDataForCategory: (int)_tabBar.selectedItem.tag withRowAnimation:UITableViewRowAnimationAutomatic];
        [self reloadCount];
    }
}

#pragma mark UITabBar
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self reloadDataForCategory:(int)item.tag withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark ReportController
- (void)refreshRecordsForType:(int)type
{
    // Reset all the settings to make sure it shows
    //[FilterViewController turnOffAllTheFilters];
    
    switch (type) {
        case TAG_SAVED:
            [_tabBar setSelectedItem:_savedTabBarItem];
            break;
        case TAG_DRAFT:
            [_tabBar setSelectedItem:_draftTabBarItem];
            break;
        case TAG_OUTBOX:
            [_tabBar setSelectedItem:_outboxTabBarItem];
            break;
        case TAG_SENT:
            [_tabBar setSelectedItem:_sentTabBarItem];
            break;
        default:
            break;
    }
    [self reloadDataForCategory:(int)_tabBar.selectedItem.tag withRowAnimation:UITableViewRowAnimationAutomatic];
    [self reloadCount];
}

#pragma mark DetailController
- (void)didSwiped:(UISwipeGestureRecognizer *)gesture
{
    NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        // go to next
        long newRow = selectedIndex.row + 1;
        if (newRow < _resultArray.count) {
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


#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonObject *personObject = _resultArray[indexPath.row];
    if (_tabBar.selectedItem.tag == TAG_DRAFT) {
        [self editPersonObject:personObject];
    } else {
        [self viewPersonObject:personObject atIndexPath:indexPath];
    }
}



@end
