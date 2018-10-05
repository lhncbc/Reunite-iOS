//
//  PLfollowRecordRequestType.m
//  Reunite
//


#import "PLfollowRecordRequestType.h"

@implementation PLfollowRecordRequestType

@synthesize token = _token;
@synthesize uuid = _uuid;
@synthesize sub = _sub;

- (id) init
{
    if(self = [super init])
    {
        self.token = nil;
        self.uuid = nil;
        self.sub = 1;
        
    }
    return self;
}

+ (PLfollowRecordRequestType*) createWithNode: (CXMLNode*) node
{
    if(node == nil) { return nil; }
    return [[self alloc] initWithNode: node];
}

- (id) initWithNode: (CXMLNode*) node {
    if(self = [super initWithNode: node])
    {
        self.token = [Soap getNodeValue: node withName: @"token"];
        self.uuid = [Soap getNodeValue: node withName: @"uuid"];
        self.sub = [[Soap getNodeValue: node withName: @"sub"]intValue];
    }
    return self;
}

- (NSMutableString*) serialize
{
    return [self serialize: @"reportAbuseRequestType"];
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
    if (self.token != nil) [s appendFormat: @"<token>%@</token>", [CommonFunctions escapeForXML:self.token]];
   //[s appendFormat: @"<sub>%@</sub>", [CommonFunctions escapeForXML:self.sub]];
    if (self.uuid != nil) [s appendFormat: @"<uuid>%@</uuid>", [CommonFunctions escapeForXML:self.uuid]];

    [s appendFormat: @"<errorCode>%@</errorCode>", [NSString stringWithFormat: @"%i", 1]];

    
    return s;
}

- (NSMutableString*) serializeAttributes
{
    NSMutableString* s = [super serializeAttributes];
    
    return s;
}

- (BOOL)isEqual:(id)object{
    if(object != nil && [object isKindOfClass:[PLfollowRecordRequestType class]]) {
        return [[self serialize] isEqualToString:[object serialize]];
    }
    return NO;
}

- (NSUInteger)hash{
    return [Soap generateHash:self];
    
}
@end



