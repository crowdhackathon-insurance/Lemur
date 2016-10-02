//
//  CYHTTPClient.m
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import "CYHTTPClient.h"
#import "UCHTTPClient.h"

#define kPOHTTPClientBaseURLString @"http://192.168.177.95/"

@implementation CYHTTPClient

static CYHTTPClient *_sharedCYHTTPClient = nil;

+ (CYHTTPClient *)sharedCYHTTPClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCYHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kPOHTTPClientBaseURLString]];
    });
    
    return _sharedCYHTTPClient;
}

- (NSURLSessionDataTask *)fetchResponseWithUserInput:(Request *)userRequest
                                    WithSuccessBlock:(void (^)(Response *response))success
                                     andFailureBlock:(void (^)(Response *error))failure
{
//    NSString *targetResource
//    = [NSString stringWithFormat:@"%@", @"names", AFPercentEscapedStringFromString(userRequest.userInput)];

    __weak typeof(self) weakSelfRef = self;
    //Fetch from the uclassify the matched classes
    [[UCHTTPClient sharedUCHTTPClient] classifyText:userRequest.userInput
                                    usingClassifier:kInsuranceFaqClassifierName
                                   withSuccessBlock:^(NSArray<NSString *> *classesNames) {
                                       __strong typeof(self) strongSelfRef = weakSelfRef;
                                       
                                       //Return if no classes where matched
                                       if ([classesNames count] <= 0) {
                                           failure([Response couldNotUnderstandRequestError]);
                                           return;
                                       }
                                       
                                       NSString *targetResource = [self targetResourceForClasses:classesNames
                                                                                     userRequest:userRequest.userInput];


                                       [strongSelfRef GET:targetResource
                                               parameters:nil
                                                 progress:nil
                                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                           
                                           NSDictionary *response = (NSDictionary *)responseObject;
                                           NSError *error;
                                           Response *result
                                           = [[Response alloc] initWithDictionary:response error:&error];
                                           
                                           
                                           if (error || !result) {
                                               failure([Response unknownError]);
                                           }
                                           else {
                                               success(result);
                                           }
                                       } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           failure([Response unknownError]);
                                       }];
                                       
                                   }];

    return nil;
}

- (NSString *)targetResourceForClasses:(NSArray<NSString *> *)classesNames userRequest:(NSString *)userRequest
{
    NSString *targetResource = @"";
    
    BOOL hasPrice = [classesNames containsObject:kCyBrokerPrice];
    BOOL hasDuration = [classesNames containsObject:kCyBrokerDuration];
    BOOL hasCovarage = [classesNames containsObject:kCyBrokerCoverage];
    BOOL hasAgents = [classesNames containsObject:kCyBrokerAgents];
    
    if (hasPrice) {
        targetResource = @"sum";
    }
    else if (hasDuration) {
        targetResource = @"dates";
    }
    else if (hasCovarage) {
        targetResource = @"coverage";
    }
    else if (hasAgents) {
        targetResource = @"agents";
    }
/*    else if () {
        targetResource = @"";
    }*/
    
    return targetResource;
}

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
}

@end
