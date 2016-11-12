//
//  UserCellModel.m
//  YMChat
//
//  Created by 炎檬 on 16/8/20.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "UserCellModel.h"

@implementation UserCellModel

- (UserCellModel *)initWithMessage:(NSString *)message isSelf:(BOOL) isSelf time:(NSString *)time {
    
    self.isSelf = isSelf;
    self.message = message;
    self.timeString = time;
    
    return self;
}

@end
