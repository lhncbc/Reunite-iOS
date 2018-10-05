//
//  BTFilterCell.m
//  BTFilterControllerExample
//

//

#import "BTFilterCell.h"
@implementation BTFilterCell
- (void)setupWithInputType:(BTCellType)cellType delegate:(id)delegate
{
    //[self setBackgroundColor:[UIColor clearColor]];
    _cellType = cellType;
    
    if (cellType != BTCellTypeDisplayImage &&
        cellType != BTCellTypeDisplayText &&
        cellType != BTCellTypeCustomCell &&
        cellType != BTCellTypeInputTextBox &&
        cellType != BTCellTypeAction &&
        cellType != BTCellTypeDeleteAction
        ) {
        _cellLabel = [[UILabel alloc] init];
        [_cellLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_cellLabel setContentMode:UIViewContentModeCenter];
        [_cellLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self addSubview:_cellLabel];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cellLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_cellLabel)]];
    }

    switch (cellType) {
        case BTCellTypeAction:
            _cellButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [_cellButton setUserInteractionEnabled:NO];
            [_cellButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
            [_cellButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:_cellButton];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cellButton]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_cellButton)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-20]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            break;
        case BTCellTypeDeleteAction:
            _cellButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [_cellButton setUserInteractionEnabled:NO];
            [_cellButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
            [_cellButton setTintColor:[UIColor redColor]];
            [_cellButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:_cellButton];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cellButton]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_cellButton)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-20]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            break;
        case BTCellTypeInputBool:
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];

            _cellSwitch = [[UISwitch alloc] init];
            [_cellSwitch addTarget:self action:@selector(switchDidChange:) forControlEvents:UIControlEventValueChanged];
            [self setAccessoryView:_cellSwitch];
            
            _delegate = delegate;
            
            break;
        case BTCellTypeInputChoice:
            [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
            _choiceImageView = [[UIImageView alloc] init];
            [_choiceImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:_choiceImageView];
            
            _cellChoice = [[UILabel alloc] init];
            [_cellChoice setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:_cellChoice];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellLabel]-(>=5)-[_choiceImageView]-(5)-[_cellChoice]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_cellLabel, _choiceImageView, _cellChoice)]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(2)-[_choiceImageView]-(2)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_choiceImageView)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_choiceImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
           [self addConstraint:[NSLayoutConstraint constraintWithItem:_choiceImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_choiceImageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellChoice attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellChoice attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-30]];
            
            break;
        case BTCellTypeInputText:
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];

            _cellTextFeild = [[UITextField alloc] init];
            [_cellTextFeild setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_cellTextFeild setDelegate:self];
            _cellTextFeild.autocapitalizationType=UITextAutocapitalizationTypeNone;
            [_cellTextFeild setTextAlignment:NSTextAlignmentRight];
            [_cellTextFeild setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self addSubview:_cellTextFeild];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellLabel]-(>=10)-[_cellTextFeild(>=100)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_cellLabel, _cellTextFeild)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextFeild attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-15]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextFeild attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
           [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextFeild attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_cellLabel attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
            
            _delegate = delegate;
            break;
        case BTCellTypeInputTextBox:
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            _cellTextView = [[UITextView alloc] init];
            [_cellTextView setScrollsToTop:NO];
            [_cellTextView setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            [_cellTextView setBackgroundColor:[UIColor clearColor]];
            [_cellTextView setDelegate:self];
            [_cellTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:_cellTextView];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:15]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-15]];
           [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:15]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-15]];
            break;
        case BTCellTypeInputSlider:
        case BTCellTypeInputSliderRange:            
            _cellSlider = [[UISlider alloc] init];
            [_cellSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_cellSlider addTarget:self action:@selector(sliderDidChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:_cellSlider];
            
            _sliderLabel = [[UILabel alloc] init];
            [_sliderLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:_sliderLabel];
            
            _sliderStatus = [[UILabel alloc] init];
            [_sliderStatus setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_sliderStatus setText:@"Tap to Enable"];
            [_sliderStatus setAlpha:0];
            [_sliderStatus setTextColor:[UIColor grayColor]];
            [self addSubview:_sliderStatus];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellSlider]-(5)-[_sliderLabel]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_cellSlider, _sliderLabel)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellSlider attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:.9 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_sliderLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-15]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_sliderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_sliderStatus attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_sliderStatus attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-30]];

            _delegate = delegate;
            break;
        case BTCellTypeController:
            [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case BTCellTypeDisplayImage:
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            _cellImage = [[UIImageView alloc] init];
            [_cellImage setContentMode:UIViewContentModeScaleAspectFit];
            [_cellImage setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:_cellImage];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellImage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellImage attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
            break;
        case BTCellTypeDisplayText:
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];

            _cellTextView = [[UITextView alloc] init];
            [_cellTextView setEditable:NO];
            [_cellTextView setScrollsToTop:NO];
            [_cellTextView setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            [_cellTextView setUserInteractionEnabled:NO];
            [_cellTextView setBackgroundColor:[UIColor clearColor]];
            [_cellTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:_cellTextView];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:15]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-15]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:15]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellTextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-15]];
            break;
        case BTCellTypeDisplayKeyValue:
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            _cellValueLabel = [[UILabel alloc] init];
            [_cellValueLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:_cellValueLabel];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cellLabel]-(>=10)-[_cellValueLabel(>=10)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_cellLabel, _cellValueLabel)]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellValueLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-15]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellValueLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_cellValueLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_cellLabel attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
            
            _delegate = delegate;
            break;/*
        case BTCellTypeCustomView:
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            _cellView = [[UILabel alloc] initWithFrame:self.frame];
            [_cellView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [self addSubview:_cellView];
            break;*/
        default:
            break;
    }
    _isSetup = YES;
}


