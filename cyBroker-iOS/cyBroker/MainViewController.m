//
//  MainViewController.m
//  cyBroker
//
//  Created by Christos Koninis on 01/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import "MainViewController.h"

//Communication
#import "CYHTTPClient.h"

//Views
#import "HeaderLabelCell.h"
#import "TextAnswerCell.h"

@import Speech;

typedef NS_ENUM(NSInteger, kCyStatus) {
    cyStatusWaitingUserInput,
    cyStatusWaitingServerResponse,
    cyStatusDisplayingResponse,
    cyStatusDisplayingEmptyResponse
};

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (strong, nonatomic) SFSpeechRecognitionTask *recognitionTask;
@property (strong, nonatomic) AVAudioEngine *audioEngine;
@property (strong, nonatomic) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, nullable) AVAudioInputNode *inputNode;

@property (nonatomic) kCyStatus currentStatus;

@property (strong, nonatomic) UITextField *userInputTextField;
@property (strong, nonatomic) UIButton *micButton;
@property (strong, nonatomic) NSString *lastUserInput;

@property (strong, nonatomic) Response *lastServerResponse;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 68.0;
    self.tableview.tableFooterView = [UIView new];
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        self.audioEngine = [[AVAudioEngine alloc] init];
        self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    }];
    
    /*
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://192.168.177.95/names" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];*/
    
    [[CYHTTPClient sharedCYHTTPClient] fetchResponseWithUserInput:[Request requestWithUserInput:@"ewf s"] WithSuccessBlock:^(Response *response) {
        NSLog(@"got response %@", response.text);
    } andFailureBlock:^(Response *error) {
        NSLog(@"got ERROR %@", error.text);
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
    if (self.currentStatus == cyStatusDisplayingResponse) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.currentStatus == cyStatusDisplayingResponse) {
        return 1;
    }
    else {
        return 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        HeaderLabelCell *headerLabelCell = (HeaderLabelCell *)[[NSBundle mainBundle] loadNibNamed:@"HeaderLabelCell" owner:nil options:nil].firstObject;
        self.userInputTextField = headerLabelCell.textField;
        self.userInputTextField.text = self.lastUserInput;
        if (self.micButton != headerLabelCell.micButton) {
            self.micButton = headerLabelCell.micButton;
            [self.micButton addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchUpInside];
            [self.micButton setBackgroundImage:[UIImage imageNamed:@"mic-disabled"] forState:UIControlStateNormal];
        }
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
                headerLabelCell.mainLabel.text = @"Sorry, I did not find any results";
                break;
        }
        cell = headerLabelCell;
        
    }
    else {
        TextAnswerCell *textAnswerCell = (TextAnswerCell *)[[NSBundle mainBundle] loadNibNamed:@"TextAnswerCell" owner:nil options:nil].firstObject;

        textAnswerCell.answerLabel.text = self.lastServerResponse.text;
        
        cell = textAnswerCell;
    }
    
    return cell;
}

#pragma mark - Server Communication

- (void)performRequestForUserInput:(NSString *)userInput
{
    self.lastUserInput = userInput;
    self.currentStatus = cyStatusWaitingServerResponse;
    [self.tableview reloadData];
    [self performSelector:@selector(serverResponse) withObject:nil afterDelay:1.5];
}

- (void)serverResponse
{
    self.lastServerResponse = [Response unknownError];//responseWithAnswer:@"i am afraid i can't let you do that"];
    
    if (self.lastServerResponse == [Response unknownError]) {
        self.currentStatus = cyStatusDisplayingEmptyResponse;
    }
    else {
        self.currentStatus = cyStatusDisplayingResponse;
    }
    
    [self.tableview reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self performRequestForUserInput:textField.text];
    return YES;
}

- (kCyStatus)getCurrentStatus
{
    return self.currentStatus;
}

#pragma mark - Audio Rec

- (void)startRecording:(UIButton *)sender
{
    if (self.recognitionTask != nil) {
        [self.audioEngine stop];
        [self.inputNode removeTapOnBus:0];
        self.recognitionTask = nil;
        self.recognitionRequest = nil;

        [self.recognitionTask cancel];
        self.recognitionTask = nil;
        self.userInputTextField.text = @"";
    }
    [self.micButton setBackgroundImage:[UIImage imageNamed:@"mic-enabled"] forState:UIControlStateNormal];
    
/*
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setMode:AVAudioSessionModeMeasurement error:nil];
    [session setActive:YES error:nil];
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
//self.audioEngine.inputNode
    self.recognitionRequest.shouldReportPartialResults= YES;
    self.recognitionTask = self.spe
 */
    
    NSError * outError;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&outError];
    [audioSession setMode:AVAudioSessionModeMeasurement error:&outError];
    [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation  error:&outError];
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    self.inputNode = [self.audioEngine inputNode];
    
    if (self.recognitionRequest == nil) {
        NSLog(@"Unable to created a SFSpeechAudioBufferRecognitionRequest object");
    }
    
    if (self.inputNode == nil) {
        
        NSLog(@"Unable to created a inputNode object");
    }
    
    self.recognitionRequest.shouldReportPartialResults = true;
    
   self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest
                                        resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
                                            [self speechRecognitionTask:self.recognitionTask didFinishRecognition:result];
                                        }];
//    _currentTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest
  //                                                delegate:self];

    
    [self.inputNode installTapOnBus:0 bufferSize:4096 format:[self.inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when){
        NSLog(@"Block tap!");
        
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
        
    }];
    
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&outError];
    NSLog(@"Error %@", outError);
}

- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)result {
    
    NSLog(@"speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition");
    NSString * translatedString = [[[result bestTranscription] formattedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
//    [self log:translatedString];
   
    NSLog(@"%@", translatedString);
    
    if ([result isFinal]) {
        [self.audioEngine stop];
        [self.inputNode removeTapOnBus:0];
        self.recognitionTask = nil;
        self.recognitionRequest = nil;
        self.micButton.alpha = 1.0f;
        [self.micButton setBackgroundImage:[UIImage imageNamed:@"mic-disabled"] forState:UIControlStateNormal];
        //perform request
        [self performRequestForUserInput:self.userInputTextField.text];
    }
    [self performSelector:@selector(cancelRecordingAndStartRequest)
               withObject:nil afterDelay:2.0];
    
    self.userInputTextField.text = translatedString;
}

- (void)cancelRecordingAndStartRequest
{
    @synchronized (self) {
        if (self.userInputTextField.text.length > 10
            && (self.currentStatus != cyStatusWaitingServerResponse)) {
            [self.audioEngine stop];
            [self.inputNode removeTapOnBus:0];
            self.recognitionTask = nil;
            self.recognitionRequest = nil;
            self.micButton.alpha = 1.0f;
            [self.micButton setBackgroundImage:[UIImage imageNamed:@"mic-disabled"] forState:UIControlStateNormal];
            //perform request
            [self performRequestForUserInput:self.userInputTextField.text];
        }
    }
}

@end
