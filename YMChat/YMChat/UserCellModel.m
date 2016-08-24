//
//  UserCellModel.m
//  YMChat
//
//  Created by 炎檬 on 16/8/20.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "UserCellModel.h"

@implementation UserCellModel

- (UserCellModel *)initWithMessage:(NSString *)message isSelf:(BOOL) isSelf {
    
    self.isSelf = isSelf;
    self.message = message;
    
    return self;
}

@end
