//
//  PersonObject.m
//  ReUnite + TriagePic
//


#import "PersonObject.h"
#define GLOBAL_KEY_HOSPITAL_ARRAY @"GLOBAL_KEY_HOSPITAL"
#import "WSCommon.h"

@implementation PersonObject
- (id)initWithPersonID:(int)personID type:(NSString *)type givenName:(NSString *)givenName familyName:(NSString *)familyName status:(NSString *)status gender:(NSString *)gender ageMin:(NSString *)ageMin ageMax:(NSString *)ageMax event:(NSString *)event lastUpdated:(NSDate *)lastUpdated webLink:(NSString *)webLink uuid:(NSString *)uuid additionalDetail:(NSString *)additionalDetail imageObjectArray:(NSMutableArray *)imageObjectArray commentObjectArray:(NSMutableArray *)commentObjectArray location:(LocationObject *)location canEdit:(BOOL)canEdit{
    self = [super init];
    if (self){
        _personID = personID;
        _type = type;
        _givenName = givenName;
        _familyName = familyName;
        _status = status;
        _gender = gender;
        _ageMin = ageMin;
       // _ageMax = ageMax;
        _event = event;
        _lastUpdated = lastUpdated;
        _webLink = webLink;
        _uuid = uuid;
        _additionalDetail = additionalDetail;
        _imageObjectArray = imageObjectArray;
        _commentObjectArray = commentObjectArray;
        _location = location;
        _canEdit = canEdit;
        
        // To Store urls to delete
        _imagesURLToDelete = [NSMutableArray array];
        
        //prevent null objects
        [self removeNulls];
    }
    return self;
}

- (id)init
{
    if(self = [super init]) {
        _imagesURLToDelete = [NSMutableArray array];
    }
    return self;
}

#pragma mark - empty object
+ (PersonObject *)emptyPersonObject{
    NSString *familyName = [[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_FAMILY_NAME]?[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SAVED_FAMILY_NAME]:@"";
    NSString *status = [[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_STATUS]?[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SAVED_STATUS]:NSLocalizedString(@"Missing", nil);
    PersonObject *personObject = [[PersonObject alloc] initWithPersonID:[PersonObject uniqueLocalID]
                                             type:PERSON_TYPE_DRAFT
                                        givenName:@""
                                       familyName:familyName
                                           status:status
                                           gender:NSLocalizedString(@"Unknown", nil)
                                           ageMin:@""
                                           ageMax:@""
                                            event:[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT]
                                      lastUpdated:[NSDate date]
                                          webLink:@""
                                             uuid:@""
                                 additionalDetail:@""
                                 imageObjectArray:[NSMutableArray array]
                               commentObjectArray:[NSMutableArray array]
                                         location:[LocationObject emptyLocationOrSavedLocation]
                                          canEdit:YES];
    if (IS_TRIAGEPIC) {
        personObject.patientId = KEY_PATIENT_ID;
        personObject.zone = @"Green";
        personObject.hospitalName = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_HOSPITAL];
    }
    
    return personObject;
}


+ (id)samplePersonObject
{    
    return [[PersonObject alloc] initWithPersonID:[PersonObject uniqueLocalID]
                                             type:PERSON_TYPE_DRAFT
                                        givenName:@"Byte"
                                       familyName:@"Smith"
                                           status:@"Missing"
                                           gender:@"Male"
                                           ageMin:@"40"
                                           ageMax:@"50"
                                            event:@"Dummy Event 2010"
                                      lastUpdated:[NSDate date]
                                          webLink:@""
                                             uuid:@""
                                 additionalDetail:@"This is a sample dummy thing, ignore!!"
                                 imageObjectArray:[@[[ImageObject imageObjectFromImage:[UIImage imageNamed:@"sampleImage"]], [ImageObject imageObjectFromImage:[UIImage imageNamed:@"sampleImage2"]]] mutableCopy]
                               commentObjectArray:[@[[CommentObject testCommentObject], [CommentObject testCommentObject], [CommentObject testCommentObject]] mutableCopy]
                                         location:[LocationObject sampleLocation]
                                          canEdit:YES];
}


#pragma mark - web service serializer and deserializer
- (id)initWithPersonDictionary:(NSDictionary *)personDictionary type:(NSString *)type event:(NSString *)event backgroundDownload:(BOOL)backgroundDownload delegate:(id<PersonObjectDelegate>)delegate{
    self = [super init];
    if (self){
        _personID = [PersonObject uniqueLocalID];
        _imagesURLToDelete = [NSMutableArray array];
        _type = type;
        
        _givenName = personDictionary[@"name"];
        //_familyName = personDictionary[@"family_name"];
        _status = [PersonObject statusDictionary][personDictionary[@"stat"]];
        _gender = [PersonObject genderDictionary][personDictionary[@"sex"]];
        
        //age
       // NSString *ageN = personDictionary[@"years_old"];
       // _ageMax = personDictionary[@"max_age"];
       _ageMin = personDictionary[@"age"];
        //prevent NSNULL
        //_ageMax = [_ageMax isKindOfClass:[NSNull class]]?@"":_ageMax;
        _ageMin = [_ageMin isKindOfClass:[NSNull class]]?@"":_ageMin;
        //ageN = [ageN isKindOfClass:[NSNull class]]?@"":ageN;
//        if ([_ageMax isEqualToString:@""] && ageN.intValue > 0){ //range is not available
//            _ageMax = _ageMin = ageN; //max and min are the same
//        }
        _canEdit = [personDictionary[@"editable"] boolValue];
        _event = event;

        //convert to NSDate
        NSString *lastUpdatedString = personDictionary[@"updated"];
        lastUpdatedString = [lastUpdatedString isKindOfClass:[NSNull class]]?@"":lastUpdatedString;
        _lastUpdated = [CommonFunctions getDateFromStandardString:lastUpdatedString];
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        _uuid = personDictionary[@"uuid"];
        
        
//    
//        NSString *currentEvent = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT];
//    NSDictionary *chosenEventDict;
////        
////        // the user has yet to select a current event
//            chosenEventDict = [PersonObject eventArray][0];
////        
//           [[NSUserDefaults standardUserDefaults] setObject:chosenEventDict[@"shortname"] forKey:GLOBAL_KEY_CURRENT_SHORTEVENT];

        NSString * uuidURL = _uuid;
        NSString * finalUUID = [uuidURL stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [uuidURL length])];
       // NSLog(@"%@strippedNumberstrippedNumberstrippedNumberstrippedNumber", finalUUID);

        
   if([language isEqualToString:@"es"]||[language isEqualToString:@"es-US"])
        {
            _webLink = [NSString stringWithFormat:@"https://pl.nlm.nih.gov/es/%@/record#%@",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_SHORTEVENT],finalUUID];
            
            
        }
        
       else if([language isEqualToString:@"ja"]||[language isEqualToString:@"ja-US"])
        {
            _webLink = [NSString stringWithFormat:@"https://",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_SHORTEVENT],finalUUID];
            
            
        }
       else if([language isEqualToString:@"zh-Hans"]||[language isEqualToString:@"zh-Hans-US"])
       {
           _webLink = [NSString stringWithFormat:@"https:/",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_SHORTEVENT],finalUUID];

           
       }
       else if([language isEqualToString:@"zh-Hant"]||[language isEqualToString:@"zh-Hant-US"])
       {
           _webLink = [NSString stringWithFormat:@"https://",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_SHORTEVENT],finalUUID];

           
       }
       else if([language isEqualToString:@"vi"]||[language isEqualToString:@"vi-US"])
       {
           _webLink = [NSString stringWithFormat:@"https://",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_SHORTEVENT],finalUUID];
           
           
       }
        else
        {
            _webLink = [NSString stringWithFormat:@"https://",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_SHORTEVENT],finalUUID];
  
        }
           //_webLink = [NSString stringWithFormat:@"%@%@/edit?puuid=%@",[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_HTTP],[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_SERVER_NAME],_uuid];
