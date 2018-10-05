//
//  CommonFunctions.m
//  ReUnite + TriagePic
//

//

#import "CommonFunctions.h"

@implementation CommonFunctions
#pragma mark - Connectivity
+ (BOOL)hasConnectivity
{
    BOOL hasConnection = NO;
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                hasConnection = NO;
            }
            
            else if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                hasConnection = YES;
            }
            
            
            else if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    hasConnection = YES;
                }
            }
            
            else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                hasConnection = YES;
            }
        }
        CFRelease(reachability);
    } else {
        hasConnection = NO;
    }
    
    
    return hasConnection;
}

+ (BOOL)canConnectTo:(NSString *)urlString
{
    urlString = [urlString stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"HEAD"];
    [request setTimeoutInterval:10];
    NSHTTPURLResponse *response;
    DLog(@"start %@", urlString);
    NSError *error;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    DLog(@"stop %@", urlString);
    return error? NO : YES;
}

//undocumented, will not be too useful till later
+ (int)currentConnectionTech
{
    /*
    CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
    
    if ([networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        return 1;
    }
    if ([networkInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        return 2;
    }
    */
    return 0;
}


#pragma mark - JSON
//JSON serialization
+ (NSString *)serializedJSONStringFromDictionaryOrArray:(id)object
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString = @"";
    if (! jsonData) {
        DLog(@"Error while converting dictionary to JSON string: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
   // NSLog(@"%@jsonStringjsonStringjsonStringjsonString",jsonString);
    return jsonString;
}

+ (id)deserializedDictionaryFromJSONString:(NSString *)jsonString
{
    // Sanity
    if (!jsonString || [jsonString isEqualToString:@""]) {
        return nil;
    }
    
    
    NSMutableData *dataFromServer = [NSMutableData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:dataFromServer options:kNilOptions error:&error];
    if (error) DLog(@"%@",error);
   // NSLog(@"%@JSONObjectJSONObjectJSONObjectJSONObject",JSONObject);

    return JSONObject;
}

#pragma mark - XML Escape
+ (NSString *)escapeForXML:(NSString *)string
{
    if (string == nil) {
        return @"";
    }
    
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    
    return string;
}

#pragma mark - Date Manipulation
+ (NSDate *)getDateFromStandardString:(NSString *)timeString{
    if (!timeString || [timeString isEqualToString:@""]) {
        return nil;
    }
    
    //convert to NSDate
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    return [dateFormatter dateFromString:timeString];
}

+ (NSString *)getDateRepresentationByDate:(NSDate *)date withLongFormat:(BOOL)isLongFormat{
    if (!date || ![date isKindOfClass:[NSDate class]]) {
        return NSLocalizedString(@"Unspecified", @"the word used when time date cannot be converted into string for unknown reason");
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyy - HH:mm";
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    NSString *lastUpdatedString = [dateFormatter stringFromDate:date];
    if (isLongFormat){
        lastUpdatedString = [lastUpdatedString stringByAppendingFormat:@" %@",dateFormatter.timeZone.abbreviation];
    }else{
        //remove time
        lastUpdatedString = [lastUpdatedString substringToIndex:10];
    }
    return lastUpdatedString;
}

+ (NSString *)getStandardRepresentationFromDate:(NSDate *)date
{
    if (!date) {
        return [CommonFunctions getStandardRepresentationFromDate:[NSDate date]];
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSMutableString *timeString = [[dateFormatter stringFromDate:date] mutableCopy];
    
    return timeString;
}


#pragma mark - Logging
+ (void)printCGRect:(CGRect)rect
{
    DLog(@"%f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

#pragma mark - Common UI element
+ (UIFont *)normalFont
{
    return [UIFont systemFontOfSize:17];
}

+ (UIFont *)fontNormalDeviceSpecific:(BOOL)isDeviceSpecific
{
    if (isDeviceSpecific) {
        if ([CommonFunctions isPad]) {
            return [UIFont systemFontOfSize:20];
        }
        return [UIFont systemFontOfSize:17];
    }
    return [UIFont systemFontOfSize:17];
}

+ (UIFont *)fontSmallDeviceSpecific:(BOOL)isDeviceSpecific
{
    if (isDeviceSpecific) {
        if ([CommonFunctions isPad]) {
            return [UIFont systemFontOfSize:16];
        }
        return [UIFont systemFontOfSize:13];
    }
    return [UIFont systemFontOfSize:13];
}

#pragma mark - Color
+ (UIColor *)addLight:(CGFloat)lightValue ToColor:(UIColor *)color
{
    MIN(MAX(lightValue, -1), 1);
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        
        if (lightValue > 0) {
            r = r + (lightValue * (1-r));
            g = g + (lightValue * (1-g));
            b = b + (lightValue * (1-b));
        } else {
            r = r + (lightValue * r);
            g = g + (lightValue * g);
            b = b + (lightValue * b);
        }
        
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

+ (UIColor *)addWhite:(CGFloat)lightValue ToColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MAX(MIN(r + lightValue, 1.0), 0)
                               green:MAX(MIN(g + lightValue, 1.0), 0)
                                blue:MAX(MIN(b + lightValue, 1.0), 0)
                               alpha:a];
    }
    return nil;
}

#pragma mark - Device Validation

+ (BOOL)isPad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)is4InchesScreen
{
    return (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON);
}

+ (BOOL)is35InchesScreen
{
    return ![CommonFunctions isPad] && ![CommonFunctions is4InchesScreen];
}

#pragma mark - Encoding
+ (NSString *)base64EncodeStringFromImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat compression = 1;
    CGFloat maxFileSize = 250*1024;
    CGFloat maxCompression = .30;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    //NSString *photoAfterResizedString = [ImageObject base64StringFromData:imageData length:(int)[imageData length]];
    //NSData *imageData = UIImagePNGRepresentation(image);
    return [imageData base64EncodedStringWithOptions:0];
}

+ (UIImage *)base64DecodeImageFromString:(NSString *)string
{
    if (!string) {
        return nil;
    }
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    return [[UIImage alloc] initWithData:imageData];
}

#pragma mark - Time
+ (NSString *)timeDurationFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSTimeInterval interval = [toDate timeIntervalSinceDate:fromDate];
    
    int timeInterval = floor(interval/(60*60*24));
    
    NSString *s;
    NSString *timeString;
    

    if (timeInterval){// days
        s = (timeInterval>1? @"s":@"");
        timeString = [NSString stringWithFormat: @"%i day%@ ago", timeInterval, s];
    }else if ((timeInterval = floor(interval/(60*60)))){//hours
        s = (timeInterval>1? @"s":@"");
        timeString = [NSString stringWithFormat: @"%i hour%@ ago", timeInterval, s];
    }else if ((timeInterval = floor(interval/(60)))){//minutes
        s = (timeInterval>1? @"s":@"");
        timeString = [NSString stringWithFormat: @"%i minute%@ ago", timeInterval, s];
    } else {
        timeString = @"Just Now";
    }
    
    return timeString;
}

