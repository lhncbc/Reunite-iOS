//
// PeopleDatabase.m
//  ReUnite + TriagePic + TriagePic
//


#import "PeopleDatabase.h"

@implementation PeopleDatabase
static PeopleDatabase * database;

+ (PeopleDatabase *)database{
    if (database == nil){
        database = [[PeopleDatabase alloc] init];
    }
    return database;
}

- (id)init{
    self = [super init];
    if(self){
        [self createDatabase];
        if (sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK){
            DLog(@"Failed to open the database");
        }
        /*
        NSString *sqliteDb = [[NSBundle mainBundle] pathForResource:@"People Database" ofType:@"sqlite3"];
        if (sqlite3_open([sqliteDb UTF8S    tring], &database) != SQLITE_OK){
            DLog(@"Failed to open the database");
        }
        */
    }
    return self;
}

#ifdef _IS_TRIAGEPIC
typedef enum {
    DatabaseEnumPrimKey,
    DatabaseEnumType,
    DatabaseEnumImageNames,
    DatabaseEnumFaceRect,
    DatabaseEnumFaceRectAvailable,
    DatabaseEnumImageURL,
    DatabaseEnumGivenName,
    DatabaseEnumFamilyName,
    DatabaseEnumEvent,
    DatabaseEnumZone,
    DatabaseEnumHospitalID,
    DatabaseEnumPatientID,
    DatabaseEnumAgeMin,
    DatabaseEnumAgeMax,
    DatabaseEnumGender,
    DatabaseEnumDetail,
    DatabaseEnumTimeStamp,
    DatabaseEnumUUID,
    DatabaseEnumWeblink,
    DatabaseEnumComment,
    DatabaseEnumCanEdit,
    DatabaseEnumDeleteImageURLs,
    
    DatabaseEnumCount,
    
    DatabaseEnumStatus,
    DatabaseEnumLocation
}DatabaseEnum;
#else
typedef enum {
    DatabaseEnumPrimKey,
    DatabaseEnumType,
    DatabaseEnumImageNames,
    DatabaseEnumFaceRect,
    DatabaseEnumFaceRectAvailable,
    DatabaseEnumImageURL,
    DatabaseEnumGivenName,
    DatabaseEnumFamilyName,
    DatabaseEnumEvent,
    DatabaseEnumStatus,
    DatabaseEnumAgeMin,
    DatabaseEnumAgeMax,
    DatabaseEnumGender,
    DatabaseEnumLocation,
    DatabaseEnumDetail,
    DatabaseEnumTimeStamp,
    DatabaseEnumUUID,
    DatabaseEnumWeblink,
    DatabaseEnumComment,
    DatabaseEnumCanEdit,
    DatabaseEnumDeleteImageURLs,
    
    DatabaseEnumCount,
    
    DatabaseEnumZone,
    DatabaseEnumHospitalID,
    DatabaseEnumPatientID,
    
}DatabaseEnum;
#endif

- (void)createDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    
    databasePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"Report Database.sqlite3"]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath] == FALSE)
   {
       if (sqlite3_open_v2([databasePath UTF8String], &database, SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_FILEPROTECTION_COMPLETE, NULL) == SQLITE_OK)
       {
            //PhotoNames - abc/abc/photo01,abc/abc/photo02
            //BoundingBoxes - 12/21/32/32,52/64/54/43
           const char *sqlStatement;
           if (IS_TRIAGEPIC) {
               sqlStatement = "CREATE TABLE IF NOT EXISTS PeopleTable (Id INTEGER PRIMARY KEY, Type TEXT, PhotoNames TEXT, BoundingBoxes TEXT, BoxValidity TEXT, URL TEXT, GivenName TEXT, FamilyName TEXT, Event TEXT, Zone TEXT, HospitalID TEXT, patientID TEXT,FromAge TEXT, ToAge TEXT, Gender TEXT, Detail TEXT, TimeStamp TEXT, UUID TEXT, WebLink TEXT, Comment TEXT, CanEdit TEXT, imagesToDelete TEXT)";
           } else {
               sqlStatement = "CREATE TABLE IF NOT EXISTS PeopleTable (Id INTEGER PRIMARY KEY, Type TEXT, PhotoNames TEXT, BoundingBoxes TEXT, BoxValidity TEXT, URL TEXT, GivenName TEXT, FamilyName TEXT, Event TEXT, Status TEXT, FromAge TEXT, ToAge TEXT, Gender TEXT, Location TEXT, Detail TEXT, TimeStamp TEXT, UUID TEXT, WebLink TEXT, Comment TEXT, CanEdit TEXT, imagesToDelete TEXT)";
           }
            char *error;
            sqlite3_exec(database, sqlStatement, NULL, NULL, &error);
        }
    }
}