//
        
       // NSLog(@"%@_webLink_webLink_webLink_webLink",_webLink);
        _additionalDetail = personDictionary[@"lki"];
        _additionalDetail = [_additionalDetail isKindOfClass:[NSNull class]]?nil:_additionalDetail;
        _imageObjectArray = [NSMutableArray array];
        NSMutableDictionary *imagefullDictionaryArray = personDictionary[@"image_url"];
        NSMutableDictionary *imagethumbDictionaryArray = personDictionary[@"thumb_url"];

//        if(!imageDictionaryArray)
//        {
//        [[NSUserDefaults standardUserDefaults] setObject:imageDictionaryArray forKey:@"image_url"];
//        }
//        else{
//            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"image_url"];
//
//        }
        
        NSMutableDictionary *tags = [NSMutableDictionary dictionary];
        [tags setObject:@"" forKey:@"tag_h"];
        [tags setObject:@"" forKey:@"tag_id"];
        [tags setObject:@"" forKey:@"tag_text"];
        [tags setObject:@"" forKey:@"tag_w"];
        [tags setObject:@"" forKey:@"tag_x"];
        [tags setObject:@"" forKey:@"tag_y"];


        

        
        NSMutableDictionary *Imagedatadict = [NSMutableDictionary dictionaryWithObjectsAndKeys:tags,@"tags",nil];
        [Imagedatadict setObject:@"" forKey:@"created"];
        [Imagedatadict setObject:@"" forKey:@"color_channels"];
        [Imagedatadict setObject:@"" forKey:@"image_height"];
        [Imagedatadict setObject:@"" forKey:@"image_id"];
        [Imagedatadict setObject:@"" forKey:@"image_type"];
        [Imagedatadict setObject:@"" forKey:@"note_id"];
        [Imagedatadict setObject:@"" forKey:@"note_record_id"];
        [Imagedatadict setObject:@"" forKey:@"original_filename"];
        [Imagedatadict setObject:@"" forKey:@"principal"];
        [Imagedatadict setObject:@"" forKey:@"sha1original"];
        [Imagedatadict setObject:imagefullDictionaryArray forKey:@"url"];
        [Imagedatadict setObject:imagethumbDictionaryArray forKey:@"url_thumb"];
      

        if ([Imagedatadict objectForKey:@"url_thumb"] == [NSNull null]) {
            [Imagedatadict setObject:@"" forKey:@"url_thumb"];
        }
        
        if ([Imagedatadict objectForKey:@"url"] == [NSNull null]) {
            [Imagedatadict setObject:@"" forKey:@"url"];
        }

