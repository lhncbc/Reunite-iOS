//
//  FilterViewController.m
//  ReUnite + TriagePic
//


#import "FilterViewController.h"
#import "PersonObject.h"
#import "HospitalObject.h"
#import "WSCommon.h"
@interface FilterViewController ()

@end

@implementation FilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!(IS_IPAD)) {
        UIBarButtonItem *tmpButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action: @selector(backAction)];
        self.navigationItem.leftBarButtonItem = tmpButtonItem;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEventList) name:NOTIFICATION_UPDATE_EVENT_LIST object:nil];
}
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BTFilterCell *cell = (BTFilterCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == FilterSectionCondition) {
        NSDictionary *rowDict = self.itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row];
        UIColor *color;
        
        if (IS_TRIAGEPIC) {
            color = [PersonObject colorForZone:rowDict[KEY_2_LABEL]];
        } else {
            color = [PersonObject colorForStatus:rowDict[KEY_2_LABEL]];
            
        }
        [cell.cellLabel setTextColor:color];
        [cell setBackgroundColor:[CommonFunctions addLight:.8 ToColor:color]];
        
    } else {
        if (cell.cellType == BTCellTypeInputBool) {
            [cell setBackgroundColor:[UIColor whiteColor]];
            [cell.cellLabel setTextColor:[UIColor blackColor]];
        }
    }
    
    // For Organize Page
    if (_disableEventSelection) {
        if (indexPath.section == FilterSectionEvent) {
            [cell setUserInteractionEnabled:NO];
            [cell.cellChoice setEnabled:NO];
            [cell.cellChoice setText:NSLocalizedString(@"All Events", nil)];
        }
        else if (indexPath.section == FilterSectionOther) {
            [cell.cellTextFeild setText:@"All"];
            [cell.cellTextFeild setEnabled:NO];
            [cell.cellTextFeild setTextColor:[UIColor lightGrayColor]];
        }
        else if (indexPath.section == FilterSectionSort) {
            [cell.cellChoice setEnabled:NO];
            [cell setUserInteractionEnabled:NO];
            if (indexPath.row == 0) { // Sort By
                NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
                
                if([language isEqualToString:@"es"]||[language isEqualToString:@"es-US"]||[language isEqualToString:@"es-ES"]||[language isEqualToString:@"es-MX"]||[language isEqualToString:@"es-419"])
                {
                    [cell.cellChoice setText:@"Update Time"];
                }
                [cell.cellChoice setText:NSLocalizedString(@"Update Time",nil)];
            } else if (indexPath.row == 1) { // Order
                NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
                if([language isEqualToString:@"es"]||[language isEqualToString:@"es-US"]||[language isEqualToString:@"es-ES"]||[language isEqualToString:@"es-MX"]||[language isEqualToString:@"es-419"])
                {
                    [cell.cellChoice setText:@"Descending"];
                }
                
                [cell.cellChoice setText:NSLocalizedString(@"Descending", nil)];
            }
        }
    } else {
        [cell setUserInteractionEnabled:YES];
        [cell.cellSwitch setEnabled:YES];
    }
    
    return cell;
    
}


- (void)refreshEventList
{
    // reset the event list
    [self removeRow:0 fromSection:FilterSectionEvent];
    [self addRowDict:[FilterViewController eventRowDict] toSection:FilterSectionEvent];
    
    // reset the chosen one
    self.selectionArray[FilterSectionEvent] = [@{@" ": [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT]} mutableCopy];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionEvent] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (IS_TRIAGEPIC) {
        // reset the event list
        [self removeRow:0 fromSection:FilterSectionHospital];
        [self addRowDict:[FilterViewController hospitalRowDict] toSection:FilterSectionHospital];
        
        // reset the chosen hospital
        self.selectionArray[FilterSectionHospital] = [@{@" ": [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_HOSPITAL]} mutableCopy];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionHospital] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

