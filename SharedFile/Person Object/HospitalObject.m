//
//  HospitalObject.m
//  Reunite
//

#import "HospitalObject.h"

#define GLOBAL_KEY_HOSPITAL_ARRAY @"GLOBAL_KEY_HOSPITAL_ARRAY"
#define GLOBAL_KEY_PATIENT_ID_ARRAY @"GLOBAL_KEY_PATIENT_ID_ARRAY"
#define GLOBAL_KEY_PATIENT_ID_HOSPITAL @"GLOBAL_KEY_PATIENT_ID_HOSPITAL"

@implementation HospitalObject

+ (void)setHospitalList:(NSString *)hospitalList
{
    [[NSUserDefaults standardUserDefaults] setObject:hospitalList forKey:GLOBAL_KEY_HOSPITAL_ARRAY];
    _hospitalIdToObjectDictionary = nil; // trigger a reimport sequence
    _hospitalNameToIdDictionary = nil;
}

+ (HospitalObject *)hospitalObjectWithDict:(NSDictionary *)hospitalDict
{
    HospitalObject *hospitalObject = [[HospitalObject alloc] init];
    [hospitalObject setHospitalId:[hospitalDict[@"hospital_uuid"] intValue]];
    [hospitalObject setHospitalName:hospitalDict[@"name"]];
    [hospitalObject setHospitalPrefix:@""]; // To be filled in when web service updated
    [hospitalObject setHospitalZones:@[]]; // To be filled when web service updated
    [hospitalObject setHospitalAutoPatientId:[NSMutableArray array]];
    return hospitalObject;
}

static NSMutableDictionary *_hospitalIdToObjectDictionary;
+ (NSMutableDictionary *)hospitalIdToObjectDictionary
{
    if (_hospitalIdToObjectDictionary == nil) {
        _hospitalIdToObjectDictionary = [NSMutableDictionary dictionary];
        
        NSString *hospitalListString = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_HOSPITAL_ARRAY];
        if (hospitalListString != nil) {
            NSArray *hospitalList = [CommonFunctions deserializedDictionaryFromJSONString:hospitalListString];
            for (NSDictionary *hospitalDict in hospitalList) {
                HospitalObject *hospitalObject = [HospitalObject hospitalObjectWithDict:hospitalDict];
                _hospitalIdToObjectDictionary[@(hospitalObject.hospitalId)] = hospitalObject;
            }
        }
    }
    return _hospitalIdToObjectDictionary;
}

static NSMutableDictionary *_hospitalNameToIdDictionary;
+ (NSArray *)hospitalNamesArray
{
    return [[HospitalObject hospitalNameToIdDictionary] allKeys];
}

+ (NSMutableDictionary *)hospitalNameToIdDictionary
{
    if (_hospitalNameToIdDictionary == nil) {
        _hospitalNameToIdDictionary = [NSMutableDictionary dictionary];
        
        for (NSNumber *hospitalId in [HospitalObject hospitalIdToObjectDictionary]) {
            HospitalObject *hospitalObject = _hospitalIdToObjectDictionary[hospitalId];
            _hospitalNameToIdDictionary[hospitalObject.hospitalName] = hospitalId;
        }
    }
    return _hospitalNameToIdDictionary;
}
/*
+ (HospitalObject *)hospitalObjectForHospitalName:(NSString *)hospitalName
{
    //_hospitalList[hospitalName]
}
*/
// patient ID
+ (NSMutableArray *)patientIdForHospitalId:(int)hospitalId
{
    HospitalObject *hospitalObject = [_hospitalIdToObjectDictionary objectForKey:@(hospitalId)];
    return hospitalObject.hospitalAutoPatientId;
}

+ (void)setPatientIdArray:(NSMutableArray *)patientIds forHospitalId:(int)hospitalId
{
    HospitalObject *hospitalObject = [_hospitalIdToObjectDictionary objectForKey:@(hospitalId)];
    [hospitalObject setHospitalAutoPatientId:patientIds];
}
@end