//        NSMutableDictionary *imageForCommentDict = [NSMutableDictionary dictionary];
//        // Since the image of the record and image of the comments are bundled up in the same place, This seperates them into 2 different places
//        for (NSDictionary *imageDictionary in imageDictionaryArray){
//            NSString * noteID = [imageDictionary objectForKey:@"id"];
//           // NSString * noteID=nil;
//            if ([noteID isKindOfClass:[NSString class]] && ![noteID isEqualToString:@"0"]) { // make sure it is not the NOTE image
//                [imageForCommentDict setObject:imageDictionary forKey:noteID];
//            }else{
                ImageObject *imageObject = [[ImageObject alloc]initWithImage:Imagedatadict delegate:self backgroundDownload:YES];

                [_imageObjectArray addObject:imageObject];
     
        
        //if ([_imageObjectArray count] && [UserDefaultHelper peopleRecordImageDictFind][((ImageObject *)_imageObjectArray[0]).imageURL]) {
            _smallDisplayImage = [ImageObject peopleRecordImageSmallDictFind][_uuid];
        
        //}
        /*else{
            [[UserDefaultHelper peopleRecordImageSmallDictFind] removeObjectForKey:_uuid];
        }*/

        
       NSString *lat= personDictionary[@"latitude"];
       NSString *longt =personDictionary[@"longitude"];
        
        CLLocationCoordinate2D pinlocation;
        pinlocation.latitude=[lat doubleValue];
        pinlocation.longitude=[longt doubleValue];
        NSString *_tempStreet1;
        NSString *_tempStreet2;
        NSString *_tempregion;
        NSString *_tempPostalcode;
        // NSString *_tempneigh;
        NSString *_tempCountry;
        NSString *_tempCity;
      
        NSString *lat1 =[NSString stringWithFormat:@"%@",lat];
        NSString *lat2 =[NSString stringWithFormat:@"%@",longt];

        

        
        if(![lat1 isEqualToString:@"0"] && ![lat2 isEqualToString:@"0"])
        {
            NSArray *_arrayLocation=[LocationObject getpossibleLocationFromGPS:pinlocation];
            // dispatch_async(dispatch_get_main_queue(), ^{
            if ([_arrayLocation count]){ //if Google has suggestions
                LocationObject *tempLocationObject = ((LocationObject *)_arrayLocation[0]);
                
                _tempStreet1=tempLocationObject.street1;
                _tempStreet2=tempLocationObject.street2;
                _tempregion=tempLocationObject.region;
                _tempCity=tempLocationObject.city;
                _tempCountry=tempLocationObject.country;
                _tempPostalcode=tempLocationObject.zip;

                
            }
        }

        NSMutableDictionary *gps = [NSMutableDictionary dictionary];
        [gps setObject:lat?lat:@"0" forKey:@"latitude"];
        [gps setObject:longt?longt:@"0" forKey:@"longitude"];
        
        NSMutableDictionary *locationdata = [NSMutableDictionary dictionaryWithObjectsAndKeys:gps,@"gps",nil];
        [locationdata setObject:_tempCity?_tempCity:@"" forKey:@"city"];
       [locationdata setObject:_tempCountry?_tempCountry:@"" forKey:@"country"];
       [locationdata setObject:@"" forKey:@"neighborhood"];
       [locationdata setObject:_tempPostalcode?_tempPostalcode:@"" forKey:@"postal_code"];
        [locationdata setObject:_tempregion?_tempregion:@"" forKey:@"region"];
        [locationdata setObject:_tempStreet1?_tempStreet1:@"" forKey:@"street1"];
        [locationdata setObject:_tempStreet2?_tempStreet2:@"" forKey:@"street2"];
        


        _location = [LocationObject locationByLocationDictionary:locationdata];
        
        
       // if the structured location is not available, check unstructured
//        if (!_location.hasAddress){
//            NSString *lastSeenAddress = @"10th street,NY,9779";
//            if (lastSeenAddress && ![lastSeenAddress isKindOfClass:[NSNull class]]){
//                //dump everything into street1
//                _location.street1 = lastSeenAddress;
//                _location.hasAddress = YES;
//            }
//        }
//
        
        //Comment
        _commentObjectArray = [NSMutableArray array];
        NSMutableDictionary *commentDictionaryArray = personDictionary[@"comments"];
        int rank = 1;
        for (NSDictionary *commentDictionary in commentDictionaryArray) {
            NSMutableDictionary *tempCommentDictionary = [commentDictionary mutableCopy];
            NSString *noteID = [tempCommentDictionary objectForKey:@"id"];
            //DLog(@"%@",commentDictionary);
             NSMutableDictionary *imageForCommentDict = [NSMutableDictionary dictionary];
            NSDictionary *imageDictionary = [imageForCommentDict objectForKey:noteID];

            if (imageDictionary) {
                NSString *imageURL = [commentDictionaryArray objectForKey:@"thumb_url"];
                [tempCommentDictionary setObject:imageURL forKey:COMMENT_KEY_IMAGE_URL];
            }
            CommentObject *commentObject = [CommentObject commentObjectFromDicitonary:tempCommentDictionary rank:rank++ statusCodeDict:[PersonObject statusDictionary] uuid:_uuid];
            [_commentObjectArray addObject:commentObject];
        }
        
        // Can Edit
       // _canEdit = [personDictionary[@"is_editable"] boolValue];
        

        
        _delegate = delegate;
        
        //prevent null objects
        [self removeNSNulls]; // <null> <- generated by TriagePic
        [self removeNulls];
    }
    return self;
}

- (NSString *)getLastUpdatedStringLongFormat:(BOOL)longFormat{
    return [CommonFunctions getDateRepresentationByDate:_lastUpdated withLongFormat:longFormat];
}

- (BOOL)createSmallImage{
    if (!_smallDisplayImage) { // make sure the image did not already exist
        if (!_imageObjectArray || ![_imageObjectArray count]){
            return NO; // no images here
        }else{
            // get first Image
            ImageObject *firstImageObject = _imageObjectArray[0];
            
            // In some case, the image is corrupted. We need to check if the image is actually there.
            // If not just return like there is no image
            if (!firstImageObject.image) {
                return NO;
            }
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:GLOBAL_KEY_SETTINGS_FACE_DETECTION]) {
                _smallDisplayImage = firstImageObject.image;
            }
            else if (firstImageObject.faceRectAvailable){ //if there is a face rect, crop and display
                _smallDisplayImage = [ImageObject imageForButtonWithRect:firstImageObject.faceRect image:firstImageObject.image buttonSize:64 * [[UIScreen mainScreen] scale]];
            }else{
                NSArray *faceRectArray = [ImageObject faceDetectionRectArrayFromImage:firstImageObject.image];
                if ([faceRectArray count]){ //if there is not a face rect, detect and crop and display
                    _smallDisplayImage = [ImageObject imageForButtonWithRect:[faceRectArray[0] CGRectValue] image:firstImageObject.image buttonSize:64 * [[UIScreen mainScreen] scale]];
                }else{ //if face rect is not found, just show the full image
                    _smallDisplayImage = firstImageObject.image;
                }
            }
        }
    }
    
    //allow refreshes of the bad image
    if ([_imageObjectArray count] && [ImageObject peopleRecordImageDictFind][((ImageObject *)_imageObjectArray[0]).imageURL]) {
        //store for later usage in find
        [ImageObject peopleRecordImageSmallDictFind][_uuid] = _smallDisplayImage;
    }
    
    //store for later usage in report
    if (_smallDisplayImage) { // For some reason, it got here with nil small image...
        [ImageObject peopleRecordImageSmallDictFind][[NSString stringWithFormat:@"%i", _personID]] = _smallDisplayImage;
    }
    return YES;
}

