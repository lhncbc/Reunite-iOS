//
// PeopleDatabase.h
//  ReUnite + TriagePic
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "PersonObject.h"
#import "FilterViewController.h"

@interface PeopleDatabase : NSObject{
    sqlite3 *database;
    NSString *databasePath;
}

+ (PeopleDatabase *)database;
- (void)createDatabase;

#pragma mark - database interaction
// add
- (BOOL)addPersonWithPersonObject:(PersonObject *)personObject;

// get
- (int) getAllPeopleCount;
- (NSArray *)getPersonObjectArrayWithName:(NSString *)name type:(NSString *)type includeFilters:(BOOL)includeFilters;
- (NSArray *)getPersonObjectArrayWithUUID:(NSString *)uuid type:(NSString *)type;

//remove
- (BOOL)deletePersonWithPersonID:(int)personID;
- (BOOL)deletePersonWithUUID:(NSString *)uuid type:(NSString *)type;
- (BOOL)containsPersonWithUUID:(NSString *)uuid;

#pragma mark - helper functions
- (NSString *)escapeApos:(NSString *)string;
@end