+ (NSDictionary *)eventRowDict
{
    // Event
    NSMutableArray *eventRowChoiceArray = [NSMutableArray array];
    for (NSDictionary *dict in [PersonObject eventArray]) {
       // NSString *eventName = dict[@"name"];
         NSString *eventName = [[dict objectForKey:@"names"] objectForKey:@"en"];
        if ([eventName rangeOfString:@"Google Code In"].location == NSNotFound && [eventName rangeOfString:@"GCI"].location == NSNotFound) {
            NSDictionary *eventChoiceRow = [BTFilterController choiceWithString:eventName];
            [eventRowChoiceArray addObject:eventChoiceRow];
        }
    }
    return [BTFilterController rowInputChoiceWithLabel:@" " choiceArray:eventRowChoiceArray lastChoice:[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT] hasColorOrImage:NO];
}

+ (NSDictionary *)hospitalRowDict
{
    NSMutableArray *hospitalRowChoiceArray = [NSMutableArray array];
    for (NSString *hospitalName in [HospitalObject hospitalNameToIdDictionary]) {
        NSDictionary *hospitalChoiceRow = [BTFilterController choiceWithString:hospitalName];
        [hospitalRowChoiceArray addObject:hospitalChoiceRow];
    }
    [hospitalRowChoiceArray addObject:[BTFilterController choiceWithString:@"All"]];
    
    return [BTFilterController rowInputChoiceWithLabel:@" " choiceArray:hospitalRowChoiceArray lastChoice:[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_FILTER_HOSPITAL] hasColorOrImage:NO];
}

+ (NSArray *)filterItemArray
{
    // Status
    NSMutableArray *statusRowArray = [NSMutableArray array];
    if (IS_TRIAGEPIC) {
        for (NSString *key in [[PersonObject colorZoneDictionary] allKeys]) {
            if (![key isEqualToString:@"Unspecified"]) {
                NSDictionary *statusRow = [BTFilterController rowInputBoolWithLabel:key defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForStatus:key]]];
                [statusRowArray addObject:statusRow];
            }
        }
    } else {
        for (NSString *key in [[PersonObject statusDictionaryUpload] allKeys]) {
            if (![key isEqualToString:@"Unspecified"]) {
                NSDictionary *statusRow = [BTFilterController rowInputBoolWithLabel:key defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForStatus:key]]];
                [statusRowArray addObject:statusRow];
            }
        }
    }
    
    NSDictionary *statusSectionArray = [BTFilterController sectionWithRowArray:statusRowArray header:NSLocalizedString(@"INCLUDES CONDITION", nil) footer:nil];
    
    // Gender
    NSMutableArray *genderRowArray = [NSMutableArray array];
    for (NSString *key in [[PersonObject genderDictionaryUpload] allKeys]) {
        NSDictionary *genderRow = [BTFilterController rowInputBoolWithLabel:key defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForGender:key]]];
        [genderRowArray addObject:genderRow];
    }
    NSDictionary *genderSectionArray = [BTFilterController sectionWithRowArray:genderRowArray header:NSLocalizedString(@"INCLUDES GENDER", nil) footer:nil];
    // Age
    NSDictionary *ageAdultRow = [BTFilterController rowInputBoolWithLabel:NSLocalizedString(@"Adult", nil) defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_ADULT]];
    NSDictionary *ageChildRow = [BTFilterController rowInputBoolWithLabel:NSLocalizedString(@"Child", nil)
                                                           defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_CHILD]];
    NSDictionary *ageUnknownRow = [BTFilterController rowInputBoolWithLabel:NSLocalizedString(@"Unknown", nil) defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_UNKNOWN]];
    NSDictionary *ageSectionArray = [BTFilterController sectionWithRowArray:@[ageAdultRow, ageChildRow, ageUnknownRow] header:NSLocalizedString(@"INCLUDES AGE GROUP", nil) footer:nil];
    
    // Event
    NSDictionary *eventSectionDict = [BTFilterController sectionWithRowArray:@[ [FilterViewController eventRowDict] ] header:NSLocalizedString(@"CURRENT EVENT", nil) footer:nil];
    
    // Sort By
    NSMutableArray *sortByRowChoiceArray = [NSMutableArray array];
    for (NSString *sortByKey in [[PersonObject sortByDictionary] allKeys]) {
        NSDictionary *sortByChoiceRow = [BTFilterController choiceWithString:sortByKey];
        [sortByRowChoiceArray addObject:sortByChoiceRow];
    }
    NSDictionary *sortByRowDict = [BTFilterController rowInputChoiceWithLabel:NSLocalizedString(@"Sort By", nil) choiceArray:sortByRowChoiceArray lastChoice:[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_BY] hasColorOrImage:NO];
    
    NSDictionary *sortOrderChoiceUpDict = [BTFilterController choiceWithString:NSLocalizedString(@"Ascending", nil)];
    NSDictionary *sortOrderChoiceDownDict = [BTFilterController choiceWithString:NSLocalizedString(@"Descending", nil)];
    NSDictionary *sortOrderRowDict = [BTFilterController rowInputChoiceWithLabel:NSLocalizedString(@"Order", nil) choiceArray:@[sortOrderChoiceUpDict, sortOrderChoiceDownDict] lastChoice:[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_ORDER] hasColorOrImage:NO];
    NSDictionary *sortSectionDict = [BTFilterController sectionWithRowArray:@[ sortOrderRowDict] header:NSLocalizedString(@"", nil) footer:nil];
    
    
    // Has Image
    NSDictionary *hasImageRowDict = [BTFilterController rowInputBoolWithLabel:NSLocalizedString(@"Contains Image", nil)defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_CONTAIN_IMAGE]];
    // Per Page
    NSDictionary *perPageRowDict = [BTFilterController rowInputTextWithLabel:NSLocalizedString(@"Records per Request", nil) defaultString:@([[NSUserDefaults standardUserDefaults] integerForKey:FILTER_PER_PAGE]).stringValue placeHolder:@"25" keyboardType:UIKeyboardTypeNumberPad isSecureInput:NO shouldAutoCorrect:NO];
    NSDictionary *otherSectionDict = [BTFilterController sectionWithRowArray:@[hasImageRowDict,perPageRowDict] header:NSLocalizedString(@"OTHER", nil) footer:nil];
    // Exact String
    NSDictionary *exactStringRow = [BTFilterController rowInputBoolWithLabel:NSLocalizedString(@"Exact term", nil) defaultBoolean:[[NSUserDefaults standardUserDefaults] boolForKey:FILTER_EXACT_STRING]];
    NSDictionary *exactStringDict = [BTFilterController sectionWithRowArray:@[exactStringRow] header:nil footer:NSLocalizedString(@"Only display result matching the exact search term", nil)];
    
    if (IS_TRIAGEPIC) {
        // Hospital stuff
        NSDictionary *hospitalRowDict = [FilterViewController hospitalRowDict];
        NSDictionary *hospitalSectionDict = [BTFilterController sectionWithRowArray:@[hospitalRowDict] header:@"HOSPITAL FILTER" footer:nil];
        
        return @[eventSectionDict, statusSectionArray, genderSectionArray, ageSectionArray, hospitalSectionDict, otherSectionDict, exactStringDict];
    } else {
        return @[eventSectionDict, perPageRowDict, statusSectionArray, genderSectionArray, ageSectionArray, otherSectionDict];
    }
}

