//
//  YMChatTableViewCell.h
//  YMChat
//
//  Created by 炎檬 on 16/8/20.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMChatTableViewCell : UITableViewCell

+ (NSString *)cellIdentifier;

+ (instancetype)dequeueReusableCellForTableView:(UITableView *)tableView;

- (void)setUserName:(NSString *)userName;

- (void)setAddr:(NSString *)addr;

@end