- (void)removeSmallImage
{
    _smallDisplayImage = nil;
    [[ImageObject peopleRecordImageSmallDictFind] removeObjectForKey:[NSString stringWithFormat:@"%i", _personID]];
    if (_uuid != nil && ![_uuid isEqualToString:@""]) {
        [[ImageObject peopleRecordImageSmallDictFind] removeObjectForKey:_uuid];
    }
}
- (NSString *)serializedJSONToUploadDelete
{
    return [CommonFunctions serializedJSONStringFromDictionaryOrArray:[self serializedJSONDictToDelete:NO]];
}

- (NSDictionary *)serializedJSONDictToDelete:(BOOL)toExpire
{
    NSMutableDictionary *uploadDict = [NSMutableDictionary dictionary];
    uploadDict[@"call"]= @"delete";
   // uploadDict[@"format"]= @"PA1";
   // uploadDict[@"pa"]= @"0";
    uploadDict[@"uuid"]=_uuid;
//uploadDict[@"short"]= [[PersonObject eventLongNameToShortNameDict] objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT]];
    uploadDict[@"token"]= [WSCommon retrieveToken];
    //Prepare imfo
//    NSString *givenName = [self trimSpaces:_givenName];
//    //NSString *familyName = [self trimSpaces:_familyName];
//    NSString *additionalDetail = [self trimSpaces:_additionalDetail];
//    //NSString *patientId = [self trimSpaces:_patientId];
//    NSString *lat= [[NSString alloc] initWithFormat:@"%g", _location.gpsCoordinates.latitude];
//    NSString *lon= [[NSString alloc] initWithFormat:@"%g", _location.gpsCoordinates.longitude];
//    NSString *gender = [PersonObject genderDictionaryUpload][_gender];
//    NSString *status = [PersonObject statusDictionaryUpload][_status];
//    
//    if ([[NSString stringWithFormat:@"%@",_ageMin] isEqualToString:@""] ||[[NSString stringWithFormat:@"%@",_ageMin] isEqualToString:@"??"]){
//        
//        uploadDict[@"age"] = @"-1";
//        
//    }
//    //if age exists
//    if (![[NSString stringWithFormat:@"%@",_ageMin] isEqualToString:@""]){
//        //if age is not a range
//        uploadDict[@"age"] = _ageMin;
//        
//    }
//    
//    //Time
//    /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//     NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
//     [dateFormatter setTimeZone:timeZone];
//     [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//@"yyyy-MM-dd HH:mm:ss";
//     NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:GregorianCalendar];
//     NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//     [dateComponents setYear:1];
//     NSDate *targetDate = [gregorian dateByAddingComponents:dateComponents toDate:[NSDate date]  options:0];
//     NSString *now = [dateFormatter stringFromDate:[NSDate date]];
//     NSString *expire = toExpire? now : [dateFormatter stringFromDate:targetDate];*/
//    
//    
//    //uploadDict[@"hospitalUUID"] =@"23";
//    uploadDict[@"name"] = givenName;
//    uploadDict[@"stat"] = status;
//    uploadDict[@"sex"] = gender;
//    uploadDict[@"lki"] = additionalDetail;
//    uploadDict[@"latitude"]= lat;
//    uploadDict[@"longitude"]= lon;
//    
//    // Images
//    NSMutableArray *imageArray = [NSMutableArray array];
//    for (ImageObject *imageObject in _imageObjectArray) {
//        if (!imageObject.imageURL || [imageObject.imageURL isEqualToString:@""]) { // catching already uploaded image
//            [imageArray addObject:[imageObject getImageDictionary]];
//        }
//    }
//    NSString *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"imageData"];
//    
//    uploadDict[@"photo"] = imageData;
//    
//    // Delete Image
//    if ([_imagesURLToDelete count] > 0) {
//        NSMutableArray *objectToDelete = [NSMutableArray array];
//        for (NSString *string in _imagesURLToDelete) {
//            [objectToDelete addObject:@{@"url" : string}];
//        }
//        // uploadDict[@"removeImage"] = objectToDelete;
//    }
   [[NSUserDefaults standardUserDefaults] setObject:uploadDict forKey:@"deleteObject"];
    
    
    return uploadDict;
}

- (NSString *)serializedJSONToUpload
{
    return [CommonFunctions serializedJSONStringFromDictionaryOrArray:[self serializedJSONDictToExpire:NO]];
}

- (NSString *)serializedJSONToUploadToExpire:(BOOL)toExpire;
{
    return [CommonFunctions serializedJSONStringFromDictionaryOrArray:[self serializedJSONDictToExpire:toExpire]];
}

