//
//  BTSubFilterController.m
//  BTFilterControllerExample
//

//

#import "BTSubFilterController.h"
#define CELL_ID @"cellID"
@interface BTSubFilterController ()

@end

@implementation BTSubFilterController
{
    UITapGestureRecognizer *_tapRecognizer;
}

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

-(void)viewDidAppear:(BOOL)animated
{
    
    
    [super viewDidAppear:animated];

    // In case this is being used alone as a sheet model, it will allow the view to dismiss when you touch the side!
//    if (!_tapRecognizer) {
//        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
//        [_tapRecognizer setNumberOfTapsRequired:1];
//        _tapRecognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
//    }
//    [self.view.window addGestureRecognizer:_tapRecognizer];
}

//- (void) viewDidDisappear:(BOOL)animated
//{
//    
//    
////    [super viewDidDisappear:animated];
////
////    [self.view.window removeGestureRecognizer:_tapRecognizer];
//}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
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
