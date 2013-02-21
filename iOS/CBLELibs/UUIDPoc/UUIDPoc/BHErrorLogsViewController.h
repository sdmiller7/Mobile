//
//  BHErrorLogsViewController.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/20/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHViewController.h"

@interface BHErrorLogsViewController : BHViewController
<UITableViewDataSource, UITableViewDelegate>
{
    
}


@property (retain, nonatomic) IBOutlet UITableView *errorsTableView;


@end
