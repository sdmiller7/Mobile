//
//  BHErrorLogTableViewCellContentView.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/20/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHErrorLogTableViewCellContentView.h"

@interface BHErrorLogTableViewCellContentView ()
{
    
}
@property (nonatomic, retain) UIColor *startColor;
@property (nonatomic, retain) UIColor *endColor;
@end

@implementation BHErrorLogTableViewCellContentView
-(void)dealloc
{
    self.startColor = nil;
    self.endColor = nil;
    [_dateLabel release];
    [_titleLabel release];
    [_detailsLabel release];
    [super dealloc];
}

-(void)internalInit
{
    self.startColor = [UIColor lightGrayColor];
    self.endColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.25];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
   return self;
}

- (void)drawRect:(CGRect)rect
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect currentBounds = self.bounds;
    
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = [NSArray arrayWithObjects:(id)self.startColor.CGColor, (id)self.endColor.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
	
    CGPoint startPoint = CGPointZero;
	CGPoint endPoint = CGPointZero;
    
    //topToBottom
    startPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMinY(currentBounds));
    endPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    
    CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    
    //bottomToTop
    gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    startPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
    endPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    
    CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    
    [super drawRect:rect];
}

@end
