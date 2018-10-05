//
//  FindViewController.h
//  ReUnite + TriagePic
//


#import <UIKit/UIKit.h>
#import "DetailController.h"
#import "PersonTableViewCell.h"
#import "FilterViewController.h"
#import "WSCommon.h"
#import "SVProgressHUD.h"
#import "FaceMatchHandlerObject.h"

@interface FindViewController : UITableViewController <UISearchBarDelegate, WSCommonDelegate, PersonObjectDelegate, BTFilterControllerDelegate, DetailControllerDelegate, FaceMatchHandlerObjectDelegate>

@end
