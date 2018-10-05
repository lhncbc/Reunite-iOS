/*
	PLgetHospitalPolicyResponseType.h
	The interface definition of properties and methods for the PLgetHospitalPolicyResponseType object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface PLgetHospitalPolicyResponseType : SoapObject
{
	NSString* _patientIdPrefix;
	BOOL _patientIdSuffixVariable;
	int _patientIdSuffixFixedLength;
	NSString* _triageZoneList;
	BOOL _photoRequired;
	BOOL _honorNoPhotoRequest;
	BOOL _photographerNameRequired;
	int _errorCode;
	NSString* _errorMessage;
	
}
		
	@property (retain, nonatomic) NSString* patientIdPrefix;
	@property BOOL patientIdSuffixVariable;
	@property int patientIdSuffixFixedLength;
	@property (retain, nonatomic) NSString* triageZoneList;
	@property BOOL photoRequired;
	@property BOOL honorNoPhotoRequest;
	@property BOOL photographerNameRequired;
	@property int errorCode;
	@property (retain, nonatomic) NSString* errorMessage;

	+ (PLgetHospitalPolicyResponseType*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end