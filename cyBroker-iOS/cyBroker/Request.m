//
//  Request.m
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import "Request.h"

@implementation Request

+ (instancetype)requestWithUserInput:(NSString *)aUserInput
{
    Request *rq = [Request new];
    rq.userInput = aUserInput;
    
    return rq;
}

@end
