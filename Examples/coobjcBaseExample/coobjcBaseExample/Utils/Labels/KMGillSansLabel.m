//
//  KMGillSansLabel.m
//
//
//  Created by Kevin Mindeguia on 24/06/2013.
//  Copyright (c) 2013 iKode Ltd. All rights reserved.
//

#import "KMGillSansLabel.h"
#import "UIFont+GillSansFonts.h"

@implementation KMGillSansLabel

- (void)resizeFontToFit{
    
    UIFont* font = self.font;
    
    CGSize constraintSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
    CGFloat minSize = self.minimumScaleFactor;
    CGFloat maxSize = self.font.pointSize;
    
    // start with maxSize and keep reducing until it doesn't clip
    for (int i = maxSize; i >= minSize; i--) {
        font = [font fontWithSize:i];
        
        // This step checks how tall the label would be with the desired font.
        CGRect labelRect = [self.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        if(labelRect.size.height <= self.frame.size.height)
            break;
    }
    // Set the font to the newly adjusted font.
    self.font = font;
    
}

@end


@interface KMGillSansBoldLabel ()

- (void)configureWithGillSansFont;

@end

@implementation KMGillSansBoldLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureWithGillSansFont];
    }
    return self;
}

- (void)setFontSize:(CGFloat)size
{
    self.font = [UIFont gillSansBoldFontWithSize:size];
}

- (void)awakeFromNib
{
    [self configureWithGillSansFont];
    
    [super awakeFromNib];
}

- (void)configureWithGillSansFont
{
    self.font = [UIFont gillSansBoldFontWithSize:self.font.pointSize];
}

@end

@interface KMGillSansMediumLabel ()

- (void)configureWithGillSansFont;

@end

@implementation KMGillSansMediumLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureWithGillSansFont];
    }
    return self;
}

- (void)setFontSize:(CGFloat)size
{
    self.font = [UIFont gillSansMediumFontWithSize:size];
}

- (void)awakeFromNib{
    [self configureWithGillSansFont];
    
    [super awakeFromNib];
}

- (void)configureWithGillSansFont
{
    self.font = [UIFont gillSansMediumFontWithSize:self.font.pointSize];
}

@end

@implementation KMGillSansRegularLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureWithGillSansFont];
    }
    return self;
}

- (void)setFontSize:(CGFloat)size
{
    self.font = [UIFont gillSansRegularFontWithSize:size];
}

- (void)awakeFromNib
{
    [self configureWithGillSansFont];
    
    [super awakeFromNib];
}

- (void)configureWithGillSansFont
{
    self.font = [UIFont gillSansRegularFontWithSize:self.font.pointSize];
}

@end

@implementation KMGillSansLightLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureWithGillSansFont];
    }
    return self;
}

- (void)setFontSize:(CGFloat)size
{
    self.font = [UIFont gillSansLightFontWithSize:size];
}

- (void)awakeFromNib
{
    [self configureWithGillSansFont];
    
    [super awakeFromNib];
}

- (void)configureWithGillSansFont
{
    self.font = [UIFont gillSansLightFontWithSize:self.font.pointSize];
}

@end
