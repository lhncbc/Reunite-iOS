//
//  LocationObject.m
//  ReUnite + TriagePic
//


#import "LocationObject.h"

@implementation LocationObject
- (id)initWithStreet:(NSString *)street1 street2:(NSString *)street2 city:(NSString *)city region:(NSString *)region zip:(NSString *)zip country:(NSString *)country hasGPS:(BOOL)hasGPS gpsCoordinates:(CLLocationCoordinate2D)gpsCoordinates span:(MKCoordinateSpan)span{
    self = [super init];
    if (self){
        _street1 = [street1 isKindOfClass:[NSNull class]]?@"":street1;
        _street2 = [street2 isKindOfClass:[NSNull class]]?@"":street2;
        _city = [city isKindOfClass:[NSNull class]]?@"":city;
        _region = [region isKindOfClass:[NSNull class]]?@"":region;
        _zip = [zip isKindOfClass:[NSNull class]]?@"":zip;
        _country = [country isKindOfClass:[NSNull class]]?@"":country;
        _hasGPS = hasGPS;
        _gpsCoordinates = gpsCoordinates;
        _span = span;
        [self removeNSNulls];
        [self removeNulls];
        
        //check if the address is valid
        _hasAddress = ![[self getLocationString] isEqualToString:@""];
    }
    return self;
}
+ (id)locationByLocationDictionary:(NSDictionary *)locationDictionary{
    if (!locationDictionary) {
        return [LocationObject emptyLocation];
    }
    
    if ([locationDictionary isKindOfClass:[NSDictionary class]]){
        //NSDictionary *locationDictionary = personDictionary[@"location"];
        NSDictionary *gpsDictionary = locationDictionary[@"gps"];
        
        float latitude = 0;
        float longitude = 0;
        
        BOOL hasGPS = YES;
        id lat = gpsDictionary[@"latitude"];
        id lng =gpsDictionary[@"longitude"];
        if (![lat isKindOfClass:[NSNull class]] && ![lng isKindOfClass:[NSNull class]] && lat && lng) {
            latitude = [lat floatValue];
            longitude = [lng floatValue];
          
        }
        if (!gpsDictionary && latitude == 0 && longitude == 0){
            hasGPS = NO;
            latitude = 0;
            longitude = 0;
        }
        LocationObject *tempLocationObject =  [[LocationObject alloc]initWithStreet:locationDictionary[@"street1"] street2:locationDictionary[@"street2"] city:locationDictionary[@"city"] region:locationDictionary[@"region"] zip:locationDictionary[@"postal_code"] country:locationDictionary[@"country"] hasGPS:hasGPS gpsCoordinates:CLLocationCoordinate2DMake(latitude, longitude) span:MKCoordinateSpanMake(.05, .05)];
        NSString *locationString = tempLocationObject.getLocationString;

        if ([locationString isEqualToString:@""]) { // To prevent any possible false positive when the dictionary is available but the data aren't
            return [self emptyLocation];
        }
        return tempLocationObject;
    }else if ([locationDictionary isKindOfClass:[NSString class]]){
        return [LocationObject locationWithString:(NSString *)locationDictionary];
    }
    return [LocationObject emptyLocation];
    
}

+ (id)emptyLocationOrSavedLocation
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_LOCATION]) {
        NSString *savedLocation = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SAVED_LOCATION];
        return [LocationObject locationByLocationDictionary:[CommonFunctions deserializedDictionaryFromJSONString:savedLocation]];
    }
    return [LocationObject emptyLocation];
    
}

+ (id)sampleLocation
{
    return [[LocationObject alloc] initWithStreet:@"8600 Rockville Pike" street2:@"" city:@"Bethesda" region:@"Maryland" zip:@"20894" country:@"USA" hasGPS:NO gpsCoordinates:CLLocationCoordinate2DMake(0, 0) span:MKCoordinateSpanMake(.05, .05)];
}

+ (id)emptyLocation
{
    return [[LocationObject alloc] initWithStreet:@"" street2:@"" city:@"" region:@"" zip:@"" country:@"" hasGPS:NO gpsCoordinates:CLLocationCoordinate2DMake(0, 0) span:MKCoordinateSpanMake(.05, .05)];
}

+ (id)locationWithString:(NSString *)locationString
{
    return [[LocationObject alloc] initWithStreet:locationString street2:@"" city:@"" region:@"" zip:@"" country:@"" hasGPS:NO gpsCoordinates:CLLocationCoordinate2DMake(0, 0) span:MKCoordinateSpanMake(.05, .05)];
}