- (BOOL)sliderToggle:(BOOL)currentStatus
{
    [UIView animateWithDuration:.1 animations:^{
        [_cellSlider setAlpha:currentStatus?0:1];
        [_sliderLabel setAlpha:currentStatus?0:1];
        [_sliderStatus setAlpha:currentStatus?1:0];
        
        //iPad doesnt work with animation, no idea why
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self setSelected:NO animated:NO];
        } else {
            [self setSelected:NO animated:YES];
        }
    }];
    return !currentStatus;
}


- (void)switchDidChange:(UISwitch *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(filterCell:switchChangedTo:)]) {
        [_delegate filterCell:self switchChangedTo:sender.isOn];
    }
}

- (void)sliderDidChanged:(UISlider *)sender
{
    float newStep = roundf((sender.value) / _sliderStep);
    sender.value = newStep * _sliderStep;
    if (_delegate && [_delegate respondsToSelector:@selector(filterCell:sliderValueChangedTo:)]) {
        [_delegate filterCell:self sliderValueChangedTo:sender.value];
    }
    
    //set the show number
    CGFloat value = sender.value;
    if (_sliderLow < 0|| _sliderHigh > 0) {
        [_sliderLabel setText:[NSString stringWithFormat:@"%.0f~%.0f", value+_sliderLow>0?value+_sliderLow:0, value+_sliderHigh]];
    } else {
        [_sliderLabel setText:[NSString stringWithFormat:@"%.0f", value]];
    }
}

#pragma mark - Delegate
#pragma mark UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(filterCell:textChangedTo:)]) {
        [_delegate filterCell:self textChangedTo:textField.text];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField invalidateIntrinsicContentSize];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    double delayInSeconds = .01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [textField invalidateIntrinsicContentSize];
    });
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (_delegate && [_delegate respondsToSelector:@selector(filterCell:textChangedTo:)]) {
        [_delegate filterCell:self textChangedTo:newString];
    }
    
    return YES;
}

#pragma mark UITextView
- (void)textViewDidChange:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(filterCell:attTextChangedTo:)]) {
        [_delegate filterCell:self attTextChangedTo:textView.attributedText];
    }
}

@end
