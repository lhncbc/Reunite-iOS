//
//  OrganizeController.h
//  ReUnite + TriagePic
//


#import <UIKit/UIKit.h>
#import "PersonTableViewCell.h"
#import "FilterViewController.h"
#import "ReportController.h"
#import "PeopleDatabase.h"
#import "DetailController.h"

#define NOTIFICATION_UPDATE_TABLE @"NOTIFICATION_UPDATE_TABLE"

@interface OrganizeController : UITableViewController<UISearchBarDelegate, BTFilterControllerDelegate, UITabBarDelegate, ReportControllerDelegate, DetailControllerDelegate>

- (void)editPersonObject:(PersonObject *)personObject;
@end
