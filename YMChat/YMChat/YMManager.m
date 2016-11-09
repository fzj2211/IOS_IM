//
//  YMManager.m
//  YMChat
//
//  Created by 炎檬 on 16/8/23.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "YMManager.h"

@implementation YMManager

+ (instancetype)sharedInstance
{
    static YMManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _vcWithSocketId = [NSMutableDictionary dictionary];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)registerVCWithSocketId:(int)socketId
{
    NSString *socketIdS = [NSString stringWithFormat:@"%d", socketId];
    
    if ([_vcWithSocketId objectForKey:socketIdS]) {
        return;
    }
    
    [_lock lock];
    
    ChatRoomViewController *vc = [[ChatRoomViewController alloc] init];
    
    vc.socket = socketId;
    
    [_vcWithSocketId setValue:vc forKey:socketIdS];
    
    [_lock unlock];
    
}

- (ChatRoomViewController *)getRootVCById:(int)socketId
{
    NSString *socketIdS = [NSString stringWithFormat:@"%d", socketId];
    return [_vcWithSocketId objectForKey:socketIdS];
}

- (void)refreshData:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(refreshData:)]) {
        [self.delegate performSelector:@selector(refreshData:)withObject:string];
    }
}

- (void)refreshDataWithAddress:(NSDictionary *)result {
    if ([self.delegate respondsToSelector:@selector(refreshDataWithAddress:)]) {
        [self.delegate performSelector:@selector(refreshDataWithAddress:)withObject:result];
    }
}

@end
