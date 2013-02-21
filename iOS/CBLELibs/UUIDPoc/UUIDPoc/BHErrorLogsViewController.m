//
//  BHErrorLogsViewController.m
//  UUIDPoc
//
//  Created by Ryan Morton on 2/20/13.
//  Copyright (c) 2013 Ryan Morton. All rights reserved.
//

#import "BHErrorLogsViewController.h"
#import "BHErrorLogTableViewCellContentView.h"
#import "BHError.h"
#import "BHCoreDataManager.h"
#import "BHAppDelegate.h"

#pragma mark - BHErrorLogsTableViewCell
@interface BHErrorLogsTableViewCell : UITableViewCell
{
    
}
@property (nonatomic, retain) BHErrorLogTableViewCellContentView *contentSubView;
@end
@implementation BHErrorLogsTableViewCell

-(void)dealloc
{
    self.contentSubView = nil;
    [super dealloc];
}

@end

#pragma mark - BHErrorLogsViewController
@interface BHErrorLogsViewController ()
{
    
}

@property (nonatomic, retain) NSMutableArray *errors;

@end

@implementation BHErrorLogsViewController
-(void)dealloc
{
    self.errors = nil;
    [_errorsTableView release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"BHErrorLogsViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Logged Errors";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadErrorList];
}

-(void)reloadErrorList
{
    self.errorsTableView.userInteractionEnabled = NO;
    [self.loadingThrobber startAnimating];
    [[BHCoreDataManager sharedManager] getAllErrorsForTest:[BHAppDelegate sharedAppDelegate].currentTest withCompleteBlock:^(NSArray *queryResults) {
        self.errors = [NSMutableArray arrayWithArray:queryResults];
        
        if(self.errors.count ==0)
        {
            [self.errors addObject:[NSNull null]];//empty
            self.errorsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        else
        {
            self.errorsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        }
        
        [self.errorsTableView reloadData];
        [self.errorsTableView setUserInteractionEnabled:YES];
        [self.loadingThrobber stopAnimating];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate/DataSource Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.errors.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;//prevent selection
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdent = @"cell";
    static NSDateFormatter *dataFormatter;
    if(!dataFormatter)
    {
        dataFormatter  = [[NSDateFormatter alloc] init];
        [dataFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dataFormatter setLocale:[NSLocale currentLocale]];
        [dataFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    BHErrorLogsTableViewCell *cell = (BHErrorLogsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdent];
    
    if(!cell)
    {
        cell = [[[BHErrorLogsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent] autorelease];
        
        BHErrorLogTableViewCellContentView *contentView = [[[NSBundle mainBundle] loadNibNamed:@"BHErrorLogTableViewCellContentView" owner:nil options:nil] lastObject];
        contentView.frame = cell.contentView.bounds;
        [cell.contentView addSubview:contentView];
        cell.contentSubView = contentView;
        
    }
    
    NSObject *o = [self.errors objectAtIndex:indexPath.row];
    if([o isKindOfClass:[NSNull class]])
    {
        cell.contentSubView.titleLabel.text = @"No Errors";
        cell.contentSubView.detailsLabel.text = nil;
        cell.contentSubView.dateLabel.text = nil;
    }
    else
    {
        BHError *error = (BHError*)o;
        cell.contentSubView.titleLabel.text = error.title.length>0?error.title:@"No title...";
        cell.contentSubView.detailsLabel.text = error.cause.length>0?error.cause:@"No details...";
        cell.contentSubView.dateLabel.text = [dataFormatter stringFromDate:error.date];
    }
    
    return cell;
}
@end
