//
//  HospitalObject.h
//  Reunite
//


#import <Foundation/Foundation.h>

@interface HospitalObject : NSObject
@property (nonatomic, strong) NSString *hospitalName;
@property (nonatomic, assign) int hospitalId;
@property (nonatomic, strong) NSArray *hospitalZones;
@property (nonatomic, strong) NSString *hospitalPrefix;
@property (nonatomic, strong) NSMutableArray *hospitalAutoPatientId;

// Web service parser
+ (void)setHospitalList:(NSString *)hospitalList;
+ (HospitalObject *)hospitalObjectWithDict:(NSDictionary *)hospitalDict;

+ (NSMutableArray *)hospitalNamesArray;
+ (NSMutableDictionary *)hospitalNameToIdDictionary;

// patient ID
+ (NSMutableArray *)patientIdForHospitalId:(int)hospitalId;
+ (void)setPatientIdArray:(NSMutableArray *)patientIds forHospitalId:(int)hospitalId;
@end
