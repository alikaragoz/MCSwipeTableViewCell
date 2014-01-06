//
//  MCSwipeTableViewCell.m
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//

#import "MCSwipeTableViewCell.h"

static CGFloat const kMCStop1 = 0.25; // Percentage limit to trigger the first action
static CGFloat const kMCStop2 = 0.75; // Percentage limit to trigger the second action
static CGFloat const kMCBounceAmplitude = 20.0; // Maximum bounce amplitude when using the MCSwipeTableViewCellModeSwitch mode
static NSTimeInterval const kMCBounceDuration1 = 0.2; // Duration of the first part of the bounce animation
static NSTimeInterval const kMCBounceDuration2 = 0.1; // Duration of the second part of the bounce animation
static NSTimeInterval const kMCDurationLowLimit = 0.25; // Lowest duration when swiping the cell because we try to simulate velocity
static NSTimeInterval const kMCDurationHightLimit = 0.1; // Highest duration when swiping the cell because we try to simulate velocity

@interface MCSwipeTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) MCSwipeTableViewCellDirection direction;
@property (nonatomic, assign) CGFloat currentPercentage;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIImageView *slidingImageView;
@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) UIView *colorIndicatorView;

@end

@implementation MCSwipeTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializer];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    
    _colorIndicatorView = [[UIView alloc] initWithFrame:self.bounds];
    [_colorIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_colorIndicatorView setBackgroundColor:(self.defaultColor ? self.defaultColor : [UIColor clearColor])];
    [self insertSubview:_colorIndicatorView atIndex:0];
    
    _slidingImageView = [[UIImageView alloc] init];
    [_slidingImageView setContentMode:UIViewContentModeCenter];
    [_colorIndicatorView addSubview:_slidingImageView];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:_panGestureRecognizer];
    [_panGestureRecognizer setDelegate:self];
    
    _isDragging = NO;
    
    // By default the cells are draggable
    _shouldDrag = YES;
    
    // By default the icons are animating
    _shouldAnimatesIcons = YES;
    
    // The defaut triggers match the icons location
    _firstTrigger = kMCStop1;
    _secondTrigger = kMCStop2;
    
    // Set state modes
    _modeForState1 = _modeForState2 = _modeForState3 = _modeForState4 = MCSwipeTableViewCellModeNone;
}

#pragma mark - Flexble blocks

- (void)setSwipeGestureWithImage:(UIImage *)image
                           color:(UIColor *)color
                            mode:(MCSwipeTableViewCellMode)mode
                           state:(MCSwipeTableViewCellState)state
                 completionBlock:(MCSwipeCompletionBlock)completionBlock {
    
    NSParameterAssert(image);
    NSParameterAssert(color);
    
    // Depending on the state we assign the attributes
    switch (state) {
        case MCSwipeTableViewCellState1: {
            _completionBlock1 = completionBlock;
            _image1 = image;
            _firstColor = color;
            _modeForState1 = mode;
            
        } break;
            
        case MCSwipeTableViewCellState2: {
            _completionBlock2 = completionBlock;
            _image2 = image;
            _secondColor = color;
            _modeForState2 = mode;
        } break;
            
        case MCSwipeTableViewCellState3: {
            _completionBlock3 = completionBlock;
            _image3 = image;
            _thirdColor = color;
            _modeForState3 = mode;
        } break;
            
        case MCSwipeTableViewCellState4: {
            _completionBlock4 = completionBlock;
            _image4 = image;
            _fourthColor = color;
            _modeForState4 = mode;
        } break;
            
        default:
            break;
    }
    
}

#pragma mark - Prepare reuse
- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_colorIndicatorView setBackgroundColor:[UIColor clearColor]];
    
    _isDragging = NO;
    _shouldDrag = YES;
    _shouldAnimatesIcons = YES;

    _modeForState1 = MCSwipeTableViewCellModeNone;
    _modeForState2 = MCSwipeTableViewCellModeNone;
    _modeForState3 = MCSwipeTableViewCellModeNone;
    _modeForState4 = MCSwipeTableViewCellModeNone;
    
    _firstColor = nil;
    _secondColor = nil;
    _thirdColor = nil;
    _fourthColor = nil;
    
    _image1 = nil;
    _image2 = nil;
    _image3 = nil;
    _image4 = nil;
}

