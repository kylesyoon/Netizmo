//
//  UserTableViewCell.m
//  Metwork
//
//  Created by Kyle Yoon on 11/11/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "UserTableViewCell.h"

@implementation UserTableViewCell

- (void)awakeFromNib {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.userJobTitleAndCompany = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, screenBounds.size.width - 35, 20)];
    self.userJobTitleAndCompany.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    
    self.userNeed = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, screenBounds.size.width - 35, 50)];
    self.userNeed.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    self.userNeed.lineBreakMode = NSLineBreakByWordWrapping;
    self.userNeed.numberOfLines = 2;
    
    [self.contentView addSubview:self.userJobTitleAndCompany];
    [self.contentView addSubview:self.userNeed];
}

@end
