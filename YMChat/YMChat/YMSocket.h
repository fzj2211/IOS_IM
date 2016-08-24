//
//  YMSocket.h
//  YMChat
//
//  Created by 炎檬 on 16/8/16.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import <Foundation/Foundation.h>
#define YM_BROADCAST_PORT 11111
#define YM_TCP_PORT 22222
#define YM_GROUP "224.0.0.100"
#define NEW_ERROR(num, str) [[NSError alloc] initWithDomain:@"FastSocketErrorDomain" code:(num) userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%s", (str)] forKey:NSLocalizedDescriptionKey]]

typedef void (^listenBlock)(NSDictionary *result);
typedef void (^connectBlock)(NSDictionary *result);

@interface YMSocket : NSObject

#pragma mark - Properties

@property (nonatomic, readonly) int sockfd;

@property (nonatomic, readonly) NSString *host;

@property (nonatomic, readonly) NSString *port;

@property (nonatomic, readonly) NSError *lastError;

- (id)initWithHost:(NSString *)host andPort:(NSString *)port;

- (id)initWithFileDescriptor:(int)fd;

- (long)sendBytes:(const void *)buf count:(long)count;

- (long)sendBytes:(const void *)buf count:(long)count bySocket:(int)socket;

- (long)receiveBytes:(void *)buf limit:(long)limit;

- (long)receiveBytes:(void *)buf count:(long)count;

- (long)sendFile:(NSString *)path;

- (long)timeout;

- (BOOL)setTimeout:(long)seconds;

- (int)segmentSize;

- (BOOL)setSegmentSize:(int)bytes;

- (int)socketInfo;



- (int)sendTo:(NSString *)addr withMessage:(NSString *)message;

- (void)listen;

- (BOOL)sendBroadcastWithUserName:(NSString *)userName;

- (void)listenBroadcastWithBlock:(listenBlock)block;

- (void)dispatchReceiveOperationWithSocket:(int)peerfd andAddress:(NSString *)address;

@end
