//
//  BTFilterController.m
//  BTFilterControllerExample
//
//  Created by Krittach on 12/3/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import "BTFilterController.h"
@interface BTFilterController ()

@end

@implementation BTFilterController{
    BTSubFilterController *_subFilterController;
    BOOL _dataNeedsReloaded; //if the filter is reused with new item array this will trigger reload when comes to view
    NSArray *_oldSelectionArray;
}

- (id)initWithStyle:(UITableViewStyle)style itemArray:(NSArray *)itemArray selectionArray:(NSMutableArray *)selectionArray
{
    self = [super initWithStyle:style];
    if (self) {
        _itemArray = itemArray;
        _selectionArray = [self verifySelectionArray:selectionArray];
        _cellBackgroundColor = [UIColor whiteColor];
        _cellTextColor = [UIColor blackColor];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style itemArray:(NSArray *)itemArray selectionArray:(NSMutableArray *)selectionArray cellBackgroundColor:(UIColor *)cellBackgroundColor cellTextColor:(UIColor *)cellTextColor;
{
    self = [super initWithStyle:style];
    if (self) {
        _itemArray = itemArray;
        _selectionArray = [self verifySelectionArray:selectionArray];
        _cellBackgroundColor = cellBackgroundColor;
        _cellTextColor = cellTextColor;
    }
    return self;

}


- (void)viewDidLoad
{
    [super viewDidLoad];

    //they have the same base class
    //but set up differently, thus reusability is conditional base on the input type
    for (int i = 0; i < BTCellTypeCount; i++) {
        [self.tableView registerClass:[BTFilterCell class] forCellReuseIdentifier:@(i).stringValue];
    }
    
    //making the cell ends
    self.tableView.tableFooterView = [[UIView alloc] init];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"   " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
    
    if (_dataNeedsReloaded) {
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Best I got for endEditing, cant do it else where for unknown reason.
    [self.tableView endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //only activates when popped, andthing pushed on top, will not trigger
    
    if (!self.parentViewController && _delegate && [_delegate respondsToSelector:@selector(filterController:didFinishSelectionArray:)]) {
        [_delegate filterController:self didFinishSelectionArray:_selectionArray];
    }
    
    if (!self.parentViewController && _delegate && [_delegate respondsToSelector:@selector(filterController:didFinishSelectionArray:hasChangedSelection:)]) {
        [_delegate filterController:self didFinishSelectionArray:_selectionArray hasChangedSelection:![self filterHasChanged]];
    }
}


#pragma mark - Bug catcher
- (NSMutableArray *)verifySelectionArray:(NSMutableArray *)selectionArray
{
    if (!selectionArray) {
        selectionArray = [NSMutableArray array];
        for (NSDictionary *sectionDict in _itemArray) {
            NSMutableDictionary *selectionSectionDict = [NSMutableDictionary dictionary];
            NSArray *sectionArray = sectionDict[KEY_1_ROW_ARRAY];
            for (NSDictionary *rowDict in sectionArray) {
                if (rowDict[KEY_2X_DEFAULT] && rowDict[KEY_2_LABEL]) {
                    selectionSectionDict[rowDict[KEY_2_LABEL]] = rowDict[KEY_2X_DEFAULT];
                }
            }
            [selectionArray addObject:selectionSectionDict];
        }
    }
    _oldSelectionArray = [[NSMutableArray alloc] initWithArray:selectionArray copyItems:YES];

    return selectionArray;
}

- (BOOL)filterHasChanged
{
    if ([_oldSelectionArray isEqual:_selectionArray]) {
        return YES;
    } else {
        _oldSelectionArray = [[NSMutableArray alloc] initWithArray:_selectionArray copyItems:YES];
        return NO;
    }
}

#pragma mark - Alteration
- (void)setValue:(id)value forIndexPath:(NSIndexPath *)indexPath
{
    NSString *label = _itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row][KEY_2_LABEL];
    
    BTFilterCell *cell = (BTFilterCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        switch (cell.cellType) {
            case BTCellTypeInputText:
                [cell.cellTextFeild setText:value];
                break;
            case BTCellTypeDisplayImage:
                [cell.cellImage setImage:value];
                break;
            case BTCellTypeInputBool:
                [cell.cellSwitch setOn:[value boolValue]];
                break;
            case BTCellTypeInputTextBox:
                [cell.cellTextView setAttributedText:value];
                break;
            default:
                break;
        }
        self.selectionArray[indexPath.section][label] = value;
    }
}

- (void)alterSection:(int)section withNewSectionDict:(NSDictionary *)sectionDict
{
    NSMutableArray *mutableItemArray = [_itemArray mutableCopy];
    mutableItemArray[section] = sectionDict;
    _itemArray = mutableItemArray;

    //rework selection array
    NSMutableDictionary *selectionSectionDict = [NSMutableDictionary dictionary];
    for (NSDictionary *rowDict in sectionDict[KEY_1_ROW_ARRAY]) {
        if (rowDict[KEY_2X_DEFAULT] && rowDict[KEY_2_LABEL]) {
            selectionSectionDict[rowDict[KEY_2_LABEL]] = rowDict[KEY_2X_DEFAULT];
        }
    }
    _selectionArray[section] = selectionSectionDict;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)insertRowDict:(NSDictionary *)rowDictionary inPlace:(int)place inSection:(int)section
{
    NSMutableArray *rowDictArray = [_itemArray[section][KEY_1_ROW_ARRAY] mutableCopy];
    [rowDictArray insertObject:rowDictionary atIndex:place];
    _itemArray[section][KEY_1_ROW_ARRAY] = rowDictArray;
    
    if (!_selectionArray[section][rowDictionary[KEY_2_LABEL]] && rowDictionary[KEY_2X_DEFAULT] && rowDictionary[KEY_2_LABEL]) {
        _selectionArray[section][rowDictionary[KEY_2_LABEL]] = rowDictionary[KEY_2X_DEFAULT];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addRowDict:(NSDictionary *)rowDictionary toSection:(int)section
{
    [self insertRowDict:rowDictionary inPlace:(int)[_itemArray[section][KEY_1_ROW_ARRAY] count] inSection:section];
}

- (void)removeRow:(int)row fromSection:(int)section
{
    NSMutableArray *rowDictArray = [_itemArray[section][KEY_1_ROW_ARRAY] mutableCopy];
    [rowDictArray removeObjectAtIndex:row];
    _itemArray[section][KEY_1_ROW_ARRAY] = rowDictArray;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setItemArray:(NSArray *)itemArray selectionArray:(NSMutableArray *)selectionArray
{
    [self setItemArray:itemArray selectionArray:selectionArray withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setItemArray:(NSArray *)itemArray selectionArray:(NSMutableArray *)selectionArray withRowAnimation:(UITableViewRowAnimation)tableViewRowAnimation
{
    _itemArray = itemArray;
    _selectionArray = [self verifySelectionArray:selectionArray];
    if (self.isViewLoaded && self.view.window) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, itemArray.count)] withRowAnimation:tableViewRowAnimation];
    }else{
        _dataNeedsReloaded = YES;
    }
}


#pragma mark - Datasource
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _dataNeedsReloaded = NO; // once table has been reloaded, set to no
    return [_itemArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray[section][KEY_1_ROW_ARRAY] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowDict = _itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row];
    BTCellType cellType = [rowDict[KEY_2_INPUT_TYPE] intValue];

    // This is a little hack for a customCell because for some reason the custom cell do not play well with scrollView
    if (cellType == BTCellTypeCustomCell) {
        /*
        NSString *cellIdentifier = [NSString stringWithFormat:@"customViewCell %@ %i", rowDict[KEY_2_LABEL], (int)indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(filterController:customView:forIndexPath:label:height:)]) {
            [_delegate filterController:self customView:cell.contentView forIndexPath:indexPath label:rowDict[KEY_2_LABEL] height:[rowDict[KEY_2X_HEIGHT] floatValue]];
        }*/
        UITableViewCell *cell;
        if (_delegate && [_delegate respondsToSelector:@selector(filterController:cellForIndexPath:label:height:)]) {
            cell = [_delegate filterController:self cellForIndexPath:indexPath label:rowDict[KEY_2_LABEL] height:[rowDict[KEY_2X_HEIGHT] floatValue]];
        }
        
        if (!cell) {
            // to prevent crash but there is definitely a problem if it comes here
            cell = [[UITableViewCell alloc] init];
            NSLog(@"CHECK delegate for BTFilterViewController or filterController:cellForIndexPath:label:height:");
        }
        return cell;
    }
    
    BTFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@(cellType).stringValue forIndexPath:indexPath];
    
    if (!cell.isSetup) {
        [cell setupWithInputType:cellType backgroundColor:_cellBackgroundColor textColor:_cellTextColor delegate:self];
        if (_delegate && [_delegate respondsToSelector:@selector(filterController:setDelegateForIndexPath:cell:label:)]) {
            [_delegate filterController:self setDelegateForIndexPath:indexPath cell:cell label:rowDict[KEY_2_LABEL]];
        }
    }
    //indexpath
    [cell setIndexPath:indexPath];
    
    //label
    [cell.cellLabel setText:rowDict[KEY_2_LABEL]];
    if (rowDict[KEY_2X_ATTRIBUTE_LABEL]) {
        [cell.cellLabel setAttributedText:rowDict[KEY_2X_ATTRIBUTE_LABEL]];
    }
    id selectValue = _selectionArray[indexPath.section][rowDict[KEY_2_LABEL]];
   
    switch (cellType) {
        case BTCellTypeInputBool:
            [cell.cellSwitch setOn:[selectValue boolValue]];
            break;
        case BTCellTypeInputChoice:
            [cell.cellChoice setText:selectValue];
            if ([rowDict[KEY_2X_CHOICE_INCLUDES_COLOR_OR_IMAGE] boolValue]) {
                BOOL found = NO;
                for (NSDictionary *choiceDict in rowDict[KEY_2X_CHOICE_ARRAY]) {
                    if ([choiceDict[KEY_3_CHOICE] isEqualToString:selectValue]) {
                        [cell.cellChoice setTextColor:choiceDict[KEY_3_TEXT_COLOR]];
                        [cell.choiceImageView setImage:choiceDict[KEY_3_IMAGE]];
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    [cell.cellChoice setTextColor:nil];
                    [cell.choiceImageView setImage:nil];
                }
            }else{
                [cell.cellChoice setTextColor:nil];
                [cell.choiceImageView setImage:nil];
            }
            break;
        case BTCellTypeInputText:
            [cell.cellTextFeild setText:selectValue];
            [cell.cellTextFeild setPlaceholder:rowDict[KEY_2X_PLACE_HOLDER]];
            [cell.cellTextFeild setKeyboardType:[rowDict[KEY_2X_KEYBOARD_TYPE] intValue]];
            [cell.cellTextFeild setSecureTextEntry:[rowDict[KEY_2X_SECURE_INPUT] boolValue]];
            [cell.cellTextFeild setAutocorrectionType:[rowDict[KEY_2X_AUTO_CORRECT] boolValue]?UITextAutocorrectionTypeDefault:UITextAutocorrectionTypeNo];
            break;
        case BTCellTypeInputTextBox:
            [cell.cellTextView setAttributedText:selectValue];
            break;
        case BTCellTypeInputSliderRange:
            cell.sliderLow = [rowDict[KEY_2X_SLIDER_LOW] floatValue];
            cell.sliderHigh = [rowDict[KEY_2X_SLIDER_HIGH] floatValue];
        case BTCellTypeInputSlider:
            [cell.cellSlider setMinimumValue:[rowDict[KEY_2X_MIN] floatValue]];
            [cell.cellSlider setMaximumValue:[rowDict[KEY_2X_MAX] floatValue]];
            [cell setSliderStep:[rowDict[KEY_2X_STEP] floatValue]];
            [cell sliderToggle:!selectValue];
            [cell.cellSlider setValue:[selectValue floatValue]];
            if (cell.sliderLow < 0|| cell.sliderHigh > 0) {
                [cell.sliderLabel setText:[NSString stringWithFormat:@"%.0f~%.0f", cell.cellSlider.value+cell.sliderLow>0?cell.cellSlider.value+cell.sliderLow:0, cell.cellSlider.value+cell.sliderHigh]];
            } else {
                [cell.sliderLabel setText:[NSString stringWithFormat:@"%.0f", cell.cellSlider.value]];
            }
            break;
        case BTCellTypeDisplayImage:
            [cell.cellImage setImage:rowDict[KEY_2X_IMAGE]];
            break;
        case BTCellTypeDisplayText:
            [cell.cellTextView setAttributedText:rowDict[KEY_2X_ATTRIBUTE_TEXT]];
            break;
        case BTCellTypeDisplayKeyValue:
            [cell.cellValueLabel setText:rowDict[KEY_2X_DEFAULT]];
            break;/*
        case BTCellTypeCustomView:
            if (_delegate && [_delegate respondsToSelector:@selector(filterController:customView:forIndexPath:label:)]) {
                [_delegate filterController:self customView:cell.cellView forIndexPath:indexPath label:rowDict[KEY_2_LABEL]];
            }
            break;*/
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _itemArray[section][KEY_1_HEADER];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return _itemArray[section][KEY_1_FOOTER];
}

#pragma mark - Delegate
#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView endEditing:YES];
    switch ([_itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row][KEY_2_INPUT_TYPE] intValue]) {
        case BTCellTypeInputBool:
            //do nothing
            break;
        case BTCellTypeInputChoice:{
            NSDictionary *rowDict = _itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row];
            
            //push another controller
            if (!_subFilterController) {
                _subFilterController = [[BTSubFilterController alloc] initWithStyle:UITableViewStylePlain];
                [_subFilterController setDelegate:self];
            }
            NSMutableArray *choiceArray = [rowDict[KEY_2X_CHOICE_ARRAY] mutableCopy];
            if (rowDict[KEY_2X_DEFAULT]) {
                //check that defualt is not already one of the choice
                BOOL choiceAlreadyExists = NO;
                for (NSDictionary *dict in choiceArray) {
                    if ([dict[KEY_3_CHOICE] isEqualToString:rowDict[KEY_2X_DEFAULT]]) {
                        choiceAlreadyExists = YES;
                        break;
                    }
                }
                
                if (!choiceAlreadyExists) {
                    [choiceArray addObject:@{KEY_3_CHOICE: rowDict[KEY_2X_DEFAULT]}];
                }
            }
            
            [_subFilterController setTitle:_itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row][KEY_2_LABEL]];
            [_subFilterController setChoiceArray:choiceArray];
            
            [_subFilterController setIndexPath:indexPath];
            int currentSelect = 0;
            for (NSDictionary *choiceDict in choiceArray) {
                if ([choiceDict[KEY_3_CHOICE] isEqualToString:_selectionArray[indexPath.section][_subFilterController.title]]) {
                    break;
                }
                currentSelect++;
            }
            [_subFilterController setCurrentSelect:currentSelect];
            
            [_subFilterController.tableView reloadData];
            [self.navigationController pushViewController:_subFilterController animated:YES];
            break;
        }
        case BTCellTypeInputText:{
            //make text become first responder
            BTFilterCell *cell = (BTFilterCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.cellTextFeild becomeFirstResponder];
            break;
        }
        case BTCellTypeController:
            if (_delegate && [_delegate respondsToSelector:@selector(filterController:controllerForDefaultValue:)]) {
                NSString *defaultValue = _itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row][KEY_2X_DEFAULT];
                id controller = [_delegate filterController:self controllerForDefaultValue:defaultValue];
                if (controller) {
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }
            break;
        case BTCellTypeInputSliderRange:
        case BTCellTypeInputSlider:{
            BTFilterCell *cell = (BTFilterCell *)[tableView cellForRowAtIndexPath:indexPath];
            if ([cell sliderToggle:cell.cellSlider.alpha]) {
                _selectionArray[indexPath.section][cell.cellLabel.text] = @(cell.cellSlider.value);
                if (cell.sliderLow < 0|| cell.sliderHigh > 0) {
                    [cell.sliderLabel setText:[NSString stringWithFormat:@"%.0f~%.0f", cell.cellSlider.value+cell.sliderLow>0?cell.cellSlider.value+cell.sliderLow:0, cell.cellSlider.value+cell.sliderHigh]];
                } else {
                    [cell.sliderLabel setText:[NSString stringWithFormat:@"%.0f", cell.cellSlider.value]];
                }
            }else{
                [_selectionArray[indexPath.section] removeObjectForKey:cell.cellLabel.text];
            }
        }
        case BTCellTypeAction:
        case BTCellTypeDeleteAction:
            // clear selection
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        default:
            break;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(filterController:didSelectAtIndexPath:rowDict:)]) {
        NSDictionary *rowDict = _itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row];
        [_delegate filterController:self didSelectAtIndexPath:indexPath rowDict:rowDict];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowDict = _itemArray[indexPath.section][KEY_1_ROW_ARRAY][indexPath.row];
    
    if (rowDict[KEY_2X_HEIGHT]) {
        return [rowDict[KEY_2X_HEIGHT] floatValue];
    } else if ([rowDict[KEY_2_INPUT_TYPE] intValue] == BTCellTypeDisplayText) {
        NSAttributedString *attrString = rowDict[KEY_2X_ATTRIBUTE_TEXT];
        CGRect bounding = [attrString boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 30, MAXFLOAT)
                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                    context:nil];
        return bounding.size.height + 30;
    } else {
        return 44;
    }
}

