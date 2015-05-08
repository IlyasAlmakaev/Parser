//
//  ParserTableViewCell.h
//  Parser
//
//  Created by Admin on 08.05.15.
//  Copyright (c) 2015 intent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageLabel;

@end
