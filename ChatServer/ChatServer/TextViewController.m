//
//  TextViewController.m
//  ChatServer
//
//  Created by 炎檬 on 16/7/15.
//  Copyright © 2016年 炎檬. All rights reserved.
//

#import "TextViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface TextViewController ()

@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) UIButton *creatTCPSocketBtn;
@property(nonatomic, strong) UIButton *creatUDPSocketBtn;

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatBackgroundMode];
    [self setupViews];
    NSThread *socketThread = [[NSThread alloc]  initWithTarget:self selector:@selector(creatUDPSocket) object:nil];
    [socketThread start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = CGRectInset(self.view.frame, 50, 150);
    self.label = [[UILabel alloc]initWithFrame:rect];
    [self.label setNumberOfLines:0];
    self.label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:15];
    self.label.textColor = [UIColor blackColor];
    self.label.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.label];
    
}

- (void)showMessage:(NSString *)str{
    self.label.text = str;
}

//跑个空音频文件用来支持后台
- (void)creatBackgroundMode {
    //后台播放音频设置
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //播放背景音乐
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"wav"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
    
    // 创建播放器
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    [player setVolume:1];
    player.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
    [player play]; //播放
}

- (void)creatTCPSocket {
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
                NSLog(@"%@",str);
                if (count>0) {
                    [self performSelectorOnMainThread:@selector(showMessage:) withObject:str waitUntilDone:NO];
                }
            }
            close(peerfd);
            
        }
    }
}

- (void)creatUDPSocket {
    
//    // 绑定地址
//    struct sockaddr_in addrto;
//    bzero(&addrto, sizeof(struct sockaddr_in));
//    addrto.sin_family = AF_INET;
//    addrto.sin_addr.s_addr = htonl(INADDR_ANY);
//    addrto.sin_port = htons(17777);
//    
//    // 广播地址
//    struct sockaddr_in from;
//    bzero(&from, sizeof(struct sockaddr_in));
//    from.sin_family = AF_INET;
//    from.sin_addr.s_addr = htonl(INADDR_ANY);
//    from.sin_port = htons(17777);
//    
//    int sock = -1;
//    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1)
//    {
//        NSLog(@"socket error");
//        return;
//    }
//    
//    const int opt = 1;
//    //设置该套接字为广播类型，
//    int nb = 0;
//    nb = setsockopt(sock, SOL_SOCKET, SO_BROADCAST, (char *)&opt, sizeof(opt));
//    if(nb == -1)
//    {
//        NSLog(@"set socket error...");
//        return;
//    }
//    
//    if(bind(sock,(struct sockaddr *)&(addrto), sizeof(struct sockaddr_in)) == -1)
//    {
//        NSLog(@"bind error...");
//        perror("bind");
//        return;
//    }
//    
//    int len = sizeof(struct sockaddr_in);
//    char smsg[10] = {0};
//    
//    while(true)
//    {
//        //从广播地址接受消息
//        NSLog(@"prepare to receive UDP broadcast");
//        ssize_t ret = recvfrom(sock, smsg, sizeof(smsg), 0, (struct sockaddr*)&(from),(socklen_t*)&len);
//        perror("recvfrom");
//        NSString *str = [NSString stringWithCString:smsg encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
//        if (ret > 0) {
//            [self performSelectorOnMainThread:@selector(showMessage:) withObject:str waitUntilDone:NO];
//        }
//    }
    // 绑定地址
    struct sockaddr_in addrto;
    bzero(&addrto, sizeof(struct sockaddr_in));
    addrto.sin_family = AF_INET;
    addrto.sin_addr.s_addr = htonl(INADDR_ANY);
    addrto.sin_port = htons(17777);
    
    // 广播地址
    struct sockaddr_in from;
    bzero(&from, sizeof(struct sockaddr_in));
    from.sin_family = AF_INET;
    from.sin_addr.s_addr = htonl(INADDR_ANY);
    from.sin_port = htons(17777);
    
    int sock = -1;
    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1)
    {
        NSLog(@"socket error");
//        return false;
    }
    
    const int opt = 1;
    //设置该套接字为广播类型
    int nb = 0;
    nb = setsockopt(sock, SOL_SOCKET, SO_BROADCAST, (char *)&opt, sizeof(opt));
    if(nb == -1)
    {
        NSLog(@"set socket error...");
//        return false;
    }
    
    if(bind(sock,(struct sockaddr *)&(addrto), sizeof(struct sockaddr_in)) == -1)
    {
        NSLog(@"bind error...");
//        return false;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
