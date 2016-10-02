//
//  UCHTTPClient.m
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import "UCHTTPClient.h"

#define kCUHTTPClientBaseURLString @"https://api.uclassify.com/v1/"

@interface UCHTTPClient ()

@property (strong, nonatomic) NSString *username;

@end

@implementation UCHTTPClient

static UCHTTPClient *_sharedUCHTTPClient = nil;

+ (UCHTTPClient *)sharedUCHTTPClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUCHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kCUHTTPClientBaseURLString]];
    });
    
    return _sharedUCHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        
        NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"credentials" ofType:@"plist"]];

        NSString *token = dictRoot[@"token"];
        self.username = dictRoot[@"username"];
        
        //[self.requestSerializer setAuthorizationHeaderFieldWithUsername:@"Token" password:token];
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setValue:[NSString stringWithFormat:@"Token %@", token]
                      forHTTPHeaderField:@"Authorization"];

//        [self.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
//        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:kPOHTTPClientUsername
//                                                               password:kPOHTTPClientPassword];
    }
    
    return self;
}

- (void)classifyText:(NSString *)text
     usingClassifier:(NSString *)classifier
    withSuccessBlock:(void (^)(NSArray<NSString *> *classesNames))success;

{
//    success(@[kCyBrokerDuration]);
    //return;
    NSString *targetResource = [NSString stringWithFormat:@"%@/%@/classify", AFPercentEscapedStringFromString(self.username), AFPercentEscapedStringFromString(classifier)];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"texts"] = @[text];
    
    NSURLSessionDataTask *task = [self POST:targetResource
    parameters:[parameters copy]
      progress:nil
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSArray *resultArray = (NSArray *)responseObject;
           NSDictionary *result = [resultArray firstObject];
           
           NSMutableArray *classesNames = [NSMutableArray new];
           
           if (result[@"classification"]) {
               for (NSDictionary *objs in result[@"classification"]) {
                   NSString *className = objs[@"className"];
                   NSString *probabilityString = objs[@"p"];
                   
                   if (className && probabilityString && [probabilityString doubleValue] > 0.29) {
                       [classesNames addObject:className];
                   }
               }
           }
           
           success([classesNames copy]);
           
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           success(@[]);
       }];
    
    [self logTask:task];
}

-(void)logTask:(NSURLSessionDataTask *)task {
    
    NSString *requestString = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:0];
    NSString *responseString = [task.originalRequest.URL absoluteString];
    
    NSLog(@"\n\nRequest - %@\n\nResponse - %@\n\n", requestString, responseString);
}
/*
NSString * AFPercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(string.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}*/

@end