#pragma mark BTFilterCell

- (void)filterCell:(BTFilterCell *)filterCell switchChangedTo:(BOOL)boolValue
{
    _selectionArray[filterCell.indexPath.section][filterCell.cellLabel.text] = @(boolValue);
    if (_delegate && [_delegate respondsToSelector:@selector(filterController:switchChangedAtIndexPath:rowDict:isOn:)])
    {
        [_delegate filterController:self switchChangedAtIndexPath:filterCell.indexPath rowDict:_itemArray[filterCell.indexPath.section][KEY_1_ROW_ARRAY][filterCell.indexPath.row] isOn:boolValue];
    }
}

- (void)filterCell:(BTFilterCell *)filterCell textChangedTo:(NSString *)textValue
{
    _selectionArray[filterCell.indexPath.section][filterCell.cellLabel.text] = textValue;
}

- (void)filterCell:(BTFilterCell *)filterCell attTextChangedTo:(NSAttributedString *)attTextValue
{
    _selectionArray[filterCell.indexPath.section][filterCell.cellLabel.text] = attTextValue;
}

- (void)filterCell:(BTFilterCell *)filterCell sliderValueChangedTo:(CGFloat)floatValue
{
    _selectionArray[filterCell.indexPath.section][filterCell.cellLabel.text] = @(floatValue);
}

