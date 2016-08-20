//
//  YMChatTableViewCell.m
//  YMChat
//
//  Created by 炎檬 on 16/8/20.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "YMChatTableViewCell.h"

@interface YMChatTableViewCell ()

@property(nonatomic, strong) IBOutlet UILabel *userNameLabel;

@property(nonatomic, strong) IBOutlet UILabel *userAddrLabel;

@end

@implementation YMChatTableViewCell

+ (instancetype)dequeueReusableCellForTableView:(UITableView *)tableView
{
    id cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifier]];
    if (!cell) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIdentifier]];
    }
    return cell;
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setUserName:(NSString *)userName {
    self.userNameLabel.text = userName;
}

- (void)setAddr:(NSString *)addr {
    self.userAddrLabel.text = addr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
