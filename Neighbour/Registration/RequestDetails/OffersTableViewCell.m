//
//  OffersTableViewCell.m
//  Neighbour
//
//  Created by bkongara on 9/11/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "OffersTableViewCell.h"
#import "User.h"
#import "VendorData.h"
#import "VendorBidDetail.h"
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "ProfileViewController.h"


@interface OffersTableViewCell()<ServiceProtocol>

@property (weak, nonatomic) IBOutlet UIButton *btnUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblBidAmount;

@property (nonatomic,strong) UITableView *offersTableView;
@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic,strong) ProfileViewController *profileViewController;
@property (weak, nonatomic) IBOutlet UILabel *lblBidType;
@property (weak, nonatomic) IBOutlet UILabel *lblBestOffers;
@property (weak,nonatomic)  NSMutableArray *imgUserArray;
@property (strong,nonatomic) NSMutableArray *requestArrays;
@property (strong,nonatomic) UserRequests *usrRequest;
@property (nonatomic,strong) BidDetails *bidDetail;
@property (nonatomic,strong) NSMutableArray *bidsArray;
@property BOOL isProfileView;

@end
@implementation OffersTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) mockData
{
    User *userData = [User sharedData];
    self.requestArrays = userData.usrRequests;
  
}

- (void)prepareCellForTabelView:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath withBids:(NSMutableArray *)listOfBids
{
   
    self.offersTableView = tableView;
    
    BidDetails *requestBidDetail = [listOfBids objectAtIndex:indexPath.item];
    self.lblBidType.text= requestBidDetail.userName;
    [self.btnUserName setTitle:requestBidDetail.userName forState:UIControlStateNormal];
    self.btnUserName.tag = indexPath.item;
    self.btnAccept.tag = indexPath.section;
    //self.btnUserName.titleLabel.text = requestBidDetail.userName;
    
    [self.lblBidAmount setText: [requestBidDetail.bidAmount stringByAppendingString:@"$/hr"]];
    [self.lblTime setText:@"5 hrs"];
    //self.lblBestOffers.text = [requestBidDetail.bidAmount stringByAppendingString:@"$/hr"];
    self.lblBidAmount.text = [requestBidDetail.bidAmount stringByAppendingString:@"$/hr"];
    self.bidOffererId  = requestBidDetail.offererUserId;
    [self timeDifference:requestBidDetail];
    
}


- (void)prepareCellForVendorTabelView:(UITableView *)tableView atIndex:(NSIndexPath *)indexPath withBids:(NSMutableArray *)listOfBids{
    
    VendorBidDetail *requestBidDetail = [listOfBids objectAtIndex:indexPath.item];
    self.lblBidType.text= requestBidDetail.offererName;
    self.lblBestOffers.text = [requestBidDetail.bidAmount stringByAppendingString:@"$/hr"];
}

-(void) timeDifference:(BidDetails *) requestBidDetail
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"E, dd MMM yyyy H:m:s z"];
    NSDate *date1 = [[NSDate alloc] init];
    date1 = [df dateFromString:(NSString *)requestBidDetail.bidCreatedDate];
    
    NSDate* date2 = [NSDate date];
    NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
    double secondsInAnHour = 3600;
    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    self.lblTimeAgo.text = [[@(hoursBetweenDates) stringValue] stringByAppendingString:@" hrs ago"];
}

- (IBAction)userNameTapped:(id)sender
{
   
    UIButton *button =(UIButton *)sender;
    OffersTableViewCell *cell =(OffersTableViewCell *)[self.offersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    self.manager = [ServiceManager defaultManager];
    self.manager.serviceDelegate = self;
    NSMutableDictionary *parameters = [self prepareParmeters:cell.bidOffererId];
    NSString *url = [ServiceURLProvider getURLForServiceWithKey:kGetUserProfile];
    [self.manager serviceCallWithURL:url andParameters:parameters];
    
}

- (IBAction)btnBidAccept:(id)sender
{
    
    UIButton *button =(UIButton *)sender;
    OffersTableViewCell *cell =(OffersTableViewCell *)[self.offersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    NSMutableDictionary *paymentDetails = [[NSMutableDictionary alloc]init];
    [paymentDetails setObject:cell.bidAmount forKey:@"bidAmountPay"];
       [paymentDetails setObject:[@(cell.bidId) stringValue] forKey:@"bidId"];
    [self.paymentDetailsDelegate getPaymentDetails:paymentDetails];
    
}

-(NSMutableDictionary *) prepareParmeters:(NSString *) userId
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:userId forKey:@"userId"];
    return parameters;
}

#pragma mark - ServiceProtocol Methods

- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    //NSDictionary *data = [response valueForKey:@"data"];
    NSLog(@"data%@",responsedata);
    //NSString *status = [[NSString alloc] initWithString:[responsedata valueForKey:@"status"]];
    [self.userProfileViewDelegate getProfileView:response];
    
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}



@end