- (NSString *)escapeApos:(NSString *)string{
    NSString *returnString = [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    return returnString;
}

- (int) getAllPeopleCount{
    int count = 0;    
    NSString *query = @"SELECT COUNT( *)as 'count' FROM PeopleTable";
    sqlite3_stmt *statement;

    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW){
            NSString *countString = @((char *)sqlite3_column_text(statement,0));
            count = countString?[countString intValue]:0;  
        }
        sqlite3_finalize(statement);
    }
    return count;
    
}

#pragma mark - database interaction
- (BOOL)addPersonWithPersonObject:(PersonObject *)personObject{
    BOOL addSuccessfulWithoutError = YES;
    
    [self deletePersonWithPersonID:personObject.personID uuid:nil type:nil removeDeleteQue:NO];
    if (personObject.uuid && ![personObject.uuid isEqualToString:@""]) {
        [self deletePersonWithPersonID:-1 uuid:personObject.uuid type:personObject.type removeDeleteQue:NO];
    }

    
    //Image processing
    NSMutableString *tempImagePathString = [[NSMutableString alloc]init];
    NSMutableString *tempFaceRectString = [[NSMutableString alloc]init];
    NSMutableString *tempFaceRectAvailabilityString = [[NSMutableString alloc]init];
    NSMutableString *tempImageURLString = [[NSMutableString alloc]init];
    int count = 0;
    for (ImageObject *imageObject in personObject.imageObjectArray){
        NSData *imageData = UIImageJPEGRepresentation(imageObject.image, 1);
        NSString *pathToImage = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *ReUnitePersonPhotoID = [NSString stringWithFormat:@"/ReUnitePersonPhotoID-%i-%i.jpg",personObject.personID,count++];
        pathToImage = [pathToImage stringByAppendingString:ReUnitePersonPhotoID];
        [tempImagePathString appendFormat:@"%@,",pathToImage];
        [tempFaceRectString appendFormat:@"%f/%f/%f/%f,",imageObject.faceRect.origin.x, imageObject.faceRect.origin.y, imageObject.faceRect.size.width, imageObject.faceRect.size.height];
        [tempFaceRectAvailabilityString appendFormat:@"%@,",@(imageObject.faceRectAvailable)];
        [tempImageURLString appendFormat:@"%@,",imageObject.imageURL];
        
        NSError *error;
        [imageData writeToFile:pathToImage options:NSDataWritingFileProtectionComplete error:&error];
        if (error !=nil){
            DLog(@"SQLite 3 INSERT statement bug! %@", error); 
            addSuccessfulWithoutError = NO;
        }
    }

    NSMutableString *imagesToDeleteString = [NSMutableString string];
    for (NSString *imageURLtoDelete in personObject.imagesURLToDelete) {
        [imagesToDeleteString appendFormat:@",%@", imageURLtoDelete];
    }
    
    //Comment
    NSString *commentString = @"";
    for (CommentObject *commentObject in personObject.commentObjectArray) {
        NSString *jsonString = [CommonFunctions serializedJSONStringFromDictionaryOrArray:[CommentObject dictionaryFromCommentObject:commentObject personID:personObject.personID]];
        commentString = [commentString stringByAppendingFormat:@"%@%@", jsonString, COMMENT_SEPARATOR];
    }
    
    NSString *query;
    if (IS_TRIAGEPIC) {
        //CREATE TABLE IF NOT EXISTS PeopleTable (Id INTEGER PRIMARY KEY, Type TEXT, PhotoNames TEXT, BoundingBoxes TEXT, BoxValidity TEXT, URL TEXT, GivenName TEXT, FamilyName TEXT, Event TEXT, Zone TEXT, HospitalID TEXT, patientID TEXT, FromAge TEXT, ToAge TEXT, Gender TEXT, Detail TEXT, TimeStamp TEXT, UUID TEXT, WebLink TEXT, Comment TEXT)
        query = [NSString stringWithFormat: @"INSERT INTO PeopleTable VALUES (%d,'%@', '%@', '%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                 personObject.personID,
                 personObject.type,
                 tempImagePathString,
                 tempFaceRectString,
                 tempFaceRectAvailabilityString,
                 tempImageURLString,
                 [self escapeApos:personObject.givenName],
                 [self escapeApos:personObject.familyName],
                 personObject.event,
                 personObject.zone,
                 personObject.hospitalName,
                 personObject.patientId,
                 personObject.ageMin,
                 personObject.ageMax,
                 personObject.gender,
                 [self escapeApos:personObject.additionalDetail],
                 personObject.lastUpdated,
                 personObject.uuid,
                 personObject.webLink,
                 [self escapeApos:commentString],
                 @(personObject.canEdit),
                imagesToDeleteString];
    } else {
        //CREATE TABLE IF NOT EXISTS PeopleTable (Id INTEGER PRIMARY KEY, Type TEXT, PhotoNames TEXT, BoundingBoxes TEXT, BoxValidity TEXT, URL TEXT, GivenName TEXT, FamilyName TEXT, Event TEXT, Status TEXT, FromAge TEXT, ToAge TEXT, Gender TEXT, Street TEXT, City TEXT, Region TEXT, Zip TEXT, Country TEXT, coor TEXT, Detail TEXT, TimeStamp TEXT, UUID TEXT, WebLink TEXT, Comment TEXT)
        query = [NSString stringWithFormat: @"INSERT INTO PeopleTable VALUES (%d,'%@', '%@', '%@', '%@','%@', '%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",
                 personObject.personID,
                 personObject.type,
                 tempImagePathString,
                 tempFaceRectString,
                 tempFaceRectAvailabilityString,
                 tempImageURLString,
                 [self escapeApos:personObject.givenName],
                 [self escapeApos:personObject.familyName],
                 personObject.event,
                 personObject.status,
                 personObject.ageMin,
                 personObject.ageMin,
                 personObject.gender,
                 [personObject.location getLocationJSONSerializedString],
                 [self escapeApos:personObject.additionalDetail],
                 personObject.lastUpdated,
                 personObject.uuid,
                 personObject.webLink,
                 [self escapeApos:commentString],
                 @(personObject.canEdit),
                 imagesToDeleteString];
    }
    
    char *error;
    sqlite3_exec(database, [query UTF8String], NULL, NULL, &error);
    
    DLog(@"%@", query);
    if (error !=nil){
        DLog(@"SQLite 3 INSERT statement bug! %@", [[NSString alloc] initWithUTF8String:(char *)error]);
        addSuccessfulWithoutError = NO;
    }
    return addSuccessfulWithoutError;
}

