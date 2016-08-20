//
//  YMSocket.m
//  YMChat
//
//  Created by 炎檬 on 16/8/16.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "YMSocket.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet/tcp.h>
#import <arpa/inet.h>
#include <ifaddrs.h>

@interface YMSocket () {
@protected
    void *_buffer;
    long _size;
    long _timeout;
    int _segmentSize;
}
@end

@implementation YMSocket

- (id)initWithHost:(NSString *)host andPort:(NSString *)port {
    if((self = [super init]))
        {
            _sockfd = 0;
            _host = [host copy];
            _port = [port copy];
            _size = getpagesize();
            _buffer = valloc(_size);
        }
        return self;
}

- (id)initWithFileDescriptor:(int)fd {
    if ((self = [super init])) {
        _sockfd = fd;
        _size = getpagesize();
        _buffer = valloc(_size);
        
        
    }
    return self;
}

- (long)sendBytes:(const void *)buf count:(long)count {
    long sent = send(_sockfd, buf, count, 0);
    if (sent < 0) {
        _lastError = NEW_ERROR(errno, strerror(errno));
    }
    return sent;
}

- (long)receiveBytes:(void *)buf limit:(long)limit {
    long received = recv(_sockfd, buf, limit, 0);
    if (received < 0) {
        _lastError = NEW_ERROR(errno, strerror(errno));
    }
    return received;
}

- (long)receiveBytes:(void *)buf count:(long)count {
    long expected = count;
    while (expected>0) {
        long receive = [self receiveBytes:buf limit:expected];
        expected -= receive;
        buf += receive;
    }
    return (count - expected);
}

- (long)sendFile:(NSString *)path {
    int fd = 0;
    long sent = 0;
    @try {
        const char *cPath = [path fileSystemRepresentation];
        if ((fd = open(cPath, O_RDONLY)) < 0) {
            _lastError = NEW_ERROR(errno, strerror(errno));
            return -1;
        }
        if (fcntl(fd, F_NOCACHE, 1) < 0) {
            // Ignore because this will still work with disk caching on.
        }
        
        long count;
        while (1) {
            count = read(fd, _buffer, _size);
            if (count == 0) {
                break; // Reached end of file.
            }
            if (count < 0) {
                _lastError = NEW_ERROR(errno, strerror(errno));
                break;
            }
            if ([self sendBytes:_buffer count:count] < 0) {
                _lastError = NEW_ERROR(errno, strerror(errno));
                break;
            }
            sent += count;
        }
    }
    @finally {
        close(fd);
    }
    return sent;
}

#pragma mark 设置

- (long)timeout {
    if (_sockfd > 0) {
        struct timeval tv;
        if (getsockopt(_sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, &(socklen_t){sizeof(tv)}) < 0) {
            _lastError = NEW_ERROR(errno, strerror(errno));
            return NO;
        }
        _timeout = tv.tv_sec;
    }
    return _timeout;
}

- (BOOL)setTimeout:(long)seconds {
    if (_sockfd > 0) {
        struct timeval tv = {seconds, 0};
        if (setsockopt(_sockfd, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv)) < 0 || setsockopt(_sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0) {
            _lastError = NEW_ERROR(errno, strerror(errno));
            return NO;
        }
    }
    _timeout = seconds;
    return YES;
}

- (int)segmentSize {
    if (_sockfd > 0 && getsockopt(_sockfd, IPPROTO_TCP, TCP_MAXSEG, &_segmentSize, &(socklen_t){sizeof(_segmentSize)}) < 0) {
        _lastError = NEW_ERROR(errno, strerror(errno));
        return NO;
    }
    return _segmentSize;
}

- (BOOL)setSegmentSize:(int)bytes {
    if (_sockfd > 0 && setsockopt(_sockfd, IPPROTO_TCP, TCP_MAXSEG, &bytes, sizeof(bytes)) < 0) {
        _lastError = NEW_ERROR(errno, strerror(errno));
        return NO;
    }
    _segmentSize = bytes;
    return YES;
}

#pragma mark 最早的方法版本

- (BOOL)sendTCPConnectTo:(NSString *)address withMessage:(NSString *)message{
    int err;
    int fd=socket(AF_INET, SOCK_STREAM, 0);
    BOOL success=(fd!=-1);
    struct sockaddr_in addr;
    
    if (success) {
        struct sockaddr_in peeraddr;
        //初始化地址
        memset(&peeraddr, 0, sizeof(peeraddr));
        peeraddr.sin_len=sizeof(peeraddr);
        peeraddr.sin_family=PF_INET;
        peeraddr.sin_port=htons(YM_TCP_PORT);
        //这个地址是服务器的地址，
        peeraddr.sin_addr.s_addr=inet_addr([address UTF8String]);
        socklen_t addrLen;
        addrLen =sizeof(peeraddr);
        NSLog(@"connecting");
        err=connect(fd, (struct sockaddr *)&peeraddr, addrLen);
        success=(err==0);
        perror("err");
        if (success) {
            //                struct sockaddr_in addr;
            err =getsockname(fd, (struct sockaddr *)&addr, &addrLen);
            success=(err==0);
            if (success) {
                NSLog(@"connect success,local address:%s,port:%d",inet_ntoa(addr.sin_addr),ntohs(addr.sin_port));
                send(fd, [message UTF8String], 1024, 0);
            }
        }
        else{
            NSLog(@"connect failed");
            return NO;
        }
    } else{
        NSLog(@"创建socket失败!");
        return NO;
    }
    
    return YES;
}

