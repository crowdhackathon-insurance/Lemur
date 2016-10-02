//
//  CYHTTPClient.m
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import "CYHTTPClient.h"

#define kPOHTTPClientBaseURLString @"http://192.168.177.95/"

@implementation CYHTTPClient

static CYHTTPClient *_sharedPOHTTPClient = nil;

+ (CYHTTPClient *)sharedCYHTTPClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPOHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kPOHTTPClientBaseURLString]];
    });
    
    return _sharedPOHTTPClient;
}

- (NSURLSessionDataTask *)fetchResponseWithUserInput:(Request *)userRequest
                                    WithSuccessBlock:(void (^)(Response *response))success
                                     andFailureBlock:(void (^)(Response *error))failure
{
    
    NSString *targetResource
    = [NSString stringWithFormat:@"%@", @"names", AFPercentEscapedStringFromString(userRequest.userInput)];

    return [self GET:targetResource parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