#pragma mark - parser
- (NSString *)getLocationString{
    NSString *locationString = @"";
    locationString = [LocationObject appendString:locationString withString:_street1];
    locationString = [LocationObject appendString:locationString withString:_street2];// not yet implemented
    locationString = [LocationObject appendString:locationString withString:_city];
    locationString = [LocationObject appendString:locationString withString:_region];
    locationString = [LocationObject appendString:locationString withString:_zip];
    locationString = [LocationObject appendString:locationString withString:_country];
    return [locationString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)appendString:(NSString *)returnString withString:(NSString *)appendString{
    //to simplify getLocationString
    if (appendString &&  ![appendString isKindOfClass:[NSNull class]] && ![appendString isEqualToString:@""]){
        if (returnString && ![returnString isEqualToString:@""]){
            //to put punctuation correctly
            returnString = [returnString stringByAppendingFormat:@", %@",appendString];
        }else{
            returnString = [returnString stringByAppendingFormat:@"%@",appendString];
        }
    }else{
        returnString = [returnString stringByAppendingFormat:@""];
    }
    return returnString;
}

#pragma mark - converter & verifier
+ (NSArray *)getpossibleLocationFromString:(NSString *)locationString{
    if ([CommonFunctions hasConnectivity]) { // check for internet access
        NSMutableArray *returnLocationObjectArray = [NSMutableArray array];
        NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",
                            [locationString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSData *dataFromServer = [NSData dataWithContentsOfURL: [NSURL URLWithString:urlStr]];
        if (!dataFromServer) {
            return @[];
        }
        NSDictionary *allAddressDictionary = [NSJSONSerialization JSONObjectWithData:dataFromServer options:kNilOptions error:nil];
        
        //DLog(@"%@",allAddressDictionary);
        //DLog(@"*******************************\n%@\n*****************************",[[allAddressDictionary objectForKey:@"results"]objectAtIndex:0]);
        NSArray *allAddressArray = allAddressDictionary[@"results"];
        
        //start parsing each one
        for (NSDictionary *addressDictionary in allAddressArray){
            // DLog(@"*******************************\n%@\n*****************************",addressDictionary);
            [returnLocationObjectArray addObject:[self objectFromAddressDictionary:addressDictionary]];
            
        }
        return returnLocationObjectArray;
    }// if it is not connected, just return an empty array
    return @[];
}

+ (void)getpossibleLocationFromString:(NSString *)locationString target:(id)target selector:(SEL)selector{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *locationArray = [self getpossibleLocationFromString:locationString];
        [target performSelectorOnMainThread:selector withObject:locationArray waitUntilDone:YES];
    });
}



+ (NSArray *)getpossibleLocationFromGPS:(CLLocationCoordinate2D)coordinate{
    if ([CommonFunctions hasConnectivity]) { // check for internet access
        NSMutableArray *returnLocationObjectArray = [NSMutableArray array];
        NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",
                            coordinate.latitude, coordinate.longitude];
        NSData *dataFromServer = [NSData dataWithContentsOfURL: [NSURL URLWithString:urlStr]];
        if (!dataFromServer) {
            return @[];
        }
        NSDictionary *allAddressDictionary = [NSJSONSerialization JSONObjectWithData:dataFromServer options:kNilOptions error:nil];
        
        DLog(@"%@",allAddressDictionary);
        //DLog(@"*******************************\n%@\n*****************************",[[allAddressDictionary objectForKey:@"results"]objectAtIndex:0]);
        NSArray *allAddressArray = allAddressDictionary[@"results"];
        
        //start parsing each one
        for (NSDictionary *addressDictionary in allAddressArray){
            // DLog(@"*******************************\n%@\n*****************************",addressDictionary);
            [returnLocationObjectArray addObject:[self objectFromAddressDictionary:addressDictionary]];
        }
        return returnLocationObjectArray;
    }// if it is not connected, just return an empty array
    return @[];
}

+ (void)getpossibleLocationFromGPS:(CLLocationCoordinate2D)coordinate target:(id)target selector:(SEL)selector{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *locationArray = [self getpossibleLocationFromGPS:coordinate];
        [target performSelectorOnMainThread:selector withObject:locationArray waitUntilDone:YES];
    });}

