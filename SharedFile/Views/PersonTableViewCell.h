//
//  PersonTableViewCell.h
//  ReUnite + TriagePic
//


#import <UIKit/UIKit.h>
#import "PersonObject.h"

@interface PersonTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *personImageView;
@property (strong, nonatomic) UILabel *personNameLabel;
@property (strong, nonatomic) UILabel *personUpdatedLabel;
@property (strong, nonatomic) UILabel *personAgeLabel;
@property (strong, nonatomic) UILabel *personGenderLabel;
@property (strong, nonatomic) UILabel *personRankLabel;
@property (strong, nonatomic) PersonObject *personObject;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

- (void)fillWithPersonObject:(PersonObject *)personObject;

@end
