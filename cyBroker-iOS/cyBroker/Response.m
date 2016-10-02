//
//  Response.m
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import "Response.h"

@implementation Response

static Response *unknownErrorRsp;

+ (Response *)responseWithAnswer:(NSString *)answer
{
    Response *rsp = [Response new];
    rsp.text = answer;
    
    return rsp;
}

+ (Response *)unknownError
{
    //TODO: synchronize
    if (!unknownErrorRsp) {
        Response *rsp = [Response new];
        rsp.text = @"Unknown error, please try again latter";
        unknownErrorRsp = rsp;
    }
    
    return unknownErrorRsp;
}

+ (Response *)couldNotUnderstandRequestError
{
    //TODO: synchronize
    if (!unknownErrorRsp) {
        Response *rsp = [Response new];
        rsp.text = @"Sorry, I could not understand yout question";
        unknownErrorRsp = rsp;
    }
    
    return unknownErrorRsp;
}


@end
