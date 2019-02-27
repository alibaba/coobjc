//
//  KMActivityIndicator.m
//  
//
//  Created by Kevin Mindeguia on 19/08/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//

#import "KMActivityIndicator.h"

#define ANIMATION_DURATION_SECS 0.5

typedef enum {
    KMActivityIndicatorStepZero = 0,
    KMActivityIndicatorStepOne,
    KMActivityIndicatorStepTwo,
    KMActivityIndicatorStepThree,
    KMActivityIndicatorStepFour,
} KMActivityIndicatorStep;

@interface KMActivityIndicator ()

@property (nonatomic, assign) CGFloat dotRadius;
@property (nonatomic, assign) KMActivityIndicatorStep stepNumber;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) CGRect firstPoint, secondPoint, thirdPoint, fourthPoint;
@property (nonatomic, strong) CALayer *firstDot, *secondDot, *thirdDot;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation KMActivityIndicator

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupViewLayout:self.frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        [self setupViewLayout:frame];
    }

    return self;
}

- (void)setupViewLayout:(CGRect)frame
{
    _stepNumber = KMActivityIndicatorStepZero;
    _isAnimating = NO;
    _hidesWhenStopped = YES;
    _color = [UIColor colorWithRed:241/255.0f green:196/255.0f blue:15/255.0f alpha:1.0];
    
    _dotRadius = frame.size.height <= frame.size.width ? frame.size.width/12 : frame.size.height/12;
    _firstPoint = CGRectMake(frame.size.width/4-_dotRadius, frame.size.height/2-_dotRadius, 2*_dotRadius, 2*_dotRadius);
    _secondPoint = CGRectMake(frame.size.width/2-_dotRadius, frame.size.height/4-_dotRadius, 2*_dotRadius, 2*_dotRadius);
    _thirdPoint = CGRectMake(3*frame.size.width/4-_dotRadius, frame.size.height/2-_dotRadius, 2*_dotRadius, 2*_dotRadius);
    _fourthPoint = CGRectMake(frame.size.width/2-_dotRadius, 3*frame.size.height/4-_dotRadius, 2*_dotRadius, 2*_dotRadius);
    
    //First dot is the one that moves straight up and down
    _firstDot = [CALayer layer];
    [_firstDot setMasksToBounds:YES];
    [_firstDot setBackgroundColor:[self.color CGColor]];
    [_firstDot setCornerRadius:_dotRadius];
    [_firstDot setBounds:CGRectMake(0.0f, 0.0f, _dotRadius*2, _dotRadius*2)];
    _firstDot.frame = _fourthPoint;
    
    //Second dot is the one that moves straight left and right
    _secondDot = [CALayer layer];
    [_secondDot setMasksToBounds:YES];
    [_secondDot setBackgroundColor:[self.color CGColor]];
    [_secondDot setCornerRadius:_dotRadius];
    [_secondDot setBounds:CGRectMake(0.0f, 0.0f, _dotRadius*2, _dotRadius*2)];
    _secondDot.frame = _firstPoint;
    
    //Third dot is the one that moves around all four positions clockwise
    _thirdDot = [CALayer layer];
    [_thirdDot setMasksToBounds:YES];
    [_thirdDot setBackgroundColor:[self.color CGColor]];
    [_thirdDot setCornerRadius:_dotRadius];
    [_thirdDot setBounds:CGRectMake(0.0f, 0.0f, _dotRadius*2, _dotRadius*2)];
    _thirdDot.frame = _thirdPoint;
    
    [[self layer] addSublayer:_firstDot];
    [[self layer] addSublayer:_secondDot];
    [[self layer] addSublayer:_thirdDot];
    
    self.layer.hidden = YES;
}

- (void)startAnimating
{
    if (!_isAnimating)
    {
        _isAnimating = YES;
        
        self.layer.hidden = NO;
        
       _timer = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_DURATION_SECS target:self selector:@selector(animateNextStep) userInfo:nil repeats:YES];
    }
}

- (void)stopAnimating
{
    _isAnimating = NO;
    
    if (self.hidesWhenStopped)
    {
        self.layer.hidden = YES;
    }

    [_timer invalidate];
    
    _stepNumber = KMActivityIndicatorStepZero;
    _firstDot.frame = _fourthPoint;
    _secondDot.frame = _firstPoint;
    _thirdDot.frame = _thirdPoint;
}

- (void)animateNextStep
{
    switch (_stepNumber)
    {
        case KMActivityIndicatorStepZero:
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:ANIMATION_DURATION_SECS];
            _firstDot.frame = _secondPoint;
            _thirdDot.frame = _fourthPoint;
            [CATransaction commit];
            break;
        }
        case KMActivityIndicatorStepOne:
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:ANIMATION_DURATION_SECS];
            _secondDot.frame = _thirdPoint;
            _thirdDot.frame = _firstPoint;
            [CATransaction commit];
            break;
        }
        case KMActivityIndicatorStepTwo:
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:ANIMATION_DURATION_SECS];
            _firstDot.frame = _fourthPoint;
            _thirdDot.frame = _secondPoint;
            [CATransaction commit];
            break;
        }
        case KMActivityIndicatorStepThree:
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:ANIMATION_DURATION_SECS];
            _secondDot.frame = _firstPoint;
            _thirdDot.frame = _thirdPoint;
            [CATransaction commit];
            break;
        }
        case KMActivityIndicatorStepFour:
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:ANIMATION_DURATION_SECS];
            _firstDot.frame = _secondPoint;
            _thirdDot.frame = _fourthPoint;
            [CATransaction commit];
            _stepNumber = KMActivityIndicatorStepZero;
        }
        default:
            break;
    }
    
    _stepNumber++;
}

- (BOOL)isAnimating
{
    return _isAnimating;
}


@end
