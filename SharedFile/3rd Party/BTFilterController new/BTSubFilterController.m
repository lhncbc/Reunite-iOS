//
//  BTSubFilterController.m
//  BTFilterControllerExample
//
//  Created by Krittach on 12/4/13.
//  Copyright (c) 2013 Byte. All rights reserved.
//

#import "BTSubFilterController.h"
#define CELL_ID @"cellID"
@interface BTSubFilterController ()

@end

@implementation BTSubFilterController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID];
    //making the cell ends
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_choiceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    
    [cell.textLabel setText:_choiceArray[indexPath.row][KEY_3_CHOICE]];
    [cell.textLabel setTextColor:_choiceArray[indexPath.row][KEY_3_TEXT_COLOR]];
    [cell.imageView setImage:_choiceArray[indexPath.row][KEY_3_IMAGE]];
    
    if (indexPath.row == _currentSelect) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

#pragma mark - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentSelect = (int)indexPath.row;
    [tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(subFilterController:didChooseDict:)]) {
        [_delegate subFilterController:self didChooseDict:_choiceArray[indexPath.row]];
    }
}


@end
