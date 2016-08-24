//
//  YMManager.h
//  YMChat
//
//  Created by 炎檬 on 16/8/23.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatRoomViewController.h"

@protocol YMManagerDelegate <NSObject>

@optional

- (void)refreshData:(NSString *)string;

- (void)refreshDataWithAddress:(NSDictionary *)result;

@end

@interface YMManager : NSObject

@property (nonatomic) NSMutableDictionary *vcWithSocketId;

@property (nonatomic) NSLock *lock;

@property (nonatomic, weak) id<YMManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)registerVCWithSocketId:(int)socketId;

- (ChatRoomViewController *)getRootVCById:(int)socketId;

- (void)flushNewData:(NSString *)data bySocketId:(int)socketId;

- (void)refreshData:(NSString *)string;

- (void)refreshDataWithAddress:(NSDictionary *)result;

@end
