/*
	PLappCheckRequestType.h
	The implementation of properties and methods for the PLappCheckRequestType object.
	Generated by SudzC.com
*/
#import "PLappCheckRequestType.h"

@implementation PLappCheckRequestType
	@synthesize token = _token;
	@synthesize query_string = _query_string;

	- (id) init
	{
		if(self = [super init])
		{
			self.token = nil;
			self.query_string = nil;

		}
		return self;
	}

	+ (PLappCheckRequestType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.token = [Soap getNodeValue: node withName: @"token"];
			self.query_string = [Soap getNodeValue: node withName: @"query_string"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"appCheckRequestType"];
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
		if (self.query_string != nil) [s appendFormat: @"<query_string>%@</query_string>", [CommonFunctions escapeForXML:self.query_string]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	- (BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[PLappCheckRequestType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end