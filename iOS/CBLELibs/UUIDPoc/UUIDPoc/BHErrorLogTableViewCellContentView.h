//
//  BHErrorLogTableViewCellContentView.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/20/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BHErrorLogTableViewCellContentView : UIView
{
    
}

@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailsLabel;

@end