+ (NSString *)keyForStatus:(NSString *)status
{
    return [NSString stringWithFormat:@"%@%@", FILTER_STATUS_LEAD , status];
}

+ (NSString *)keyForGender:(NSString *)gender
{
    return [NSString stringWithFormat:@"%@%@", FILTER_GENDER_LEAD , gender];
}

+ (void)turnOffAllTheFilters
{
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Alive and Well", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Deceased", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Found (no status)", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Injured", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Missing", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Unknown", nil)]];
    
    //NSLocalizedString(@"Missing", nil),NSLocalizedString(@"Injured", nil),NSLocalizedString(@"Deceased", nil),NSLocalizedString(@"Unknown", nil), NSLocalizedString(@"Found (no status)", nil)
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForGender:NSLocalizedString(@"Others", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForGender:NSLocalizedString(@"Female", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForGender:NSLocalizedString(@"Male", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[FilterViewController keyForGender:NSLocalizedString(@"Unknown", nil)]];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FILTER_AGE_CHILD];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FILTER_AGE_ADULT];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FILTER_AGE_UNKNOWN];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FILTER_CONTAIN_IMAGE];
    
}

+ (void)saveSettingIntoUserDefualt:(NSArray *)selectionArray
{
    
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][NSLocalizedString(@"Alive and Well", nil)] boolValue] forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Alive and Well", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][NSLocalizedString(@"Deceased", nil)] boolValue] forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Deceased", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][NSLocalizedString(@"Found (no status)", nil)] boolValue] forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Found (no status)", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][NSLocalizedString(@"Injured", nil)] boolValue] forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Injured", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][NSLocalizedString(@"Missing", nil)] boolValue] forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Missing", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionCondition][NSLocalizedString(@"Unknown", nil)] boolValue] forKey:[FilterViewController keyForStatus:NSLocalizedString(@"Unknown", nil)]];
    
    
    
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionGender][NSLocalizedString(@"Other", nil)] boolValue] forKey:[FilterViewController keyForGender:NSLocalizedString(@"Other", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionGender][NSLocalizedString(@"Female", nil)] boolValue] forKey:[FilterViewController keyForGender:NSLocalizedString(@"Female", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionGender][NSLocalizedString(@"Male", nil)] boolValue] forKey:[FilterViewController keyForGender:NSLocalizedString(@"Male", nil)]];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionGender][NSLocalizedString(@"Unknown", nil)] boolValue] forKey:[FilterViewController keyForGender:NSLocalizedString(@"Unknown", nil)]];
    
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionAge][NSLocalizedString(@"Child", nil)] boolValue] forKey:FILTER_AGE_CHILD];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionAge][NSLocalizedString(@"Adult", nil)] boolValue] forKey:FILTER_AGE_ADULT];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionAge][NSLocalizedString(@"Unknown", nil)] boolValue] forKey:FILTER_AGE_UNKNOWN];
    
    int perPage = [selectionArray[FilterSectionOther][NSLocalizedString(@"Records per Request", nil)] intValue];
    if (perPage <= 0) {
        perPage = 25;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:perPage forKey:FILTER_PER_PAGE];
    [[NSUserDefaults standardUserDefaults] setBool:[selectionArray[FilterSectionOther][NSLocalizedString(@"Contains Image", nil)] boolValue] forKey:FILTER_CONTAIN_IMAGE];
    
    [[NSUserDefaults standardUserDefaults] setObject:selectionArray[FilterSectionEvent][@" "] forKey:GLOBAL_KEY_CURRENT_EVENT];
    [[NSUserDefaults standardUserDefaults] setObject:selectionArray[FilterSectionSort][NSLocalizedString(@"Order", nil)] forKey:FILTER_SORT_ORDER];
    [[NSUserDefaults standardUserDefaults] setObject:selectionArray[FilterSectionSort][NSLocalizedString(@"Sort By", nil)] forKey:FILTER_SORT_BY];
    
    
}

