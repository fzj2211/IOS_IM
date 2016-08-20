//
//  UserCellModel.m
//  YMChat
//
//  Created by 炎檬 on 16/8/20.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "UserCellModel.h"

@implementation UserCellModel

- (UserCellModel *)initWithUserName:(NSString *)userName andAddress:(NSString *)address{
    
    self.userName = userName;
    self.address = address;
    
    return self;
}

@end
