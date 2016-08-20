//
//  UserCellModel.h
//  YMChat
//
//  Created by 炎檬 on 16/8/20.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCellModel : NSObject

@property(nonatomic, strong) NSString *userName;

@property(nonatomic, strong) NSString *address;

- (UserCellModel *)initWithUserName:(NSString *)userName andAddress:(NSString *)address;

@end
