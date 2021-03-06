/*
	PLregisterUserRequestType.h
	The interface definition of properties and methods for the PLregisterUserRequestType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLregisterUserRequestType : SoapObject
{
	NSString* _token;
	NSString* _username;
	NSString* _emailAddress;
	NSString* _password;
	NSString* _givenName;
	NSString* _familyName;
	
}
		
	@property (retain, nonatomic) NSString* token;
	@property (retain, nonatomic) NSString* username;
	@property (retain, nonatomic) NSString* emailAddress;
	@property (retain, nonatomic) NSString* password;
	@property (retain, nonatomic) NSString* givenName;
	@property (retain, nonatomic) NSString* familyName;

	+ (PLregisterUserRequestType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
