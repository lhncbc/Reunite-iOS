//
//  BTFilterCell.h
//  BTFilterControllerExample
//
//  Created by Krittach on 12/3/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    //input cell
    BTCellTypeInputChoice, // the cell will lead to an array of option
    BTCellTypeInputText, // the cell will allow user to enter text
    BTCellTypeInputTextBox, // the cell will be an empty text box
    BTCellTypeInputBool, // the cell will contain a switch
    BTCellTypeInputSlider, // the cell will contain a slider
    BTCellTypeInputSliderRange, //the cell will contain a slider which shows a range instead of a single number
    
    //action cell
    BTCellTypeController, // the cell will push a controller over the navigation stack
    BTCellTypeAction, // the cell will allow any action to be taken via delegate
    BTCellTypeDeleteAction, // like above but RED

    //display cell
    BTCellTypeDisplayImage, // this will only display image
    BTCellTypeDisplayText, // this will desplay text
    BTCellTypeDisplayKeyValue, // this will key and value
    
    //totally customized
    BTCellTypeCustomCell, // it will call delegate to grab a cell
    //BTCellTypeCustomView, // it will call delegate to set up the view
    
    BTCellTypeCount // keep track
}BTCellType;


@protocol BTFilterCellDelegate;

@interface BTFilterCell : UITableViewCell <UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, readonly, assign) BTCellType cellType;

@property (nonatomic, strong) UILabel *cellLabel;
@property (nonatomic, assign) BOOL isSetup;
@property (nonatomic, strong) NSIndexPath *indexPath;

//choice specific
@property (nonatomic, strong) UILabel *cellChoice;
@property (nonatomic, strong) UIImageView *choiceImageView;

//textfield specific
@property (nonatomic, strong) UITextField *cellTextFeild;

//boolean specific
@property (nonatomic, strong) UISwitch *cellSwitch;

//slider specific
@property (nonatomic, strong) UISlider *cellSlider;
@property (nonatomic, assign) CGFloat sliderStep;
@property (nonatomic, strong) UILabel *sliderLabel;
@property (nonatomic, strong) UILabel *sliderStatus;
@property (nonatomic, assign) CGFloat sliderLow;
@property (nonatomic, assign) CGFloat sliderHigh;

//image specific
@property (nonatomic, strong) UIImageView *cellImage;

//text specific
@property (nonatomic, strong) UITextView *cellTextView;

//customView specific
@property (nonatomic, strong) UIView *cellView;

//key-value specific
@property (nonatomic, strong) UILabel *cellValueLabel;

@property (nonatomic, weak) id<BTFilterCellDelegate> delegate;

- (void)setupWithInputType:(BTCellType)cellType backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor delegate:(id)delegate;

//either enable or disable the slider -> return value is the final state
- (BOOL)sliderToggle:(BOOL)currentStatus;
@end

@protocol BTFilterCellDelegate <NSObject>
@required
- (void)filterCell:(BTFilterCell *)filterCell switchChangedTo:(BOOL)boolValue;
- (void)filterCell:(BTFilterCell *)filterCell textChangedTo:(NSString *)textValue;
- (void)filterCell:(BTFilterCell *)filterCell attTextChangedTo:(NSAttributedString *)attTextValue;
- (void)filterCell:(BTFilterCell *)filterCell sliderValueChangedTo:(CGFloat)floatValue;
@end