#pragma mark fetchers
- (NSArray *)getPersonObjectArrayWithName:(NSString *)name type:(NSString *)type includeFilters:(BOOL)includeFilters{
    return [self getPersonObjectArrayWithName:name type:type uuid:nil personID:-1 includeFilters:includeFilters];
}
- (NSArray *)getPersonObjectArrayWithUUID:(NSString *)uuid type:(NSString *)type{
    return [self getPersonObjectArrayWithName:nil type:type uuid:uuid personID:-1 includeFilters:NO];
}

#pragma mark deleter
- (BOOL)deletePersonWithPersonID:(int)personID{
    return [self deletePersonWithPersonID:personID uuid:nil type:nil removeDeleteQue:YES];
}

- (BOOL)deletePersonWithUUID:(NSString *)uuid type:(NSString *)type{
    return [self deletePersonWithPersonID:-1 uuid:uuid type:type removeDeleteQue:YES];
}

#pragma mark verifier
- (BOOL)containsPersonWithUUID:(NSString *)uuid{
    NSString *query = [NSString stringWithFormat: @"SELECT COUNT( *)as 'count' FROM PeopleTable WHERE UUID = '%@'", uuid];
    sqlite3_stmt *statement;
    int count = 0;
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW){
            NSString *countString = @((char *)sqlite3_column_text(statement,0));
            count = countString?[countString intValue]:0;
        }
        sqlite3_finalize(statement);
    }
    return count>0?YES:NO;
}

