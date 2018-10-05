//
//  ImageObject.m
//  ReUnite + TriagePic
//


#import "ImageObject.h"
@implementation ImageObject

static NSMutableDictionary *peopleRecordImageDictFind;
static NSMutableDictionary *peopleRecordImageSmallDictFind;
static NSMutableDictionary *peopleRecordImageTagDictFind;
static NSMutableDictionary *peopleRecordImageTagAvailableFind;

- (id)initWithImage:(UIImage *)image imageURL:(NSString *)imageURL faceRect:(CGRect)faceRect faceRectAvailable:(BOOL)faceRectAvailable primary:(BOOL)primary delegate:(id)delegate{
    self = [super init];
    if (self){
        _image = image;
        _imageURL = imageURL;
        _faceRect = faceRect;
        _faceRectAvailable = faceRectAvailable;
        _primary = primary;
        _delegate = delegate;
    }
    return self;
}

- (id)initWithImage:(NSDictionary *)imageDictionary delegate:(id)delegate backgroundDownload:(BOOL)backgroundDownload{
    self = [super init];
    if (self){
        
       // NSString *image=imageDictionary[@"url"];
       // _image = [UIImage imageWithContentsOfFile:image];
        _image=nil;
        _imageURL = @"";
        
      // [self getImageObjectFromDictionary:imageDictionary];
        _faceRect = CGRectMake(0, 0, 0, 0);
        _faceRectAvailable = NO;
        _primary = NO;
        _delegate = delegate;
        if (backgroundDownload){
            dispatch_async([ImageObject getImageLoadingQue], ^{
                [self getImageObjectFromDictionary:imageDictionary];
            });
        }else{
            [self getImageObjectFromDictionary:imageDictionary];
        }
    }
    return self;
}

- (NSDictionary *)getImageDictionary {
    CGFloat compression = 1;
    CGFloat maxFileSize = 250*1024;
    CGFloat maxCompression = .30;
    
    NSData *imageData = UIImageJPEGRepresentation(_image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(_image, compression);
    }
    NSString *photoAfterResizedString = [ImageObject base64StringFromData:imageData length:(int)[imageData length]];
    
    [[NSUserDefaults standardUserDefaults] setObject:photoAfterResizedString forKey:@"imageData"];

    NSMutableDictionary *imageDictionary = [NSMutableDictionary dictionary];
   // imageDictionary[@"primary"] = _primary?@"true":@"false";
    imageDictionary[@"primary"] = @"true";
    imageDictionary[@"data"] = photoAfterResizedString;
    imageDictionary[@"tags"] = [self getTagDictionary];
    
    return imageDictionary;
}

- (NSDictionary *)getTagDictionary {
    return @{@"x": @(_faceRect.origin.x).stringValue,
             @"y": @(_faceRect.origin.y).stringValue,
             @"w": @(_faceRect.size.width).stringValue,
             @"h": @(_faceRect.size.height).stringValue};
}

- (NSString *)getImageXML{
    CGFloat compression = 1;
    CGFloat maxFileSize = 250*1024;
    CGFloat maxCompression = .30;
    
    NSMutableString *returnString = [[NSMutableString alloc] init];
    
    NSData *imageData = UIImageJPEGRepresentation(_image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression)
   {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(_image, compression);
    }
    
    NSString *photoAfterResizedString = [ImageObject base64StringFromData:imageData length:(int)[imageData length]];
    NSString *tagString = [NSString stringWithFormat:@"<x>%f</x><y>%f</y><w>%f</w><h>%f</h>", _faceRect.origin.x,_faceRect.origin.y,_faceRect.size.width,_faceRect.size.height];
    
    [returnString appendString:@"<photo>"];
   [returnString appendString:@"<primary>1</primary>"];
    [returnString appendFormat:@"<data>%@</data>",photoAfterResizedString];
    // For future reference in case you want to add a text for the image
    //[returnString appendFormat:@"<tags><tag>%@<text>Face</text></tag></tags>",tagString];
    [returnString appendFormat:@"<tags><tag>%@</tag></tags>",tagString];
    [returnString appendString:@"</photo>"];

    return returnString;
}


