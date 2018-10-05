//
//  BTSubFilterController.h
//  BTFilterControllerExample
//

//

#import <UIKit/UIKit.h>

#define KEY_3_CHOICE @"choice"
#define KEY_3_TEXT_COLOR @"textColor"
#define KEY_3_IMAGE @"image"

@protocol BTSubFilterControllerDelegate;

@interface BTSubFilterController : UITableViewController
@property (nonatomic, strong) NSArray *choiceArray;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) int currentSelect;
@property (nonatomic, weak) id<BTSubFilterControllerDelegate> delegate;
@end

@protocol BTSubFilterControllerDelegate <NSObject>
- (void)subFilterController:(BTSubFilterController *)subFilterController didChooseDict:(NSDictionary *)itemDict;
@end
