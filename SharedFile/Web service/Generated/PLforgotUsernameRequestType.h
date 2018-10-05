/*
	PLforgotUsernameRequestType.h
	The interface definition of properties and methods for the PLforgotUsernameRequestType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLforgotUsernameRequestType : SoapObject
{
	NSString* _token;
	NSString* _email;
	
}
		
	@property (retain, nonatomic) NSString* token;
	@property (retain, nonatomic) NSString* email;

	+ (PLforgotUsernameRequestType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end