- (NSDictionary *)serializedJSONDictToExpire:(BOOL)toExpire
{
    NSMutableDictionary *uploadDict = [NSMutableDictionary dictionary];
     uploadDict[@"call"]= @"report";
    uploadDict[@"format"]= @"PA1";
    uploadDict[@"pa"]= @"0";
    uploadDict[@"uuid"]=_uuid;
     uploadDict[@"short"]= [[PersonObject eventLongNameToShortNameDict] objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT]];
    uploadDict[@"token"]= [WSCommon retrieveToken];
    //Prepare imfo
    NSString *givenName = [self trimSpaces:_givenName];
    //NSString *familyName = [self trimSpaces:_familyName];
    NSString *additionalDetail = [self trimSpaces:_additionalDetail];
    //NSString *patientId = [self trimSpaces:_patientId];
     NSString *lat= [[NSString alloc] initWithFormat:@"%g", _location.gpsCoordinates.latitude];
    NSString *lon= [[NSString alloc] initWithFormat:@"%g", _location.gpsCoordinates.longitude];
    NSString *gender = [PersonObject genderDictionaryUpload][_gender];
     NSString *status = [PersonObject statusDictionaryUpload][_status];
    
    if ([[NSString stringWithFormat:@"%@",_ageMin] isEqualToString:@""] ||[[NSString stringWithFormat:@"%@",_ageMin] isEqualToString:@"??"]){
        
        uploadDict[@"age"] = @"-1";
        
    }
    //if age exists
    if (![[NSString stringWithFormat:@"%@",_ageMin] isEqualToString:@""]){
        //if age is not a range
        uploadDict[@"age"] = _ageMin;

    }
    
    //Time
    /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//@"yyyy-MM-dd HH:mm:ss";
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:GregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:1];
    NSDate *targetDate = [gregorian dateByAddingComponents:dateComponents toDate:[NSDate date]  options:0];
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    NSString *expire = toExpire? now : [dateFormatter stringFromDate:targetDate];*/
    
    
    //uploadDict[@"hospitalUUID"] =@"23";
    uploadDict[@"name"] = givenName;
    uploadDict[@"stat"] = status;
    uploadDict[@"sex"] = gender;
    uploadDict[@"lki"] = additionalDetail;
    uploadDict[@"latitude"]= lat;
    uploadDict[@"longitude"]= lon;

    // Images
    NSMutableArray *imageArray = [NSMutableArray array];
    for (ImageObject *imageObject in _imageObjectArray) {
        if (!imageObject.imageURL || [imageObject.imageURL isEqualToString:@""]) { // catching already uploaded image
            [imageArray addObject:[imageObject getImageDictionary]];
        }
    }
    NSString *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"imageData"];

    uploadDict[@"photo"] = imageData;
    imageData=nil;
    
    // Delete Image
    if ([_imagesURLToDelete count] > 0) {
        NSMutableArray *objectToDelete = [NSMutableArray array];
        for (NSString *string in _imagesURLToDelete) {
            [objectToDelete addObject:@{@"url" : string}];
        }
       // uploadDict[@"removeImage"] = objectToDelete;
    }
    [[NSUserDefaults standardUserDefaults] setObject:uploadDict forKey:@"uploadDict"];


    return uploadDict;
}

- (NSString *)serializedXMLToUpload
{
    return [self serializedXMLToUploadToExpire:NO];
}

// This is called when you want to expire a record
// Created to handle the case since web service version 34 drops the expire a record api
- (NSString *)serializedXMLToUploadToExpire:(BOOL)toExpire
{
    NSMutableString *returnString = [[NSMutableString alloc] init];
    [returnString appendString:@"<person>"];
    [returnString appendString:@"<xmlFormat>REUNITE4</xmlFormat>"];
    
    //Prepare imfo
    NSString *givenName = [self trimSpaces:[self escaper:_givenName]];
    NSString *familyName = [self trimSpaces:[self escaper:_familyName]];
    NSString *additionalDetail = [self escaper:_additionalDetail];
    NSString *status = [PersonObject statusDictionaryUpload][_status];
    NSString *locationXML = [_location  getLocationXML];
    NSString *gender = [PersonObject genderDictionaryUpload][_gender];
    
    //Time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:GregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:1];
    NSDate *targetDate = [gregorian dateByAddingComponents:dateComponents toDate:[NSDate date]  options:0];
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    // if set to expire, now is a good time to expire
    NSString *expire = toExpire? now : [dateFormatter stringFromDate:targetDate];
    
    [returnString appendFormat:@"<dateTimeSent>%@ UTC</dateTimeSent>",now];
    [returnString appendFormat:@"<expiryDate>%@ UTC</expiryDate>",expire];
    [returnString appendFormat:@"<eventShortname>%@</eventShortname>",[[PersonObject eventLongNameToShortNameDict] objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_CURRENT_EVENT]]];
    [returnString appendFormat:@"<givenName>%@</givenName>",givenName];
    [returnString appendFormat:@"<familyName>%@</familyName>",familyName];
    [returnString appendFormat:@"<gender>%@</gender>",gender];
    
    //age
    
    if ([_ageMin isEqualToString:@""] ||[_ageMin isEqualToString:@"??"]){
        [returnString appendFormat:@"<estimatedAge>%@</estimatedAge>",@"-1"];

    }
    //if age exists
    if (![_ageMin isEqualToString:@""]){
        //if age is not a range
                   [returnString appendFormat:@"<estimatedAge>%@</estimatedAge>",_ageMin];
    }
//        }
//            else{
////            [returnString appendFormat:@"<minAge>%@</minAge>",_ageMin];
////            [returnString appendFormat:@"<maxAge>%@</maxAge>",_ageMax];
////        }
//    }
    
    [returnString appendFormat:@"<status>%@</status>",status];
    [returnString appendFormat:@"<location>%@</location>",locationXML];
    
    //photo to delete
    [returnString appendFormat:@"<deletePhotos>"];
    for (NSString *imageUrlToDelete in _imagesURLToDelete) {
        [returnString appendFormat:@"<photo>%@</photo>",imageUrlToDelete];
    }
    [returnString appendFormat:@"</deletePhotos>"];
    
    /*NSMutableDictionary *tempDeleteQueDict = [[[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_QUE_DELETE_DICT] mutableCopy];
     #pragma mark definitely check here too
     if (_uuid && ![_uuid isEqualToString:@""] && tempDeleteQueDict[_uuid]){
     [returnString appendFormat:@"<deletePhotos>"];
     NSString * tempDeleteURLsString = tempDeleteQueDict[_uuid];
     [tempDeleteQueDict removeObjectForKey:_uuid];
     NSArray *tempDeleteURLsArray = [tempDeleteURLsString componentsSeparatedByString:@","];
     for (NSString *urlString in tempDeleteURLsArray){
     if (![urlString isEqualToString:@""]){
     [returnString appendFormat:@"<photo>%@</photo>",urlString];
     }
     }
     [returnString appendFormat:@"</deletePhotos>"];
     [[NSUserDefaults standardUserDefaults] setObject:tempDeleteQueDict forKey:GLOBAL_KEY_QUE_DELETE_DICT];
     [[NSUserDefaults standardUserDefaults] synchronize];
     }
     */
    NSMutableString *photoXML = [[NSMutableString alloc]init];
    for (ImageObject *imageObject in _imageObjectArray){
        if (!imageObject.imageURL || [imageObject.imageURL isEqualToString:@""]) { // catching already uploaded image
            [photoXML appendString:[imageObject getImageXML]];
        }
    }
    NSString *stringWithoutSpaces = [photoXML
                                     stringByReplacingOccurrencesOfString:@"<primary>1</primary>" withString:@""];
    NSString *myString = stringWithoutSpaces;
    NSString *original = @"<photo><data>";
    NSString *replacement = @"<photo><primary>1</primary><data>";
    
    
    NSRange rOriginal = [myString rangeOfString: original];
    if (NSNotFound != rOriginal.location) {
        myString = [myString
                    stringByReplacingCharactersInRange: rOriginal
                    withString:                         replacement];
    }
    

    [returnString appendFormat:@"<photos>%@</photos>",myString];
    [returnString appendFormat:@"<note>%@</note>",additionalDetail];
    [returnString appendString:@"</person>"];
    
    //escape XML
    //returnString = [self escaper:returnString];
    
    return returnString;

}

