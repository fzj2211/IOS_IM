//
//  main.m
//  11111
//
//  Created by 炎檬 on 16/8/5.
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
        int s;                                     /*套接字文件描述符*/
        struct sockaddr_in to;                     /*接收方的地址信息*/
        ssize_t n;                                 /*发送到的数据长度*/
        char buf[10] = "yanmeng";                 /*发送数据缓冲区*/
        s = socket(AF_INET, SOCK_DGRAM, 0); /*初始化一个IPv4族的数据报套接字*/
        if (s == -1) {                             /*检查是否正常初始化socket*/
            perror("socket");
            exit(EXIT_FAILURE);
        }
        
        to.sin_family = AF_INET;                   /*协议族*/
        to.sin_port = htons(17777);                 /*本地端口*/
        //to.sin_addr.s_addr = inet_addr("10.1.4.227");
        to.sin_addr.s_addr = INADDR_BROADCAST;
        
        int opt = 1;
        int nb = 0;
        nb = setsockopt(s, SOL_SOCKET, SO_BROADCAST, (char *)&opt, sizeof(opt));
        if(nb == -1)
        {
            NSLog(@"set socket error...");
        }
        
        while (true) {
            sleep(1);
            n = sendto(s, buf, sizeof(buf), 0, (struct sockaddr*)&to, sizeof(to));
            /*将数据buff发送到主机to上*/
            if(n == -1){                       /*发送数据出错*/
                perror("sendto");
                exit(EXIT_FAILURE);
            }
            /*处理过程*/
            NSLog(@"链接UDP成功!");
        }

    }
    return 0;
}
