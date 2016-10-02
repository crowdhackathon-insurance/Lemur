//
//  MainViewController.m
//  cyBroker
//
//  Created by Christos Koninis on 01/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import "MainViewController.h"
#import "HeaderLabelCell.h"
@import Speech;

typedef NS_ENUM(NSInteger, kCyStatus) {
    cyStatusWaitingUserInput,
    cyStatusWaitingServerResponse,
    cyStatusDisplayingResponse,
    cyStatusDisplayingEmptyResponse
};

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SFSpeechRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic) kCyStatus currentStatus;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 68.0;
    self.tableview.tableFooterView = [UIView new];
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Called when the availability of the given recognizer changes
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        HeaderLabelCell *headerLabelCell = (HeaderLabelCell *)[[NSBundle mainBundle] loadNibNamed:@"HeaderLabelCell" owner:nil options:nil].firstObject;
//        headerLabelCell.translatesAutoresizingMaskIntoConstraints = NO;
        
        headerLabelCell.textField.delegate = self;
        
        kCyStatus status = [self getCurrentStatus];
        
        if (status == cyStatusWaitingServerResponse) {
            [headerLabelCell.loadingIndicator startAnimating];
        }
        else {
            [headerLabelCell.loadingIndicator stopAnimating];
        }
        
        switch (status) {
            case cyStatusWaitingUserInput:
                headerLabelCell.mainLabel.text = @"How may I help you?";
                break;
            case cyStatusWaitingServerResponse:
                headerLabelCell.mainLabel.text = @"Please wait ";
                break;
            case cyStatusDisplayingResponse:
                headerLabelCell.mainLabel.text = @"How may I help you?";
                break;
            case cyStatusDisplayingEmptyResponse:
                headerLabelCell.mainLabel.text = @"Sorry I did not find any results";
                break;
        }
        cell = headerLabelCell;
        
    }
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    self.currentStatus = cyStatusWaitingServerResponse;
    [self performSelector:@selector(serverResponse) withObject:nil afterDelay:2];
    [self.tableview reloadData];
    return YES;
}

- (void)serverResponse
{
    self.currentStatus = cyStatusDisplayingEmptyResponse;
    [self.tableview reloadData];
}

- (kCyStatus)getCurrentStatus
{
    return self.currentStatus;
}

@end