#pragma mark - helper function
- (void)getImageObjectFromDictionary:(NSDictionary *)imageDictionary{
    //first get urls

//
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    // getting an NSString
//    NSString *myString = [prefs stringForKey:@"image_url"];
//    
//    NSString *imageURL =myString;
//    
    
    NSString *imageURL = imageDictionary[@"url_thumb"];
    imageURL = ![imageURL isKindOfClass:[NSNull class]]?imageURL:@"";


    UIImage *image = [ImageObject peopleRecordImageDictFind][imageURL]; //image from userdefault
   
    CGRect faceRect = [[ImageObject peopleRecordImageTagDictFind][imageURL] CGRectValue];
    BOOL faceRectAvailable = [[ImageObject peopleRecordImageTagAvailableFind][imageURL] boolValue];
    
   
   // image = [ImageObject getPLImagesFromURLExtension:imageURL];
   if (!image){ //if not exists (or was error last time around),  get everything about it
//        //get image
        image = [ImageObject getPLImagesFromURLExtension:imageURL];
       if (image) {
////            //get faceRect
//            NSArray *tagArray = imageDictionary[@"tags"];
//        
//           if ([tagArray count]){
//               NSDictionary *faceRectDict;
//                if (faceRectDict && [faceRectDict[@"tag_w"] floatValue] != 0 && [faceRectDict[@"tag_h"] floatValue] != 0){ //if tag is not valid
//                   // CGFloat scaleFactor = image.size.width/[imageDictionary[@"image_width"]floatValue];
//                   // faceRect = CGRectMake([faceRectDict[@"tag_x"] floatValue]*scaleFactor, [faceRectDict[@"tag_y"] floatValue]*scaleFactor, [faceRectDict[@"tag_w"] floatValue]*scaleFactor, [faceRectDict[@"tag_h"] floatValue]*scaleFactor);
//                    faceRectAvailable = YES;
//                }else{
//                    faceRect = CGRectMake(0, 0, image.size.width, image.size.height);
//                    faceRectAvailable = NO;
//                }
//            }else{
//                faceRect = CGRectMake(0, 0, image.size.width, image.size.height);
//                faceRectAvailable = NO;
//            }
//            //store into userdefault
            [ImageObject peopleRecordImageDictFind][imageURL] = image; //store image
            //[ImageObject peopleRecordImageTagDictFind][imageURL] = [NSValue valueWithCGRect:faceRect]; //store face rect
            //[ImageObject peopleRecordImageTagAvailableFind][imageURL] = @(faceRectAvailable); //store face rect availability from server
       }else{
           
          // image = [ImageObject imageForButtonWithRect:CGRectMake(0, 0, 100, 100) image:[UIImage imageNamed:@"No Image Male"] buttonSize:64 * [[UIScreen mainScreen] scale]];

            image = [UIImage imageNamed:@"No Image Male"];
           faceRectAvailable = NO;
        }
    }
   
    _image = image;
    _imageURL = imageURL;
    _faceRect = faceRect;
    _faceRectAvailable = faceRectAvailable;
    [self.delegate didCompleteLoadImageWithImageObject:self];
}

#pragma mark - Global App Image Management
+ (NSMutableDictionary *)peopleRecordImageDictFind{
    if (peopleRecordImageDictFind == nil){
        peopleRecordImageDictFind = [[NSMutableDictionary alloc] init];
    }
    return peopleRecordImageDictFind;
}

+ (NSMutableDictionary *)peopleRecordImageSmallDictFind{
    if (peopleRecordImageSmallDictFind == nil){
        peopleRecordImageSmallDictFind = [[NSMutableDictionary alloc] init];
    }
    return peopleRecordImageSmallDictFind;
}

+ (NSMutableDictionary *)peopleRecordImageTagDictFind{
    if (peopleRecordImageTagDictFind == nil){
        peopleRecordImageTagDictFind = [[NSMutableDictionary alloc] init];
    }
    return peopleRecordImageTagDictFind;
}

+ (NSMutableDictionary *)peopleRecordImageTagAvailableFind{
    if (peopleRecordImageTagAvailableFind == nil){
        peopleRecordImageTagAvailableFind = [[NSMutableDictionary alloc] init];
    }
    return peopleRecordImageTagAvailableFind;
}


