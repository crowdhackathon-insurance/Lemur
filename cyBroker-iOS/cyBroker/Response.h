//
//  Response.h
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface Response : JSONModel

//Type of respose, "text", "locations", "url"
@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *text;
//@property (strong, nonatomic) NSArray<NSString *> *locations;

+ (Response *)responseWithAnswer:(NSString *)answer;

+ (Response *)unknownError;

@end
