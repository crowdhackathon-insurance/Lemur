//
//  CYHTTPClient.h
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "Request.h"
#import "Response.h"

@interface CYHTTPClient : AFHTTPSessionManager

+ (CYHTTPClient *)sharedCYHTTPClient;

- (NSURLSessionDataTask *)fetchResponseWithUserInput:(Request *)userRequest
                                    WithSuccessBlock:(void (^)(Response *response))success
                                     andFailureBlock:(void (^)(Response *error))failure;

@end