#pragma mark Image Loading Queue Management
static dispatch_queue_t imageLoadingQue;
+ (dispatch_queue_t)getImageLoadingQue{
    if (!imageLoadingQue){
        imageLoadingQue = dispatch_queue_create("ImageFetchingQueue", DISPATCH_QUEUE_SERIAL);
    }
    return imageLoadingQue;
}

#pragma mark Image Manipulation
+ (ImageObject *)imageObjectFromImage:(UIImage *)image
{
    return [[ImageObject alloc] initWithImage:image imageURL:@"" faceRect:CGRectZero faceRectAvailable:NO primary:NO delegate:nil];
}

+ (UIImage *)getPLImagesFromURLExtension:(NSString *)urlExtension{
    NSData *dataImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",[[NSUserDefaults standardUserDefaults] stringForKey:GLOBAL_KEY_SERVER_HTTP], [[NSUserDefaults standardUserDefaults] stringForKey:GLOBAL_KEY_SERVER_NAME] ,urlExtension]]];//load
    return [UIImage imageWithData:dataImg];
}
+ (UIImage *)getImagesFromURLString:(NSString *)urlString{
    NSData *dataImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];//load
    return [UIImage imageWithData:dataImg];
}

+ (NSArray *)faceDetectionRectArrayFromImage:(UIImage *)image{
    NSMutableArray *factRectArray = [NSMutableArray array];
    CIImage* ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIDetector* detector = [self imageDetector];//[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    NSArray* features = [detector featuresInImage:ciImage];
    
    for (CIFaceFeature *faceFeature in features){
        int pad = faceFeature.bounds.size.width/5;
        CGRect faceRect = CGRectMake(faceFeature.bounds.origin.x - pad,image.size.height - faceFeature.bounds.origin.y - faceFeature.bounds.size.height - pad, faceFeature.bounds.size.width + 2*pad, faceFeature.bounds.size.height + 2*pad);
        [factRectArray addObject:[NSValue valueWithCGRect:faceRect]];
    }
    
    return factRectArray;
}

