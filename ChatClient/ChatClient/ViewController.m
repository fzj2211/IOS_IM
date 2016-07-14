//
//  ViewController.m
//  ChatClient
//
//  Created by 炎檬 on 16/7/14.
//  Copyright © 2016年 炎檬. All rights reserved.
//

#import "ViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatSocket];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)creatSocket {
        int err;
        int fd=socket(AF_INET, SOCK_STREAM, 0);
        BOOL success=(fd!=-1);
        struct sockaddr_in addr;
        
        if (success) {
            struct sockaddr_in peeraddr;
            memset(&peeraddr, 0, sizeof(peeraddr));
            peeraddr.sin_len=sizeof(peeraddr);
            peeraddr.sin_family=PF_INET;
            peeraddr.sin_port=htons(17777);
            //peeraddr.sin_addr.s_addr=INADDR_ANY;
            peeraddr.sin_addr.s_addr=inet_addr("10.1.5.113");
            //            这个地址是服务器的地址，
            socklen_t addrLen;
            addrLen =sizeof(peeraddr);
            NSLog(@"connecting");
            err=connect(fd, (struct sockaddr *)&peeraddr, addrLen);
            success=(err==0);
            if (success) {
                //                struct sockaddr_in addr;
                err =getsockname(fd, (struct sockaddr *)&addr, &addrLen);
                success=(err==0);
                if (success) {
                    NSLog(@"connect success,local address:%s,port:%d",inet_ntoa(addr.sin_addr),ntohs(addr.sin_port));
                    char buf[1024] = "yanmeng!";
                    do {
                        printf("input message:");
                        scanf("%s",buf);
                        send(fd, buf, 1024, 0);
                    } while (strcmp(buf, "exit")!=0);
                }
            }
            else{
                NSLog(@"connect failed");
            }
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
