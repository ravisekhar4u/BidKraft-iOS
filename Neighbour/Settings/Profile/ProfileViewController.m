//
//  ProfileViewController.m
//  BidKraft
//
//  Created by Bharath Kongara on 3/29/15.
//  Copyright (c) 2015 ODU_HANDSON. All rights reserved.
//

#import "ProfileViewController.h"
#import <MapKit/MapKit.h>
#import "ServiceManager.h"
#import "ServiceURLProvider.h"
#import "UserProfile.h"
#import "User.h"

@interface ProfileViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,ServiceProtocol,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userPoints;
@property (weak, nonatomic) IBOutlet UILabel *vendorPoints;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UITextView *userDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtUserEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtUserPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextView *txtUserAddress;
@property (weak, nonatomic) IBOutlet UINavigationItem *profileNavigationItem;


@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic,strong) UIImageView *temptumb;
@property (nonatomic,strong) UIImageView *fullview;
@property (nonatomic,strong) ServiceManager *manager;
@property (nonatomic, strong) UserProfile *userProfileData;
@property (nonatomic, strong) User *userData;
@property (nonatomic,strong) NSString *lattitude;
@property (nonatomic,strong) NSString *longitude;
@property (nonatomic,strong) UITextView *address;

@end

@implementation ProfileViewController

- (UserProfile *)userProfileData
{
    if(!_userProfileData)
        _userProfileData = [UserProfile sharedData];
    
    return _userProfileData;
}
- (User *)userData
{
    if(!_userData)
        _userData = [User sharedData];
    
    return _userData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f]}];
    
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTapped:)];
    
    [self.profileNavigationItem setRightBarButtonItem:anotherButton];
    
    //[self.navigationItem setRightBarButtonItem:anotherButton];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    self.navigationItem.backBarButtonItem.tintColor = [UIColor colorWithRed:243.0f/255.0f green:156.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
    [self disableEditing];
    self.imgProfile.layer.cornerRadius = (self.imgProfile.frame.size.width)/2;
    self.imgProfile.clipsToBounds = YES;
    self.txtUserAddress.delegate = self;
    self.userDescription.delegate = self;
   
    // Do any additional setup after loading the view.
}
-(void) viewWillAppear:(BOOL)animated
{
     [self disableEditing];
    self.navigationItem.rightBarButtonItem.title = @"Edit";
}

-(void) disableEditing
{
    self.txtUserEmail.enabled = NO;
    self.txtUserName.enabled = NO;
    self.txtUserPhoneNumber.enabled = NO;
    [self.txtUserAddress setEditable:NO];
    [self.userDescription setEditable:NO];
}
-(void) enableEditing
{
    self.txtUserEmail.enabled = YES;
    self.txtUserName.enabled = YES;
    self.txtUserPhoneNumber.enabled = YES;
    [self.txtUserAddress setEditable:YES];
    [self.userDescription setEditable:YES];
}

- (IBAction)captureImage:(id)sender {
   
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Choose From photos", @"Take Picture", nil];
    [actionSheet showInView:self.view];
    
}
#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
    
    if([buttonTitle isEqualToString:@"Take Picture"])
    {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
    else if( [buttonTitle isEqualToString:@"Choose From photos"])
    {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [self.imgProfile setImage:chosenImage];
    [[self profilePictureDelegate] imageCpatured:chosenImage];
    [self.userProfileData saveProfilePicture:chosenImage];
    [self.imagePickerController dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void) convertAddressToLatLong
{
    CLGeocoder  *geocoder = [[CLGeocoder alloc] init];
    //NSMutableDictionary *parametersList =[[NSMutableDictionary alloc]init];
    [geocoder geocodeAddressString:self.address.text
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     for (CLPlacemark* aPlacemark in placemarks)
                     {
                         NSString *url;
                         CLLocation *location = [aPlacemark location];
                         CLLocationCoordinate2D coordinate = location.coordinate;
                         self.lattitude = [[NSString alloc ]initWithFormat:@"%f",coordinate.latitude];
                         self.longitude = [[NSString alloc ]initWithFormat:@"%f",coordinate.longitude];
                         self.manager = [ServiceManager defaultManager];
                         self.manager.serviceDelegate = self;
                         NSMutableDictionary *parameters = [self prepareParametersForProfile];
                         url = [ServiceURLProvider getURLForServiceWithKey:kUpdateProfile];
                         [self.manager serviceCallWithURL:url andParameters:parameters];
                         
                         
                     }
                 }];
}

-(void) editTapped :(UIBarButtonItem *) button
{
    
    if([button.title isEqualToString:@"Edit"])
    {
        [self enableEditing];
        button.title = @"Submit";
 
    }
    else if([button.title isEqualToString:@"Submit"])
    {
       
        
    }
    
}

-(NSMutableDictionary *) prepareParametersForProfile
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    return parameters;
    
}

#pragma UITextViewDelegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    return YES;
}
- (void) textViewDidBeginEditing:(UITextView *) textView {
    [textView setText:@""];
}

#pragma mark - ServiceProtocol Methods


- (void)serviceCallCompletedWithResponseObject:(id)response
{
    NSDictionary *responsedata = (NSDictionary *)response;
    NSLog(@"data%@",responsedata);
    NSString *status = [response valueForKey:@"status"];
    if([status isEqualToString:@"success"])
    {
        NSString *updated = [response valueForKey:@"message"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@" Updated!"
                                                            message:updated.description
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        
    }
    else
    {
        NSString *error = [response valueForKey:@"message"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@" Error!"
                                                            message:error.description
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
    }
    
}

- (void)serviceCallCompletedWithError:(NSError *)error
{
    NSLog(@"%@",error.description);
}


@end