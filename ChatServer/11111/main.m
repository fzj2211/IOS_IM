//
//  main.m
//  11111
//
//  Created by 炎檬 on 16/8/4.
//  Copyright © 2016年 炎檬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
//        setvbuf(stdout, NULL, _IONBF, 0);
//        fflush(stdout);
        
        // 绑定地址
        struct sockaddr_in addrto;
        bzero(&addrto, sizeof(struct sockaddr_in));
        addrto.sin_len = sizeof(struct sockaddr_in);
        addrto.sin_family = AF_INET;
        addrto.sin_addr.s_addr = htonl(INADDR_ANY);
        addrto.sin_port = htons(17777);
        
        // 广播地址
        struct sockaddr_in from;
        from.sin_len = sizeof(struct sockaddr_in);
        bzero(&from, sizeof(struct sockaddr_in));
        from.sin_family = AF_INET;
        from.sin_addr.s_addr = htonl(INADDR_ANY);
        from.sin_port = htons(17777);
        
        int sock = -1;
        if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1)
        {
            NSLog(@"socket error");
            return false;
        }
//        
//        const int opt = 1;
//        //设置该套接字为广播类型
//        int nb = 0;
//        nb = setsockopt(sock, SOL_SOCKET, SO_BROADCAST, (char *)&opt, sizeof(opt));
//        if(nb == -1)
//        {
//            NSLog(@"set socket error...");
//            return false;
//        }
        
        if(bind(sock,(struct sockaddr *)&(addrto), sizeof(struct sockaddr_in)) == -1)
        {
            NSLog(@"bind error...");
            return false;
        }
        
        int len = sizeof(struct sockaddr_in);
        char smsg[10] = {0};
        
        while(true)
        {
            //从广播地址接受消息
            recvfrom(sock, smsg, sizeof(smsg), 0, (struct sockaddr*)&(from),(socklen_t*)&len);
            NSString *str = [NSString stringWithCString:smsg encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str);
        }
    }
    return 0;
}