+ (PLsearchRequestType *)requestFromUserDefualt
{
   // NSString *sortBy = [PersonObject sortByDictionary][[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_BY]];
     //NSString *sortBy=@"";
    //NSString *sortOrder = [[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_ORDER] isEqualToString:NSLocalizedString(@"Ascending", nil)]?@"asc":@"desc";
    //NSString *sortString = [NSString stringWithFormat:@"%@ %@",sortBy, sortOrder];
    
    //NSString *eventFullName = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT];
    //NSString *eventShortName = [[PersonObject eventLongNameToShortNameDict] objectForKey:eventFullName];
    
    // get a reqest type
    PLsearchRequestType *request = [[PLsearchRequestType alloc] init];
   // request.eventShortname = eventShortName;
    request.filters = [self filterJsonString];
    
    NSString *jsonString=[FilterViewController filterJsonString];
    
//    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    NSMutableDictionary *mutableDict = [json mutableCopy];
//    //int count= (int)_resultArray.count;
//    
//    NSNumber *your_object = [NSNumber numberWithInt: (int)[[NSUserDefaults standardUserDefaults] integerForKey:FILTER_PER_PAGE]];
//    if (json) {
//        if ([json objectForKey:@"perPage"]) {
//            
//            [mutableDict setObject:your_object forKey:@"perPage"];
//            json = [mutableDict mutableCopy];
//            
//            
//        }
//        
//    }
    //request.sortBy = sortString;
    //request.perPage = (int)[[NSUserDefaults standardUserDefaults] integerForKey:FILTER_PER_PAGE];
    
    return request;
}

