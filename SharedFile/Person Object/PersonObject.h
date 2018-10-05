//
//  PersonObject.h
//  ReUnite + TriagePic
//

#import <Foundation/Foundation.h>
#import "ImageObject.h"
#import "LocationObject.h"
#import "CommentObject.h"
#import "HospitalObject.h"


#define PERSON_TYPE_FIND @"PERSON_TYPE_FIND"
#define PERSON_TYPE_SAVE @"PERSON_TYPE_SAVE"
#define PERSON_TYPE_OUTBOX @"PERSON_TYPE_OUTBOX"
#define PERSON_TYPE_SENT @"PERSON_TYPE_SENT"
#define PERSON_TYPE_DRAFT @"PERSON_TYPE_DRAFT"

#define KEY_GIVEN_NAME @"Full Name"
#define KEY_FAMILY_NAME @"Family Name"
#define KEY_CONDITION @"Condition"
#define KEY_ZONE @"Zone"
//#define KEY_AGE_MAXIMUM @"Maximum Age"
#define KEY_AGE_MINIMUM @"Approximate Age"
#define KEY_AGE @"Age"
#define KEY_ABOVE_18 @"Age: 18+"
#define KEY_PATIENT_ID @"Patient ID"
#define KEY_HOSPITAL_NAME @"Hospital"
#define KEY_NOTE @"Note"
#define KEY_GENDER @"Gender"
#define KEY_TIME @"creationtime"

#define TAG_FIND 51
#define TAG_SAVED 52
#define TAG_DRAFT 53
#define TAG_OUTBOX 54
#define TAG_SENT 55

#define COMMENT_SEPARATOR @";;"

@protocol PersonObjectDelegate <NSObject>
@optional
//- (void)didFinishedDownloadImagesForUUID:(NSString *)uuid;
- (void)didFinishedDownloadImagesForPersonObject:(id)personObject;
@end

@interface PersonObject : NSObject <ImageObjectDelegate>
//everything in a person
@property (assign,nonatomic) int personID;
@property (strong,nonatomic) NSString *type;
@property (strong,nonatomic) NSString *givenName;
@property (strong,nonatomic) NSString *familyName;
@property (strong,nonatomic) NSString *status;
@property (strong,nonatomic) NSString *gender;
@property (strong,nonatomic) NSString *ageMin;
@property (strong,nonatomic) NSString *ageMax;
@property (strong,nonatomic) NSString *creationtime;
@property (strong,nonatomic) NSString *event;
@property (strong,nonatomic) NSDate *lastUpdated;
@property (strong,nonatomic) NSString *webLink;
@property (strong,nonatomic) NSString *uuid;
@property (strong,nonatomic) NSString *additionalDetail;
@property (strong,nonatomic) NSMutableArray *imageObjectArray;
@property (strong,nonatomic) NSMutableArray *commentObjectArray;
@property (strong,nonatomic) LocationObject *location;
@property (strong,nonatomic) UIImage *smallDisplayImage; //show as thumbnail on list, only called on and stored when being displayed
@property (assign,nonatomic) BOOL canEdit;
@property (strong,nonatomic) NSMutableArray *imagesURLToDelete;

// Triage Pic stuff
@property (strong, nonatomic) NSString *zone;
@property (strong, nonatomic) NSString *patientId;
@property (strong, nonatomic) NSString *hospitalName;

//delegate
@property (weak,nonatomic) id<PersonObjectDelegate> delegate;

- (id)initWithPersonID:(int)personID
                  type:(NSString *)type
             givenName:(NSString *)givenName
            familyName:(NSString *)familyName
                status:(NSString *)status
                gender:(NSString *)gender
                ageMin:(NSString *)ageMin
                ageMax:(NSString *)ageMax
                 event:(NSString *)event
           lastUpdated:(NSDate *)lastUpdated
               webLink:(NSString *)webLink
                  uuid:(NSString *)uuid
      additionalDetail:(NSString *)additionalDetail
      imageObjectArray:(NSMutableArray *)imageObjectArray
    commentObjectArray:(NSMutableArray *)commentObjectArray
              location:(LocationObject *)location
               canEdit:(BOOL)canEdit;

//empty object
+ (id)emptyPersonObject;
+ (id)samplePersonObject;

//web service serializer and deserializer
- (id)initWithPersonDictionary:(NSDictionary *)personDictionary type:(NSString *)type event:(NSString *)event backgroundDownload:(BOOL)backgroundDownload delegate:(id)delegate;
- (NSString *)serializedXMLToUpload;
- (NSString *)serializedXMLToUploadToExpire:(BOOL)toExpire;
- (NSString *)serializedJSONToUpload; // Triage Pic
- (NSString *)serializedJSONToUploadDelete; // Triage Pic

- (NSString *)serializedJSONToUploadToExpire:(BOOL)toExpire;
- (NSDictionary *)serializedJSONDictToDelete:(BOOL)toExpire;


//storage serializer and deserializer
//- (id)initWithPersonArray:(NSArray *)personArray;
//- (NSArray *)serializedArrayToStorage;

// Helper
- (void)removeNSNulls;
- (void)removeNulls;

//display
- (NSString *)getLastUpdatedStringLongFormat:(BOOL)longFormat;
- (BOOL)createSmallImage;
- (void)removeSmallImage;

//globalKey
+ (NSMutableArray *)eventArray;
+ (NSDictionary *)eventLongNameToShortNameDict;
+ (NSDictionary *)sortByDictionary;
+ (NSDictionary *)statusDictionary;
+ (NSDictionary *)statusDictionaryUpload;
+ (NSDictionary *)genderDictionary;
+ (NSDictionary *)genderDictionaryUpload;
+ (UIColor *)colorForStatus:(NSString *)status;

+ (int)tagForType:(NSString *)type;
+ (NSString *)typeForTag:(int)tag;


//TriagePic
//+ (NSMutableArray *)hospitalArray;
//+ (NSDictionary *)hospitalNameToIdDict;
+ (NSDictionary *)colorZoneDictionary;
+ (UIColor *)colorForZone:(NSString *)zone;
@end
