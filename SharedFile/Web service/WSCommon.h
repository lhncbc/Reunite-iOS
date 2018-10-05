//
//  WSCommon.h
//  ReUnite + TriagePic
//


#import <Foundation/Foundation.h>
#import "PLplusWebServices.h"
#import "PersonObject.h"
#import "SSKeychain.h"
#import <SystemConfiguration/SCNetworkReachability.h>


#ifdef _IS_TRIAGEPIC
#define SERVICE_NAME @"Reunite"
#else
#define SERVICE_NAME @"Triagepic"
#endif

#define NOTIFICATION_LOG_OUT @"NOTIFICATION_LOG_OUT"

@protocol WSCommonDelegate;
@interface WSCommon : NSObject
@property (strong, nonatomic) SoapObject *requestObject;
@property (strong, nonatomic) id request;
@property (strong, nonatomic) id response;
@property (strong, nonatomic) NSMutableData* wasreceivedData;

@property (assign, nonatomic) SEL webServiceSelector;
@property (assign, nonatomic) SEL callBackSelector;
@property (weak, nonatomic) id<WSCommonDelegate> delegate;


//****** NOTE ******//
/*
 the following code is made to work with the updated version of code parsed with Sudzc.com. To add new webservices or change any parameter inside a web service, you can do one of the two things.
 1. Make your own requestType and responseType and add the service call into PLWebService.h and .m file 
 or 
 2. get the file from Sudzc.com and apply the following find/replace parameter. Then add the service call to PLWebService.h and .m (Dont forget to #include them)
 
From: (Regex)
    \[\[(.*) stringByReplacingOccurrencesOfString:@"\\"" withString:@"&quot;"] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]
To: (Regex)
    \[CommonFunctions escapeForXML:\1\]
 
From: 
    @"true"
To:
    @YES
 
From
    @"false"
To:
    @NO

From:
    \(SoapRequest\*\)(.*)action;

To: 
    \(SoapRequest\*\)\1action params:\(NSMutableString \*\)params deserializeTo:\(id\)deserializeTo;
 
 
From:
    \(SoapRequest\*\)(.*)_target action:\(SEL\)_action \{
To:
    \(SoapRequest\*\)\1target action:\(SEL\)action params:\(NSMutableString \*\)params deserializeTo:\(id\)deserializeTo \{

From:
    - \(SoapRequest\*\)(.*)handler
    - \(SoapRequest\*\)(.*)completionBlock;
 to : nothing
*/

+ (void)updateEndPoint;
// event list
+ (void)getEventDataWithDelegate:(id<WSCommonDelegate>)delegate;
// authentication
+ (void)getAnonymousTokenWithDelegate:(id<WSCommonDelegate>)delegate;
+ (void)authenticateWithUsername:(NSString *)username password:(NSString *)password delegate:(id<WSCommonDelegate>)delegate;
+ (void)registerUsername:(NSString *)username password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email delegate:(id<WSCommonDelegate>)delegate;
+ (void)forgotPasswordForEmail:(NSString *)email delegate:(id<WSCommonDelegate>)delegate;
+(void)confirmUser:(NSString *)Code delegate:(id<WSCommonDelegate>)delegate;




// search
+ (void)searchCountWithSearchRequestType:(PLsearchRequestType *)request delegate:(id<WSCommonDelegate>)delegate;
+ (void)searchWithSearchRequestType:(PLsearchRequestType *)request delegate:(id<WSCommonDelegate>)delegate;
+ (void)searchWithSearchUuidRequestType:(PLsearchRequestType *)request delegate:(id<WSCommonDelegate>)delegate;
// upload a comment
+ (void)uploadCommentWithCommentObject:(CommentObject *)commentObject delegate:(id<WSCommonDelegate>)delegate;
// remove record
//+ (void)removeRecordFromServerWithUUID:(NSString *)uuid reason:(NSString *)reason delegate:(id<WSCommonDelegate>)delegate;
+ (void)removeRecordFromServerWithPersonObject:(PersonObject *)personObject reason:(NSString *)reason delegate:(id<WSCommonDelegate>)delegate;
// report Abuse
+ (void)reportAbuseWithUUID:(NSString *)uuid reason:(NSString *)reason delegate:(id<WSCommonDelegate>)delegate;
// Ping - A peculiar structure!
// it needs to do a 1-2 punch
// 1 - call this with no parameter
// 2 - call it with the duration it takes to return the first call

//+(void)followRecord:(NSString *)uuid sub:(int)sub delegate:(id<WSCommonDelegate>)delegate;
+ (void)pingWithDelegate:(id<WSCommonDelegate>)delegate;
// upload a person record
+ (void)reportPersonWithPersonObject:(PersonObject *)personObject delegate:(id<WSCommonDelegate>)delegate;
//+ (void)rereportPersonWithPersonObject:(PersonObject *)personObject delegate:(id<WSCommonDelegate>)delegate;

// Update Token on PL server
+ (void)registerPushTokenToPL;
//+ (void)registerPushTokenToPL:(NSString *)CustomToken;

+(void)setUserPref:(NSString *)Code delegate:(id<WSCommonDelegate>)delegate;


// Cleaning up
+ (BOOL)storeToken:(NSString *)token;
+ (BOOL)removeToken;
+(NSString *)retrieveToken;
// Get the current Web Service URL
+ (NSString *)currentServerString;


// TriageTrak stuff
+ (void)getHospitalListWithDelegate:(id<WSCommonDelegate>)delegate;
+ (void)getAutoGenPatientForHospitalId:(int)hospitalID withDelegate:(id<WSCommonDelegate>)delegate;
@end

@protocol WSCommonDelegate <NSObject>
@optional
- (void)wsGetEventDataWithSuccess:(BOOL)success eventArray:(NSArray *)eventArray error:(id)error;
- (void)wsGetAnonTokenWithSuccess:(BOOL)success error:(id)error;
- (void)wsAuthenticateWithSuccess:(BOOL)success error:(id)error;
- (void)wsRegisterWithSuccess:(BOOL)success error:(id)error;
- (void)wsResetPasswordWithSuccess:(BOOL)success error:(id)error;
- (void)wsGetSearchCountResultWithSuccess:(BOOL)success count:(int)count error:(id)error;
- (void)wsGetSearchResultWithSuccess:(BOOL)success resultArray:(NSArray *)resultArray error:(id)error;
- (void)wsAddCommentWithSuccess:(BOOL)success error:(id)error;
- (void)wsRemoveRecordWithSuccess:(BOOL)success error:(id)error;
- (void)wsfollowRecordWithSuccess:(BOOL)success error:(id)error;
- (void)wsconfirmCodeWithSuccess:(BOOL)success error:(id)error;



- (void)wsReportAbuseWithSuccess:(BOOL)success error:(id)error;
- (void)wsPingWithSuccess:(BOOL)success ping:(int)ping error:(id)error;
//- (void)wsReportPersonWithSuccess:(BOOL)success personObject:(PersonObject *)personObject error:(id)error;
//- (void)wsRereportPersonWithSuccess:(BOOL)success personObject:(PersonObject *)personObject error:(id)error;
- (void)wsReportPersonWithSuccess:(BOOL)success uuid:(NSString *)uuid error:(id)error;
- (void)wsReReportPersonWithSuccess:(BOOL)success error:(id)error;

//TriagePic
- (void)wsGetHospitalListWithSuccess:(BOOL)success hospitalList:(NSArray *)hospitalList error:(id)error;
- (void)wsGetReservedIdListWithSuccess:(BOOL)success hospitalID:(int)hospitalId patientIDList:(NSArray *)patientIDList error:(id)error;
@end
