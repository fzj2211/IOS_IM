//
//  ChatRoomViewController.m
//  YMChat
//
//  Created by 炎檬 on 16/8/22.
//  Copyright © 2016年 juangua. All rights reserved.
//

#import "ChatRoomViewController.h"
#import "ChatRoomTableViewCell.h"
#import "YMSocket.h"
#import "UserCellModel.h"
#import "YMManager.h"

#define TOOLBARTAG		200
#define TABLEVIEWTAG	300

@interface ChatRoomViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, YMManagerDelegate>

@property (nonatomic, strong) UITableView *chatTableView;
@property (nonatomic, strong) UITextField *messageTextField;
@property (nonatomic, strong) UIButton *sendMessageButton;
@property (nonatomic, strong) UIImageView *inputView;
@property (nonatomic, assign) NSString *message;
@property (nonatomic, strong) NSMutableArray <UserCellModel *> *userCellModel;

@end

@implementation ChatRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self registerForKeyboardNotifications];//键盘高度变化通知
    [YMManager sharedInstance].delegate = self;
    // Do any additional setup after loading the view.
}

- (void)setupViews {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.chatTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, FULL_FRAME.size.width, FULL_FRAME.size.height)];
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.chatTableView registerNib:[UINib nibWithNibName:[ChatRoomTableViewCell cellIdentifier] bundle:nil] forCellReuseIdentifier:[ChatRoomTableViewCell cellIdentifier]];
    [self.view addSubview:self.chatTableView];
    
    self.messageTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, FULL_FRAME.size.width - 100, 40)];
    self.messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.messageTextField.delegate = self;
    
    self.sendMessageButton = [[UIButton alloc]initWithFrame:CGRectMake(FULL_FRAME.size.width-80, 5, 50, 40)];
    [self.sendMessageButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendMessageButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchDown];
    
    self.inputView = [[UIImageView alloc]initWithFrame:CGRectMake(0, FULL_FRAME.size.height-50, FULL_FRAME.size.width, 50)];
    self.inputView.image = [UIImage imageNamed:@"input_back_image"];
    [self.inputView setUserInteractionEnabled:YES];
    [self.inputView addSubview:self.messageTextField];
    [self.inputView addSubview:self.sendMessageButton];
    [self.view addSubview:self.inputView];
    
    self.userCellModel = [NSMutableArray array];
}


- (void)sendMessage {
    dispatch_queue_t currentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak typeof (self) weakself = self;
    dispatch_async(currentQueue, ^{
        char *message = [weakself.messageTextField.text UTF8String];
        YMSocket *ymsocket = [[YMSocket alloc]init];
        [ymsocket sendBytes:message count: 1024 bySocket:weakself.socket];
    });
    UserCellModel *tempUserCellModel = [[UserCellModel alloc]initWithMessage:self.messageTextField.text isSelf:YES time:[self timeNow]];
    [self.userCellModel addObject:tempUserCellModel];
    [self.chatTableView reloadData];
}

- (void)refreshTableView:(NSNotification *)notification {
    NSDictionary *result = [notification object];
    UserCellModel *tempUserCellModel = [[UserCellModel alloc]initWithMessage:[result objectForKey:@"message"] isSelf:NO time:[self timeNow]];
    [self.userCellModel addObject:tempUserCellModel];
    [self.chatTableView reloadData];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.messageTextField resignFirstResponder];
}

#pragma mark TextField Delegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.messageTextField resignFirstResponder];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.messageTextField)
    {
        if (self.userCellModel.count > 5) {
            [self.chatTableView setFrame:CGRectMake(0, -(FULL_FRAME.size.height-self.inputView.frame.origin.y), FULL_FRAME.size.width, FULL_FRAME.size.height)];
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.userCellModel.count - 1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- 添加键盘高度监听
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark -- 键盘高度  （inputView就是随键盘弹出改变frame的视图）
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect beginKeyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y;
    
    CGRect inputFieldRect = self.inputView.frame;
    inputFieldRect.origin.y += yOffset;
    [UIView animateWithDuration:duration animations:^{
        self.inputView.frame = inputFieldRect;
        //tableView随inputView一起上移
        if (self.userCellModel.count > 5) {
            [self.chatTableView setFrame:CGRectMake(0, -(FULL_FRAME.size.height-inputFieldRect.origin.y), FULL_FRAME.size.width, FULL_FRAME.size.height)];
        }
    }];
}

#pragma mark table代理实现

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatRoomTableViewCell *cell = (ChatRoomTableViewCell *)[self tableView:self.chatTableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userCellModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatRoomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ChatRoomTableViewCell cellIdentifier]];
    if (self.userCellModel[indexPath.row].isSelf) {
        cell.selfMessageBubbleView.hidden = NO;
        cell.selfMessageLabel.hidden = NO;
        cell.otherMessageBubbleView.hidden = YES;
        cell.otherMessageLabel.hidden = YES;
        [cell setSelfMessage: self.userCellModel[indexPath.row].message time:self.userCellModel[indexPath.row].timeString];
    }else {
        cell.selfMessageBubbleView.hidden = YES;
        cell.selfMessageLabel.hidden = YES;
        cell.otherMessageBubbleView.hidden = NO;
        cell.otherMessageLabel.hidden = NO;
        [cell setOtherMessage: self.userCellModel[indexPath.row].message time:self.userCellModel[indexPath.row].timeString];
    }
    
    return cell;
}

#pragma mark 刷新数据

- (void)refreshData:(NSString *)string {
    __weak typeof (self) weakself = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UserCellModel *tempUserCellModel = [[UserCellModel alloc]initWithMessage:string isSelf:NO time:[self timeNow]];
        [weakself.userCellModel addObject:tempUserCellModel];
        [weakself.chatTableView reloadData];
    });
}

- (NSString *)timeNow {
    NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm"];
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSMutableString *timeString = [NSMutableString stringWithFormat:@"%@",[formatter stringFromDate:currentDate]];
    return timeString;
}

@end
