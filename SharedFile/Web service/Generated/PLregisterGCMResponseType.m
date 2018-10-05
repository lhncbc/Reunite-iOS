//
//  PLregisterGoogleCloudMessagingResponseType.m
//  Reunite
//


#import "PLregisterGCMResponseType.h"

@implementation PLregisterGCMResponseType
@synthesize errorCode = _errorCode;
@synthesize errorMessage = _errorMessage;

- (id) init
{
    if(self = [super init])
    {
        self.errorMessage = nil;
        
    }
    return self;
}

+ (PLregisterGCMResponseType*) createWithNode: (CXMLNode*) node
{
    if(node == nil) { return nil; }
    return [[self alloc] initWithNode: node];
}

- (id) initWithNode: (CXMLNode*) node {
    if(self = [super initWithNode: node])
    {
        self.errorCode = [[Soap getNodeValue: node withName: @"errorCode"] intValue];
        self.errorMessage = [Soap getNodeValue: node withName: @"errorMessage"];
    }
    return self;
}

- (NSMutableString*) serialize
{
    return [self serialize: @"registerApplePushTokenResponseType"];
}

- (NSMutableString*) serialize: (NSString*) nodeName
{
    NSMutableString* s = [NSMutableString string];
    [s appendFormat: @"<%@", nodeName];
    [s appendString: [self serializeAttributes]];
    [s appendString: @">"];
    [s appendString: [self serializeElements]];
    [s appendFormat: @"</%@>", nodeName];
    return s;
}

- (NSMutableString*) serializeElements
{
    NSMutableString* s = [super serializeElements];
    [s appendFormat: @"<errorCode>%@</errorCode>", [NSString stringWithFormat: @"%i", self.errorCode]];
    if (self.errorMessage != nil) [s appendFormat: @"<errorMessage>%@</errorMessage>", [CommonFunctions escapeForXML:self.errorMessage]];
    
    return s;
}

- (NSMutableString*) serializeAttributes
{
    NSMutableString* s = [super serializeAttributes];
    
    return s;
}

- (BOOL)isEqual:(id)object{
    if(object != nil && [object isKindOfClass:[PLregisterGCMResponseType class]]) {
        return [[self serialize] isEqualToString:[object serialize]];
    }
    return NO;
}

- (NSUInteger)hash{
    return [Soap generateHash:self];
    
}
@end