#pragma mark BTSubFilterController

- (void)subFilterController:(BTSubFilterController *)subFilterController didChooseDict:(NSDictionary *)itemDict
{
    _selectionArray[subFilterController.indexPath.section][subFilterController.title] = itemDict[KEY_3_CHOICE];
    
    double delayInSeconds = .01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView reloadRowsAtIndexPaths:@[subFilterController.indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - Global
#pragma section creator
+ (NSDictionary *)sectionWithRowArray:(NSArray *)rowArray header:(NSString *)header footer:(NSString *)footer
{
    NSMutableDictionary *dict = [@{KEY_1_ROW_ARRAY: rowArray} mutableCopy];
    
    if (header) {
        dict[KEY_1_HEADER] = header;
    }
    
    if (footer) {
        dict[KEY_1_FOOTER] = footer;
    }
    
    return dict;
}

#pragma mark row creator
+ (NSDictionary *)rowWithLabel:(NSString *)label cellType:(BTCellType)cellType defaultValue:(id)defaultValue
{
    NSMutableDictionary *dict = [@{KEY_2_LABEL: label, KEY_2_INPUT_TYPE: @(cellType)} mutableCopy];
    if (defaultValue) {
        dict[KEY_2X_DEFAULT] = defaultValue;
    }
    return dict;
}

+ (NSDictionary *)rowInputChoiceWithLabel:(NSString *)label choiceArray:(NSArray *)choiceArray lastChoice:(NSString *)lastChoice hasColorOrImage:(BOOL)hasColorOrImage
{
    NSMutableDictionary *dict = [@{KEY_2_LABEL: label, KEY_2_INPUT_TYPE: @(BTCellTypeInputChoice), KEY_2X_CHOICE_ARRAY:choiceArray} mutableCopy];
    if (lastChoice) {
        dict[KEY_2X_DEFAULT] = lastChoice;
    }
    
    if (hasColorOrImage) {
        dict[KEY_2X_CHOICE_INCLUDES_COLOR_OR_IMAGE] = @YES;
    }
    
    return dict;
}

+ (NSDictionary *)rowInputTextWithLabel:(NSString *)label defaultString:(NSString *)defaultString placeHolder:(NSString *)placeHolder
{
    NSMutableDictionary *dict = [@{KEY_2_LABEL: label, KEY_2_INPUT_TYPE: @(BTCellTypeInputText), KEY_2X_AUTO_CORRECT: @YES} mutableCopy];
    if (defaultString) {
        dict[KEY_2X_DEFAULT] = defaultString;
    }
    if (placeHolder) {
        dict[KEY_2X_PLACE_HOLDER] = placeHolder;
    }
    return dict;
}

+ (NSDictionary *)rowInputTextWithLabel:(NSString *)label defaultString:(NSString *)defaultString placeHolder:(NSString *)placeHolder keyboardType:(UIKeyboardType)keyboardType isSecureInput:(BOOL)isSecureInput shouldAutoCorrect:(BOOL)shouldAutoCorrect
{
    NSMutableDictionary *dict = [@{KEY_2_LABEL: label, KEY_2_INPUT_TYPE: @(BTCellTypeInputText)} mutableCopy];
    if (defaultString) {
        dict[KEY_2X_DEFAULT] = defaultString;
    }
    if (placeHolder) {
        dict[KEY_2X_PLACE_HOLDER] = placeHolder;
    }
    
    if (keyboardType != UIKeyboardTypeDefault) {
        dict[KEY_2X_KEYBOARD_TYPE] = @(keyboardType);
    }
    
    if (isSecureInput) {
        dict[KEY_2X_SECURE_INPUT] = @YES;
    }
    
    if (shouldAutoCorrect) {
        dict[KEY_2X_AUTO_CORRECT] = @YES;
    }
    
    return dict;
}

+ (NSDictionary *)rowInputTextBoxWithLabel:(NSString *)label defaultAttrString:(NSAttributedString *)defaultAttrString height:(CGFloat)height;
{
    NSMutableDictionary *dict = [@{KEY_2_LABEL: label, KEY_2_INPUT_TYPE: @(BTCellTypeInputTextBox), KEY_2X_HEIGHT:@(height)} mutableCopy];
    if (defaultAttrString) {
        dict[KEY_2X_DEFAULT] = defaultAttrString;
    }
    return dict;
}

+ (NSDictionary *)rowInputBoolWithLabel:(NSString *)label defaultBoolean:(BOOL)defaultBoolean
{
    return  @{KEY_2_LABEL: label,
              KEY_2_INPUT_TYPE: @(BTCellTypeInputBool),
              KEY_2X_DEFAULT: defaultBoolean?@YES:@NO};
}

+ (NSDictionary *)rowInputSliderWithLabel:(NSString *)label min:(CGFloat)min max:(CGFloat)max step:(CGFloat)step
{
    return  @{KEY_2_LABEL: label,
              KEY_2_INPUT_TYPE: @(BTCellTypeInputSlider),
              KEY_2X_MIN:@(min),
              KEY_2X_MAX:@(max),
              KEY_2X_STEP:@(step)};
}

+ (NSDictionary *)rowInputSliderRangeWithLabel:(NSString *)label min:(CGFloat)min max:(CGFloat)max step:(CGFloat)step sliderLow:(CGFloat)sliderLow sliderHigh:(CGFloat)sliderHigh
{
    return  @{KEY_2_LABEL: label,
              KEY_2_INPUT_TYPE: @(BTCellTypeInputSliderRange),
              KEY_2X_MIN:@(min),
              KEY_2X_MAX:@(max),
              KEY_2X_STEP:@(step),
              KEY_2X_SLIDER_LOW:@(sliderLow),
              KEY_2X_SLIDER_HIGH:@(sliderHigh)};
}

+ (NSDictionary *)rowActionWithLabel:(NSString *)label defualtValue:(id)defaultValue
{
    NSMutableDictionary *dict = [@{KEY_2_LABEL: label, KEY_2_INPUT_TYPE: @(BTCellTypeAction)} mutableCopy];
    if (defaultValue) {
        dict[KEY_2X_DEFAULT] = defaultValue;
    }
    return dict;
}

+ (NSDictionary *)rowDeleteActionWithLabel:(NSString *)label defualtValue:(id)defaultValue
{
    NSMutableDictionary *dict = [@{KEY_2_LABEL: label, KEY_2_INPUT_TYPE: @(BTCellTypeDeleteAction)} mutableCopy];
    if (defaultValue) {
        dict[KEY_2X_DEFAULT] = defaultValue;
    }
    return dict;
}

+ (NSDictionary *)rowDisplayImageWithImage:(UIImage *)image height:(CGFloat)height
{
    NSMutableDictionary *dict = [@{KEY_2_INPUT_TYPE: @(BTCellTypeDisplayImage), KEY_2X_HEIGHT: @(height)} mutableCopy];
    if (image) {
        dict[KEY_2X_IMAGE] = image;
    }
    return dict;
}

+ (NSDictionary *)rowDisplayImageWithImage:(UIImage *)image height:(CGFloat)height defualtValue:(id)defaultValue
{
    NSMutableDictionary *dict = [@{KEY_2_INPUT_TYPE: @(BTCellTypeDisplayImage), KEY_2X_HEIGHT: @(height)} mutableCopy];
    if (image) {
        dict[KEY_2X_IMAGE] = image;
    }
    if (defaultValue) {
        dict[KEY_2X_DEFAULT] = defaultValue;
    }
    return dict;
}

+ (NSDictionary *)rowDisplayTextWithAttributeString:(NSAttributedString *)attrString
{
    return  @{KEY_2_INPUT_TYPE: @(BTCellTypeDisplayText),
              KEY_2X_ATTRIBUTE_TEXT: attrString
              };
}

+ (NSDictionary *)rowDisplayKeyValueWithKey:(NSString *)key value:(NSString *)value
{
    return  @{KEY_2_INPUT_TYPE: @(BTCellTypeDisplayKeyValue),
              KEY_2_LABEL: key,
              KEY_2X_DEFAULT:value};
}

+ (NSDictionary *)rowCustomCellWithHeight:(CGFloat)height label:(NSString *)label
{
    NSMutableDictionary *dict = [@{KEY_2_INPUT_TYPE: @(BTCellTypeCustomCell), KEY_2X_HEIGHT: @(height)} mutableCopy];
    if (label) {
        dict[KEY_2_LABEL] = label;
    }
    return dict;
}

/*
+ (NSDictionary *)rowCustomViewWithHeight:(CGFloat)height label:(NSString *)label
{
    NSMutableDictionary *dict = [@{KEY_2_INPUT_TYPE: @(BTCellTypeCustomView), KEY_2X_HEIGHT: @(height)} mutableCopy];
    if (label) {
        dict[KEY_2_LABEL] = label;
    }
    return dict;
}*/

#pragma mark choice creator

+ (NSDictionary *)choiceWithString:(NSString *)string
{
    return @{KEY_3_CHOICE: string};
}
	
+ (NSDictionary *)choiceWithString:(NSString *)string textColor:(UIColor *)textColor image:(UIImage *)image
{
    NSMutableDictionary *dict = [@{KEY_3_CHOICE: string} mutableCopy];
    
    if (textColor) {
        dict[KEY_3_TEXT_COLOR] = textColor;
    }
    
    if (image) {
        dict[KEY_3_IMAGE] = image;
    }
    
    return dict;
}


#pragma mark - Setter interception
- (void)setItemArray:(NSArray *)itemArray
{
    [self setItemArray:itemArray selectionArray:nil];
}

- (void)setSelectionArray:(NSMutableArray *)selectionArray
{
    [self setSelectionArray:selectionArray tableViewAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setSelectionArray:(NSMutableArray *)selectionArray tableViewAnimation:(UITableViewRowAnimation)tableViewAnimation
{
    _selectionArray = [self verifySelectionArray:selectionArray];
    if (self.isViewLoaded && self.view.window) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _itemArray.count)] withRowAnimation:tableViewAnimation];
    }else{
        _dataNeedsReloaded = YES;
    }
}


@end