#pragma mark - ImageObject delegate
- (int)personID
{
    return _personID;
}

- (void)didCompleteLoadImageWithImageObject:(id)imageObject{
    if (!_imageObjectArray || ![_imageObjectArray count]){
        return; //make sure that the object has not yet to be released, otherwise discard
    }
    
    ImageObject * tempImageObject = imageObject;
    
    NSString *firstImageURL = [(ImageObject *)_imageObjectArray[0] imageURL];
    if ([firstImageURL isEqualToString:tempImageObject.imageURL] && ![ImageObject peopleRecordImageSmallDictFind][_uuid]){ //check for the first URL only to display face on the cell
        [self createSmallImage];
    }

    //check if this is the last image, if it is, refresh the record
    NSString *lastImageURL = [(ImageObject *)_imageObjectArray[[_imageObjectArray count] - 1] imageURL];
    if ([tempImageObject.imageURL isEqualToString:lastImageURL]) {
        //refresh img on the cell
        if (_delegate && [_delegate respondsToSelector:@selector(didFinishedDownloadImagesForPersonObject:)]){
            [_delegate didFinishedDownloadImagesForPersonObject:self];
        }
    }
}

#pragma mark - Helper functions
- (void)removeNSNulls{
    _givenName = ![_givenName isKindOfClass:[NSNull class]]?_givenName:@"";
    _familyName = ![_familyName isKindOfClass:[NSNull class]]?_familyName:@"";
    _status = ![_status isKindOfClass:[NSNull class]]?_status:@"";
    _gender = ![_gender isKindOfClass:[NSNull class]]?_gender:NSLocalizedString(@"Unknown", nil);
    _additionalDetail = ![_additionalDetail isKindOfClass:[NSNull class]]?_additionalDetail:@"";
}

- (void)removeNulls{ // to change all (null) to @""
    _givenName = _givenName?_givenName:@"";
    _familyName = _familyName?_familyName:@"";
    _status = _status?_status:@"";
    _gender = _gender?_gender:NSLocalizedString(@"Unknown", nil);
    _ageMin = _ageMin?_ageMin:@"";
_ageMax = _ageMax?_ageMax:@"";
    _event = _event?_event:@"";
    _lastUpdated = _lastUpdated?_lastUpdated:[NSDate date];
    _uuid = _uuid?_uuid:@"";
    _additionalDetail = _additionalDetail?_additionalDetail:@"";
    _location = _location?_location:[LocationObject emptyLocation];
}

- (NSMutableString *)escaper:(NSString *)string{
    NSMutableString *returnString = [string mutableCopy];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    return string?returnString:[@"" mutableCopy];
}

- (NSMutableString *)deEscaper:(NSString *)string{
    NSMutableString *returnString = [string mutableCopy];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    returnString = (NSMutableString *)[returnString stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    return returnString;
}

- (NSString *)trimSpaces:(NSString *)inString{
    NSArray * a = [inString componentsSeparatedByString:@" "];
    BOOL firstWord = YES;
    NSString *outString;
    for (NSString * string in a){
        if (![string isEqualToString:@""]){
            //if the string is not empty
            if (firstWord){
                //if it is firstword, dont input space infront
                outString = string;
                firstWord = NO;
            }else{
                outString = [outString stringByAppendingFormat:@" %@",string];
            }
        }
    }
    return outString?outString:@"";
}

#pragma mark - Global App Person ID
+ (int)uniqueLocalID
{
    int returnInt = (int)[[NSUserDefaults standardUserDefaults] integerForKey:GLOBAL_KEY_CURRENT_UNIQUE_ID];
    [[NSUserDefaults standardUserDefaults] setInteger:returnInt + 1 forKey:GLOBAL_KEY_CURRENT_UNIQUE_ID];
    return returnInt;
}


#pragma mark - globalKey converters
static NSMutableArray *eventArray;
static NSMutableDictionary *eventLongNameToShortNameDict;
static NSDictionary *sortByDictionary;
static NSDictionary *statusShortToLong;
static NSDictionary *statusLongToShort;
static NSDictionary *genderShortToLong;
static NSDictionary *genderLongToShort;
static NSDictionary *colorDictionary;

+ (NSMutableArray *)eventArray
{
    NSString *eventArrayJSONString = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_EVENT_ARRAY];
    if (eventArrayJSONString) {
        eventArray = [CommonFunctions deserializedDictionaryFromJSONString:eventArrayJSONString];
       // eventArray=eventArrayJSONString;
        eventArray = [eventArray mutableCopy];
    }
    
    if (!eventArray) {
        eventArray = [NSMutableArray array];
    }
    return eventArray;
}

+ (NSDictionary *)eventLongNameToShortNameDict
{
    if (!eventLongNameToShortNameDict || eventLongNameToShortNameDict.count != [PersonObject eventArray].count) {
        eventLongNameToShortNameDict = [NSMutableDictionary dictionary];
        for (NSDictionary *eventDict in [PersonObject eventArray]) {
            NSString *longName = [[eventDict objectForKey:@"names"] objectForKey:@"en"];
            NSString *shortName = eventDict[@"short"];
            eventLongNameToShortNameDict[longName] = shortName;
        }
    }
    return eventLongNameToShortNameDict;
}

