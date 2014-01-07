//
//  MCSwipeTableViewCell.m
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//

#import "MCSwipeTableViewCell.h"

static CGFloat const kMCStop1 = 0.25; // Percentage limit to trigger the first action
static CGFloat const kMCStop2 = 0.55; // Percentage limit to trigger the second action
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
@property (nonatomic, strong) UILabel *slidingTextLabel;
@property (nonatomic, strong) NSString *currentImageName;
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

#pragma mark - Custom Initializer

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
         firstColor:(UIColor *)firstColor
          firstText:(NSString *)firstText
        secondColor:(UIColor *)secondColor
         secondText:(NSString *)secondText
         thirdColor:(UIColor *)thirdColor
          thirdText:(NSString *)thirdText
        fourthColor:(UIColor *)fourthColor
         fourthText:(NSString *)fourthText {
    
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setFirstStateIconName:nil
                         firstColor:firstColor
                          firstText:firstText
                secondStateIconName:nil
                        secondColor:secondColor
                          secondText:secondText
                      thirdIconName:nil
                         thirdColor:thirdColor
                          thirdText:thirdText
                     fourthIconName:nil
                        fourthColor:fourthColor
                         fourthText:fourthText];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
 firstStateIconName:(NSString *)firstIconName
         firstColor:(UIColor *)firstColor
secondStateIconName:(NSString *)secondIconName
        secondColor:(UIColor *)secondColor
      thirdIconName:(NSString *)thirdIconName
         thirdColor:(UIColor *)thirdColor
     fourthIconName:(NSString *)fourthIconName
        fourthColor:(UIColor *)fourthColor {
    
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setFirstStateIconName:firstIconName
                         firstColor:firstColor
                secondStateIconName:secondIconName
                        secondColor:secondColor
                      thirdIconName:thirdIconName
                         thirdColor:thirdColor
                     fourthIconName:fourthIconName
                        fourthColor:fourthColor];
    }
    return self;
}

