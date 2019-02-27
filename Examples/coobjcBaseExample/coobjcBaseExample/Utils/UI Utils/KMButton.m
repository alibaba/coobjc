//
//  KMButton.m
//  Movies
//
//  Created by Kevin Mindeguia on 09/03/2016.
//  Copyright © 2016 iKode Ltd. All rights reserved.
//

#import "KMButton.h"

@implementation KMButton

#pragma mark - Init Methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setupLayerAttributes];
        [self setupMotionEffects];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setupLayerAttributes];
        [self setupMotionEffects];
    }
    
    return self;
}

#pragma mark - Setup Methods

- (void)setupLayerAttributes
{
    self.layer.cornerRadius = self.frame.size.height / 2;
}

- (void)setupMotionEffects
{
    UIControlEvents applyEffectEvents = UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragEnter;
    [self removeTarget:self action:@selector(applyTouchEffect) forControlEvents:applyEffectEvents];
    [self addTarget:self action:@selector(applyTouchEffect) forControlEvents:applyEffectEvents];
    
    UIControlEvents dismissEffectEvents = UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDragOutside | UIControlEventTouchDragExit | UIControlEventTouchCancel;
    [self removeTarget:self action:@selector(dismissTouchEffect) forControlEvents:dismissEffectEvents];
    [self addTarget:self action:@selector(dismissTouchEffect) forControlEvents:dismissEffectEvents];
}

#pragma mark - Motion Methods

- (void)applyTouchEffect
{
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:nil];
}

- (void)dismissTouchEffect
{
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                self.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

@end
