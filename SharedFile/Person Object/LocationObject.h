//
//  LocationObject.h
//  ReUnite + TriagePic

#import <Foundation/Foundation.h>
@import MapKit;

#define KEY_STREET_1 @"Street 1"
#define KEY_STREET_2 @"Street 2"
#define KEY_CITY @"City"
#define KEY_REGION @"Region"
#define KEY_COUNTRY @"Country"
#define KEY_POSTAL @"Postal code"


@interface LocationObject : NSObject
@property (assign,nonatomic) BOOL hasAddress;
@property (strong,nonatomic) NSString *street1;
@property (strong,nonatomic) NSString *street2;
@property (strong,nonatomic) NSString *city;
@property (strong,nonatomic) NSString *region;
@property (strong,nonatomic) NSString *zip;
@property (strong,nonatomic) NSString *country;
@property (assign,nonatomic) BOOL hasGPS;
@property (assign,nonatomic) CLLocationCoordinate2D gpsCoordinates;
@property (assign,nonatomic) MKCoordinateSpan span;

//reference
- (id)initWithStreet:(NSString *)street1 street2:(NSString *)street2 city:(NSString *)city region:(NSString *)region zip:(NSString *)zip country:(NSString *)country hasGPS:(BOOL)hasGPS gpsCoordinates:(CLLocationCoordinate2D)gpsCoordinates span:(MKCoordinateSpan)span;

//return location object
+ (id)locationByLocationDictionary:(NSDictionary *)locationDictionary;
+ (id)emptyLocationOrSavedLocation;
+ (id)sampleLocation;
+ (id)emptyLocation;
+ (id)locationWithString:(NSString *)locationString;

//for display
- (NSString *)getLocationString;

//for upload
- (NSString *)getLocationXML;
- (NSString *)getLocationJSONSerializedString;
- (NSDictionary *)getLocationDictionary;

// helper
- (void)removeNSNulls;
- (void)removeNulls;

//lookup and verify
+ (NSArray *)getpossibleLocationFromString:(NSString *)locationString;
+ (void)getpossibleLocationFromString:(NSString *)locationString target:(id)target selector:(SEL)selector;
+ (NSArray *)getpossibleLocationFromGPS:(CLLocationCoordinate2D)coordinate;
+ (void)getpossibleLocationFromGPS:(CLLocationCoordinate2D)coordinate target:(id)target selector:(SEL)selector;


@end