+ (UIImage *)imageForButtonWithRect:(CGRect)frame image:(UIImage *)image buttonSize:(int)size{ //cuts to the very core of the rect
    //first, look at the width and height of both, choose the bigger one
    float maxLength = MAX(frame.size.width, frame.size.height);
    //if width or height is greater than picture size, that means it needs to be cropped to the image size
    float minImageSize = MIN(image.size.width, image.size.height);
    maxLength = MIN(maxLength, minImageSize);
    
    //then get origin x and y to crop
    int x = frame.origin.x + frame.size.width/2 - maxLength/2;
    int y = frame.origin.y + frame.size.height/2 - maxLength/2;
    
    //if origin x < 0 or y < 0, adjust accordingly
    x = x<0?0:x;
    y = y<0?0:y;
    
    //if the box goes over the border, adjust accordingly
    x = x+maxLength > image.size.width? x- (x+maxLength - image.size.width):x;
    y = y+maxLength > image.size.height? y- (y+maxLength - image.size.height):y;
    
    //proceed for the crop
    CGRect rect = CGRectMake(x, y, maxLength, maxLength);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage],rect);
    //UIImage *imageOut =  [UIImage imageWithCGImage:imageRef];
    UIImage *imageOut=image;
    CGImageRelease(imageRef);
    
    return imageOut;
}

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)targetSize{
    if (!image){
        return nil;
    }
    
    //If scaleFactor is not touched, no scaling will occur
    CGFloat scaleFactor = 1.0;
    
    while ((image.size.width < targetSize.width) || (image.size.height < targetSize.height)){
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width *2, image.size.height *2));
        [image drawInRect:CGRectMake(0,0,image.size.width *2,image.size.height *2)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = newImage;
    }
    
    //Deciding which factor to use to scale the image (factor = targetSize / imageSize)
    if (image.size.width > targetSize.width || image.size.height > targetSize.height)
        if (!((scaleFactor = (targetSize.width / image.size.width)) > (targetSize.height / image.size.height))) //scale to fit width, or
            scaleFactor = targetSize.height / image.size.height; //scale to fit heigth.
    
    UIGraphicsBeginImageContext(targetSize);
    
    //Creating the rect where the scaled image is drawn in
    CGRect rect = CGRectMake((targetSize.width - image.size.width * scaleFactor) / 2,
                             (targetSize.height -  image.size.height * scaleFactor) / 2,
                             image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    //Draw the image into the rect
    [image drawInRect:rect];
    
    //Saving the image, ending image context
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)enlargeImage:(UIImage *)image maxLengthToLength:(CGFloat)targetLength
{
    if (!image) {
        return nil;
    }
    
    CGFloat maxLength = MAX(image.size.width, image.size.height);
    if (maxLength > targetLength) {
        return image;
    }
    
    CGFloat ratio = targetLength/maxLength;
    CGSize newSize = CGSizeMake(ratio * image.size.width, ratio * image.size.height);
    UIGraphicsBeginImageContext(newSize);
    
    //Creating the rect where the scaled image is drawn in
    CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
    [image drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


+ (UIImage *)resizeImage:(UIImage *)image toFitHeight:(CGFloat)height allowedWidth:(CGFloat)allowedWidth
{
    CGSize newSize = CGSizeMake(image.size.width * height/image.size.height, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    if (allowedWidth < newImage.size.width) {
        //proceed for the crop
        CGRect rectToCrop = CGRectMake((newImage.size.width - allowedWidth)/2, 0, allowedWidth, height);
        CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage],rectToCrop);
        newImage =  [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    
    return newImage;
}

+ (UIImage *)resizeImage:(UIImage *)image toFitWidth:(CGFloat)width allowedHeight:(CGFloat)allowedHeight
{
    CGSize newSize = CGSizeMake(width, image.size.height * width/image.size.width);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (allowedHeight < newImage.size.height) {
        //proceed for the crop
        CGRect rectToCrop = CGRectMake(0, (newImage.size.height - allowedHeight)/2, width, allowedHeight);
        CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage],rectToCrop);
        newImage =  [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    
    return newImage;
}


#pragma mark  - encoding 64;
static char base64EncodingTable[64] ={
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

+ (NSString *)base64StringFromData:(NSData *)data length:(int)length{
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true){
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++){
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining){
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}

+ (UIImage *)cropImage:(UIImage *)image atRect:(CGRect)rect{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage],rect);
    image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

static CIDetector* detector;
+ (CIDetector *)imageDetector{
    if (!detector){
        detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        
        
    }
    return detector;
}

+ (UIImage *)fixOrientation:(UIImage *)oldImage toSize:(CGSize)newSize{
    //No-op if the orientation is already correct
    //if (oldImage.imageOrientation == UIImageOrientationUp) return oldImage;
    
    //We need to calculate the proper transformation to make the image upright.
    //We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (oldImage.imageOrientation){
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, oldImage.size.width, oldImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, oldImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, oldImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    //Now we draw the underlying CGImage into a new context, applying the transform
    //calculated above.
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little;


    CGContextRef ctx = CGBitmapContextCreate(NULL, oldImage.size.width, oldImage.size.height,
                                             CGImageGetBitsPerComponent(oldImage.CGImage), 0,
                                             CGImageGetColorSpace(oldImage.CGImage),
                                             bitmapInfo);
    CGContextConcatCTM(ctx, transform);
    switch (oldImage.imageOrientation){
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            //Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,oldImage.size.height,oldImage.size.width), oldImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,oldImage.size.width,oldImage.size.height), oldImage.CGImage);
            break;
    }
    
    //And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    //Resize
    CGFloat scale = MIN(newSize.width/image.size.width, newSize.height/image.size.height);
    if (scale >= 1){
        return image;
    }
    newSize.width = scale * image.size.width;
    newSize.height = scale * image.size.height;
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* correctSizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return correctSizedImage;
}

+ (NSString *)base64EncodingImageWithImage:(UIImage *)image
{    
    CGFloat compression = 1;
    CGFloat maxFileSize = 250*1024;
    CGFloat maxCompression = .30;
        
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    NSString *photoAfterResizedString = [ImageObject base64StringFromData:imageData length:(int)[imageData length]];
    
    DLog(@"%f",[[NSDate date] timeIntervalSinceNow]);
    
    return photoAfterResizedString;
}

+ (BOOL)compareImage:(UIImage *)image1 withImage:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqualToData:data2];
}

#pragma mark - Debug
- (id)debugQuickLookObject
{
    return self.image;
}
@end