+ (NSDictionary *)sortByDictionary
{
    if (!sortByDictionary) {
        
      //  NSArray *sortArray = @[@"Given Name",@"Family Name",@"Update Time", @"Age" ,@"Status",@"Gender"];//NSLocalizedString(@"Given Name", nil)NSLocalizedString(@"Family Name", nil)NSLocalizedString(@"Update Time", nil)NSLocalizedString(@"Age", nil)NSLocalizedString(@"Status", nil)NSLocalizedString(@"Gender", nil)
         NSArray *sortArray = @[NSLocalizedString(@"Given Name", nil),NSLocalizedString(@"Update Time", nil), NSLocalizedString(@"Age", nil) ,NSLocalizedString(@"Status", nil),NSLocalizedString(@"Gender", nil)];//NSLocalizedString(@"Given Name", nil)NSLocalizedString(@"Family Name", nil)NSLocalizedString(@"Update Time", nil)NSLocalizedString(@"Age", nil)NSLocalizedString(@"Status", nil)NSLocalizedString(@"Gender", nil)
        sortByDictionary = [NSDictionary dictionaryWithObjects:@[@"given_name", @"updated", @"years_old", @"opt_status", @"opt_gender"] forKeys:sortArray];
    }
    return sortByDictionary;
}

+ (NSDictionary *)statusDictionary{
    
    if (statusShortToLong == nil){
        //NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        
        
//        if([language isEqualToString:@"es"]||[language isEqualToString:@"es-US"]||[language isEqualToString:@"es-ES"]||[language isEqualToString:@"es-MX"]||[language isEqualToString:@"es-419"])
//            
//        {
//            statusShortToLong = [[NSDictionary alloc] initWithObjects:@[@"Alive and Well", @"Missing",@"Injured", @"Deceased", @"Unknown", @"Found (no status)"] forKeys:@[@"ali", @"mis", @"inj", @"dec", @"unk", @"fnd"]];
//
//        }
      
        statusShortToLong = [[NSDictionary alloc] initWithObjects:@[NSLocalizedString(@"Alive and Well", nil), NSLocalizedString(@"Missing", nil),NSLocalizedString(@"Injured", nil), NSLocalizedString(@"Deceased", nil),NSLocalizedString(@"Unknown", nil), NSLocalizedString(@"Found (no status)", nil)] forKeys:@[@"ali", @"mis", @"inj", @"dec", @"unk", @"fnd"]];
       
       
    }
    return statusShortToLong;
}

+ (NSDictionary *)statusDictionaryUpload{
    if (statusLongToShort == nil){
         //NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
//        if([language isEqualToString:@"es"]||[language isEqualToString:@"es-US"]||[language isEqualToString:@"es-ES"]||[language isEqualToString:@"es-MX"]||[language isEqualToString:@"es-419"])
//            
//        {
//            statusLongToShort = [[NSDictionary alloc] initWithObjects:@[@"ali", @"mis", @"inj", @"dec", @"unk", @"fnd"] forKeys:@[@"Alive and Well",@"Missing",@"Injured",@"Deceased",@"Unknown",@"Found (no status)"]];
//
//           
//        }
     
     
         statusLongToShort = [[NSDictionary alloc] initWithObjects:@[@"ali", @"mis", @"inj", @"dec", @"unk", @"fnd"] forKeys:@[NSLocalizedString(@"Alive and Well", nil),NSLocalizedString(@"Missing", nil),NSLocalizedString(@"Injured", nil),NSLocalizedString(@"Deceased", nil),NSLocalizedString(@"Unknown", nil),NSLocalizedString(@"Found (no status)", nil)]];
     
      
        
    }
    return statusLongToShort;
}

+ (NSDictionary *)genderDictionary{
    if (genderShortToLong == nil){
       // NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
//        if([language isEqualToString:@"es"]||[language isEqualToString:@"es-US"]||[language isEqualToString:@"es-ES"]||[language isEqualToString:@"es-MX"]||[language isEqualToString:@"es-419"])
//            
//        {
//            genderShortToLong = [[NSDictionary alloc] initWithObjects:@[@"Male",@"Female",@"Other",@"Unknown"] forKeys:@[@"mal", @"fml", @"cpx", @"unk"]];
//
//        }
//      
     
        genderShortToLong = [[NSDictionary alloc] initWithObjects:@[NSLocalizedString(@"Male", nil),NSLocalizedString(@"Female", nil),NSLocalizedString(@"Other", nil),NSLocalizedString(@"Unknown", nil)] forKeys:@[@"mal", @"fml", @"cpx", @"unk"]];
     
   

    }
    return genderShortToLong;
}

+ (NSDictionary *)genderDictionaryUpload{
    if (genderLongToShort == nil){
       // NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
//        if([language isEqualToString:@"es"]||[language isEqualToString:@"es-US"]||[language isEqualToString:@"es-ES"]||[language isEqualToString:@"es-MX"]||[language isEqualToString:@"es-419"])
//            
//        {
//            genderLongToShort = [[NSDictionary alloc] initWithObjects:@[@"mal", @"fml", @"cpx", @"unk"] forKeys:@[@"Male",@"Female",@"Complex",@"Unknown"] ];
//
//        }
    
         genderLongToShort = [[NSDictionary alloc] initWithObjects:@[@"mal", @"fml", @"cpx", @"unk"] forKeys:@[NSLocalizedString(@"Male", nil),NSLocalizedString(@"Female", nil),NSLocalizedString(@"Other", nil),NSLocalizedString(@"Unknown", nil)] ];

   
     

        
    }
    return genderLongToShort;
}

