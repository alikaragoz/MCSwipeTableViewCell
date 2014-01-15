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

@protocol MCSwipeTableViewCellDelegate;

@interface MCSwipeTableViewCell : UITableViewCell

@property (nonatomic, assign) id <MCSwipeTableViewCellDelegate> delegate;

@property (nonatomic, strong, readwrite) UIColor *firstColor;
@property (nonatomic, strong, readwrite) UIColor *secondColor;
@property (nonatomic, strong, readwrite) UIColor *thirdColor;
@property (nonatomic, strong, readwrite) UIColor *fourthColor;

@property (nonatomic, strong, readwrite) UIView *view1;
@property (nonatomic, strong, readwrite) UIView *view2;
@property (nonatomic, strong, readwrite) UIView *view3;
@property (nonatomic, strong, readwrite) UIView *view4;

@property (nonatomic, copy, readwrite) MCSwipeCompletionBlock completionBlock1;
@property (nonatomic, copy, readwrite) MCSwipeCompletionBlock completionBlock2;
@property (nonatomic, copy, readwrite) MCSwipeCompletionBlock completionBlock3;
@property (nonatomic, copy, readwrite) MCSwipeCompletionBlock completionBlock4;

// Percentage of when the first and second action are activated, respectively
@property (nonatomic, assign, readwrite) CGFloat firstTrigger;
@property (nonatomic, assign, readwrite) CGFloat secondTrigger;

// Damping of the spring animation (iOS 7 only)
@property (nonatomic, assign, readwrite) CGFloat damping;

// Velocity of the spring animation (iOS 7 only)
@property (nonatomic, assign, readwrite) CGFloat velocity;

// Duration of the animation.
@property (nonatomic, assign, readwrite) NSTimeInterval animationDuration;

// Color for background, when any state hasn't triggered yet
@property (nonatomic, strong, readwrite) UIColor *defaultColor;

// Individual mode for states
@property (nonatomic, assign, readwrite) MCSwipeTableViewCellMode modeForState1;
@property (nonatomic, assign, readwrite) MCSwipeTableViewCellMode modeForState2;
@property (nonatomic, assign, readwrite) MCSwipeTableViewCellMode modeForState3;
@property (nonatomic, assign, readwrite) MCSwipeTableViewCellMode modeForState4;

@property (nonatomic, assign, readonly) BOOL isDragging;
@property (nonatomic, assign, readwrite) BOOL shouldDrag;
@property (nonatomic, assign, readwrite) BOOL shouldAnimatesIcons;

- (void)setSwipeGestureWithView:(UIView *)view
                          color:(UIColor *)color
                           mode:(MCSwipeTableViewCellMode)mode
                          state:(MCSwipeTableViewCellState)state
                completionBlock:(MCSwipeCompletionBlock)completionBlock;

// Manually swipe to origin
- (void)swipeToOriginWithCompletion:(void(^)(void))completion;

@end


@protocol MCSwipeTableViewCellDelegate <NSObject>

@optional

// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell;

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell;

// When the user is dragging, this method is called and return the dragged percentage from the border
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipWithPercentage:(CGFloat)percentage;

@end
