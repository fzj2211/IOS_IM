//
//  ChatFriendModel.h
//  YMChat
//
//  Created by 炎檬 on 16/8/17.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatFriendModel : NSObject

@property(nonatomic, strong) NSString *userName;

@property(nonatomic, strong) NSString *address;

@property(nonatomic, assign) int peerfd;

- (ChatFriendModel *)initWithUserName:(NSString *)userName address:(NSString *)address socketInfo:(int)peerfd;

@end
