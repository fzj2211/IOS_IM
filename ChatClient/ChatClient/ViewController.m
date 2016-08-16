//
//  ViewController.m
//  ChatClient
//
//  Created by 炎檬 on 16/7/14.
//  Copyright © 2016年 炎檬. All rights reserved.
//

#import "ViewController.h"
#import "NSString+stringChange.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define FULLFRAME self.view.frame

@interface ViewController ()

@property(nonatomic, strong) UIButton *sendButton;
@property(nonatomic, strong) UIButton *broadcastButton;
@property(nonatomic, strong) UITextView *inputView;
@property(nonatomic, strong) NSString *textMessage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupViews {
    self.inputView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, FULLFRAME.size.width - 100.f, 300.f)];
    self.inputView.center = self.view.center;
    self.inputView.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:15];
    self.inputView.backgroundColor =[UIColor greenColor];
    [self.view addSubview:self.inputView];
    
    self.sendButton = [[UIButton alloc]initWithFrame:CGRectMake(self.inputView.center.x-50, self.inputView.frame.origin.y + 310, 100, 50)];
    [self.sendButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.tintColor = [UIColor blackColor];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.sendButton];
    
    self.broadcastButton = [[UIButton alloc]initWithFrame:CGRectMake(self.inputView.center.x-50, self.inputView.frame.origin.y - 70, 100, 60)];
    [self.broadcastButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.broadcastButton.tintColor = [UIColor blackColor];
    [self.broadcastButton setTitle:@"发送广播" forState:UIControlStateNormal];
    self.broadcastButton.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.broadcastButton];
    
}

- (void)sendButtonClicked {
    self.textMessage = self.inputView.text;
    [self creatUDPSocket];
}

- (void)creatTCPSocket {
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
        peeraddr.sin_port=htons(YM_PORT);
        //这个地址是服务器的地址，
        peeraddr.sin_addr.s_addr=inet_addr("10.1.5.113");
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
                NSUInteger length = [self.textMessage length];
                char buf[1024] = {0};
                
                [self.textMessage  getBytes:buf
                                  maxLength:(1024 - 1)
                                 usedLength:NULL
                                   encoding:NSUTF8StringEncoding
                                    options:0
                                      range:NSMakeRange(0, length)
                             remainingRange:NULL];
                
                send(fd, buf, 1024, 0);
            }
        }
        else{
            NSLog(@"connect failed");
        }
    } else{
        NSLog(@"创建socket失败!");
    }
}

- (void)startUDPConnect {
    NSThread *socketThread = [[NSThread alloc]  initWithTarget:self selector:@selector(creatUDPSocket) object:nil];
    [socketThread start];
}

- (void)creatUDPSocket {
    int s;                                     /*套接字文件描述符*/
    struct sockaddr_in to;                     /*接收方的地址信息*/
    ssize_t n;                                 /*发送到的数据长度*/
    NSUInteger length = [self.textMessage length];
    char buf[1024] = {0};
    
    [self.textMessage  getBytes:buf
                      maxLength:(1024 - 1)
                     usedLength:NULL
                       encoding:NSUTF8StringEncoding
                        options:0
                          range:NSMakeRange(0, length)
                 remainingRange:NULL];                 /*发送数据缓冲区*/
    s = socket(AF_INET, SOCK_DGRAM, 0); /*初始化一个IPv4族的数据报套接字*/
    if (s == -1) {                             /*检查是否正常初始化socket*/
        perror("socket");
        exit(EXIT_FAILURE);
    }
    
    to.sin_family = AF_INET;                   /*协议族*/
    to.sin_port = htons(YM_PORT);                 /*本地端口*/
    to.sin_addr.s_addr = inet_addr(YM_GROUP);
    
    int opt = 1;
    int nb = 0;
    nb = setsockopt(s, SOL_SOCKET, SO_BROADCAST, (char *)&opt, sizeof(opt));
    if(nb == -1)
    {
        NSLog(@"set socket error...");
    }
    
        n = sendto(s, buf, sizeof(buf), 0, (struct sockaddr*)&to, sizeof(to));
        /*将数据buff发送到主机to上*/
        if(n == -1){                       /*发送数据出错*/
            perror("sendto");
            exit(EXIT_FAILURE);
        }
        /*处理过程*/
        NSLog(@"链接UDP成功!");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.inputView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
