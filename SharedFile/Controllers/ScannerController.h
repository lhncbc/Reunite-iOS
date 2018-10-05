//
//  ScannerController.h
//  ReUnite + TriagePic
//


#import <UIKit/UIKit.h>

@protocol ScannerControllerDelegate <NSObject>

- (void)successScanWithString:(NSString *)string;

@end

@interface ScannerController : UIViewController <UIAlertViewDelegate>
@property (nonatomic, weak) id<ScannerControllerDelegate> delegate;
@end
