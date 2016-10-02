//
//  Response.m
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import "Response.h"

@implementation Response

+ (Response *)unknownError
{
    Response *rsp = [Response new];
    rsp.text = @"Unknown error, please try again latter";
    
    return rsp;
}

@end
