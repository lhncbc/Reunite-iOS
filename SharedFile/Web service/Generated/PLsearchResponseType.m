/*
	PLsearchResponseType.h
	The implementation of properties and methods for the PLsearchResponseType object.
	Generated by SudzC.com
*/
#import "PLsearchResponseType.h"

@implementation PLsearchResponseType
	@synthesize resultSet = _resultSet;
	@synthesize recordsFound = _recordsFound;
	@synthesize timeElapsed = _timeElapsed;
	@synthesize errorCode = _errorCode;
	@synthesize errorMessage = _errorMessage;

	- (id) init
	{
		if(self = [super init])
		{
			self.resultSet = nil;
			self.errorMessage = nil;

		}
		return self;
	}

	+ (PLsearchResponseType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.resultSet = [Soap getNodeValue: node withName: @"resultSet"];
			self.recordsFound = [[Soap getNodeValue: node withName: @"recordsFound"] intValue];
			self.timeElapsed = [[Soap getNodeValue: node withName: @"timeElapsed"] doubleValue];
			self.errorCode = [[Soap getNodeValue: node withName: @"errorCode"] intValue];
			self.errorMessage = [Soap getNodeValue: node withName: @"errorMessage"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"searchResponseType"];
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
		if (self.resultSet != nil) [s appendFormat: @"<resultSet>%@</resultSet>", [CommonFunctions escapeForXML:self.resultSet]];
		[s appendFormat: @"<recordsFound>%@</recordsFound>", [NSString stringWithFormat: @"%i", self.recordsFound]];
		[s appendFormat: @"<timeElapsed>%@</timeElapsed>", [NSString stringWithFormat: @"%f", self.timeElapsed]];
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
		if(object != nil && [object isKindOfClass:[PLsearchResponseType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end
