//
//  FilterViewController.h
//  ReUnite + TriagePic
//


#import "BTFilterController.h"
#import "PLsearchRequestType.h"

#define FILTER_STATUS_LEAD @"STATUS"
#define FILTER_GENDER_LEAD @"GENDER"

#define FILTER_AGE_CHILD @"FILTER_AGE_CHILD"
#define FILTER_AGE_ADULT @"FILTER_AGE_ADULT"
#define FILTER_AGE_UNKNOWN @"FILTER_AGE_UNKNOWN"

#define FILTER_PER_PAGE @"FILTER_PER_PAGE"
#define FILTER_CONTAIN_IMAGE @"FILTER_CONTAIN_IMAGE"
#define FILTER_SORT_BY @"FILTER_SORT_BY"
#define FILTER_SORT_ORDER @"FILTER_SORT_ORDER"

#define FILTER_EXACT_STRING @"FILTER_EXACT_STRING"

#define FILTER_HOSPITAL @"FILTER_HOSPITAL"

#define NOTIFICATION_UPDATE_EVENT_LIST @"NOTIFICATION_UPDATE_EVENT_LIST"

#ifdef _IS_TRIAGEPIC
typedef enum {
    FilterSectionEvent,
    FilterSectionSort,
    FilterSectionCondition,
    FilterSectionGender,
    FilterSectionAge,
    FilterSectionHospital,
    FilterSectionOther
}FilterSection;

#else
typedef enum {
    FilterSectionEvent,
    FilterSectionSort,
    FilterSectionCondition,
    FilterSectionGender,
    FilterSectionAge,
    FilterSectionOther,
    
    // not used
    FilterSectionHospital
}FilterSection;
#endif


@interface FilterViewController : BTFilterController
+ (NSArray *)filterItemArray;
+ (NSString *)keyForStatus:(NSString *)status;
+ (NSString *)keyForGender:(NSString *)gender;
+ (void)saveSettingIntoUserDefualt:(NSArray *)selectionArray;
+ (PLsearchRequestType *)requestFromUserDefualt;
+ (PLsearchRequestType *)requestForRefreshWithEvent:(NSString *)event UUID:(NSString *)uuid;
+ (void)turnOffAllTheFilters;
+(NSString *)filterJsonString;

@property (assign, nonatomic) BOOL disableEventSelection;
@end