#pragma mark - Handle Gestures

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    
    // The user does not want you to be dragged!
    if (!_shouldDrag) return;
    
    UIGestureRecognizerState state      = [gesture state];
    CGPoint translation                 = [gesture translationInView:self];
    CGPoint velocity                    = [gesture velocityInView:self];
    CGFloat percentage                  = [self percentageWithOffset:CGRectGetMinX(self.contentView.frame) relativeToWidth:CGRectGetWidth(self.bounds)];
    NSTimeInterval animationDuration    = [self animationDurationWithVelocity:velocity];
    _direction                          = [self directionWithPercentage:percentage];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        _isDragging = YES;
        
        CGPoint center = {self.contentView.center.x + translation.x, self.contentView.center.y};
        [self.contentView setCenter:center];
        [self animateWithOffset:CGRectGetMinX(self.contentView.frame)];
        [gesture setTranslation:CGPointZero inView:self];
        
        // Notifying the delegate that we are dragging with an offset percentage
        if ([_delegate respondsToSelector:@selector(swipeTableViewCell:didSwipWithPercentage:)]) {
            [_delegate swipeTableViewCell:self didSwipWithPercentage:percentage];
        }
    }
    
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        
        _isDragging = NO;
        _currentImage = [self imageWithPercentage:percentage];
        _currentPercentage = percentage;
        
        MCSwipeTableViewCellState cellState = [self stateWithPercentage:percentage];
        MCSwipeTableViewCellMode cellMode = MCSwipeTableViewCellModeNone;
        
        if (cellState == MCSwipeTableViewCellState1 && _modeForState1) {
            cellMode = self.modeForState1;
        }
        
        else if (cellState == MCSwipeTableViewCellState2 && _modeForState2) {
            cellMode = self.modeForState2;
        }
        
        else if (cellState == MCSwipeTableViewCellState3 && _modeForState3) {
            cellMode = self.modeForState3;
        }
        
        else if (cellState == MCSwipeTableViewCellState4 && _modeForState4) {
            cellMode = self.modeForState4;
        }
        
        if (cellMode == MCSwipeTableViewCellModeExit && _direction != MCSwipeTableViewCellDirectionCenter) {
            [self moveWithDuration:animationDuration andDirection:_direction];
        }
        
        else {
            __weak MCSwipeTableViewCell *weakSelf = self;
            [self swipeToOriginWithCompletion:^{
                __strong MCSwipeTableViewCell *strongSelf = weakSelf;
                [strongSelf notifyDelegate];
            }];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        
        UIPanGestureRecognizer *g = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [g velocityInView:self];
        
        if (fabsf(point.x) > fabsf(point.y) ) {
            if (point.x < 0 && !_modeForState3 && !_modeForState4) {
                return NO;
            }
            
            if (point.x > 0 && !_modeForState1 && !_modeForState2) {
                return NO;
            }
            
            // We notify the delegate that we just started dragging
            if ([_delegate respondsToSelector:@selector(swipeTableViewCellDidStartSwiping:)]) {
                [_delegate swipeTableViewCellDidStartSwiping:self];
            }
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Percentage

- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width {
    CGFloat offset = percentage * width;
    
    if (offset < -width) offset = -width;
    else if (offset > width) offset = width;
    
    return offset;
}

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width {
    CGFloat percentage = offset / width;
    
    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;
    
    return percentage;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat width = CGRectGetWidth(self.bounds);
    NSTimeInterval animationDurationDiff = kMCDurationHightLimit - kMCDurationLowLimit;
    CGFloat horizontalVelocity = velocity.x;
    
    if (horizontalVelocity < -width) horizontalVelocity = -width;
    else if (horizontalVelocity > width) horizontalVelocity = width;
    
    return (kMCDurationHightLimit + kMCDurationLowLimit) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}

- (MCSwipeTableViewCellDirection)directionWithPercentage:(CGFloat)percentage {
    if (percentage < 0)
        return MCSwipeTableViewCellDirectionLeft;
    else if (percentage > 0)
        return MCSwipeTableViewCellDirectionRight;
    else
        return MCSwipeTableViewCellDirectionCenter;
}

- (UIImage *)imageWithPercentage:(CGFloat)percentage {

    UIImage *image;
    
    if (percentage >= 0 && _modeForState1) {
        image = _image1;
    }
    
    if (percentage >= _secondTrigger && _modeForState2) {
        image = _image2;
    }
    
    if (percentage < 0  && _modeForState3) {
        image = _image3;
    }
    
    if (percentage <= -_secondTrigger && _modeForState4) {
        image = _image4;
    }
    
    return image;
}

- (CGFloat)imageAlphaWithPercentage:(CGFloat)percentage {
    CGFloat alpha;
    
    if (percentage >= 0 && percentage < _firstTrigger)
        alpha = percentage / _firstTrigger;
    else if (percentage < 0 && percentage > -_firstTrigger)
        alpha = fabsf(percentage / _firstTrigger);
    else alpha = 1.0;
    
    return alpha;
}

- (UIColor *)colorWithPercentage:(CGFloat)percentage {
    UIColor *color;
    
    // Background Color
    
    color = self.defaultColor ? self.defaultColor : [UIColor clearColor];
    
    if (percentage > _firstTrigger && _modeForState1) {
        color = _firstColor;
    }
    
    if (percentage > _secondTrigger && _modeForState2) {
        color = _secondColor;
    }
    
    if (percentage < -_firstTrigger && _modeForState3) {
        color = _thirdColor;
    }
    
    if (percentage <= -_secondTrigger && _modeForState4) {
        color = _fourthColor;
    }
    
    return color;
}

- (MCSwipeTableViewCellState)stateWithPercentage:(CGFloat)percentage {
    MCSwipeTableViewCellState state;
    
    state = MCSwipeTableViewCellStateNone;
    
    if (percentage >= _firstTrigger && _modeForState1) {
        state = MCSwipeTableViewCellState1;
    }
    
    if (percentage >= _secondTrigger && _modeForState2) {
        state = MCSwipeTableViewCellState2;
    }
    
    if (percentage <= -_firstTrigger && _modeForState3) {
        state = MCSwipeTableViewCellState3;
    }
    
    if (percentage <= -_secondTrigger && _modeForState4) {
        state = MCSwipeTableViewCellState4;
    }
    
    return state;
}

#pragma mark - Movement

- (void)animateWithOffset:(CGFloat)offset {
    CGFloat percentage = [self percentageWithOffset:offset relativeToWidth:CGRectGetWidth(self.bounds)];
    
    // Image Name
    UIImage *image = [self imageWithPercentage:percentage];
    
    // Image Position
    if (image != nil) {
        [_slidingImageView setImage:image];
        [_slidingImageView setAlpha:[self imageAlphaWithPercentage:percentage]];
        [self slideImageWithPercentage:percentage image:image isDragging:self.shouldAnimatesIcons];
    }
    
    // Color
    UIColor *color = [self colorWithPercentage:percentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }
}

- (void)slideImageWithPercentage:(CGFloat)percentage image:(UIImage *)image isDragging:(BOOL)isDragging {
    if (!image) return;
    
    CGSize slidingImageSize = image.size;
    CGRect slidingImageRect;
    
    CGPoint position = CGPointZero;
    
    position.y = CGRectGetHeight(self.bounds) / 2.0;
    
    if (isDragging) {
        if (percentage >= 0 && percentage < kMCStop1) {
            position.x = [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        
        else if (percentage >= kMCStop1) {
            position.x = [self offsetWithPercentage:percentage - (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        
        else if (percentage < 0 && percentage >= -kMCStop1) {
            position.x = CGRectGetWidth(self.bounds) - [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        
        else if (percentage < -kMCStop1) {
            position.x = CGRectGetWidth(self.bounds) + [self offsetWithPercentage:percentage + (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
    }
    
    else {
        if (_direction == MCSwipeTableViewCellDirectionRight) {
            position.x = [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        
        else if (_direction == MCSwipeTableViewCellDirectionLeft) {
            position.x = CGRectGetWidth(self.bounds) - [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        
        else {
            return;
        }
    }
    
    
    slidingImageRect = CGRectMake(position.x - slidingImageSize.width / 2.0,
                                  position.y - slidingImageSize.height / 2.0,
                                  slidingImageSize.width,
                                  slidingImageSize.height);
    
    slidingImageRect = CGRectIntegral(slidingImageRect);
    [_slidingImageView setFrame:slidingImageRect];
}

- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction {
    CGFloat origin;
    
    if (direction == MCSwipeTableViewCellDirectionLeft)
        origin = -CGRectGetWidth(self.bounds);
    else
        origin = CGRectGetWidth(self.bounds);
    
    CGFloat percentage = [self percentageWithOffset:origin relativeToWidth:CGRectGetWidth(self.bounds)];
    CGRect rect = self.contentView.frame;
    rect.origin.x = origin;
    
    // Color
    UIColor *color = [self colorWithPercentage:_currentPercentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }
    
    // Image
    if (_currentImage != nil) {
        [_slidingImageView setImage:_currentImage];
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.contentView setFrame:rect];
        [_slidingImageView setAlpha:0];
        [self slideImageWithPercentage:percentage image:_currentImage isDragging:self.shouldAnimatesIcons];
    } completion:^(BOOL finished) {
        [self notifyDelegate];
    }];
}

- (void)swipeToOriginWithCompletion:(void(^)(void))completion {
    CGFloat bounceDistance = kMCBounceAmplitude * _currentPercentage;
    
    [UIView animateWithDuration:kMCBounceDuration1 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        
        CGRect frame = self.contentView.frame;
        frame.origin.x = -bounceDistance;
        [self.contentView setFrame:frame];
        [_slidingImageView setAlpha:0.0];
        [self slideImageWithPercentage:0 image:_currentImage isDragging:NO];
        
        // Setting back the color to the default
        _colorIndicatorView.backgroundColor = self.defaultColor;
        
    } completion:^(BOOL finished1) {
        
        [UIView animateWithDuration:kMCBounceDuration2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            CGRect frame = self.contentView.frame;
            frame.origin.x = 0;
            [self.contentView setFrame:frame];
            
            // Clearing the indicator view
            _colorIndicatorView.backgroundColor = [UIColor clearColor];
            
        } completion:^(BOOL finished2) {
            if (completion) {
                completion();
            }
        }];
    }];
}

#pragma mark - Delegate Notification

- (void)notifyDelegate {
    MCSwipeTableViewCellState state = [self stateWithPercentage:_currentPercentage];
    MCSwipeTableViewCellMode mode = MCSwipeTableViewCellModeNone;
    MCSwipeCompletionBlock completionBlock;
    
    switch (state) {
        case MCSwipeTableViewCellState1: {
            mode = self.modeForState1;
            completionBlock = _completionBlock1;
        } break;
            
        case MCSwipeTableViewCellState2: {
            mode = self.modeForState2;
            completionBlock = _completionBlock2;
        } break;
            
        case MCSwipeTableViewCellState3: {
            mode = self.modeForState3;
            completionBlock = _completionBlock3;
        } break;
            
        case MCSwipeTableViewCellState4: {
            mode = self.modeForState4;
            completionBlock = _completionBlock4;
        } break;
            
        default:
            break;
    }
    
    // We notify the delegate that we just ended dragging
    if ([_delegate respondsToSelector:@selector(swipeTableViewCellDidEndSwiping:)]) {
        [_delegate swipeTableViewCellDidEndSwiping:self];
    }
    
    // This is only called if a state has been triggered
    if (state != MCSwipeTableViewCellStateNone) {
        if ([_delegate respondsToSelector:@selector(swipeTableViewCell:didEndSwipingSwipingWithState:mode:)]) {
            [_delegate swipeTableViewCell:self didEndSwipingSwipingWithState:state mode:mode];
        }
    }
    
    if (completionBlock) {
        completionBlock(self, state, mode);
    }
    
}

@end
