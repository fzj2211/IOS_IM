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
@property(nonatomic, strong) UITextField *inputText;
@property(nonatomic, strong) UITextView *inputView;
@property(nonatomic, strong) NSString *textMessage;

@property(nonatomic, assign) struct sockaddr_in peeraddr;
@property(nonatomic, assign) int fd;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatSocket];
    [self setupViews];
//    NSThread *connectThread = [[NSThread alloc] initWithTarget:self selector:@selector(creatSocket) object:nil];
//    [connectThread start];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupViews {
    self.inputView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, FULLFRAME.size.width - 100.f, 300.f)];
    self.inputView.center = self.view.center;
    self.inputView.backgroundColor =[UIColor greenColor];
    [self.view addSubview:self.inputView];
    
    self.sendButton = [[UIButton alloc]initWithFrame:CGRectMake(self.inputView.center.x-50, self.inputView.frame.origin.y + 310, 100, 50)];
    [self.sendButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.tintColor = [UIColor blackColor];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.sendButton];
    
}
- (void) test {
    dispatch_queue_t queue = dispatch_get_main_queue();
    for (int i = 0; i < 10; ++i) {
        dispatch_async(queue, ^{
            NSLog(@"%@ %d", [NSThread currentThread],i);
        });
    }
}

- (void)sendButtonClicked {
    self.textMessage = self.inputView.text;
    //[self creatSocket];
    NSThread *connectThread = [[NSThread alloc] initWithTarget:self selector:@selector(connectToServer) object:nil];
    [connectThread start];
}

- (void)creatSocket {
        _fd=socket(AF_INET, SOCK_STREAM, 0);
        BOOL success=(_fd!=-1);
//        struct sockaddr_in addr;

        if (success) {
            //struct sockaddr_in peeraddr;
            //初始化地址
            memset(&_peeraddr, 0, sizeof(_peeraddr));
            _peeraddr.sin_len=sizeof(_peeraddr);
            _peeraddr.sin_family=PF_INET;
            _peeraddr.sin_port=htons(17777);
            //这个地址是服务器的地址，
            _peeraddr.sin_addr.s_addr=inet_addr("10.1.5.113");
//            socklen_t addrLen;
//            addrLen =sizeof(peeraddr);
//            NSLog(@"connecting");
//            err=connect(fd, (struct sockaddr *)&peeraddr, addrLen);
//            success=(err==0);
//            if (success) {
//                //                struct sockaddr_in addr;
//                err =getsockname(fd, (struct sockaddr *)&addr, &addrLen);
//                success=(err==0);
//                if (success) {
//                    NSLog(@"connect success,local address:%s,port:%d",inet_ntoa(addr.sin_addr),ntohs(addr.sin_port));
//                    NSUInteger length = [self.textMessage length];
//                    char buf[1024] = {0};
//                    
//                    [self.textMessage  getBytes:buf
//                                      maxLength:(1024 - 1)
//                                     usedLength:NULL
//                                       encoding:NSUTF8StringEncoding
//                                        options:0
//                                          range:NSMakeRange(0, length)
//                                 remainingRange:NULL];
//                    
//                    while (true) {
//                        sleep(1);
//                        ssize_t flag = send(fd, buf, 1024, 0);
//                        NSLog(@"%lu", flag);
//                    }
//                }
//            }
//            else{
//                NSLog(@"connect failed");
//            }
        } else{
            NSLog(@"创建socket失败!");
        }
}

- (void)connectToServer {
    int err;
    socklen_t addrLen;
    struct sockaddr_in addr;
    addrLen =sizeof(_peeraddr);
    NSLog(@"connecting");
    err=connect(_fd, (struct sockaddr *)&_peeraddr, addrLen);
    BOOL success=(err==0);
    if (success) {
        //                struct sockaddr_in addr;
        err =getsockname(_fd, (struct sockaddr *)&addr, &addrLen);
        success=(err==0);
        if (success) {
            [self performSelectorOnMainThread:@selector(sendMessage) withObject:nil waitUntilDone:NO];
//            NSLog(@"connect success,local address:%s,port:%d",inet_ntoa(addr.sin_addr),ntohs(addr.sin_port));
//            NSUInteger length = [self.textMessage length];
//            char buf[1024] = {0};
//            [self.textMessage  getBytes:buf
//                              maxLength:(1024 - 1)
//                             usedLength:NULL
//                               encoding:NSUTF8StringEncoding
//                                options:0
//                                  range:NSMakeRange(0, length)
//                         remainingRange:NULL];
//            send(_fd, buf, 1024, 0);
        }
    }
    else{
        NSLog(@"connect failed");
    }
}

- (void)sendMessage {
    //NSLog(@"connect success,local address:%s,port:%d",inet_ntoa(addr.sin_addr),ntohs(addr.sin_port));
    NSUInteger length = [self.textMessage length];
    char buf[1024] = {0};
    [self.textMessage  getBytes:buf
                      maxLength:(1024 - 1)
                     usedLength:NULL
                       encoding:NSUTF8StringEncoding
                        options:0
                          range:NSMakeRange(0, length)
                 remainingRange:NULL];
    send(_fd, buf, 1024, 0);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
