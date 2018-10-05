//
//  PersonTableViewCell.m
//  ReUnite + TriagePic
//


#import "PersonTableViewCell.h"
/*#define PAD_EDGE 10
#define SIZE_WIDTH 300*/
#define SIZE_HEIGHT 80
#define SIZE_EDIT 100

@implementation PersonTableViewCell{
   // UIScrollView *_backgroundScrollView;
   // BOOL _selected;
    UIView *_statusColorView;
}
//@synthesize selected = _selected;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setBackgroundColor:[UIColor clearColor]];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        // Initialization code
        /*
        _backView = [[BTBlurredView alloc] initWithFrame:CGRectMake(PAD_EDGE, PAD_EDGE, SIZE_WIDTH, SIZE_HEIGHT)];
        [_backView.layer setCornerRadius:5];
        [_backView.layer setBorderWidth:1];
        [_backView setClipsToBounds:YES];
        //[_backView setShouldUseExperimentOptimization:YES];
        [_backView setShouldObserveScroll:YES];
        [self addSubview:_backView];*/
        
        /*
        _backgroundScrollView = [[UIScrollView alloc] init];
        [_backgroundScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_backgroundScrollView setPagingEnabled:YES];
        [_backgroundScrollView setShowsHorizontalScrollIndicator:NO];
        [_backgroundScrollView setScrollsToTop:NO];
        [self.contentView addSubview:_backgroundScrollView];
        */
        /*
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80)];
        //[_backView setClipsToBounds:YES];
        [_backgroundScrollView addSubview:_backView];*/
        
        _personImageView = [[UIImageView alloc] init];
        [_personImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_personImageView.layer setBorderWidth:1];
        [_personImageView.layer setCornerRadius:[CommonFunctions is35InchesScreen]?0:5];
        [_personImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_personImageView setClipsToBounds:YES];
        [self.contentView addSubview:_personImageView];
        
        _personNameLabel = [[UILabel alloc] init];
        [_personNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_personNameLabel setFont:[CommonFunctions normalFont]];
        [_personNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_personNameLabel];
        
        _personUpdatedLabel = [[UILabel alloc] init];
        [_personUpdatedLabel setFont:[CommonFunctions normalFont]];
        [_personUpdatedLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_personUpdatedLabel setBackgroundColor:[UIColor clearColor]];
        //[_personUpdatedLabel setTextAlignment:NSTextAlignmentRight];
        [_personUpdatedLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_personUpdatedLabel];

        _personAgeLabel = [[UILabel alloc] init];
        [_personAgeLabel setFont:[CommonFunctions normalFont]];
        [_personAgeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_personAgeLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_personAgeLabel];
        
        _personGenderLabel = [[UILabel alloc] init];
        [_personGenderLabel setFont:[CommonFunctions normalFont]];
        [_personGenderLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_personGenderLabel setBackgroundColor:[UIColor clearColor]];
        //[_personGenderLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_personGenderLabel];
        
        _personRankLabel = [[UILabel alloc] init];
        [_personRankLabel setFont:[UIFont systemFontOfSize:15]];
        [_personRankLabel setShadowOffset:CGSizeMake(1, 1)];
        [_personRankLabel setShadowColor:[UIColor grayColor]];
        [_personRankLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_personRankLabel setBackgroundColor:[UIColor clearColor]];
        [_personImageView addSubview:_personRankLabel];
        
        _statusColorView = [[UIView alloc] init];
        [_statusColorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:_statusColorView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_personImageView addSubview:_activityIndicatorView];
        
        //contraints
        /*
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(4)-[_personImageView]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personImageView)]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_personImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_personImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(4)-[_personImageView]-(4)-[_personNameLabel]-(>=4)-[_personUpdatedLabel]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personImageView, _personNameLabel, _personUpdatedLabel)]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(4)-[_personNameLabel][_personAgeLabel(==_personNameLabel)]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personNameLabel, _personAgeLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(4)-[_personUpdatedLabel][_personGenderLabel(==_personUpdatedLabel)]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personUpdatedLabel, _personGenderLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(4)-[_personImageView]-(4)-[_personAgeLabel]-(>=4)-[_personGenderLabel]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personImageView, _personAgeLabel, _personGenderLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_statusColorView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_statusColorView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_statusColorView(1)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_statusColorView)]];
        
        [_personImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(2)-[_personRankLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personRankLabel)]];
        [_personImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(2)-[_personRankLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personRankLabel)]];

        [_personImageView addConstraint:[NSLayoutConstraint constraintWithItem:_personImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_activityIndicatorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [_personImageView addConstraint:[NSLayoutConstraint constraintWithItem:_personImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_activityIndicatorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
 */
        
        // constraints for universal
        /*
        UIView *leftBox = [[UIView alloc] init];
        [leftBox setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:leftBox];
        
        UIView *rightBox = [[UIView alloc] init];
        [rightBox setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:rightBox];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(4)-[_personImageView]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personImageView)]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_personImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_personImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(4)-[_personImageView]-(4)-[leftBox]-(>=4)-[rightBox]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personImageView, leftBox, rightBox)]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:leftBox attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rightBox attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];

*/
        
        //contraints
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(4)-[_personImageView]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personImageView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(4)-[_personImageView]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personImageView)]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_personImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_personImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_personUpdatedLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:.95 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_personNameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:.05 constant:72]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_personNameLabel]-(>=4)-[_personUpdatedLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personNameLabel, _personUpdatedLabel)]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_personGenderLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:.95 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_personAgeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:.05 constant:72]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_personAgeLabel]-(>=4)-[_personGenderLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personAgeLabel, _personGenderLabel)]];

        
         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(4)-[_personNameLabel][_personAgeLabel(==_personNameLabel)]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personNameLabel, _personAgeLabel)]];
         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(4)-[_personUpdatedLabel][_personGenderLabel(==_personUpdatedLabel)]-(4)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personUpdatedLabel, _personGenderLabel)]];
         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_statusColorView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_statusColorView)]];
         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_statusColorView(1)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_statusColorView)]];
         
         [_personImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(2)-[_personRankLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personRankLabel)]];
         [_personImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(2)-[_personRankLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_personRankLabel)]];
         
         [_personImageView addConstraint:[NSLayoutConstraint constraintWithItem:_personImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_activityIndicatorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
         [_personImageView addConstraint:[NSLayoutConstraint constraintWithItem:_personImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_activityIndicatorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight ];

   }
    
    return self;
}

- (void)addDummyData
{
    [_personImageView setImage:[UIImage imageNamed:@"testPerson"]];
    [_personNameLabel setText:@"John Smith"];
    [_personUpdatedLabel setText:@"12/12/14"];
    [_personAgeLabel setText:@"Age: 30"];
    [_personGenderLabel setText:@"Gender: M"];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (selected) {
        //[self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:.4]];
        if (IS_TRIAGEPIC) {
            [self setBackgroundColor:[CommonFunctions addLight:.3 ToColor:[PersonObject colorForZone:_personObject.zone]]];
        } else {
            [self setBackgroundColor:[CommonFunctions addLight:.3 ToColor:[PersonObject colorForStatus:_personObject.status]]];
        }
    }else{
        [self setStatusBackgroundColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        if (IS_TRIAGEPIC) {
            [self setBackgroundColor:[CommonFunctions addLight:.3 ToColor:[PersonObject colorForZone:_personObject.zone]]];
        } else {
            [self setBackgroundColor:[CommonFunctions addLight:.3 ToColor:[PersonObject colorForStatus:_personObject.status]]];
        }
//        [self setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:.4]];
    }else if (!self.isSelected) {
        [self setStatusBackgroundColor];
    }
}



- (void)fillWithPersonObject:(PersonObject *)personObject
{
    _personObject = personObject;
 
    //remove what was left from before
    [_activityIndicatorView stopAnimating];
    _personImageView.image = nil;
    
    if (![personObject.type isEqualToString:PERSON_TYPE_FIND]) {
        //for reports that already have the image
        personObject.smallDisplayImage = [ImageObject peopleRecordImageSmallDictFind][[NSString stringWithFormat:@"%i", personObject.personID]];
    }
    ImageObject *firstImageObject;
    
   /* if (firstImageObject.image== nil && firstImageObject.imageURL){
                [_activityIndicatorView startAnimating];
        
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSString *str=firstImageObject.imageURL;
                    UIImage *imageFromURL = [ImageObject getPLImagesFromURLExtension:str];
                    personObject.smallDisplayImage=imageFromURL;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        firstImageObject.image=personObject.smallDisplayImage;
                        //[_activityIndicatorView stopAnimating];
                    });
                });
                firstImageObject.image=personObject.smallDisplayImage;
        
            }
    */
    //image
    if (personObject.smallDisplayImage){
        _personImageView.image = personObject.smallDisplayImage;
    }else{
        if ([personObject.imageObjectArray count]){
            [_activityIndicatorView startAnimating];
            
            // if the images are available in Report, we need to zoom into the face by the following
            if (![personObject.type isEqualToString:PERSON_TYPE_FIND]) {
                //if image already exists, just go ahead and run algorithm on it
                ImageObject *thisImageObject = ((ImageObject *)personObject.imageObjectArray[0]);
                if (thisImageObject.image) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        [personObject createSmallImage];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _personImageView.image = personObject.smallDisplayImage;
                            [_activityIndicatorView stopAnimating];
                        });
                    });
                    _personImageView.image = thisImageObject.image;
                }
                
            }
        }else{ //if there is no image at all, display the generics
            if ([personObject.gender isEqualToString:@"Female"]){
                personObject.smallDisplayImage = [UIImage imageNamed:@"No Image Female"];
            }else{
                personObject.smallDisplayImage = [UIImage imageNamed:@"No Image Male"];
            }
            _personImageView.image = personObject.smallDisplayImage;
        }
    }

    
        _personNameLabel.text = [NSString stringWithFormat:@"%@ %@", personObject.givenName, personObject.familyName];
        _personNameLabel.text = [_personNameLabel.text isEqualToString:@" "]?NSLocalizedString(@"Unknown name", nil):_personNameLabel.text;
    
        //age
    
            if ([[NSString stringWithFormat:@"%@",personObject.ageMin] isEqualToString:@""] || [[NSString stringWithFormat:@"%@",personObject.ageMin] isEqualToString:@"-1"]){
                _personAgeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Age: ?", nil)];
            }else{
                _personAgeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Age: %@", nil),personObject.ageMin];
            }
    
    
    
        //gender
        _personGenderLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Gender: %@", nil), [personObject.gender substringToIndex:1]];
        if ([_personGenderLabel.text isEqualToString:@"Gender: U"]){
            _personGenderLabel.text = NSLocalizedString(@"Gender: ?", nil);
        }
        

    //status
    //[_personStatusView setBackgroundColor:[PersonObject colorForStatus:personObject.status]];
    //[_backView.layer setBorderColor:_personStatusView.backgroundColor.CGColor];
    [self setStatusBackgroundColor];
    
    //timestamp
    _personUpdatedLabel.text = [personObject getLastUpdatedStringLongFormat:NO];
}




- (void)setStatusBackgroundColor
{
    UIColor *statusColor;
    
    if (IS_TRIAGEPIC) {
        statusColor = [PersonObject colorForZone:_personObject.zone];
    } else {
        statusColor = [PersonObject colorForStatus:_personObject.status];
    }
    
    [_statusColorView setBackgroundColor:[CommonFunctions addLight:.6 ToColor:statusColor]];
    [_personImageView.layer setBorderColor:statusColor.CGColor];
    statusColor = [CommonFunctions addLight:.9 ToColor:statusColor];
    [self setBackgroundColor:statusColor];
}


@end
