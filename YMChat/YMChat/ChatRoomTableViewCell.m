//
//  ChatRoomTableViewCell.m
//  YMChat
//
//  Created by 炎檬 on 16/8/22.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "ChatRoomTableViewCell.h"

@interface ChatRoomTableViewCell()

@end

@implementation ChatRoomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selfMessageLabel.hidden = YES;
    self.otherMessageLabel.hidden = YES;
    self.selfMessageBubbleView.hidden = YES;
    self.otherMessageBubbleView.hidden = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

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

- (void)setSelfMessage:(NSString *)message {
    self.selfMessageLabel.text = message;
}

- (void)setOtherMessage:(NSString *)message {
    self.otherMessageLabel.text = message;
}

@end
