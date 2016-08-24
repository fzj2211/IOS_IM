//
//  ViewController.m
//  YMChat
//
//  Created by 炎檬 on 16/8/16.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "ViewController.h"
#import "YMSocket.h"
#import "SCLAlertView.h"
#import "ChatFriendModel.h"
#import "YMChatTableViewCell.h"
#import "ChatRoomViewController.h"
#import "YMManager.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, YMManagerDelegate>

@property(nonatomic, strong) NSMutableArray <ChatFriendModel *> *friendModelArray;

@property(nonatomic, strong) UITableView *tableView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self startListenBroadcast];
    [self startListen];
    [YMManager sharedInstance].delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupViews {
    self.navigationItem.title = @"好友列表";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, FULL_FRAME.size.width, FULL_FRAME.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:[YMChatTableViewCell cellIdentifier] bundle:nil]
         forCellReuseIdentifier:[YMChatTableViewCell cellIdentifier]];
    [self.view addSubview:self.tableView];
    
    UIButton *sendBroadcastButton = [[UIButton alloc]initWithFrame:CGRectMake((FULL_FRAME.size.width - 100)/2, FULL_FRAME.size.height - 120, 100, 100)];
    [sendBroadcastButton setImage:[UIImage imageNamed:@"send_button"] forState:UIControlStateNormal];
    [sendBroadcastButton addTarget:self action:@selector(sendBroadcast) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:sendBroadcastButton];
    
    self.friendModelArray = [NSMutableArray array];
}

- (void)sendBroadcast {
    YMSocket *ymsocket = [YMSocket alloc];
    BOOL success = [ymsocket sendBroadcastWithUserName:[[UIDevice currentDevice] name]];
    NSLog(@"%@", [[UIDevice currentDevice] name]);
    if (!success) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showNotice:@"提示信息" subTitle:@"发送失败!" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showNotice:@"提示信息" subTitle:@"发送成功!" closeButtonTitle:@"确定" duration:0.0f];
//    [self listenResponse];
}
//监听组播一直存在
- (void)startListenBroadcast {
    dispatch_queue_t currentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(currentQueue, ^{
        YMSocket *ymsocket = [YMSocket alloc];
        __weak typeof(self) weakself = self;
        [ymsocket listenBroadcastWithBlock:^(NSDictionary *result) {
            [weakself performSelectorOnMainThread:@selector(broadcastListenSuccessWithResult:) withObject:result waitUntilDone:NO];
        }];
    });
}

- (void)startListen {
    dispatch_queue_t currentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(currentQueue, ^{
        YMSocket *ymsocket = [YMSocket alloc];
        [ymsocket listen];
         });
}

- (void)broadcastListenSuccessWithResult:(NSDictionary *)result {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    __weak typeof(self) weakself = self;
    [alert addButton:@"接受" actionBlock:^{
        [weakself comfirmConnectWithResult:result];
    }];
    [alert showNotice:@"提示信息" subTitle:@"发现连接请求" closeButtonTitle:@"关闭" duration:0.0f];
}

- (void)comfirmConnectWithResult:(NSDictionary *)result {

    YMSocket *ymsocket = [YMSocket alloc];
    NSString *messageWithType = @"1";
    messageWithType = [messageWithType stringByAppendingString:[[UIDevice currentDevice] name]];
    int peerfd = [ymsocket sendTo:[result objectForKey:@"address"] withMessage:messageWithType];
    if (peerfd == -1) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showNotice:@"提示信息" subTitle:@"发送回执失败!" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showNotice:@"提示信息" subTitle:@"发送回执成功!" closeButtonTitle:@"确定" duration:0.0f];
    [[YMManager sharedInstance] registerVCWithSocketId:peerfd];
    NSLog(@"发送返回的socket:%d", peerfd);
    [ymsocket dispatchReceiveOperationWithSocket:peerfd andAddress:nil];
    ChatFriendModel *tempfriendModel = [[ChatFriendModel alloc]initWithUserName:[result objectForKey:@"userName"] address:[result objectForKey:@"address"] socketInfo:peerfd];
    [self.friendModelArray addObject:tempfriendModel];
    [self.tableView reloadData];
}

- (void)toChatAt:(NSIndexPath *)indexpath {
    ChatRoomViewController *chatRoomVC = [[YMManager sharedInstance] getRootVCById:self.friendModelArray[indexpath.row].peerfd];
    NSLog(@"点击的cell的socket:%d", self.friendModelArray[indexpath.row].peerfd);
    [self.navigationController pushViewController:chatRoomVC animated:YES];
}

//- (void)refreshTableView:(NSNotification *)notification {
//    NSDictionary *result = [notification object];
//    ChatFriendModel *tempfriendModel = [[ChatFriendModel alloc]initWithUserName:[result objectForKey:@"message"] andAddress:[result objectForKey:@"address"]];
//    [self.friendModelArray addObject:tempfriendModel];
//    [self.tableView reloadData];
//}

//- (void)listenResponse {
//    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(concurrentQueue, ^{
//        YMSocket *ymsocket = [YMSocket alloc];
//        __weak typeof(self) weakself = self;
//        [ymsocket listenWithBlock:^(NSString *message) {
//            [weakself performSelectorOnMainThread:@selector(receiveResponseSuccess:) withObject:message waitUntilDone:NO];
//        }];
//    });
//}

//- (void)receiveResponseSuccess:(NSDictionary *)result{
//    
//}

#pragma mark tableview代理实现

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YMChatTableViewCell *cell = [YMChatTableViewCell dequeueReusableCellForTableView:tableView];
    if (indexPath.row <= self.friendModelArray.count) {
        [cell setUserName:self.friendModelArray[indexPath.row].userName];
        [cell setAddr:self.friendModelArray[indexPath.row].address];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YMChatTableViewCell *cell = (YMChatTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self toChatAt:indexPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 刷新数据

- (void)refreshDataWithAddress:(NSDictionary *)result {
    __weak typeof (self) weakself = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        ChatFriendModel *tempfriendModel = [[ChatFriendModel alloc]initWithUserName:[result objectForKey:@"message"] address:[result objectForKey:@"address"] socketInfo:[[result objectForKey:@"socket"] intValue]];
        NSLog(@"当前socket:%d", [[result objectForKey:@"socket"] intValue]);
        [weakself.friendModelArray addObject:tempfriendModel];
        [weakself.tableView reloadData];
    });
}

@end
