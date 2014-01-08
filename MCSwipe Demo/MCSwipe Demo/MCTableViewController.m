//
//  MCTableViewController.m
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
#import "MCTableViewController.h"

static NSUInteger const kMCNumItems = 10;
static CGFloat const TABLE_CELL_HEIGHT = 50;

@interface MCTableViewController () <MCSwipeTableViewCellDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) NSUInteger nbItems;
@property (nonatomic, strong) MCSwipeTableViewCell *cell;

@end

@implementation MCTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _nbItems = kMCNumItems;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Swipe Table View";
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(reload:)];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0]];
    [self.tableView setBackgroundView:backgroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _nbItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    // add some views to test on
    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0,0,100,TABLE_CELL_HEIGHT)];
    [firstView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [firstView setBackgroundColor:[UIColor purpleColor]];
    
    UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,TABLE_CELL_HEIGHT)];
    [secondView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [secondView setBackgroundColor:[UIColor yellowColor]];
    
    UIView *thirdView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,TABLE_CELL_HEIGHT)];
    [thirdView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [thirdView setBackgroundColor:[UIColor cyanColor]];
    
    UIView *fourthView = [[UIView alloc] initWithFrame:CGRectMake(0,0,50,TABLE_CELL_HEIGHT)];
    [fourthView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [fourthView setBackgroundColor:[UIColor blackColor]];
    
    
    MCSwipeTableViewCell *cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    [cell setDelegate:self];
    [cell setFirstStateIconName:@"check.png"
                     firstColor:[UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0]
                      firstView:nil
            secondStateIconName:@"cross.png"
                    secondColor:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
                     secondView:nil
                  thirdIconName:@"clock.png"
                     thirdColor:[UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]
                      thirdView:nil
                 fourthIconName:@"list.png"
                    fourthColor:[UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0]
                     fourthView:nil];
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    cell.separatorInset = UIEdgeInsetsZero;
    
    // Setting the default inactive state color to the tableView background color
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];

    if (indexPath.row % kMCNumItems == 0) {
        [cell.textLabel setText:@"Switch Mode Cell"];
        [cell.detailTextLabel setText:@"Swipe to switch"];
        cell.mode = MCSwipeTableViewCellModeSwitch;
    }
    
    else if (indexPath.row % kMCNumItems == 1) {
        [cell.textLabel setText:@"Exit Mode Cell"];
        [cell.detailTextLabel setText:@"Swipe to delete"];
        cell.mode = MCSwipeTableViewCellModeExit;
    }
    
    else if (indexPath.row % kMCNumItems == 2) {
        [cell.textLabel setText:@"Mixed Mode Cell"];
        [cell.detailTextLabel setText:@"Swipe to switch or delete"];
        cell.modeForState1 = MCSwipeTableViewCellModeSwitch;
        cell.modeForState2 = MCSwipeTableViewCellModeExit;
        cell.modeForState3 = MCSwipeTableViewCellModeSwitch;
        cell.modeForState4 = MCSwipeTableViewCellModeExit;
        cell.shouldAnimatesIcons = YES;
    }
    
    else if (indexPath.row % kMCNumItems == 3) {
        [cell.textLabel setText:@"Unanimated Icons"];
        [cell.detailTextLabel setText:@"Swipe"];
        cell.mode = MCSwipeTableViewCellModeSwitch;
        cell.shouldAnimatesIcons = NO;
    }
    
    else if (indexPath.row % kMCNumItems == 4) {
        [cell.textLabel setText:@"Disabled right swipe"];
        [cell.detailTextLabel setText:@"Swipe"];
        [cell setFirstStateIconName:nil
                         firstColor:nil
                          firstView:nil
                secondStateIconName:nil
                        secondColor:nil
                         secondView:nil
                      thirdIconName:@"clock.png"
                         thirdColor:[UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]
                          thirdView:nil
                     fourthIconName:@"list.png"
                        fourthColor:[UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0]
                         fourthView:nil];
    }
    
    else if (indexPath.row % kMCNumItems == 5) {
        [cell.textLabel setText:@"Disabled left swipe"];
        [cell.detailTextLabel setText:@"Swipe"];
        [cell setFirstStateIconName:@"check.png"
                         firstColor:[UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0]
                          firstView:nil
                secondStateIconName:@"cross.png"
                        secondColor:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
                         secondView:nil
                      thirdIconName:nil
                         thirdColor:nil
                          thirdView:nil
                     fourthIconName:nil
                        fourthColor:nil
                         fourthView:nil];
    }
    
    else if (indexPath.row % kMCNumItems == 6) {
        [cell.textLabel setText:@"Small triggers"];
        [cell.detailTextLabel setText:@"Using 10% and 50%"];
        cell.firstTrigger = 0.1;
        cell.secondTrigger = 0.5;
    }
    
    else if (indexPath.row % kMCNumItems == 7) {
        [cell.textLabel setText:@"Small triggers"];
        [cell.detailTextLabel setText:@"and unanimated icons"];
        cell.firstTrigger = 0.1;
        cell.secondTrigger = 0.5;
        cell.shouldAnimatesIcons = NO;
    }
    
    else if (indexPath.row % kMCNumItems == 8) {
        [cell.textLabel setText:@"Exit Mode Cell + Confirmation"];
        [cell.detailTextLabel setText:@"Swipe to delete"];
        cell.mode = MCSwipeTableViewCellModeExit;
        
        [cell setFirstStateIconName:@"cross.png"
                         firstColor:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
                          firstView:nil
                secondStateIconName:nil
                        secondColor:nil
                         secondView:nil
                      thirdIconName:nil
                         thirdColor:nil
                          thirdView:nil
                     fourthIconName:nil
                        fourthColor:nil
                         fourthView:nil];
        
    }
    
    else if (indexPath.row % kMCNumItems == 9) {
        [cell.textLabel setText:@"For Dwellers"];
        [cell.detailTextLabel setText:@"Left swings back; right stays till dismissal"];
        cell.mode = MSSwipeTableViewCellModeDwellers;
        [cell setFirstStateIconName:nil
                         firstColor:nil
                          firstView:firstView
                secondStateIconName:nil
                        secondColor:nil
                         secondView:secondView
                      thirdIconName:nil
                         thirdColor:nil
                          thirdView:thirdView
                     fourthIconName:nil
                        fourthColor:nil
                         fourthView:fourthView];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLE_CELL_HEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCTableViewController *tableViewController = [[MCTableViewController alloc] init];
    [self.navigationController pushViewController:tableViewController animated:YES];
}

#pragma mark - MCSwipeTableViewCellDelegate

// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    NSLog(@"Did start swiping the cell!");
}

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    NSLog(@"Did end swiping the cell!");
}

/*
 // When the user is dragging, this method is called and return the dragged percentage from the border
 - (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipWithPercentage:(CGFloat)percentage {
 NSLog(@"Did swipe with percentage : %f", percentage);
 }
 */

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didEndSwipingSwipingWithState:(MCSwipeTableViewCellState)state mode:(MCSwipeTableViewCellMode)mode {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSLog(@"Did end swipping with IndexPath : %@ - MCSwipeTableViewCellState : %d - MCSwipeTableViewCellMode : %d", indexPath, state, mode);
    
    if (indexPath.row % kMCNumItems == 8) {
        _cell = cell;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete?" message:@"Are you sure your want to delete the cell?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alertView show];
    }
    
    else if (mode == MCSwipeTableViewCellModeExit) {
        _nbItems--;
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -

- (void)reload:(id)sender {
    _nbItems++;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // No
    if (buttonIndex == 0) {
        [_cell swipeToOriginWithCompletion:^{
            NSLog(@"Swipped back");
        }];
        _cell = nil;
    }
    
    // Yes
    else {
        _nbItems--;
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cell]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
