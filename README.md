MCSwipeTableViewCell
--------------------

<p align="center"><img src="https://raw.github.com/alikaragoz/MCSwipeTableViewCell/master/github-assets/mcswipe-front.png"/></p>

An Effort to show how one would implement a TableViewCell like the one we can see in the very well executed [Mailbox](http://www.mailboxapp.com/) iOS app. 

##Demo
###Exit Mode
The exit mode `MCSwipeTableViewCellModeExit` is the original behavior we can see in the Mailbox app. Swiping the cell should make it disappear. Convenient in destructive modes.

<p align="center"><img src="https://raw.github.com/alikaragoz/MCSwipeTableViewCell/master/github-assets/mcswipe-exit.gif"/></p>

###Switch Mode
The switch mode `MCSwipeTableViewCellModeSwitch` is a new behavior I'm introducing. The cell will bounce back after selecting a state, this allows you to keep the cell. Convenient to switch an option quickly.

<p align="center"><img src="https://raw.github.com/alikaragoz/MCSwipeTableViewCell/master/github-assets/mcswipe-switch.gif"/></p>

## API Reference
Please refer to the header file [`MCSwipeTableViewCell.h`](MCSwipeTableViewCell/MCSwipeTableViewCell.h) for a complete overview of the capabilities of the class.

##Usage

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];

        // Setting the background color of the cell.
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    // Configuring the views and colors.
    UIView *checkView = [self viewWithImageName:@"check"];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
    
    UIView *crossView = [self viewWithImageName:@"cross"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    
    UIView *clockView = [self viewWithImageName:@"clock"];
    UIColor *yellowColor = [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0];
    
    UIView *listView = [self viewWithImageName:@"list"];
    UIColor *brownColor = [UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0];
    
    // Setting the default inactive state color to the tableView background color.
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    [cell.textLabel setText:@"Switch Mode Cell"];
    [cell.detailTextLabel setText:@"Swipe to switch"];
    
    // Adding gestures per state basis.
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Checkmark\" cell");
    }];
    
    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Cross\" cell");
    }];
    
    [cell setSwipeGestureWithView:clockView color:yellowColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Clock\" cell");
    }];
    
    [cell setSwipeGestureWithView:listView color:brownColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"List\" cell");
    }];
    
    return cell;
}
```

###Delegation

MCSwipeTableViewCell has a set of delegate methods in order to track the user behaviors. Take a look at the header file to be aware of all the methods provided by `MCSwipeTableViewCellDelegate`.

```objc
@interface MCTableViewController () <MCSwipeTableViewCellDelegate>
```

```objc
#pragma mark - MCSwipeTableViewCellDelegate

// Called when the user starts swiping the cell.
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell;

// Called when the user ends swiping the cell.
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell;

// Called during a swipe.
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage;
```

###Cell Deletion
In `MCSwipeTableViewCellModeExit` mode you may want to delete the cell with a nice fading animation, the following lines will give you an idea how to execute it:

```objc
[cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
    NSLog(@"Did swipe \"Cross\" cell");
   
    // Code to delete your cell.
    []
}];
```

You can also ask for a confirmation before deleting a cell:

```objc

__weak MCTableViewController *weakSelf = self;

[cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
    NSLog(@"Did swipe \"Cross\" cell");
            
    __strong MCTableViewController *strongSelf = weakSelf;
    strongSelf.cellToDelete = cell;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                        message:@"Are you sure your want to delete the cell?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    [alertView show];
}];
```
Then handle the `UIAlertView` action:

```objc
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // No
    if (buttonIndex == 0) {
        [_cellToDelete swipeToOriginWithCompletion:^{
            NSLog(@"Swiped back");
        }];
        _cellToDelete = nil;
    }
    
    // Yes
    else {
        // Code to delete your cell.
        [...]
    }
}
```

There is also an example in the demo project, I recommend to take a look at it.

###Changing the trigger percentage
If the default trigger limits do not fit to your needs you can change them with the `firstTrigger` *(default: 25%)* and `secondTrigger` *(Default: 75%)* properties.

```objc
cell.firstTrigger = 0.1;
cell.secondTrigger = 0.5;
```

###Reseting cell position
It is possible to put the cell back to it's position when using the `MCSwipeTableViewCellModeExit` mode with the `-swipeToOriginWithCompletion:` method: 

```objc
[cell swipeToOriginWithCompletion:^{
    NSLog(@"Cell swiped back!");
}];
```

##Compatibility
This library is not compatible with auto-layout so you will need to disable auto-layout in your xib properties.

##Requirements
- iOS >= 5.0
- ARC

## Contact

Ali Karagoz

- http://github.com/alikaragoz
- http://twitter.com/alikaragoz

## License

MCSwipeTableViewCell is available under the MIT license. See the LICENSE file for more info.
