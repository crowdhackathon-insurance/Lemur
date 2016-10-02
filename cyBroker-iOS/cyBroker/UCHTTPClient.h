//
//  UCHTTPClient.h
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#define kInsuranceFaqClassifierName @"cyBroker"

#define kCyBrokerPrice @"Price"
#define kCyBrokerDuration @"Duration"
#define kCyBrokerCoverage @"Coverage"
#define kCyBrokerAgents @"Agents"

//uClassify REST client (see https://www.uclassify.com/docs/restapi)
@interface UCHTTPClient : AFHTTPSessionManager

+ (UCHTTPClient *)sharedUCHTTPClient;

- (void)classifyText:(NSString *)text
     usingClassifier:(NSString *)classifier
    withSuccessBlock:(void (^)(NSArray<NSString *> *classesNames))success;

@end
