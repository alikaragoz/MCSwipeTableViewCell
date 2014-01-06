//
//  MCSwipeTableViewCell.h
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCSwipeTableViewCell;

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellState) {
    MCSwipeTableViewCellStateNone = 0,
    MCSwipeTableViewCellState1,
    MCSwipeTableViewCellState2,
    MCSwipeTableViewCellState3,
    MCSwipeTableViewCellState4
};

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellDirection) {
    MCSwipeTableViewCellDirectionLeft = 0,
    MCSwipeTableViewCellDirectionCenter,
    MCSwipeTableViewCellDirectionRight
};

typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellMode) {
    MCSwipeTableViewCellModeNone = 0,
    MCSwipeTableViewCellModeExit,
    MCSwipeTableViewCellModeSwitch
};

typedef void (^MCSwipeCompletionBlock)(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode);

@protocol MCSwipeTableViewCellDelegate <NSObject>

@optional

// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell;

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell;

// When the user is dragging, this method is called and return the dragged percentage from the border
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipWithPercentage:(CGFloat)percentage;

// When the user releases the cell, after swiping it, this method is called
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didEndSwipingSwipingWithState:(MCSwipeTableViewCellState)state mode:(MCSwipeTableViewCellMode)mode;

@end

@interface MCSwipeTableViewCell : UITableViewCell

@property (nonatomic, assign) id <MCSwipeTableViewCellDelegate> delegate;

@property (nonatomic, strong) UIColor *firstColor;
@property (nonatomic, strong) UIColor *secondColor;
@property (nonatomic, strong) UIColor *thirdColor;
@property (nonatomic, strong) UIColor *fourthColor;

@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, strong) UIImage *image3;
@property (nonatomic, strong) UIImage *image4;

@property (nonatomic, copy) MCSwipeCompletionBlock completionBlock1;
@property (nonatomic, copy) MCSwipeCompletionBlock completionBlock2;
@property (nonatomic, copy) MCSwipeCompletionBlock completionBlock3;
@property (nonatomic, copy) MCSwipeCompletionBlock completionBlock4;

// Percentage of when the first and second action are activated, respectively
@property (nonatomic, assign) CGFloat firstTrigger;
@property (nonatomic, assign) CGFloat secondTrigger;

// Color for background, when any state hasn't triggered yet
@property (nonatomic, strong) UIColor *defaultColor;

// Individual mode for states
@property (nonatomic, assign) MCSwipeTableViewCellMode modeForState1;
@property (nonatomic, assign) MCSwipeTableViewCellMode modeForState2;
@property (nonatomic, assign) MCSwipeTableViewCellMode modeForState3;
@property (nonatomic, assign) MCSwipeTableViewCellMode modeForState4;

@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL shouldDrag;
@property (nonatomic, assign) BOOL shouldAnimatesIcons;

- (void)setSwipeGestureWithImage:(UIImage *)image
                           color:(UIColor *)color
                            mode:(MCSwipeTableViewCellMode)mode
                           state:(MCSwipeTableViewCellState)state
                 completionBlock:(MCSwipeCompletionBlock)completionBlock;

// Manually swipe to origin
- (void)swipeToOriginWithCompletion:(void(^)(void))completion;

@end