#pragma mark inner call class
- (NSArray *)getPersonObjectArrayWithName:(NSString *)name type:(NSString *)type uuid:(NSString *)uuid personID:(int)personID includeFilters:(BOOL)includeFilters{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    NSString *query; // preparing query depending on what is provided
    if (name) {
        query = [NSString stringWithFormat: @"SELECT * FROM PeopleTable WHERE Type = '%@' AND (GivenName LIKE '%% %@ %%' OR FamilyName LIKE '%% %@ %%' OR GivenName LIKE '%@ %%' OR FamilyName LIKE '%@ %%' OR GivenName LIKE '%% %@' OR FamilyName LIKE '%% %@' OR GivenName LIKE '%@' OR FamilyName LIKE '%@')", type, name, name, name, name, name, name, name, name];
    }else if (uuid){
        query = [NSString stringWithFormat: @"SELECT * FROM PeopleTable WHERE Type = '%@' AND UUID = '%@'", type, uuid];
    }else if (personID >= 0){
        query = [NSString stringWithFormat: @"SELECT * FROM PeopleTable WHERE Id =  '%d'", personID];
    }else{
        DLog(@"error at inner method database fetching");
        return @[];
    }
    
    if (includeFilters) { // adding filters
        query = [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_EXACT_STRING]? query: [NSString stringWithFormat: @"SELECT * FROM PeopleTable WHERE Type = '%@' AND (GivenName LIKE '%%%@%%' OR FamilyName LIKE '%%%@%%')", type, name, name];
        
        if (IS_TRIAGEPIC) {
            for (NSString *key in [[PersonObject colorZoneDictionary] allKeys]) {
                query = [[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForStatus:key]]? query: [query stringByAppendingFormat:@" AND NOT Zone = '%@'",key];
            }
        } else {
            for (NSString *key in [[PersonObject statusDictionaryUpload] allKeys]) {
                query = [[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForStatus:key]]? query: [query stringByAppendingFormat:@" AND NOT Status = '%@'",key];
            }
        }
        
        
        for (NSString *key in [[PersonObject genderDictionaryUpload] allKeys]) {
            query = [[NSUserDefaults standardUserDefaults] boolForKey:[FilterViewController keyForGender:key]]? query: [query stringByAppendingFormat:@" AND NOT Gender = '%@'", key];
        }
        query = [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_CHILD]? query: [query stringByAppendingString:@" AND (NOT CAST(ToAge as int) <= '17' OR ToAge = 'N/A')"];
        query = [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_ADULT]? query: [query stringByAppendingString:@" AND (NOT CAST(FromAge as int) > '17' OR ToAge = 'N/A')"];
        bool excludeAllAge = !([[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_CHILD] || [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_ADULT]);
        query = excludeAllAge?[query stringByAppendingString:@" AND ToAge = 'N/A'"]: query;
        query = [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_AGE_UNKNOWN]? query: [query stringByAppendingString:@" AND NOT ToAge = 'N/A'"];
        
        query = [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_CONTAIN_IMAGE]? [query stringByAppendingString:@" AND NOT (PhotoNames = '' OR PhotoNames = 'No Photo')"]:query;
        
        query = [query stringByAppendingString:@" ORDER BY Id DESC"];
    }

    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK){
        //DLog(@"%i,%i", sqlite3_step(statement),SQLITE_ROW);
        while (sqlite3_step(statement) == SQLITE_ROW){
            NSMutableArray *personArray = [NSMutableArray array];
            [personArray addObject:@(sqlite3_column_int(statement, 0))];
            for (int count = 1; count <= DatabaseEnumCount - 1; count++){
                [personArray addObject:[[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, count)]];
            }
            PersonObject *personObject = [PeopleDatabase personObjectWithPersonArray:personArray];
            [returnArray addObject:personObject];
        }
        sqlite3_finalize(statement);
    }
    return returnArray;
}

