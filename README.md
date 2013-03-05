MCSwipeTableViewCell
--------------------

<p align="center"><img src="https://raw.github.com/alikaragoz/MCSwipeTableViewCell/master/github-assets/mcswipe-front.png"/></p>

An Effort to show how one would implement a TableViewCell like the one we can see in the very well executed [Mailbox](http://www.mailboxapp.com/) iOS app. 

##Demo
###Exit Mode
The exit mode (`MCSwipeTableViewCellModeExit`) is the original behavior we can see in the **Mailbox**app. Swiping the cell should make it disappear.

<p align="center"><img src="https://raw.github.com/alikaragoz/MCSwipeTableViewCell/master/github-assets/mcswipe-exit.gif"/></p>

###Switch Mode
The switch mode (`MCSwipeTableViewCellModeSwitch`) is a new behavior I'm introducing. The cell will bounce back after selecting a state, this allows you to keep the cell. Very useful to switch an option quickly.

<p align="center"><img src="https://raw.github.com/alikaragoz/MCSwipeTableViewCell/master/github-assets/mcswipe-switch.gif"/></p>

##Usage

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
        
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // For the delegate callback
    [cell setDelegate:self];
    
    // We need to provide the icon names and the desired colors
    [cell setFirstStateIconName:@"check.png"
                     firstColor:[UIColor colorWithRed:85.0/255.0 green:213.0/255.0 blue:80.0/255.0 alpha:1.0]
            secondStateIconName:@"cross.png"
                    secondColor:[UIColor colorWithRed:232.0/255.0 green:61.0/255.0 blue:14.0/255.0 alpha:1.0]
                  thirdIconName:@"clock.png"
                     thirdColor:[UIColor colorWithRed:254.0/255.0 green:217.0/255.0 blue:56.0/255.0 alpha:1.0]
                 fourthIconName:@"list.png"
                    fourthColor:[UIColor colorWithRed:206.0/255.0 green:149.0/255.0 blue:98.0/255.0 alpha:1.0]];
    
    // We need to set a background to the content view of the cell
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    
    // Setting the type of the cell
	[cell setMode:MCSwipeTableViewCellModeExit];
    
    return cell;
}	
```

###Delegate

MCSwipeTableViewCell has a delegate to retrieve the cell/state/mode of the triggered item.

```objc
@interface MCTableViewController () <MCSwipeTableViewCellDelegate>
```

```objc
#pragma mark - MCSwipeTableViewCellDelegate

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
    NSLog(@"IndexPath : %@ - MCSwipeTableViewCellState : %d - MCSwipeTableViewCellMode : %d", [self.tableView indexPathForCell:cell], state, mode);
}
```

###Deleting cells in Exit mode
In `MCSwipeTableViewCellModeExit` mode you may want to delete the cell with a nice fading animation, the following lines will give you an idea how to execute it:

```objc
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{    
    if (mode == MCSwipeTableViewCellModeExit)
    {
		// Remove the item in your data array and then remove it with the following method
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
    }
}
```
There is also an example in the demo project, I recommend to take a look at it.

###Customization
You may want to change the number of states, have a color without the icon or the opposite. All those combinations are possible.

In `setFirstStateIconName:` method you just need to put a `nil` in the required fields to disable a state, remove the color or the icon. 

For instance if you only want to have two states out of four:

```objc
[cell setFirstStateIconName:@"check.png"
				 firstColor:[UIColor colorWithRed:85.0/255.0 green:213.0/255.0 blue:80.0/255.0 alpha:1.0]
		secondStateIconName:@"cross.png"
				secondColor:[UIColor colorWithRed:232.0/255.0 green:61.0/255.0 blue:14.0/255.0 alpha:1.0]
			  thirdIconName:nil
				 thirdColor:nil
			 fourthIconName:nil
				fourthColor:nil];
```

##Requirements
- iOS >= 5.0
- ARC

## Contact

Ali Karagoz

- http://github.com/alikaragoz
- http://twitter.com/alikaragoz

## License

MCSwipeTableViewCell is available under the MIT license. See the LICENSE file for more info.
