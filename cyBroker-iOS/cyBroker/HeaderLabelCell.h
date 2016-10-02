//
//  HeaderLabelCell.h
//  cyBroker
//
//  Created by Christos Koninis on 01/10/16.
//  Copyright © 2016 Lemur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderLabelCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *micButton;

@end