- (void)initializer {
    
    _mode = MCSwipeTableViewCellModeNone;
    
    _colorIndicatorView = [[UIView alloc] initWithFrame:self.bounds];
    [_colorIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_colorIndicatorView setBackgroundColor:(self.defaultColor ? self.defaultColor : [UIColor clearColor])];
    [self insertSubview:_colorIndicatorView atIndex:0];
    
    _slidingImageView = [[UIImageView alloc] init];
    [_slidingImageView setContentMode:UIViewContentModeCenter];
    [_colorIndicatorView addSubview:_slidingImageView];
    
    _slidingTextLabel = [[UILabel alloc] init];
    [_slidingTextLabel setBackgroundColor:[UIColor clearColor]];
    [_slidingTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    [_slidingTextLabel setTextColor:[UIColor whiteColor]];
    [_slidingTextLabel setTextAlignment:NSTextAlignmentCenter];
    [_slidingTextLabel setNumberOfLines:3];
    [_colorIndicatorView addSubview:_slidingTextLabel];
    
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
    _modeForState1 = MCSwipeTableViewCellModeNone;
    _modeForState2 = MCSwipeTableViewCellModeNone;
    _modeForState3 = MCSwipeTableViewCellModeNone;
    _modeForState4 = MCSwipeTableViewCellModeNone;
}

#pragma mark - Setter

- (void)setFirstStateIconName:(NSString *)firstIconName
                   firstColor:(UIColor *)firstColor
                    firstText:(NSString *)firstText
          secondStateIconName:(NSString *)secondIconName
                  secondColor:(UIColor *)secondColor
                    secondText:(NSString *)secondText
                thirdIconName:(NSString *)thirdIconName
                   thirdColor:(UIColor *)thirdColor
                    thirdText:(NSString *)thirdText
               fourthIconName:(NSString *)fourthIconName
                  fourthColor:(UIColor *)fourthColor
                    fourthText:(NSString *)fourthText {
    [self setFirstIconName:firstIconName];
    [self setSecondIconName:secondIconName];
    [self setThirdIconName:thirdIconName];
    [self setFourthIconName:fourthIconName];
    
    [self setFirstColor:firstColor];
    [self setSecondColor:secondColor];
    [self setThirdColor:thirdColor];
    [self setFourthColor:fourthColor];
    
    [self setFirstText:firstText];
    [self setSecondText:secondText];
    [self setThirdText:thirdText];
    [self setFourthText:fourthText];
}

- (void)setFirstStateIconName:(NSString *)firstIconName
                   firstColor:(UIColor *)firstColor
          secondStateIconName:(NSString *)secondIconName
                  secondColor:(UIColor *)secondColor
                thirdIconName:(NSString *)thirdIconName
                   thirdColor:(UIColor *)thirdColor
               fourthIconName:(NSString *)fourthIconName
                  fourthColor:(UIColor *)fourthColor {
    
    [self setFirstStateIconName:firstIconName
                     firstColor:firstColor
                      firstText:nil
            secondStateIconName:secondIconName
                    secondColor:secondColor
                     secondText:nil
                  thirdIconName:thirdIconName
                     thirdColor:thirdColor
                      thirdText:nil
                 fourthIconName:fourthIconName
                    fourthColor:fourthColor
                     fourthText:nil];
}

#pragma mark - Prepare reuse
- (void)prepareForReuse {
    [super prepareForReuse];
    
    // Clearing before presenting back the cell to the user
    [_colorIndicatorView setBackgroundColor:[UIColor clearColor]];
    
    // clearing the dragging flag
    _isDragging = NO;
    
    // Before reuse we need to reset it's state
    _shouldDrag = YES;
    _shouldAnimatesIcons = YES;
    _mode = MCSwipeTableViewCellModeNone;
    _modeForState1 = MCSwipeTableViewCellModeNone;
    _modeForState2 = MCSwipeTableViewCellModeNone;
    _modeForState3 = MCSwipeTableViewCellModeNone;
    _modeForState4 = MCSwipeTableViewCellModeNone;
}

#pragma mark - Handle Gestures

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    
    // The user does not want you to be dragged!
    if (!_shouldDrag) return;
    
    UIGestureRecognizerState state = [gesture state];
    CGPoint translation = [gesture translationInView:self];
    CGPoint velocity = [gesture velocityInView:self];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMinX(self.contentView.frame) relativeToWidth:CGRectGetWidth(self.bounds)];
    NSTimeInterval animationDuration = [self animationDurationWithVelocity:velocity];
    _direction = [self directionWithPercentage:percentage];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        _isDragging = YES;
        
        CGPoint center = {self.contentView.center.x + translation.x, self.contentView.center.y};
        [self.contentView setCenter:center];
        [self animateWithOffset:CGRectGetMinX(self.contentView.frame)];
        [gesture setTranslation:CGPointZero inView:self];
        
        if ([_delegate respondsToSelector:@selector(swipeTableViewCell:didSwipWithPercentage:)]) {
            [_delegate swipeTableViewCell:self didSwipWithPercentage:percentage];
            // Notifying the delegate that we are dragging with an offset percentage
        }
    }
    
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        _isDragging = NO;
        
        _currentImageName = [self imageNameWithPercentage:percentage];
        _currentPercentage = percentage;
        
        // Current state
        MCSwipeTableViewCellState cellState = [self stateWithPercentage:percentage];
        
        // Current mode
        MCSwipeTableViewCellMode cellMode;
        
        if (cellState == MCSwipeTableViewCellState1 && self.modeForState1 != MCSwipeTableViewCellModeNone) {
            cellMode = self.modeForState1;
        } else if (cellState == MCSwipeTableViewCellState2 && self.modeForState2 != MCSwipeTableViewCellModeNone) {
            cellMode = self.modeForState2;
        } else if (cellState == MCSwipeTableViewCellState3 && self.modeForState3 != MCSwipeTableViewCellModeNone) {
            cellMode = self.modeForState3;
        } else if (cellState == MCSwipeTableViewCellState4 && self.modeForState4 != MCSwipeTableViewCellModeNone) {
            cellMode = self.modeForState4;
        } else {
            cellMode = self.mode;
        }
        
        if (cellMode == MCSwipeTableViewCellModeExit && _direction != MCSwipeTableViewCellDirectionCenter && [self validateState:cellState]) {
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
            if (point.x < 0 && !_thirdColor && !_thirdText && !_thirdIconName && !_fourthColor && !_fourthText && !_fourthIconName){
                return NO;
            }
            if (point.x > 0 && !_firstColor && !_firstText && !_firstIconName && !_secondColor && !_secondText && !_secondIconName){
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

#pragma mark - Utils
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

- (NSString *)textWithPercentage:(CGFloat)percentage {
    NSString *text;
    
    // Text
    if (percentage >= 0 && percentage < _secondTrigger)
        text = _firstText;
    else if (percentage >= _secondTrigger)
        text = _secondText;
    else if (percentage < 0 && percentage > -_secondTrigger)
        text = _thirdText;
    else if (percentage <= -_secondTrigger)
        text = _fourthText;
    
    return text;
}
- (NSString *)imageNameWithPercentage:(CGFloat)percentage {
    NSString *imageName;
    
    // Image
    if (percentage >= 0 && percentage < _secondTrigger)
        imageName = _firstIconName;
    else if (percentage >= _secondTrigger)
        imageName = _secondIconName;
    else if (percentage < 0 && percentage > -_secondTrigger)
        imageName = _thirdIconName;
    else if (percentage <= -_secondTrigger)
        imageName = _fourthIconName;
    
    return imageName;
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
    if (percentage >= _firstTrigger && percentage < _secondTrigger)
        color = _firstColor;
    else if (percentage >= _secondTrigger)
        color = _secondColor;
    else if (percentage < -_firstTrigger && percentage > -_secondTrigger)
        color = _thirdColor;
    else if (percentage <= -_secondTrigger)
        color = _fourthColor;
    else
        color = self.defaultColor ? self.defaultColor : [UIColor clearColor];
    
    return color;
}

- (MCSwipeTableViewCellState)stateWithPercentage:(CGFloat)percentage {
    MCSwipeTableViewCellState state;
    
    state = MCSwipeTableViewCellStateNone;
    
    if (percentage >= _firstTrigger && [self validateState:MCSwipeTableViewCellState1])
        state = MCSwipeTableViewCellState1;
    
    if (percentage >= _secondTrigger && [self validateState:MCSwipeTableViewCellState2])
        state = MCSwipeTableViewCellState2;
    
    if (percentage <= -_firstTrigger && [self validateState:MCSwipeTableViewCellState3])
        state = MCSwipeTableViewCellState3;
    
    if (percentage <= -_secondTrigger && [self validateState:MCSwipeTableViewCellState4])
        state = MCSwipeTableViewCellState4;
    
    return state;
}

- (BOOL)validateState:(MCSwipeTableViewCellState)state {
    BOOL isValid = YES;
    
    switch (state) {
        case MCSwipeTableViewCellStateNone: {
            isValid = NO;
        } break;
            
        case MCSwipeTableViewCellState1: {
            if (!_firstColor && !_firstIconName && !_firstText)
                isValid = NO;
        } break;
            
        case MCSwipeTableViewCellState2: {
            if (!_secondColor && !_secondIconName && !_secondText)
                isValid = NO;
        } break;
            
        case MCSwipeTableViewCellState3: {
            if (!_thirdColor && !_thirdIconName && !_thirdText)
                isValid = NO;
        } break;
            
        case MCSwipeTableViewCellState4: {
            if (!_fourthColor && !_fourthIconName && !_fourthText)
                isValid = NO;
        } break;
            
        default:
            break;
    }
    
    return isValid;
}

#pragma mark - Movement

- (void)animateWithOffset:(CGFloat)offset {
    CGFloat percentage = [self percentageWithOffset:offset relativeToWidth:CGRectGetWidth(self.bounds)];
    
    // Image Name
    NSString *imageName = [self imageNameWithPercentage:percentage];
    
    // Image Position
    if (imageName != nil) {
        [_slidingImageView setImage:[UIImage imageNamed:imageName]];
        [_slidingImageView setAlpha:[self imageAlphaWithPercentage:percentage]];
        [self slideImageWithPercentage:percentage imageName:imageName isDragging:self.shouldAnimatesIcons];
    }
    
    // Text
    NSString *text = [self textWithPercentage:percentage];
    if (text != nil) {
        [_slidingTextLabel setText:text];
        [self slideTextWithPercentage:percentage text:text isDragging:self.shouldAnimatesIcons];
    }

    // Color
    UIColor *color = [self colorWithPercentage:percentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }
}

- (void)slideTextWithPercentage:(CGFloat)percentage text:(NSString *)text isDragging:(BOOL)isDragging {
    if (!text) return;
    
    CGRect rect = [_slidingTextLabel textRectForBounds:self.bounds limitedToNumberOfLines:3];
    
    CGSize slidingTextSize = CGSizeMake(CGRectGetWidth(rect)+8.0f, CGRectGetHeight(rect));  // todoRG text.size;
    CGRect slidingTextRect;
    
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
    
    
    slidingTextRect = CGRectMake(position.x - slidingTextSize.width / 2.0,
                                  position.y - slidingTextSize.height / 2.0,
                                  slidingTextSize.width,
                                  slidingTextSize.height);
    
    slidingTextRect = CGRectIntegral(slidingTextRect);
    [_slidingTextLabel setFrame:slidingTextRect];
}

- (void)slideImageWithPercentage:(CGFloat)percentage imageName:(NSString *)imageName isDragging:(BOOL)isDragging {
    if (!imageName) return;
    
    UIImage *slidingImage = [UIImage imageNamed:imageName];
    CGSize slidingImageSize = slidingImage.size;
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
    if (_currentImageName != nil) {
        [_slidingImageView setImage:[UIImage imageNamed:_currentImageName]];
    }
    
    // Text
    NSString *text = [self textWithPercentage:_currentPercentage];
    if (text != nil) {
        [_slidingTextLabel setText:text];
    }
    
    [UIView animateWithDuration:duration delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [self.contentView setFrame:rect];
        [_slidingImageView setAlpha:0];
        [self slideImageWithPercentage:percentage imageName:_currentImageName isDragging:self.shouldAnimatesIcons];
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
        [self slideImageWithPercentage:0 imageName:_currentImageName isDragging:NO];
        
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

- (void)hintSwipeGesture {
    
    double delayInSeconds = 0.2;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.5f delay:0.1f options:(UIViewAnimationOptionCurveEaseIn) animations:^{
            CGRect frame = self.contentView.frame;
            CGRect newFrame = CGRectMake(-80, 0, frame.size.width, frame.size.height);
            [self.contentView setFrame:newFrame];
            [self animateWithOffset:CGRectGetMinX(self.contentView.frame)];

            
        } completion:^(BOOL finished) {
            [self swipeToOriginWithCompletion:NULL];
        }];
    });

}

#pragma mark - Delegate Notification

- (void)notifyDelegate {
    MCSwipeTableViewCellState state = [self stateWithPercentage:_currentPercentage];
    
    MCSwipeTableViewCellMode mode = self.mode;
    
    if (mode == MCSwipeTableViewCellModeNone) {
        switch (state) {
            case MCSwipeTableViewCellState1: {
                mode = self.modeForState1;
            } break;
                
            case MCSwipeTableViewCellState2: {
                mode = self.modeForState2;
            } break;
                
            case MCSwipeTableViewCellState3: {
                mode = self.modeForState3;
            } break;
                
            case MCSwipeTableViewCellState4: {
                mode = self.modeForState4;
            } break;
                
            default:
                break;
        }
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
}

@end
