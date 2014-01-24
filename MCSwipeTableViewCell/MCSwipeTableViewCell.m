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
static NSTimeInterval const kMCDurationLowLimit = 0.25; // Lowest duration when swipping the cell because we try to simulate velocity
static NSTimeInterval const kMCDurationHightLimit = 0.1; // Highest duration when swipping the cell because we try to simulate velocity

@interface MCSwipeTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) MCSwipeTableViewCellDirection direction;
@property (nonatomic, assign) CGFloat currentPercentage;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIImageView *slidingImageView;
@property (nonatomic, weak) UIView* currentSlidingView;
@property (nonatomic, strong) NSString *currentImageName;
@property (nonatomic, strong) UIView *colorIndicatorView;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehaviour;
@property (nonatomic, strong) UICollisionBehavior* collisionBehaviour;
@property (nonatomic, strong) UIPushBehavior* pushBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior* itemBehaviour;

@property (nonatomic, strong) UIColor* previousBackgroundColor;

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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier firstStateView:(UIView *)firstView firstColor:(UIColor *)firstColor secondStateView:(UIView *)secondView secondColor:(UIColor *)secondColor thirdStateView:(UIView *)thirdView thirdColor:(UIColor *)thirdColor fourthStateView:(UIView *)fourthView fourthColor:(UIColor *)fourthColor
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setFirstStateView:firstView firstColor:firstColor secondStateView:secondView secondColor:secondColor thirdStateView:thirdView thirdColor:thirdColor fourthStateView:fourthView fourthColor:fourthColor];
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
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:_panGestureRecognizer];
    [_panGestureRecognizer setDelegate:self];
    
    _isDragging = NO;
    
    // By default the cells are draggable
    _shouldDrag = YES;
    
    // By default the icons are animating
    _shouldAnimatesIcons = YES;
    
    // Set state modes
    _modeForState1 = MCSwipeTableViewCellModeNone;
    _modeForState2 = MCSwipeTableViewCellModeNone;
    _modeForState3 = MCSwipeTableViewCellModeNone;
    _modeForState4 = MCSwipeTableViewCellModeNone;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    self.animator.delegate = self;
    
    self.collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.contentView]];
    // Need to create a boundary that lies to the left off of the right edge of the screen.
    
    self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.contentView]];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.contentView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    
    self.itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.contentView]];
    self.itemBehaviour.elasticity = 0.45f;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (!self.highlightColor)
    {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^
    {
        if (highlighted)
        {
            self.previousBackgroundColor = self.contentView.backgroundColor;
            
            self.contentView.backgroundColor = self.highlightColor;
        }
        else
        {
            if (self.previousBackgroundColor)
            {
                self.contentView.backgroundColor = self.previousBackgroundColor;
                
                self.previousBackgroundColor = nil;
            }
        }
    }];
}

- (void)bounceDirection:(MCSwipeTableViewCellDirection)direction withVelocity:(CGFloat)velocity
{
    //NSAssert(!(direction == MCSwipeTableViewCellDirectionCenter), @"Cannot bounce in center direction");
    
    
    if (direction == MCSwipeTableViewCellDirectionLeft)
    {
        self.colorIndicatorView.backgroundColor = [self colorWithPercentage:0.5];
        
        self.gravityBehaviour.gravityDirection = CGVectorMake(-1, 0);
        [self.collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, 0, 0, -280)];
        
        self.pushBehavior.pushDirection = CGVectorMake(velocity, 0.0f);
    }
    else
    {
        self.colorIndicatorView.backgroundColor = [self colorWithPercentage:-0.5];
        
        self.gravityBehaviour.gravityDirection = CGVectorMake(1, 0);
        [self.collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
        
        self.pushBehavior.pushDirection = CGVectorMake(-velocity, 0.0f);
    }
    
    self.colorIndicatorView.alpha = 1.0;
    
    [self.animator addBehavior:self.itemBehaviour];
    [self.animator addBehavior:self.pushBehavior];
    [self.animator addBehavior:self.collisionBehaviour];
    [self.animator addBehavior:self.gravityBehaviour];
    
    
    self.pushBehavior.active = YES;
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    //[self setBackgroundColor:[UIColor clearColor]];
    [self.animator removeAllBehaviors];
}

