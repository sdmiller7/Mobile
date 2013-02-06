//
//  BHDashboardCollectionViewCellContentView.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHDashboardCollectionViewCellContentView.h"

@implementation BHDashboardCollectionViewCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_titleLabel release];
    [super dealloc];
}
@end