- (void)listenWithBlock:(connectBlock)block {
    int err;
    int fd = socket(PF_INET, SOCK_STREAM, 0);
    BOOL success = (!(fd == -1));
    
    if (success)
    {
        NSLog(@"socket success!");
        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));//初始化socket
        addr.sin_len=sizeof(addr);//socket字节长度
        addr.sin_family=PF_INET;  //协议族
        addr.sin_port=htons(YM_TCP_PORT); //端口
        addr.sin_addr.s_addr=INADDR_ANY; //设定地址为 所有地址 本地网卡：回环网卡，。。。 无线网卡
        err=bind(fd, (const struct sockaddr *)&addr, sizeof(addr));
        success=(err==0);
    }
    //   2
    //
    if (success) {
        NSLog(@"bind(绑定) success");
        err=listen(fd, 1);//开始监听
        success=(err==0);
    }
    //3
    // 每个客户端连接服务器后，服务器都会分配一个端口给客户端，然后服务器继续在设定的端口上继续等待。
    if (success) {
        NSLog(@"listen success");
        while (true) {
            struct sockaddr_in peeraddr;
            int peerfd;
            socklen_t addrLen;
            
            addrLen=sizeof(peeraddr);
            NSLog(@"prepare accept");
            //获得服务器和当前连接客户端通信的专用socket。
            peerfd=accept(fd, (struct sockaddr *)&peeraddr, &addrLen);
            success=(peerfd!=-1);
            if (success) {
                NSLog(@"accept success,remote address:%s,port:%d",inet_ntoa(peeraddr.sin_addr),ntohs(peeraddr.sin_port));
                char buf[1024];
                ssize_t count;
                size_t len=sizeof(buf);
                NSString *str = @"";
                count=recv(peerfd, buf, len, 0);
                str = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                block(str);
                NSLog(@"%@",str);
            }
        }
    }
}

- (BOOL)sendBroadcast {
    int s;                                     /*套接字文件描述符*/
    struct sockaddr_in to;                     /*接收方的地址信息*/
    ssize_t n;                                 /*发送到的数据长度*/
    char buf[10] = "Hello";
    s = socket(AF_INET, SOCK_DGRAM, 0); /*初始化一个IPv4族的数据报套接字*/
    if (s == -1) {                             /*检查是否正常初始化socket*/
        perror("socket");
        return NO;
    }
    
    to.sin_family = AF_INET;                   /*协议族*/
    to.sin_port = htons(YM_BROADCAST_PORT);                 /*本地端口*/
    to.sin_addr.s_addr = inet_addr(YM_GROUP);
    
    int opt = 1;
    int nb = 0;
    nb = setsockopt(s, SOL_SOCKET, SO_BROADCAST, (char *)&opt, sizeof(opt));
    if(nb == -1)
    {
        NSLog(@"set socket error...");
        return NO;
    }
    
    n = sendto(s, buf, sizeof(buf), 0, (struct sockaddr*)&to, sizeof(to));
    if(n == -1){                       /*发送数据出错*/
        perror("sendto");
        return NO;
    }
    NSLog(@"发送搜寻组播成功!");
    close(s);
    return YES;
}

- (void)listenBroadcastWithBlock:(listenBlock)block {
    struct sockaddr_in addr;
    int addrlen, sock;
    ssize_t cnt;
    struct ip_mreq mreq;
    char message[1024];
    
    /* set up socket */
    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("socket");
        exit(1);
    }
    bzero((char *)&addr, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(YM_BROADCAST_PORT);
    addrlen = sizeof(addr);
    
    /* receive */
    if (bind(sock, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
        perror("bind");
        exit(1);
    }
    mreq.imr_multiaddr.s_addr = inet_addr(YM_GROUP);
    mreq.imr_interface.s_addr = htonl(INADDR_ANY);
    if (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP,
                   &mreq, sizeof(mreq)) < 0) {
        perror("setsockopt mreq");
        exit(1);
    }
    while (1) {
        cnt = recvfrom(sock, message, sizeof(message), 0, (struct sockaddr *) &addr, (socklen_t *)&addrlen);
        if (cnt < 0) {
            perror("recvfrom");
            exit(1);
        } else if (cnt == 0) {
            break;
        }
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:[NSString stringWithCString:message encoding:NSUTF8StringEncoding] forKey:@"message"];
        [result setObject:[NSString stringWithCString:inet_ntoa(addr.sin_addr) encoding:NSUTF8StringEncoding] forKey:@"address"];
        if ([[self getIPAddress] compare:[NSString stringWithCString:inet_ntoa(addr.sin_addr) encoding:NSUTF8StringEncoding]] == NSOrderedSame) {
            continue;
        }
        block(result);
        printf("%s: message = \"%s\"\n", inet_ntoa(addr.sin_addr), message);
    }
}
//获取本机IP
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}
//NSString转char

@end