#pragma mark - Setter

- (void)setFirstStateIconName:(NSString *)firstIconName
                   firstColor:(UIColor *)firstColor
          secondStateIconName:(NSString *)secondIconName
                  secondColor:(UIColor *)secondColor
                thirdIconName:(NSString *)thirdIconName
                   thirdColor:(UIColor *)thirdColor
               fourthIconName:(NSString *)fourthIconName
                  fourthColor:(UIColor *)fourthColor {
    
    [self setFirstIconName:firstIconName];
    [self setSecondIconName:secondIconName];
    [self setThirdIconName:thirdIconName];
    [self setFourthIconName:fourthIconName];
    
    [self setFirstColor:firstColor];
    [self setSecondColor:secondColor];
    [self setThirdColor:thirdColor];
    [self setFourthColor:fourthColor];
}

- (void)setFirstView:(UIView *)firstView
{
    if (_firstView)
    {
        [_firstView removeFromSuperview];
    }
    
    _firstView = firstView;
    
    [self.colorIndicatorView addSubview:_firstView];
    firstView.hidden = YES;
}

- (void)setSecondView:(UIView *)secondView
{
    if (_secondView)
    {
        [_secondView removeFromSuperview];
    }
    
    _secondView = secondView;
    
    [self.colorIndicatorView addSubview:_secondView];
    secondView.hidden = YES;
}

- (void)setThirdView:(UIView *)thirdView
{
    if (_thirdView)
    {
        [_firstView removeFromSuperview];
    }
    
    _thirdView = thirdView;
    
    [self.colorIndicatorView addSubview:_thirdView];
    thirdView.hidden = YES;
}

- (void)setFourthView:(UIView *)fourthView
{
    if (_fourthView)
    {
        [_fourthView removeFromSuperview];
    }
    
    _fourthView = fourthView;
    
    [self.colorIndicatorView addSubview:_fourthView];
    fourthView.hidden = YES;
}

- (void)setFirstStateView:(UIView *)firstView firstColor:(UIColor *)firstColor secondStateView:(UIView *)secondView secondColor:(UIColor *)secondColor thirdStateView:(UIView *)thirdView thirdColor:(UIColor *)thirdColor fourthStateView:(UIView *)fourthView fourthColor:(UIColor *)fourthColor
{
    [self setFirstView:firstView];
    [self setSecondView:secondView];
    [self setThirdView:thirdView];
    [self setFourthView:fourthView];
    
    [self setFirstColor:firstColor];
    [self setSecondColor:secondColor];
    [self setThirdColor:thirdColor];
    [self setFourthColor:fourthColor];
}

