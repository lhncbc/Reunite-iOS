//
//  CommonFunctions.h
//  ReUnite + TriagePic
//

//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "BTSplitViewDefinition.h"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil]; [alert show]; }
#else
#   define DLog(...)
#   define ULog(...)
#endif
#define ALog(fmt, ...) DLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

// Every common key for UserDefualt
#define GLOBAL_KEY_EVENT_ARRAY @"GLOBAL_KEY_EVENT_ARRAY"
#define GLOBAL_KEY_EVENT_UPDATE_TIME @"GLOBAL_KEY_EVENT_UPDATE_TIME"


//#define GLOBAL_KEY_QUE_DELETE_DICT @"GLOBAL_KEY_QUE_DELETE_DICT" // for deletion

#define GLOBAL_KEY_SERVER_HTTP @"GLOBAL_KEY_SERVER_HTTP" // host http or https
#define GLOBAL_KEY_SERVER_NAME @"GLOBAL_KEY_SERVER_NAME" // name like pl.nlm.nih.gov
#define GLOBAL_KEY_SERVER_API_VERSION @"GLOBAL_KEY_SERVER_API_VERSION" // api
#define GLOBAL_KEY_SERVER_END_POINT_ARRAY @"GLOBAL_KEY_SERVER_END_POINT_ARRAY" // store all the endpoints!

#define GLOBAL_KEY_CURRENT_UNIQUE_ID @"GLOBAL_KEY_CURRENT_UNIQUE_ID"
#define GLOBAL_KEY_CURRENT_USERNAME @"GLOBAL_KEY_CURRENT_USERNAME"
#define GLOBAL_KEY_CURRENT_EVENT @"GLOBAL_KEY_CURRENT_EVENT"
#define GLOBAL_KEY_CURRENT_HOSPITAL @"GLOBAL_KEY_CURRENT_HOSPITAL"
#define GLOBAL_KEY_FILTER_HOSPITAL @"GLOBAL_KEY_FILTER_HOSPITAL"
 #define GLOBAL_KEY_CURRENT_SHORTEVENT @"#GLOBAL_KEY_CURRENT_SHORTEVENT"
#define GLOBAL_KEY_FIND_NEEDS_REFRESH @"GLOBAL_KEY_FIND_NEEDS_REFRESH"

#define GLOBAL_KEY_FIRST_TIME_CODE @"GLOBAL_KEY_FIRST_TIME_CODE"

#define GLOBAL_KEY_STATUS_LOGIN @"GLOBAL_KEY_STATUS_LOGIN"
#define GLOBAL_KEY_STATUS_FIRST_TIME @"GLOBAL_KEY_STATUS_FIRST_TIME"
#define GLOBAL_KEY_STATUS_PRIVACY_AGREE @"GLOBAL_KEY_STATUS_PRIVACY_AGREE"

#define GLOBAL_KEY_PUSH_TOKEN_STRING @"GLOBAL_KEY_PUSH_TOKEN_STRING"
#define GLOBAL_KEY_PUSH_TOKEN_STATUS @"globalKeyDidPushToken" // lowercase because of the older version did it this way!

#define STRING_BURDEN_OMB_NUMBER @"OMB# 0925-0612, EXP:08/31/2019"
#define STRING_BURDEN_STATEMENT @"Public reporting burden for this collection of information is estimated to average 3 minutes per response. This estimate includes the time for reviewing instructions, gathering, and entering  data. An agency may not conduct or sponsor, and a person is not required to respond to, a collection of information unless it displays a currently valid OMB control number. Send comments regarding this burden estimate or any other aspect of this collection of information, including suggestions for reducing this burden, to: NIH, Project Clearance Branch, 6705 Rockledge Drive, MSC 7974, Bethesda, MD 20892-7974, ATTN: PRA (0925-0612). Do not return the completed form to this address."

#define STRING_PASSWORD_GUIDE @"Passwords must adhere to the following rules :\n1. The minimum length of the password is 8 characters.\n2. The maximum length of the password is 16 characters.\n3. Must have at least one uppercase character.\n4. Must have at least one lowercase character.\n5. Must have at least one numeral (0-9).\n6. The password cannot contain your username."

