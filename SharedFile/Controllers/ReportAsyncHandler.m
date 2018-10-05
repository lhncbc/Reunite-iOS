//
//  ReportAsyncHandler.m
//  ReUnite + TriagePic
//


#import "ReportAsyncHandler.h"
#import "PeopleDatabase.h"
#import "OrganizeController.h"

@implementation ReportAsyncHandler
static ReportAsyncHandler *sharedHandler;
+ (ReportAsyncHandler *)sharedInstanceWithPersonObject:(PersonObject *)personObject
{
    if (sharedHandler == nil) {
        sharedHandler = [[ReportAsyncHandler alloc] init];
    }
    
    [sharedHandler setPersonObject:personObject];
    
    return sharedHandler;
}

+ (void)checkAndUploadFromOutBox
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_AUTO_UPLOAD]) {
        //pull all the record from outbox
        NSArray *personObjectArray = [[PeopleDatabase database] getPersonObjectArrayWithName:@"" type:[PersonObject typeForTag:TAG_OUTBOX] includeFilters:NO];
        if ([personObjectArray count] > 0) { // Upload Serially, when done do next
            [WSCommon reportPersonWithPersonObject:personObjectArray[0] delegate:[ReportAsyncHandler sharedInstanceWithPersonObject:personObjectArray[0]]];
        }
    }
}
- (void)wsReportPersonWithSuccess:(BOOL)success uuid:(NSString *)uuid error:(id)error
{
    // Report done for background uploading
    if (success) {
        // save it in sent
        [_personObject setType:PERSON_TYPE_SENT];
        //[_personObject setUuid:uuid];
        //[[NSUserDefaults standardUserDefaults]setObject:uuid forKey:@"editUUID"];

        [_personObject setWebLink:[NSString stringWithFormat:@"%@%@/edit?puuid=%@",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_HTTP],[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_NAME], uuid]];
        [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
    }
    
    [self fetchAndUploadNextPerson];
}

- (void)wsReReportPersonWithSuccess:(BOOL)success error:(id)error
{
    // Report done for background uploading
    if (success) {
        // save it in sent
        [_personObject setType:PERSON_TYPE_SENT];
        [[PeopleDatabase database] addPersonWithPersonObject:_personObject];
    }
    
    [self fetchAndUploadNextPerson];
}

- (void)fetchAndUploadNextPerson
{
    // If Organized Page is present, refresh the count
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_TABLE object:nil];
    
    //pull all the record from outbox
    NSArray *personObjectArray = [[PeopleDatabase database] getPersonObjectArrayWithName:@"" type:[PersonObject typeForTag:TAG_OUTBOX] includeFilters:NO];
    if ([personObjectArray count] > 0) {
        [WSCommon reportPersonWithPersonObject:personObjectArray[0] delegate:[ReportAsyncHandler sharedInstanceWithPersonObject:personObjectArray[0]]];
    }
}
@end
