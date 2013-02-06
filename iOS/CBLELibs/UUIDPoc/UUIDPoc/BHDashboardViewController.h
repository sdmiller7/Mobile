//
//  BHDashboardViewController.h
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHViewController.h"

@interface BHDashboardViewController : BHViewController
<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    
}

@property (retain, nonatomic) IBOutlet UICollectionView *dashboardCollectionView;



@end
