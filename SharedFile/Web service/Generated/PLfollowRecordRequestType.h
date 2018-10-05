//
//  PLfollowRecordRequestType.h
//  Reunite
//

//#import <Foundation/Foundation.h>
//
//@interface PLfollowRecordRequestType : NSObject
//
//@end


#import "Soap.h"


@interface PLfollowRecordRequestType : SoapObject
{
    NSString* _token;
    NSString* _uuid;
   int _sub;
    
}

@property (retain, nonatomic) NSString* token;
@property (retain, nonatomic) NSString* uuid;
@property  int sub;

+ (PLfollowRecordRequestType*) createWithNode: (CXMLNode*) node;
- (id) initWithNode: (CXMLNode*) node;
- (NSMutableString*) serialize;
- (NSMutableString*) serialize: (NSString*) nodeName;
- (NSMutableString*) serializeAttributes;
- (NSMutableString*) serializeElements;

@end
