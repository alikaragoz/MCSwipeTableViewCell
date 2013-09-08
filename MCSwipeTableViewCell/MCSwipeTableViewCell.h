//
//  MCSwipeTableViewCell.h
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSwipeTableViewCell;

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellState){
    MCSwipeTableViewCellStateNone = 0,
    MCSwipeTableViewCellState1,
    MCSwipeTableViewCellState2,
    MCSwipeTableViewCellState3,
    MCSwipeTableViewCellState4
};

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellDirection){
    MCSwipeTableViewCellDirectionLeft = 0,
    MCSwipeTableViewCellDirectionCenter,
    MCSwipeTableViewCellDirectionRight
};

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellMode){
    MCSwipeTableViewCellModeNone = 0,
    MCSwipeTableViewCellModeExit,
    MCSwipeTableViewCellModeSwitch
};

@protocol MCSwipeTableViewCellDelegate <NSObject>

@optional
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode;

@end

@interface MCSwipeTableViewCell : UITableViewCell

@property (nonatomic, assign) id <MCSwipeTableViewCellDelegate> delegate;

@property (nonatomic, copy) NSString *firstIconName;
@property (nonatomic, copy) NSString *secondIconName;
@property (nonatomic, copy) NSString *thirdIconName;
@property (nonatomic, copy) NSString *fourthIconName;

@property (nonatomic, strong) UIColor *firstColor;
@property (nonatomic, strong) UIColor *secondColor;
@property (nonatomic, strong) UIColor *thirdColor;
@property (nonatomic, strong) UIColor *fourthColor;

// This is the general mode for all states
// If a specific mode for a state isn't defined, this mode will be taken in action
@property (nonatomic, assign) MCSwipeTableViewCellMode mode;

// Individual mode for states
@property (nonatomic, assign) MCSwipeTableViewCellMode modeForState1;
@property (nonatomic, assign) MCSwipeTableViewCellMode modeForState2;
@property (nonatomic, assign) MCSwipeTableViewCellMode modeForState3;
@property (nonatomic, assign) MCSwipeTableViewCellMode modeForState4;

@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL shouldDrag;
@property (nonatomic, assign) BOOL animatesIcons;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
 firstStateIconName:(NSString *)firstIconName
         firstColor:(UIColor *)firstColor
secondStateIconName:(NSString *)secondIconName
        secondColor:(UIColor *)secondColor
      thirdIconName:(NSString *)thirdIconName
         thirdColor:(UIColor *)thirdColor
     fourthIconName:(NSString *)fourthIconName
        fourthColor:(UIColor *)fourthColor;

- (void)setFirstStateIconName:(NSString *)firstIconName
                   firstColor:(UIColor *)firstColor
          secondStateIconName:(NSString *)secondIconName
                  secondColor:(UIColor *)secondColor
                thirdIconName:(NSString *)thirdIconName
                   thirdColor:(UIColor *)thirdColor
               fourthIconName:(NSString *)fourthIconName
                  fourthColor:(UIColor *)fourthColor;

@end