+ (PLsearchRequestType *)requestForRefreshWithEvent:(NSString *)event UUID:(NSString *)uuid
{
    //NSString *sortBy = [PersonObject sortByDictionary][[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_BY]];
    //NSString *sortOrder = [[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_ORDER] isEqualToString:NSLocalizedString(@"Ascending", nil)]?@"asc":@"desc";
    //NSString *sortString = [NSString stringWithFormat:@"%@ %@",sortBy, sortOrder];
    
   // NSString *eventShortName = [[PersonObject eventLongNameToShortNameDict] objectForKey:event];
    
    // get a reqest type
    PLsearchRequestType *request = [[PLsearchRequestType alloc] init];
   // request.eventShortname = eventShortName;
    //request.perPage = 1;
    //request.sortBy = sortString;
   // [request setPageStart:0];
     // request.filters = [self filterJsonString];
    
    NSString *srt=[[NSUserDefaults standardUserDefaults]objectForKey:@"editUUID"];
    NSString *u_uuid=[NSString stringWithFormat:@"p_uuid:%@", srt];

    NSString *jsonString=[self filterJsonString];
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableDictionary *mutableDict = [json mutableCopy];
    if (json) {
        if ([[json objectForKey:@"query"] isEqualToString: @""]) {
            
            [mutableDict setObject:u_uuid forKey:@"query"];
            json = [mutableDict mutableCopy];
            
            
        }
        
    }

    //request.filters = EXIFString;
    [[NSUserDefaults standardUserDefaults]setObject:json forKey:@"UUIDString"];
    
    return request;
}

+ (NSValue *)boolForStatus:(NSString *)status
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForStatus:status]]? @YES : @NO;
}

+ (NSValue *)boolForGender:(NSString *)gender
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForGender:gender]]? @YES : @NO;
}

//+ (NSString *)filterJsonString {
//    NSMutableDictionary *filterDict = [@{
//                                 @"genderMale" : [self boolForGender:NSLocalizedString(@"Male", nil)],
//                                 @"genderFemale" : [self boolForGender:NSLocalizedString(@"Female", nil)],
//                                 @"genderComplex" : [self boolForGender:NSLocalizedString(@"Complex", nil)],
//                                 @"genderUnknown" : [self boolForGender:NSLocalizedString(@"Unknown", nil)],
//
//                                 @"ageChild" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_CHILD]? @YES: @NO,
//                                 @"ageAdult" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_ADULT]?  @YES: @NO,
//                                 @"ageUnknown" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_UNKNOWN]?  @YES: @NO,
//
//                                 @"hasImage" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_CONTAIN_IMAGE]?  @YES: @NO} mutableCopy];
//
//    [filterDict addEntriesFromDictionary:[self statusOrZoneDictionary]];
//    return [CommonFunctions serializedJSONStringFromDictionaryOrArray:filterDict];
//}
//
//+ (NSDictionary *)statusOrZoneDictionary
//{
//    NSDictionary *dictionary;
//
//    if (IS_TRIAGEPIC) {
//        dictionary = @{@"Green" : [self boolForStatus:@"Green"],
//                       @"BH Green" : [self boolForStatus:@"BH Green"],
//                       @"Yellow" : [self boolForStatus:@"Yellow"],
//                       @"Red" : [self boolForStatus:@"Red"],
//                       @"Gray" : [self boolForStatus:@"Gray"],
//                       @"Black" : [self boolForStatus:@"Black"],
//                       @"Unknown" : [self boolForStatus:@"Unknown"],
//                       @"hospital" : [self hospitalFilter]};
//    } else {
//        dictionary = @{@"statusMissing" : [self boolForStatus:NSLocalizedString(@"Missing", nil)],
//                       @"statusAlive" : [self boolForStatus:NSLocalizedString(@"Alive and Well", nil)],
//                       @"statusInjured" : [self boolForStatus:NSLocalizedString(@"Injured", nil)],
//                       @"statusDeceased" : [self boolForStatus:NSLocalizedString(@"Deceased", nil)],
//                       @"statusUnknown" : [self boolForStatus:NSLocalizedString(@"Unknown", nil)],
//                       @"statusFound" : [self boolForStatus:NSLocalizedString(@"Found (no status)", nil)]};
//       // NSLocalizedString(@"Alive and Well", nil),NSLocalizedString(@"Injured", nil),NSLocalizedString(@"Deceased", nil),NSLocalizedString(@"Unknown", nil), NSLocalizedString(@"Found (no status)", nil)
//    }
//
//    return dictionary;
//}*/
+ (NSString *)filterJsonString {
    NSMutableDictionary *filterDict;
    
    //NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    int perPage= (int)[[NSUserDefaults standardUserDefaults] integerForKey:FILTER_PER_PAGE];
    
//    NSString *sortBydata= [[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_ORDER];
//    
//    NSString *sortOrder = [[[NSUserDefaults standardUserDefaults] objectForKey:FILTER_SORT_ORDER] isEqualToString:NSLocalizedString(@"Ascending", nil)]?@"asc":@"desc";
//    NSString *sortString = [NSString stringWithFormat:@"%@ %@",sortBydata, sortOrder];
    

        filterDict = [@{
                       
                        @"sexMale" : [self boolForGender:NSLocalizedString(@"Male",nil)],
                        @"sexFemale" : [self boolForGender:NSLocalizedString(@"Female",nil)],
                        @"sexOther" : [self boolForGender:NSLocalizedString(@"Other",nil)],
                        @"sexUnknown" : [self boolForGender:NSLocalizedString(@"Unknown",nil)],
                        
                        @"ageChild" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_CHILD]? @YES: @NO,
                        @"ageAdult" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_ADULT]?  @YES: @NO,
                        @"ageUnknown" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_UNKNOWN]?  @YES: @NO,
                        @"perPage":@(perPage) ,
                        @"pageStart":@"0",
                       // @"sortBy":sortString,
                        
                        @"hasImage" : [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_CONTAIN_IMAGE]?  @YES: @NO} mutableCopy];
        
   // }
    
   
    
    
    [filterDict addEntriesFromDictionary:[self statusOrZoneDictionary]];
    
    
    return [CommonFunctions serializedJSONStringFromDictionaryOrArray:filterDict];
}

