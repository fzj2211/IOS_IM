//
//  ChatRoomTableViewCell.h
//  YMChat
//
//  Created by 炎檬 on 16/8/22.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatRoomTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) IBOutlet UILabel *selfMessageLabel;

@property (nonatomic, strong) IBOutlet UILabel *otherMessageLabel;

@property (nonatomic, strong) IBOutlet UIImageView *selfMessageBubbleView;

@property (nonatomic, strong) IBOutlet UIImageView *otherMessageBubbleView;

+ (instancetype)dequeueReusableCellForTableView:(UITableView *)tableView;

+ (NSString *)cellIdentifier;

- (void)setSelfMessage:(NSString *)message;

- (void)setOtherMessage:(NSString *)message;

@end