+ (UIColor *)colorForStatus:(NSString *)status{
    if (!status) {
        return [UIColor darkGrayColor];
    }
    
    if (colorDictionary == nil){
        UIColor *darkerGreen = [[UIColor alloc] initWithRed:0 green: .68 blue:0 alpha:1.0];
        UIColor *darkerGray = [[UIColor alloc] initWithRed:.4 green: .4 blue:.4 alpha:1.0];
        UIColor *lighterBlue = [[UIColor alloc] initWithRed:0 green:0 blue:.68 alpha:1.0];
        UIColor *softerRed = [[UIColor alloc] initWithRed:.68 green:0 blue:0 alpha:1.0];
        
       // NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSArray *statusArray;
        
//        if([language isEqualToString:@"es"]||[language isEqualToString:@"es-US"]||[language isEqualToString:@"es-ES"]||[language isEqualToString:@"es-MX"]||[language isEqualToString:@"es-419"])
//            
//        {
//             statusArray = @[@"Missing",@"Alive and Well",@"Injured",@"Deceased", @"Found (no status)",@"Unknown", @"Unspecified"];
//        }
// 
            statusArray = @[NSLocalizedString(@"Missing", nil), NSLocalizedString(@"Alive and Well", nil),NSLocalizedString(@"Injured", nil), NSLocalizedString(@"Deceased", nil), NSLocalizedString(@"Found (no status)", nil),NSLocalizedString(@"Unknown", nil), NSLocalizedString(@"Unspecified", nil)];
   

        
   
        
        NSArray *statusColorArray = @[lighterBlue, darkerGreen, softerRed, [UIColor blackColor],[UIColor brownColor], darkerGray, [UIColor grayColor]];
        colorDictionary = [[NSDictionary alloc] initWithObjects:statusColorArray forKeys:statusArray];
    }
    return colorDictionary[status];
}


+ (int)tagForType:(NSString *)type
{
    if ([type isEqualToString:PERSON_TYPE_FIND]) {
        return TAG_FIND;
    } else if ([type isEqualToString:PERSON_TYPE_SAVE]) {
        return TAG_SAVED;
    } else if ([type isEqualToString:PERSON_TYPE_DRAFT]) {
        return TAG_DRAFT;
    } else if ([type isEqualToString:PERSON_TYPE_OUTBOX]) {
        return TAG_OUTBOX;
    } else if ([type isEqualToString:PERSON_TYPE_SENT]) {
        return TAG_SENT;
    }
    return 0;
}

+ (NSString *)typeForTag:(int)tag
{
    NSString *typeString = @"";
    switch (tag) {
        case TAG_FIND:
            typeString = PERSON_TYPE_FIND;
            break;
        case TAG_SAVED:
            typeString = PERSON_TYPE_SAVE;
            break;
        case TAG_DRAFT:
            typeString = PERSON_TYPE_DRAFT;
            break;
        case TAG_OUTBOX:
            typeString = PERSON_TYPE_OUTBOX;
            break;
        case TAG_SENT:
            typeString = PERSON_TYPE_SENT;
        default:
            break;
    }
    return typeString;
}

#pragma mark Triage Pic
static NSMutableArray *hospitalArray;
static NSMutableDictionary *hospitalNameIdDict;
static NSDictionary *colorZoneDictionary;

/*
+ (NSMutableArray *)hospitalArray
{
    NSString *hospitalArrayJSONString = [[NSUserDefaults standardUserDefaults] objectForKey:GLOBAL_KEY_HOSPITAL_ARRAY];
    // Add the unknown first
    hospitalArray = [NSMutableArray array];
    [hospitalArray addObject:@{@"hospital_uuid": @0,
                               @"latitude" : @0,
                               @"longitude" : @0,
                               @"name" : @"Unknown",
                               @"npi" : @"",
                               @"shortname" : @"Unknown"}];
    
    // Then add the rest
    if (hospitalArrayJSONString) {
       [hospitalArray addObjectsFromArray:[CommonFunctions deserializedDictionaryFromJSONString:hospitalArrayJSONString]];
    }
    
    
    return hospitalArray;
}


+ (NSDictionary *)hospitalNameToIdDict
{
    if (!hospitalNameIdDict || hospitalNameIdDict.count != [PersonObject hospitalArray].count) {
        hospitalNameIdDict = [NSMutableDictionary dictionary];
        for (NSDictionary *hospitalDict in [PersonObject hospitalArray]) {
            NSString *name = hospitalDict[@"name"];
            NSString *uuid = [hospitalDict[@"hospital_uuid"] description];
            hospitalNameIdDict[name] = uuid;
        }
    }
    return hospitalNameIdDict;
}
*/
+ (NSDictionary *)colorZoneDictionary
{
    if (colorZoneDictionary == nil){
        UIColor *darkerGreen = [[UIColor alloc] initWithRed:0 green:.68 blue:0 alpha:1.0];
        UIColor *darkerGray = [[UIColor alloc] initWithRed:.4 green:.4 blue:.4 alpha:1.0];
        UIColor *lightBlack = [[UIColor alloc] initWithRed:.2 green:.2 blue:.2 alpha:1.0];
        UIColor *darkerYellow = [[UIColor alloc] initWithRed:.7 green:.7 blue:0 alpha:1.0];
        UIColor *softerRed = [[UIColor alloc] initWithRed:.68 green:0 blue:0 alpha:1.0];
        
        NSArray *statusArray = @[@"Green", @"BH Green", @"Yellow", @"Red", @"Gray", @"Black", @"Unknown"];
        NSArray *statusColorArray = @[darkerGreen, [UIColor greenColor], darkerYellow, softerRed, darkerGray, lightBlack, [UIColor grayColor]];
        colorZoneDictionary = [[NSDictionary alloc] initWithObjects:statusColorArray forKeys:statusArray];
    }
    return colorZoneDictionary;
}

+ (UIColor *)colorForZone:(NSString *)zone
{
    if (!zone) {
        return [UIColor darkGrayColor];
    }
    return [PersonObject colorZoneDictionary][zone];
}

#pragma mark - Helper function
- (id)copy{
    PersonObject *personObject = [[PersonObject alloc] initWithPersonID:_personID type:_type givenName:_givenName familyName:_familyName status:_status gender:_gender ageMin:_ageMin ageMax:_ageMax event:_event lastUpdated:[_lastUpdated copy] webLink:_webLink uuid:_uuid additionalDetail:_additionalDetail imageObjectArray:[_imageObjectArray mutableCopy] commentObjectArray:[_commentObjectArray mutableCopy] location:[_location copy] canEdit:_canEdit];
    [personObject setHospitalName:_hospitalName];
    [personObject setPatientId:_patientId];
    [personObject setZone:_zone];
    return personObject;
}

#pragma mark - Debug
- (id)debugQuickLookObject
{
    return [self serializedJSONDictToExpire:NO].description;
}

@end
