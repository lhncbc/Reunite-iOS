//
//  PLfollowRecordResponseType.h
//  Reunite
//


#import "Soap.h"


@interface PLfollowRecordResponseType : SoapObject
{
    int _errorCode;
    NSString* _errorMessage;
    
}

@property int errorCode;
@property (retain, nonatomic) NSString* errorMessage;

+ (PLfollowRecordResponseType*) createWithNode: (CXMLNode*) node;
- (id) initWithNode: (CXMLNode*) node;
- (NSMutableString*) serialize;
- (NSMutableString*) serialize: (NSString*) nodeName;
- (NSMutableString*) serializeAttributes;
- (NSMutableString*) serializeElements;

@end
