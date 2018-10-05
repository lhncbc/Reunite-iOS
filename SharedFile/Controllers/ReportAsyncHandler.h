//
//  ReportAsyncHandler.h
//  ReUnite + TriagePic
//


#import <Foundation/Foundation.h>
#import "PersonObject.h"
#import "WSCommon.h"

@interface ReportAsyncHandler : NSObject <WSCommonDelegate>
+ (ReportAsyncHandler *)sharedInstanceWithPersonObject:(PersonObject *)personObject;
+ (void)checkAndUploadFromOutBox;
@property (nonatomic, strong) PersonObject *personObject;
@end