+ (NSDictionary *)statusOrZoneDictionary
{
    NSDictionary *dictionary;
    NSString *eventFullName = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT];
    NSString *eventShortName = [[PersonObject eventLongNameToShortNameDict] objectForKey:eventFullName];
    
    //NSLog(@"%@eventShortNameeventShortNameeventShortNameeventShortName",eventShortName);
    
    
    if (IS_TRIAGEPIC) {
        dictionary = @{@"Green" : [self boolForStatus:@"Green"],
                       @"BH Green" : [self boolForStatus:@"BH Green"],
                       @"Yellow" : [self boolForStatus:@"Yellow"],
                       @"Red" : [self boolForStatus:@"Red"],
                       @"Gray" : [self boolForStatus:@"Gray"],
                       @"Black" : [self boolForStatus:@"Black"],
                       @"Unknown" : [self boolForStatus:@"Unknown"],
                       @"hospital" : [self hospitalFilter]};
    } else {
        NSString *searchTerm = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchTerm"];

            dictionary = @{@"statusMissing" : [self boolForStatus:NSLocalizedString(@"Missing",nil)],
                           @"statusAlive" : [self boolForStatus:NSLocalizedString(@"Alive and Well",nil)],
                           @"statusInjured" : [self boolForStatus:NSLocalizedString(@"Injured", nil)],
                           @"statusDeceased" : [self boolForStatus:NSLocalizedString(@"Deceased", nil)],
                           @"statusUnknown" : [self boolForStatus:NSLocalizedString(@"Unknown", nil)],
                           @"statusFound" : [self boolForStatus:NSLocalizedString(@"Found (no status)", nil)],
                           @"since":@"1970-01-01TO1:23:45Z",@"sortBy":@"",@"call": @"search",@"token":[WSCommon retrieveToken]?[WSCommon retrieveToken]:@"",@"photo":@"",@"short":eventShortName?eventShortName:@"",@"query":searchTerm?searchTerm:@"" };
            
        }
  
    return dictionary;
}




+ (NSString *)hospitalFilter
{
    if (!IS_TRIAGEPIC) {
        return @"";
    }
    
    NSString *currentHospital = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_FILTER_HOSPITAL];
    if ([currentHospital isEqualToString:@"All"]) {
        return @"all";
    }
    
    return [HospitalObject hospitalNameToIdDictionary][currentHospital];
}

@end
