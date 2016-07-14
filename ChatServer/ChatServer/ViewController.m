//
//  ViewController.m
//  ChatServer
//
//  Created by 炎檬 on 16/7/14.
//  Copyright © 2016年 炎檬. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self creatSocket];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupViews {
    
}

- (void)creatSocket {
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
        addr.sin_port=htons(17777); //端口
        addr.sin_addr.s_addr=INADDR_ANY; //设定地址为 所有地址 本地网卡：回环网卡，。。。 无线网卡
        err=bind(fd, (const struct sockaddr *)&addr, sizeof(addr));
        success=(err==0);
    }
    //   2
    //
    if (success) {
        NSLog(@"bind(绑定) success");
        err=listen(fd, 5);//开始监听
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
                do {
                    count=recv(peerfd, buf, len, 0);
                    NSString* str = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    NSLog(@"%@",str);
                } while (strcmp(buf, "exit")!=0);
            }
            close(peerfd);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
