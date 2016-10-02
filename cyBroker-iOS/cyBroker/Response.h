//
//  Response.h
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface Response : JSONModel

@property (copy, nonatomic) NSString *body;
@property (copy, nonatomic) NSString *title;

//Type of respose, "text", "locations", "url"
@property (strong, nonatomic) NSString<Optional> *type;

@property (strong, nonatomic) NSString<Optional> *url;
@property (strong, nonatomic) NSString<Optional> *text;
//@property (strong, nonatomic) NSArray<NSString *> *locations;

+ (Response *)responseWithAnswer:(NSString *)answer;
+ (Response *)couldNotUnderstandRequestError;

+ (Response *)unknownError;

@end