- (BOOL)deletePersonWithPersonID:(int)personID uuid:(NSString *)uuid type:(NSString *)type removeDeleteQue:(BOOL)removeDeleteQue{
    BOOL deleteSuccessfulWithoutError = YES;

    //First find out which of the personID or uuid is provided
    NSString *imageQuery;
    NSString *deleteQuery;

    if (uuid){
        //uuid is provided, prepare query to extract the array, this is done to retrive all the images associated with it.
        imageQuery = [NSString stringWithFormat: @"SELECT * FROM PeopleTable WHERE UUID = '%@' AND Type = '%@'", uuid, type];
        deleteQuery = [NSString stringWithFormat: @"DELETE FROM PeopleTable WHERE UUID = '%@' AND Type = '%@'", uuid, type];
    }else if (personID != -1){
        imageQuery = [NSString stringWithFormat: @"SELECT * FROM PeopleTable WHERE Id =  '%d'", personID];
        deleteQuery = [NSString stringWithFormat: @"DELETE FROM PeopleTable WHERE Id = '%d'", personID];
    }
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [imageQuery UTF8String], -1, &statement, nil) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW){
            //there should be at most one record
            NSString *imagePathsString = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            //break it into individual imagePath
            NSArray *imagePathsArray = [imagePathsString componentsSeparatedByString:@","];
            for (NSString *imagePathString in imagePathsArray) {
                //deleting each one by one
                if (![imagePathString isEqualToString:@""]){
                    NSError *error;
                    [[NSFileManager defaultManager] removeItemAtPath:imagePathString error:&error];
                    if (error) {
                        deleteSuccessfulWithoutError = NO;
                        DLog(@"SQLite3 Delete bug! - %@",error);
                    }
                }
            }
        }
        sqlite3_finalize(statement); // all the images associated should now be removed
    }
    
    //remove any comment images associated with the record
    NSString *pathToImage = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *commentPhotoName = [NSString stringWithFormat:@"ReUnitePersonCommentPhotoID-%i-[A-Za-z0-9]+", personID];
    NSError *regExError;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:commentPhotoName options:0 error:&regExError];
    [self removeFiles:regEx inPath:pathToImage];
    if (regExError){
        deleteSuccessfulWithoutError = NO;
        DLog(@"SQLite3 regEx bug! - %@",[regExError description]);
    }
    
    //then we remove the record from the database
    char *error;
    sqlite3_exec(database, [deleteQuery UTF8String], NULL, NULL, &error);
    if (error){
        deleteSuccessfulWithoutError = NO;
        DLog(@"SQLite3 Delete bug! - %s",error);
    }
    
    /*
    //SPECIAL CASE
    //in an event that this record is in the draft, there might be an image delete order stuck in the Que (To propagate over to PL Server)
    //thus, we have to take that off the que
    //removeDeleteQue is set to NO only when the record is being deleted when a new record is added onto its place
    if ([type isEqualToString:PERSON_TYPE_DRAFT] && removeDeleteQue) {
        NSMutableDictionary *tempDeleteQueDict = [[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_QUE_DELETE_DICT] mutableCopy];
        [tempDeleteQueDict removeObjectForKey:uuid];
        [[NSUserDefaults standardUserDefaults] setObject:tempDeleteQueDict forKey:GLOBAL_KEY_QUE_DELETE_DICT];
    }
    */
    return deleteSuccessfulWithoutError;
}

