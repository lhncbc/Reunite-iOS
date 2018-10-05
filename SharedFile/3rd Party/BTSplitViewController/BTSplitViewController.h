//
//  BTSplitViewController.h
//  BTSplitViewControllerExample
//

//

#import <UIKit/UIKit.h>
#import "BTSplitViewDefinition.h"

@interface BTSplitViewController : UIViewController <UINavigationControllerDelegate>
// id because it could be tableViewController/viewController/navigationController
- (id)initWithMaster:(id)masterController detail:(id)detailController;

// it does not have to be UINavigationController but it would make sense most of the time
// And it makes it easier to access its view property than id
@property (nonatomic, strong) UINavigationController *masterController;
@property (nonatomic, strong) UINavigationController *detailController;

@end
