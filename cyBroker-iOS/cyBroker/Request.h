//
//  Request.h
//  cyBroker
//
//  Created by Christos Koninis on 02/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface Request : JSONModel

@property (strong, nonatomic) NSString *userInput;

@end