#ifdef _IS_TRIAGEPIC
#warning THIS NEEDS CHANGING
#define STRING_PRIVACY_STATEMENT @"The U.S. National Library of Medicine (NLM), part of the U.S. Department of Health and Human Services, has in its mission the development of communication systems technology to improve the delivery of health information. The TriagePic app is designed to speed uploading necessary personal information about missing (and found) people to NLM's TriageTrak (TT) service available at https://triageTrak.nlm.nih.gov. This service being provided for the explicit purpose of assisting in post-disaster family reunification as well as studying the utility of such tools in responding to disasters. More information on the TT service and the Lost Person Finder Project can be found at http://lpf.nlm.nih.gov\n\nNote: \n  • Submission of information using this app is voluntary.\n  • All submitted information may be made publicly available.\n  • Data stored using this tool may not be moderated and could be searchable by all visitors to NLM's PL Web site.\n  • Data stored within the app is not encrypted at this time.\n  • The user of this app must have a TT service account to upload information about missing or found people.\n  • No TT login is necessary to search the site.\n  • Information reported on an individual and sender’s provided contact information may be disseminated to other Government agencies or other institutions assisting the reunification efforts after any disaster where U.S. Government relief efforts are being provided.\n  • For missing person data provided following a disaster: If you hear from the person you are concerned about, please follow instructions at the TT Web Site to update their status.\n  • The application does not track user location\n  • User location is detected on explicit user action to aid address lookup"
#else
#define STRING_PRIVACY_STATEMENT @"The U.S. National Library of Medicine (NLM), part of the U.S. Department of Health and Human Services, has in its mission the development of communication systems technology to improve the delivery of health information. The Reunite app is designed to speed uploading necessary personal information about missing (and found) people to NLM's People Locator (PL) service available at https://pl.nlm.nih.gov. This service being provided for the explicit purpose of assisting in post-disaster family reunification as well as studying the utility of such tools in responding to disasters. More information on the PL service and the Lost Person Finder Project can be found at http://lpf.nlm.nih.gov\n\nNote: \n  • Submission of information using this app is voluntary.\n  • All submitted information may be made publicly available.\n  • Data stored using this tool may not be moderated and could be searchable by all visitors to NLM's PL Web site.\n  • Data stored within the app is not encrypted at this time.\n  • The user of this app must have a PL service account to upload information about missing or found people.\n  • No PL login is necessary to search the site.\n  • Information reported on an individual and sender’s provided contact information may be disseminated to other Government agencies or other institutions assisting the reunification efforts after any disaster where U.S. Government relief efforts are being provided.\n  • For missing person data provided following a disaster: If you hear from the person you are concerned about, please follow instructions at the PL Web Site to update their status.\n  • The application does not track user location\n  • User location is detected on explicit user action to aid address lookup"
#endif

// For Settings
#define GLOBAL_KEY_SETTINGS_FACE_DETECTION @"Face Detection"
#define GLOBAL_KEY_SETTINGS_AUTO_UPLOAD @"Auto Upload"
#define GLOBAL_KEY_SETTINGS_FAMILY_NAME @"Family Name"
#define GLOBAL_KEY_SETTINGS_STATUS @"Status"
#define GLOBAL_KEY_SETTINGS_LOCATION @"Location"
#define GLOBAL_KEY_SETTINGS_FACE_NOT_FOUND @"Face Not Found"
#define GLOBAL_KEY_SETTINGS_GPS_INACCURATE @"GPS Inaccuracy"
#define GLOBAL_KEY_SETTINGS_SERVER_END_POINT @"Server"
#define GLOBAL_KEY_SETTINGS_SERVER_REMOVE @"Remove"

// for Saved info
#define GLOBAL_KEY_SAVED_FAMILY_NAME @"GLOBAL_KEY_SAVED_FAMILY_NAME"
#define GLOBAL_KEY_SAVED_STATUS @"GLOBAL_KEY_SAVED_STATUS"
#define GLOBAL_KEY_SAVED_LOCATION @"GLOBAL_KEY_SAVED_LOCATION"

// Notification
#define NOTIFICATION_SAVE_AND_EDIT @"NOTIFICATION_SAVE_AND_EDIT"
#define NOTIFICATION_DEVICE_SHAKED @"NOTIFICATION_DEVICE_SHAKED"

#ifdef _IS_TRIAGEPIC
#define IS_TRIAGEPIC YES
#else
#define IS_TRIAGEPIC NO
#endif


@interface CommonFunctions : NSObject
// Connectivity
+ (BOOL)hasConnectivity;
+ (BOOL)canConnectTo:(NSString *)urlString;
+ (int)currentConnectionTech;

// JSON serialization
+ (NSString *)serializedJSONStringFromDictionaryOrArray:(id)object;
+ (id)deserializedDictionaryFromJSONString:(NSString *)jsonString;

// XML Escape
+ (NSString *)escapeForXML:(NSString *)string;

// Date Manipulation
+ (NSDate *)getDateFromStandardString:(NSString *)timeString;
+ (NSString *)getDateRepresentationByDate:(NSDate *)date withLongFormat:(BOOL)isLongFormat;
+ (NSString *)getStandardRepresentationFromDate:(NSDate *)date;

// Logging
+ (void)printCGRect:(CGRect)rect;

// Common UI element
+ (UIFont *)normalFont;
+ (UIFont *)fontNormalDeviceSpecific:(BOOL)isDeviceSpecific;
+ (UIFont *)fontSmallDeviceSpecific:(BOOL)isDeviceSpecific;

// Color manipulating (-1 to +1)
// -1 will return black
// +1 will return white
+ (UIColor *)addLight:(CGFloat)lightValue ToColor:(UIColor *)color;

// Device validation
+ (BOOL)isPad;
+ (BOOL)is4InchesScreen;
+ (BOOL)is35InchesScreen;

// Data Encoding
+ (NSString *)base64EncodeStringFromImage:(UIImage *)image;
+ (UIImage *)base64DecodeImageFromString:(NSString *)string;

// Time
+ (NSString *)timeDurationFrom:(NSDate *)fromDate to:(NSDate *)toDate;

// Server Stuff
+ (NSArray *)splitStringForEndPointWebServiceURL:(NSString *)string; // Returns @[http,endpoint,version]
+ (BOOL)verifyStringForEndPointWebServiceURL:(NSString *)string;
+ (BOOL)verifyStringForEmailAddress:(NSString *)string;

// App related
+ (NSString *)siteName;
+ (NSString *)appName;

@end
