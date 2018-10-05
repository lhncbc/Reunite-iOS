//
//  PLregisterGoogleCloudMessagingResponseType.h
//  Reunite
//


#import <Foundation/Foundation.h>
#import "Soap.h"

@interface PLregisterGCMResponseType : SoapObject
{
    int _errorCode;
    NSString* _errorMessage;
    
}

@property int errorCode;
@property (retain, nonatomic) NSString* errorMessage;

+ (PLregisterGCMResponseType*) createWithNode: (CXMLNode*) node;
- (id) initWithNode: (CXMLNode*) node;
- (NSMutableString*) serialize;
- (NSMutableString*) serialize: (NSString*) nodeName;
- (NSMutableString*) serializeAttributes;
- (NSMutableString*) serializeElements;



@end
