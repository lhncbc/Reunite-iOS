//
//  ImageObject.h
//  ReUnite + TriagePic
//

#import <Foundation/Foundation.h>

@protocol ImageObjectDelegate <NSObject>
@required
- (int)personID;
@optional
- (void)didCompleteLoadImageWithImageObject:(id)imageObject;
@end

@interface ImageObject : NSObject
@property (strong,nonatomic) UIImage *image;
@property (strong,nonatomic) NSString *imageURL;
@property (assign,nonatomic) CGRect faceRect;
@property (assign,nonatomic) BOOL faceRectAvailable;
@property (assign,nonatomic) BOOL primary;
@property (assign, nonatomic) BOOL mannualyLocateFaceRect;

- (id)initWithImage:(UIImage *)image imageURL:(NSString *)imageURL faceRect:(CGRect)faceRect faceRectAvailable:(BOOL)faceRectAvailable primary:(BOOL)primary delegate:(id)delegate;
- (id)initWithImage:(NSDictionary *)imageDictionary delegate:(id)delegate backgroundDownload:(BOOL)backgroundDownload;
- (NSDictionary *)getImageDictionary;
- (NSString *)getImageXML;

+ (ImageObject *)imageObjectFromImage:(UIImage *)image;
+ (UIImage *)getPLImagesFromURLExtension:(NSString *)urlExtension;
+ (UIImage *)getImagesFromURLString:(NSString *)urlString;
+ (NSArray *)faceDetectionRectArrayFromImage:(UIImage *)image;
+ (UIImage *)imageForButtonWithRect:(CGRect)frame image:(UIImage *)image buttonSize:(int)size;
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)targetSize;
+ (UIImage *)enlargeImage:(UIImage *)image maxLengthToLength:(CGFloat)targetLength;
+ (UIImage *)resizeImage:(UIImage *)image toFitHeight:(CGFloat)height allowedWidth:(CGFloat)allowedWidth;
+ (UIImage *)resizeImage:(UIImage *)image toFitWidth:(CGFloat)width allowedHeight:(CGFloat)allowedHeight;
+ (UIImage *)cropImage:(UIImage *)image atRect:(CGRect)rect;
+ (CIDetector *)imageDetector;
+ (UIImage *)fixOrientation:(UIImage *)oldImage toSize:(CGSize)newSize;
+ (NSString *)base64StringFromData:(NSData *)data length:(int)length;
+ (NSString *)base64EncodingImageWithImage:(UIImage *)image;
+ (BOOL)compareImage:(UIImage *)image1 withImage:(UIImage *)image2;

//images cache from "Find"
+ (NSMutableDictionary *)peopleRecordImageDictFind;
+ (NSMutableDictionary *)peopleRecordImageSmallDictFind;
+ (NSMutableDictionary *)peopleRecordImageTagDictFind;
+ (NSMutableDictionary *)peopleRecordImageTagAvailableFind;

@property (weak,nonatomic) id<ImageObjectDelegate> delegate;
@end
