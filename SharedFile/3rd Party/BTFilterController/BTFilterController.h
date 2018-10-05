//
//  BTFilterController.h
//  BTFilterControllerExample
//

//
#import <UIKit/UIKit.h>
#import "BTFilterCell.h"
#import "BTSubFilterController.h"

#define KEY_1_HEADER @"header"
#define KEY_1_FOOTER @"footer"
#define KEY_1_ROW_ARRAY @"rowArr" // array of key_2 dicts

#define KEY_2_CELL_TYPE @"cellType" // @(BTCellType)
#define KEY_2_LABEL @"label"

//X for optional
#define KEY_2X_ATTRIBUTE_LABEL @"attrLabel" //replaces label with attributed text
#define KEY_2X_DEFAULT @"defaultValue" // can be string or boolean literal
#define KEY_2X_CHOICE_ARRAY @"chioceArr" // array of key_3 dicts
#define KEY_2X_CHOICE_INCLUDES_COLOR_OR_IMAGE @"choiceHasColrOrImg" // to reflect in the row
#define KEY_2X_PLACE_HOLDER @"placeHolder" // for textfield
#define KEY_2X_KEYBOARD_TYPE @"keyboard" // for textfield
#define KEY_2X_SECURE_INPUT @"secure" // for textfield
#define KEY_2X_AUTO_CORRECT @"autoCorrect" // for textfield
#define KEY_2X_MIN @"minVal" // for slider
#define KEY_2X_MAX @"maxVal" // for slider
#define KEY_2X_STEP @"stepVal" // for slider
#define KEY_2X_SLIDER_LOW @"sLow" // for slider
#define KEY_2X_SLIDER_HIGH @"sHigh" // for slider
#define KEY_2X_HEIGHT @"height" // for non traditional cells
#define KEY_2X_IMAGE @"image" // for image
#define KEY_2X_ATTRIBUTE_TEXT @"attrTxt" // for displayText

@protocol BTFilterControllerDelegate;

@interface BTFilterController : UITableViewController <BTFilterCellDelegate, BTSubFilterControllerDelegate>
@property (nonatomic, strong) NSArray *itemArray; // item array -> sections dictionary -> row array -> row dictionary -> choice array
@property (nonatomic, strong) NSMutableArray *selectionArray; // selection array -> section dictionary (key:label, object:string)


@property (nonatomic, weak) id<BTFilterControllerDelegate> delegate;

// selection can be nil, but if it is provided, it must have all the section covered
- (id)initWithStyle:(UITableViewStyle)style itemArray:(NSArray *)itemArray selectionArray:(NSMutableArray *)selectionArray;

// change the value in cells
- (void)setValue:(id)value forIndexPath:(NSIndexPath *)indexPath;

// changes the cells with animation
- (void)alterSection:(int)section withNewSectionDict:(NSDictionary *)sectionDict;
- (void)insertRowDict:(NSDictionary *)rowDictionary inPlace:(int)place inSection:(int)section;
- (void)addRowDict:(NSDictionary *)rowDictionary toSection:(int)section;
- (void)removeRow:(int)row fromSection:(int)section;

// in case of reuse
- (void)setItemArray:(NSArray *)itemArray selectionArray:(NSMutableArray *)selectionArray;
- (void)setItemArray:(NSArray *)itemArray selectionArray:(NSMutableArray *)selectionArray withRowAnimation:(UITableViewRowAnimation)tableViewRowAnimation;
- (void)setSelectionArray:(NSMutableArray *)selectionArray tableViewAnimation:(UITableViewRowAnimation)tableViewAnimation;


// structural way to create items
+ (NSDictionary *)sectionWithRowArray:(NSArray *)rowArray header:(NSString *)header footer:(NSString *)footer;

