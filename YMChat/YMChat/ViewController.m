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
#import "UserCellModel.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) ChatFriendModel *friendModel;

@property(nonatomic, strong) NSMutableArray <UserCellModel *> *userCellModel;

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self startListenBroadcast];
    [self startListen];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupViews {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, FULL_FRAME.size.width, FULL_FRAME.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UIImageView *headerView= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, FULL_FRAME.size.width, 60)];
    headerView.image = [UIImage imageNamed:@"home_header"];
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:headerView.frame];
    headerLabel.text = @"好友列表";
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:headerLabel];
    self.tableView.tableHeaderView = headerView;
    [self.tableView registerNib:[UINib nibWithNibName:[YMChatTableViewCell cellIdentifier] bundle:nil]
         forCellReuseIdentifier:[YMChatTableViewCell cellIdentifier]];
    [self.view addSubview:self.tableView];
    //伪数据
    self.userCellModel = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 50; i++) {
        self.userCellModel[i] = [[UserCellModel alloc]initWithUserName:[NSString stringWithFormat:@"二狗子%d号",i] andAddress:[NSString stringWithFormat:@"250.250.250.25%d",i]];
    }
    
    UIButton *sendBroadcastButton = [[UIButton alloc]initWithFrame:CGRectMake((FULL_FRAME.size.width - 100)/2, FULL_FRAME.size.height - 120, 100, 100)];
    [sendBroadcastButton setImage:[UIImage imageNamed:@"send_button"] forState:UIControlStateNormal];
    [sendBroadcastButton addTarget:self action:@selector(sendBroadcast) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:sendBroadcastButton];
    
    self.friendModel = [ChatFriendModel alloc];
    
}

- (void)sendBroadcast {
    YMSocket *ymsocket = [YMSocket alloc];
    BOOL success = [ymsocket sendBroadcast];
    if (!success) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showNotice:@"提示信息" subTitle:@"发送失败!" closeButtonTitle:@"确定" duration:1.0f];
        return;
    }
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showNotice:@"提示信息" subTitle:@"发送成功!" closeButtonTitle:@"确定" duration:1.0f];
    [self listenResponse];
}

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
        __weak typeof(self) weakself = self;
        [ymsocket listenWithBlock:^(NSString *message) {
            [weakself performSelectorOnMainThread:@selector(receiveResponseSuccess:) withObject:message waitUntilDone:NO];
        }];
    });
}

- (void)broadcastListenSuccessWithResult:(NSDictionary *)result {
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    [alert addButton:@"接受" target:self selector:@selector(comfirmConnect)];
    [alert showNotice:@"提示信息" subTitle:@"发现连接请求" closeButtonTitle:@"关闭" duration:0.0f];
    
    self.friendModel.message = [result objectForKey:@"message"];
    self.friendModel.address = [result objectForKey:@"address"];
    [self.tableView reloadData];
}

- (void)comfirmConnect {
    YMSocket *ymsocket = [YMSocket alloc];
    BOOL success = [ymsocket sendTCPConnectTo:self.friendModel.address withMessage:@"来啊 互相伤害!"];
    if (!success) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showNotice:@"提示信息" subTitle:@"发送确认消息失败!" closeButtonTitle:@"确定" duration:1.0f];
        return;
    }
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert showNotice:@"提示信息" subTitle:@"发送确认消息成功!" closeButtonTitle:@"确定" duration:1.0f];
    [self listenResponse];
}

- (void)listenResponse {
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        YMSocket *ymsocket = [YMSocket alloc];
        __weak typeof(self) weakself = self;
        [ymsocket listenWithBlock:^(NSString *message) {
            [weakself performSelectorOnMainThread:@selector(receiveResponseSuccess:) withObject:message waitUntilDone:NO];
        }];
    });
}

- (void)receiveResponseSuccess:(NSString *)message{
    SCLAlertView *alert = [[SCLAlertView alloc]initWithNewWindow];
    [alert showNotice:@"提示信息" subTitle:message closeButtonTitle:@"关闭" duration:0.0f];
}

#pragma mark tableview代理实现

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userCellModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YMChatTableViewCell *cell = [YMChatTableViewCell dequeueReusableCellForTableView:tableView];
    if (indexPath.row <= self.userCellModel.count) {
        [cell setUserName:self.userCellModel[indexPath.row].userName];
        [cell setAddr:self.userCellModel[indexPath.row].address];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YMChatTableViewCell *cell = (YMChatTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