- (void)removeFiles:(NSRegularExpression*)regex inPath:(NSString*)path {
    NSDirectoryEnumerator *filesEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    NSString *file;
    NSError *error;
    while (file = [filesEnumerator nextObject]) {
        NSUInteger match = [regex numberOfMatchesInString:file
                                                  options:0
                                                    range:NSMakeRange(0, [file length])];
        
        if (match) {
            [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
        }
    }
}

+ (PersonObject *)personObjectWithPersonArray:(NSArray *)personArray{
    PersonObject *personObject = [[PersonObject alloc] init];
    
    personObject.personID = [personArray[DatabaseEnumPrimKey] intValue];
    personObject.type = personArray[DatabaseEnumType];
    
    // Images
    personObject.imageObjectArray = [NSMutableArray array];
    NSArray *tempPhotoPathArray = [personArray[DatabaseEnumImageNames] componentsSeparatedByString:@","];
    NSArray *tempFaceRectArray = [personArray[DatabaseEnumFaceRect] componentsSeparatedByString:@","];
    NSArray *tempFaceRectAvailabilityArray = [personArray[DatabaseEnumFaceRectAvailable] componentsSeparatedByString:@","];
    NSArray *tempImageURLArray = [personArray[DatabaseEnumImageURL] componentsSeparatedByString:@","];
    for (int count = 0; count<[tempFaceRectArray count] - 1; count++){
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:tempPhotoPathArray[count]]];
        NSString *imageURL = tempImageURLArray[count];
        
        NSArray *tempFaceRectDetailArray = [tempFaceRectArray[count] componentsSeparatedByString:@"/"];
        CGRect faceRect = CGRectMake([tempFaceRectDetailArray[0] doubleValue], [tempFaceRectDetailArray[1] doubleValue], [tempFaceRectDetailArray[2] doubleValue], [tempFaceRectDetailArray[3] doubleValue]);
        
        BOOL faceRectAvailable = [tempFaceRectAvailabilityArray[count] boolValue];
        BOOL primary = NO;//primary not yet supported
        
        [personObject.imageObjectArray addObject:[[ImageObject alloc]initWithImage:image imageURL:imageURL faceRect:faceRect faceRectAvailable:faceRectAvailable primary:primary delegate:self]];
    }
    
    //info
    personObject.givenName = personArray[DatabaseEnumGivenName];
    personObject.familyName = personArray[DatabaseEnumFamilyName];
    personObject.event = personArray[DatabaseEnumEvent];
    personObject.ageMin = personArray[DatabaseEnumAgeMin];
   // personObject.ageMax = personArray[DatabaseEnumAgeMax];
    personObject.gender = personArray[DatabaseEnumGender];
    
    
    //Other
    personObject.additionalDetail = personArray[DatabaseEnumDetail];
    //convert Time to NSDate
    NSString *lastUpdatedString = personArray[DatabaseEnumTimeStamp];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZZ";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    personObject.lastUpdated = [dateFormatter dateFromString:lastUpdatedString];
    //personObject.lastUpdated = lastUpdatedString.
    personObject.uuid = personArray[DatabaseEnumUUID];
    personObject.webLink = personArray[DatabaseEnumWeblink];
    
    //comment section
    NSString *commentString = personArray[DatabaseEnumComment];
    int rank = 1;
    personObject.commentObjectArray = [NSMutableArray array];
    if (commentString && ![commentString isEqualToString:@""]) {
        NSArray *commentArray = [commentString componentsSeparatedByString:COMMENT_SEPARATOR];
        for (NSString *commentJsonString in commentArray) {
            if (![commentJsonString isEqualToString:@""]) {
                NSDictionary *commentDictionary = [CommonFunctions deserializedDictionaryFromJSONString:commentJsonString];
                CommentObject *commentObject = [CommentObject commentObjectFromDicitonary:commentDictionary rank:rank++ statusCodeDict:[PersonObject statusDictionary] uuid:personObject.uuid];
                [personObject.commentObjectArray addObject:commentObject];
            }
        }
    }
    
    personObject.canEdit = [personArray[DatabaseEnumCanEdit] boolValue];

    if (IS_TRIAGEPIC) {
        // zone
        personObject.zone = personArray[DatabaseEnumZone];
        // patient ID
        personObject.patientId = personArray[DatabaseEnumPatientID];
        // hospital ID
        personObject.hospitalName = personArray[DatabaseEnumHospitalID];

    } else {
        // location
        personObject.location = [LocationObject locationByLocationDictionary:[CommonFunctions deserializedDictionaryFromJSONString:personArray[DatabaseEnumLocation]]];
        // status
        personObject.status = personArray[DatabaseEnumStatus];
    }
    
    
    NSMutableArray *arrayOfImagesURLs = [[personArray[DatabaseEnumDeleteImageURLs] componentsSeparatedByString:@","] mutableCopy];
    [arrayOfImagesURLs removeLastObject]; // last object is always a blank!
    personObject.imagesURLToDelete = arrayOfImagesURLs;
    
    //prevent null objects
    [personObject removeNSNulls]; // <null> <- generated by TriagePic
    [personObject removeNulls]; // (null) <- generated by PL & ReUnite
    
    return personObject;
}


@end


