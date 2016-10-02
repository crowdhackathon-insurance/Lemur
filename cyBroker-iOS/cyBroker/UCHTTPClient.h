//
//  UCHTTPClient.h
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#define kInsuranceFaqClassifierName @"cyBroker"

//uClassify REST client (see https://www.uclassify.com/docs/restapi)
@interface UCHTTPClient : AFHTTPSessionManager

+ (UCHTTPClient *)sharedUCHTTPClient;

- (void)classifyText:(NSString *)text usingClassifier:(NSString *)classifier;

@end