+ (LocationObject *)objectFromAddressDictionary:(NSDictionary *)addressDictionary{
    LocationObject *returnLocationObject = [LocationObject emptyLocation];
    //get component first
    NSArray *allComponentArray = addressDictionary[@"address_components"];
    for (NSDictionary *eachComponentDictionary in allComponentArray){
        //check the type
        returnLocationObject.street1 = [self stringWithComponentDictionary:eachComponentDictionary type:@"street_number" appendingToString:returnLocationObject.street1];
        returnLocationObject.street1 = [self stringWithComponentDictionary:eachComponentDictionary type:@"route" appendingToString:returnLocationObject.street1];
        returnLocationObject.street2 = [self stringWithComponentDictionary:eachComponentDictionary type:@"establishment" appendingToString:returnLocationObject.street2];
        returnLocationObject.city = [self stringWithComponentDictionary:eachComponentDictionary type:@"locality" appendingToString:returnLocationObject.city];
        returnLocationObject.region = [self stringWithComponentDictionary:eachComponentDictionary type:@"administrative_area_level_1" appendingToString:returnLocationObject.region];
        returnLocationObject.zip = [self stringWithComponentDictionary:eachComponentDictionary type:@"postal_code" appendingToString:returnLocationObject.zip];
        returnLocationObject.country = [self stringWithComponentDictionary:eachComponentDictionary type:@"country" appendingToString:returnLocationObject.country];
    }
    returnLocationObject.hasAddress = YES;
    
    //GPS
    NSDictionary *geometryDictionary = addressDictionary[@"geometry"]; //geo
    NSDictionary *gpsDictionary = geometryDictionary[@"location"]; //gps alone
    NSDictionary *gpsSpanDictionary = geometryDictionary[@"bounds"]; //span alone
    
    CGFloat lat = [gpsDictionary[@"lat"] floatValue];
    CGFloat lng = [gpsDictionary[@"lng"] floatValue];
    returnLocationObject.gpsCoordinates = CLLocationCoordinate2DMake(lat, lng);
    returnLocationObject.hasGPS = YES;

    CGFloat latSpan = gpsSpanDictionary?[gpsSpanDictionary[@"northeast"][@"lat"] floatValue] - returnLocationObject.gpsCoordinates.latitude:0.05;
    CGFloat lngSpan = gpsSpanDictionary?[gpsSpanDictionary[@"northeast"][@"lng"] floatValue] - returnLocationObject.gpsCoordinates.longitude:0.05;
    float minimalSpan = 0.03;
    latSpan = latSpan>minimalSpan?latSpan:minimalSpan;
    lngSpan = lngSpan>minimalSpan?lngSpan:minimalSpan;
    
    returnLocationObject.span = MKCoordinateSpanMake(latSpan, lngSpan);
    
    return returnLocationObject;
}

+ (NSString *)stringWithComponentDictionary:(NSDictionary *)eachComponentDictionary type:(NSString *)type appendingToString:(NSString *)string{
    if ([eachComponentDictionary[@"types"] count] && [eachComponentDictionary[@"types"][0] isEqualToString:type]){
        return [[string stringByAppendingFormat:@" %@",eachComponentDictionary[@"long_name"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

#pragma mark - upload
- (NSString *)getLocationXML{
    if (!_hasAddress) {
        return @"";
    }
    NSMutableString *returnString = [[NSMutableString alloc] init];
    [returnString appendFormat:@"<street1>%@</street1>",_street1];
    [returnString appendFormat:@"<street2>%@</street2>",_street2];
    [returnString appendFormat:@"<city>%@</city>",_city];
    [returnString appendFormat:@"<region>%@</region>",_region];
    [returnString appendFormat:@"<postalCode>%@</postalCode>",_zip];
    [returnString appendFormat:@"<country>%@</country>",_country];
    [returnString appendFormat:@"<gps><lat>%f</lat><lon>%f</lon></gps>",_gpsCoordinates.latitude, _gpsCoordinates.longitude];
    return returnString;
}

- (NSString *)getLocationJSONSerializedString
{
    if (!_hasAddress) {
        return @"";
    }
    return [CommonFunctions serializedJSONStringFromDictionaryOrArray:[self getLocationDictionary]];
}

- (NSDictionary *)getLocationDictionary
{
    if (!_hasAddress) {
        return [NSDictionary dictionary];
    }
    
    NSDictionary *dictionary = @{@"street1": _street1,
                                 @"street2": _street2,
                                 @"city": _city,
                                 @"region": _region,
                                 @"postal_code": _zip,
                                 @"country": _country,
                                 @"neighborhood":@""
                                 };
    
    if (_hasGPS) {
        NSMutableDictionary *mutableDict = [dictionary mutableCopy];
        [mutableDict setObject:@{@"latitude": @(_gpsCoordinates.latitude).stringValue, @"longitude": @(_gpsCoordinates.longitude).stringValue} forKey:@"gps"];
        dictionary = mutableDict;
    }
    return dictionary;
}

#pragma mark - helper function
- (void)removeNSNulls{
    _street1 = ![_street1 isKindOfClass:[NSNull class]]?_street1:@"";
    _street2 = ![_street2 isKindOfClass:[NSNull class]]?_street2:@"";
    _city = ![_city isKindOfClass:[NSNull class]]?_city:@"";
    _region = ![_region isKindOfClass:[NSNull class]]?_region:@"";
    _zip = ![_zip isKindOfClass:[NSNull class]]?_zip:@"";
    _country = ![_country isKindOfClass:[NSNull class]]?_country:@"";
}

- (void)removeNulls{
    _street1 = _street1?_street1:@"";
    _street2 = _street2?_street2:@"";
    _city = _city?_city:@"";
    _region = _region?_region:@"";
    _zip = _zip?_zip:@"";
    _country = _country?_country:@"";
}

- (id)copy{
    return [[LocationObject alloc] initWithStreet:_street1 street2:_street2 city:_city region:_region zip:_zip country:_country hasGPS:_hasGPS gpsCoordinates:_gpsCoordinates span:_span];
}

#pragma mark - Debug
- (id)debugQuickLookObject
{
    return [self getLocationDictionary].description;
}
@end
