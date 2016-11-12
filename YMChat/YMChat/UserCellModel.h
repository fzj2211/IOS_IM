//
//  UserCellModel.h
//  YMChat
//
//  Created by 炎檬 on 16/8/20.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCellModel : NSObject

@property (nonatomic, assign) BOOL isSelf;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *timeString;

- (UserCellModel *)initWithMessage:(NSString *)message isSelf:(BOOL) isSelf time:(NSString *)time;

@end
