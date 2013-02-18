//
//  BHDashboardViewController.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/5/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHDashboardViewController.h"
#import "BHUtils.h"
#import "BHDashboardCollectionViewCellContentView.h"
#import "BHDashboardCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import <jsonkit/NSObject+BitHiker.h>

@interface BHDashboardViewController ()
{
    
}

@property (nonatomic, retain) NSMutableArray *items;
@end

@implementation BHDashboardViewController
-(void)dealloc
{
    self.items = nil;
    [_dashboardCollectionView release];
    [super dealloc];
}

-(void)internalInit
{
    self.items = [NSMutableArray array];
    [self.items addObject:@"Log"];
    [self.items addObject:@"Current Stats"];
}
- (id)init
{
    self = [super initWithNibName:@"BHDashboardViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        [self internalInit];
    }
    return self;
}

-(void)configureTheToolbar
{
    UIBarButtonItem *restButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset App" style:UIBarButtonItemStyleBordered target:self action:@selector(resetButtonClicked:)];
    
    self.toolbarItems = @[restButtonItem,[BHUtils getFlexibleToolbarItem]];
    [restButtonItem release];
}

-(void)configureNavBar
{
    self.navigationItem.title = @"Dashboard";
    
    UIBarButtonItem *newTestButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New Test" style:UIBarButtonItemStyleDone target:self action:@selector(newTestButtonClicked:)];
    self.navigationItem.rightBarButtonItem = newTestButtonItem;
    [newTestButtonItem release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureTheToolbar];
    [self configureNavBar];
    
    [self.dashboardCollectionView registerClass:[BHDashboardCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interaction
-(void)newTestButtonClicked:(id)sender
{
}
-(void)resetButtonClicked:(id)sender
{
}

#pragma mark - UICollectionViewControllerDelegate/DataSource Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdent = @"cell";
    BHDashboardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdent forIndexPath:indexPath];
    
    if(!cell.contentSubview)
    {
        BHDashboardCollectionViewCellContentView *contentSubView = (BHDashboardCollectionViewCellContentView*)[[[NSBundle mainBundle] loadNibNamed:@"BHDashboardCollectionViewCellContentView" owner:nil options:nil] lastObject];
        cell.contentSubview = contentSubView;
        cell.contentSubview.frame = cell.contentView.bounds;
        [cell.contentView addSubview:cell.contentSubview];
        cell.backgroundColor = [UIColor whiteColor];
        
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds];
        cell.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        cell.layer.shadowPath = shadowPath.CGPath;
        cell.layer.shadowOpacity = 1.0f;
        cell.layer.shadowRadius = 3.0f;
    }
    
    cell.contentSubview.titleLabel.text = [self.items objectAtIndex:indexPath.row];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(86.0f, 86.0f);
}

@end
