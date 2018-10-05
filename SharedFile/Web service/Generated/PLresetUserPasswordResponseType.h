/*
	PLresetUserPasswordResponseType.h
	The interface definition of properties and methods for the PLresetUserPasswordResponseType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLresetUserPasswordResponseType : SoapObject
{
	BOOL _sent;
	int _errorCode;
	NSString* _errorMessage;
	
}
		
	@property BOOL sent;
	@property int errorCode;
	@property (retain, nonatomic) NSString* errorMessage;

	+ (PLresetUserPasswordResponseType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end
