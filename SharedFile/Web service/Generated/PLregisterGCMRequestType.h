//
//  PLregisterGoogleCloudMessagingRequestType.h
//  Reunite
//


#import <Foundation/Foundation.h>
#import "Soap.h"





@interface PLregisterGCMRequestType : SoapObject
{
    NSString* _token;
    NSString* _deviceID;
   // NSString* _pushToken;
    //NSString* _username;
    NSString* _deviceName;
    
}

@property (retain, nonatomic) NSString* token;
@property (retain, nonatomic) NSString* deviceID;
//@property (retain, nonatomic) NSString* pushToken;
//@property (retain, nonatomic) NSString* username;
@property (retain, nonatomic) NSString* deviceName;

+ (PLregisterGCMRequestType*) createWithNode: (CXMLNode*) node;
- (id) initWithNode: (CXMLNode*) node;
- (NSMutableString*) serialize;
- (NSMutableString*) serialize: (NSString*) nodeName;
- (NSMutableString*) serializeAttributes;
- (NSMutableString*) serializeElements;

@end