#pragma mark - URL Verification
+ (NSArray *)splitStringForEndPointWebServiceURL:(NSString *)string
{
        NSArray *splitProtocol = [string componentsSeparatedByString:@"://"];
        NSString *protocolString = [NSString stringWithFormat:@"%@://",splitProtocol[0]];
        NSArray *splitTheRest = [splitProtocol[1] componentsSeparatedByString:@"/"];
        NSString *serverString = splitTheRest[0];
        NSString *versionString = splitTheRest[1];
        
        return @[protocolString, serverString, versionString];
}

+ (BOOL)verifyStringForEndPointWebServiceURL:(NSString *)string
{
    NSString *webServiceEndPointRegex = @"http(s)?://\\S*/\\?wsdl&api=\\d+";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", webServiceEndPointRegex];
    return [myTest evaluateWithObject:string];
}

+ (BOOL)verifyStringForEmailAddress:(NSString *)string
{
    NSString *emailAdddresRegex = @"\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}\\b";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailAdddresRegex];
    return [myTest evaluateWithObject:string];
}

#pragma mark - App Related
+ (NSString *)siteName
{
    return IS_TRIAGEPIC?@"TraigeTrak":@"PEOPLE LOCATOR";
}

+ (NSString *)appName
{
    return IS_TRIAGEPIC?@"TriagePic":@"ReUnite";
}


@end