// generic
+ (NSDictionary *)rowWithLabel:(NSString *)label cellType:(BTCellType)cellType defaultValue:(id)defaultValue;
// specific
+ (NSDictionary *)rowInputChoiceWithLabel:(NSString *)label choiceArray:(NSArray *)choiceArray lastChoice:(NSString *)lastChoice hasColorOrImage:(BOOL)hasColorOrImage;
+ (NSDictionary *)rowInputTextWithLabel:(NSString *)label defaultString:(NSString *)defaultString placeHolder:(NSString *)placeHolder;
+ (NSDictionary *)rowInputTextWithLabel:(NSString *)label defaultString:(NSString *)defaultString placeHolder:(NSString *)placeHolder keyboardType:(UIKeyboardType)keyboardType isSecureInput:(BOOL)isSecureInput shouldAutoCorrect:(BOOL)shouldAutoCorrect;
+ (NSDictionary *)rowInputTextBoxWithLabel:(NSString *)label defaultAttrString:(NSAttributedString *)defaultAttrString height:(CGFloat)height;
+ (NSDictionary *)rowInputBoolWithLabel:(NSString *)label defaultBoolean:(BOOL)defaultBoolean;
+ (NSDictionary *)rowInputSliderWithLabel:(NSString *)label min:(CGFloat)min max:(CGFloat)max step:(CGFloat)step;
+ (NSDictionary *)rowInputSliderRangeWithLabel:(NSString *)label min:(CGFloat)min max:(CGFloat)max step:(CGFloat)step sliderLow:(CGFloat)sliderLow sliderHigh:(CGFloat)sliderHigh;
+ (NSDictionary *)rowActionWithLabel:(NSString *)label defualtValue:(id)defaultValue;
+ (NSDictionary *)rowDeleteActionWithLabel:(NSString *)label defualtValue:(id)defaultValue;
+ (NSDictionary *)rowDisplayImageWithImage:(UIImage *)image height:(CGFloat)height;
+ (NSDictionary *)rowDisplayImageWithImage:(UIImage *)image height:(CGFloat)height defualtValue:(id)defaultValue;
+ (NSDictionary *)rowDisplayTextWithAttributeString:(NSAttributedString *)attrString;
+ (NSDictionary *)rowDisplayKeyValueWithKey:(NSString *)key value:(NSString *)value;
+ (NSDictionary *)rowCustomCellWithHeight:(CGFloat)height label:(NSString *)label;
//+ (NSDictionary *)rowCustomViewWithHeight:(CGFloat)height label:(NSString *)label;

// choices for KEY_3
+ (NSDictionary *)choiceWithString:(NSString *)string;
+ (NSDictionary *)choiceWithString:(NSString *)string textColor:(UIColor *)textColor image:(UIImage *)image;
@end

@protocol BTFilterControllerDelegate <NSObject>
@optional
// called when the view dissappear, to pass on the selection and value
- (void)filterController:(BTFilterController *)filterController didFinishSelectionArray:(NSMutableArray *)selectionArray;
// called only when the filter was changed in some way
- (void)filterController:(BTFilterController *)filterController didFinishSelectionArray:(NSMutableArray *)selectionArray hasChangedSelection:(BOOL)hasChangedSelection;
// call when any row is tapped
- (void)filterController:(BTFilterController *)filterController didSelectAtIndexPath:(NSIndexPath *)indexPath rowDict:(NSDictionary *)rowDict;
// call when cell of type BTCellTypeController is tapped, expect a sort of ViewController as a return
- (id)filterController:(BTFilterController *)filterController controllerForDefaultValue:(NSString *)defaultValue;
// call when customview needs its view setup
- (UITableViewCell *)filterController:(BTFilterController *)filterController cellForIndexPath:(NSIndexPath *)indexPath label:(NSString *)label height:(CGFloat)height;
// Set Delegate if for some reason the usual one does not do what you need (ie placeholder in textView)
- (void)filterController:(BTFilterController *)filterController setDelegateForIndexPath:(NSIndexPath *)indexPath cell:(BTFilterCell *)cell label:(NSString *)label;
// Call when a switch is switched!
- (void)filterController:(BTFilterController *)filterController switchChangedAtIndexPath:(NSIndexPath *)indexPath rowDict:(NSDictionary *)rowDict isOn:(bool)isOn;
// Called when things changes its value
- (void)filterController:(BTFilterController *)filterController valueForIndexPath:(NSIndexPath *)indexPath rowDict:(NSDictionary *)rowDict changedTo:(id)value;

@end