#pragma mark - Prepare reuse
- (void)prepareForReuse {
    [super prepareForReuse];
    
    // Clearing before presenting back the cell to the user
    [_colorIndicatorView setBackgroundColor:[UIColor clearColor]];
    
    self.firstView.hidden = YES;
    self.secondView.hidden = YES;
    self.thirdView.hidden = YES;
    self.fourthView.hidden = YES;
    
    _currentSlidingView = nil;
    
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
    // The user do not want you to be dragged!
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
        
        // Notifying the delegate that we are dragging with an offset percentage
        if ([_delegate respondsToSelector:@selector(swipeTableViewCell:didSwipWithPercentage:)]) {
            [_delegate swipeTableViewCell:self didSwipWithPercentage:percentage];
        }
    }
    
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        _isDragging = NO;
        
        _currentImageName = [self imageNameWithPercentage:percentage];
        
        if (_currentSlidingView)
        {
            _currentSlidingView.hidden = YES;
        }
        
        _currentSlidingView = [self slidingViewWithPercentage:percentage];
        
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
        
        if (cellMode == MCSwipeTableViewCellModeExit && _direction != MCSwipeTableViewCellDirectionCenter && [self validateState:cellState])
            [self moveWithDuration:animationDuration andDirection:_direction];
        else
            [self bounceToOrigin];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        UIPanGestureRecognizer *g = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [g velocityInView:self];
        
        if (fabsf(point.x) > fabsf(point.y) ) {
            
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

- (UIView *)slidingViewWithPercentage:(CGFloat)percentage
{
    UIView* view;
    
    // Image
    if (percentage >= 0 && percentage < kMCStop2)
    {
        view = _firstView;
    }
    else if (percentage >= kMCStop2)
    {
        view = _secondView;
    
        if (!view)
        {
            view = _firstView;
        }
    }
    else if (percentage < 0 && percentage > -kMCStop2)
    {
        view = _thirdView;
    }
    else if (percentage <= -kMCStop2)
    {
        view = _fourthView;
    
        if (!view)
        {
            view = _thirdView;
        }
    }
    
    return view;
}

- (NSString *)imageNameWithPercentage:(CGFloat)percentage {
    NSString *imageName;
    
    // Image
    if (percentage >= 0 && percentage < kMCStop2)
        imageName = _firstIconName;
    else if (percentage >= kMCStop2)
        imageName = _secondIconName;
    else if (percentage < 0 && percentage > -kMCStop2)
        imageName = _thirdIconName;
    else if (percentage <= -kMCStop2)
        imageName = _fourthIconName;
    
    return imageName;
}
- (CGFloat)imageAlphaWithPercentage:(CGFloat)percentage {
    CGFloat alpha;
    
    if (percentage >= 0 && percentage < kMCStop1)
        alpha = percentage / kMCStop1;
    else if (percentage < 0 && percentage > -kMCStop1)
        alpha = fabsf(percentage / kMCStop1);
    else alpha = 1.0;
    
    return alpha;
}

- (UIColor *)colorWithPercentage:(CGFloat)percentage {
    UIColor *color;
    
    // Background Color
    if (percentage >= kMCStop1 && percentage < kMCStop2)
        color = _firstColor;
    else if (percentage >= kMCStop2)
        color = _secondColor;
    else if (percentage < -kMCStop1 && percentage > -kMCStop2)
        color = _thirdColor;
    else if (percentage <= -kMCStop2)
        color = _fourthColor;
    else
        color = self.defaultColor ? self.defaultColor : [UIColor clearColor];
    
    return color;
}

- (MCSwipeTableViewCellState)stateWithPercentage:(CGFloat)percentage {
    MCSwipeTableViewCellState state;
    
    state = MCSwipeTableViewCellStateNone;
    
    if (percentage >= kMCStop1 && [self validateState:MCSwipeTableViewCellState1])
        state = MCSwipeTableViewCellState1;
    
    if (percentage >= kMCStop2 && [self validateState:MCSwipeTableViewCellState2])
        state = MCSwipeTableViewCellState2;
    
    if (percentage <= -kMCStop1 && [self validateState:MCSwipeTableViewCellState3])
        state = MCSwipeTableViewCellState3;
    
    if (percentage <= -kMCStop2 && [self validateState:MCSwipeTableViewCellState4])
        state = MCSwipeTableViewCellState4;
    
    return state;
}

- (BOOL)validateState:(MCSwipeTableViewCellState)state {
    BOOL isValid = YES;
    
    switch (state) {
        case MCSwipeTableViewCellStateNone: {
            isValid = NO;
        }
            break;
            
        case MCSwipeTableViewCellState1: {
            if (!_firstColor && !_firstIconName && !_firstView)
                isValid = NO;
        }
            break;
            
        case MCSwipeTableViewCellState2: {
            if (!_secondColor && !_secondIconName && !_secondView)
                isValid = NO;
        }
            break;
            
        case MCSwipeTableViewCellState3: {
            if (!_thirdColor && !_thirdIconName && !_thirdView)
                isValid = NO;
        }
            break;
            
        case MCSwipeTableViewCellState4: {
            if (!_fourthColor && !_fourthIconName && !_fourthView)
                isValid = NO;
        }
            break;
            
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
    else
    {
        self.currentSlidingView.hidden = YES;
        
        self.currentSlidingView = [self slidingViewWithPercentage:percentage];
        
        self.currentSlidingView.hidden = NO;
        [self.currentSlidingView setAlpha:[self imageAlphaWithPercentage:percentage]];
        [self slideView:self.currentSlidingView withPercentage:percentage isDragging:self.shouldAnimatesIcons];
    }
    
    // Color
    UIColor *color = [self colorWithPercentage:percentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }
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

- (void)slideView:(UIView*)view withPercentage:(CGFloat)percentage isDragging:(BOOL)isDragging
{
    CGSize slidingSize = view.frame.size;
    CGRect slidingRect;
    
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
    
    
    slidingRect = CGRectMake(position.x - view.frame.size.width / 2.0,
                                  position.y - view.frame.size.height / 2.0,
                                  slidingSize.width,
                                  slidingSize.height);
    
    //slidingRect = CGRectIntegral(slidingRect);
    [view setFrame:slidingRect];
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
    
    if (_currentSlidingView != nil)
    {
        _currentSlidingView.hidden = NO;
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [self.contentView setFrame:rect];
                         
                         if (_currentSlidingView != nil)
                         {
                             _currentSlidingView.hidden = NO;
                             
                             [self slideView:_currentSlidingView withPercentage:percentage isDragging:self.shouldAnimatesIcons];
                         }
                         else
                         {
                             [_slidingImageView setAlpha:0];
                             [self slideImageWithPercentage:percentage imageName:_currentImageName isDragging:self.shouldAnimatesIcons];
                         }
                     }
                     completion:^(BOOL finished) {
                         [self notifyDelegate];
                     }];
}

- (void)bounceToOrigin {
    CGFloat bounceDistance = kMCBounceAmplitude * _currentPercentage;
    
    [UIView animateWithDuration:kMCBounceDuration1
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         CGRect frame = self.contentView.frame;
                         frame.origin.x = -bounceDistance;
                         [self.contentView setFrame:frame];
                         
                         NSString *imageName = [self imageNameWithPercentage:0.0];
                         
                         // Image Position
                         if (imageName != nil) {
                             [_slidingImageView setAlpha:0.0];
                             [self slideImageWithPercentage:0 imageName:_currentImageName isDragging:NO];
                         }
                         else
                         {
                             [_currentSlidingView setAlpha:0.0];
                             [self slideView:_currentSlidingView withPercentage:0.0 isDragging:NO];
                         }

                         // Setting back the color to the default
                         _colorIndicatorView.backgroundColor = self.defaultColor;
                     }
                     completion:^(BOOL finished1) {
                         
                         [UIView animateWithDuration:kMCBounceDuration2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              CGRect frame = self.contentView.frame;
                                              frame.origin.x = 0;
                                              [self.contentView setFrame:frame];
                                              
                                              // Clearing the indicator view
                                              _colorIndicatorView.backgroundColor = [UIColor clearColor];
                                          }
                                          completion:^(BOOL finished2) {
                                              [self notifyDelegate];
                                          }];
                     }];
}

#pragma mark - Delegate Notification

- (void)notifyDelegate
{
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
    
    if (state != MCSwipeTableViewCellStateNone) {
        if ([_delegate respondsToSelector:@selector(swipeTableViewCell:didEndSwipingSwipingWithState:mode:)]) {
            [_delegate swipeTableViewCell:self didEndSwipingSwipingWithState:state mode:mode];
        }
    }
}

@end