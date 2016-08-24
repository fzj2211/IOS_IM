//
//  ChatFriendModel.m
//  YMChat
//
//  Created by 炎檬 on 16/8/17.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "ChatFriendModel.h"

@implementation ChatFriendModel

- (ChatFriendModel *)initWithUserName:(NSString *)userName address:(NSString *)address socketInfo:(int)peerfd{
    self.userName = userName;
    self.address = address;
    self.peerfd = peerfd;
    return self;
}

@end
