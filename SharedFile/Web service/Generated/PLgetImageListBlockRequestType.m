/*
	PLgetImageListBlockRequestType.h
	The implementation of properties and methods for the PLgetImageListBlockRequestType object.
	Generated by SudzC.com
*/
#import "PLgetImageListBlockRequestType.h"

@implementation PLgetImageListBlockRequestType
	@synthesize tokenStart = _tokenStart;
	@synthesize stride = _stride;
	@synthesize key = _key;

	- (id) init
	{
		if(self = [super init])
		{
			self.key = nil;

		}
		return self;
	}

	+ (PLgetImageListBlockRequestType*) createWithNode: (CXMLNode*) node
	{
		if(node == nil) { return nil; }
		return [[self alloc] initWithNode: node];
	}

	- (id) initWithNode: (CXMLNode*) node {
		if(self = [super initWithNode: node])
		{
			self.tokenStart = [[Soap getNodeValue: node withName: @"tokenStart"] intValue];
			self.stride = [[Soap getNodeValue: node withName: @"stride"] intValue];
			self.key = [Soap getNodeValue: node withName: @"key"];
		}
		return self;
	}

	- (NSMutableString*) serialize
	{
		return [self serialize: @"getImageListBlockRequestType"];
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
		[s appendFormat: @"<tokenStart>%@</tokenStart>", [NSString stringWithFormat: @"%i", self.tokenStart]];
		[s appendFormat: @"<stride>%@</stride>", [NSString stringWithFormat: @"%i", self.stride]];
		if (self.key != nil) [s appendFormat: @"<key>%@</key>", [CommonFunctions escapeForXML:self.key]];

		return s;
	}
	
	- (NSMutableString*) serializeAttributes
	{
		NSMutableString* s = [super serializeAttributes];

		return s;
	}
	
	- (BOOL)isEqual:(id)object{
		if(object != nil && [object isKindOfClass:[PLgetImageListBlockRequestType class]]) {
			return [[self serialize] isEqualToString:[object serialize]];
		}
		return NO;
	}
	
	- (NSUInteger)hash{
		return [Soap generateHash:self];

	}

@end