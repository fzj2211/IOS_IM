//
//  ViewController.m
//  ChatServer
//
//  Created by 炎檬 on 16/7/14.
//  Copyright © 2016年 炎檬. All rights reserved.
//

#import "ViewController.h"
#import "TextViewController.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *startBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [startBtn addTarget:self action:@selector(openButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    startBtn.center = self.view.center;
    startBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:startBtn];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)openButtonClicked {
    TextViewController *textVC = [[TextViewController alloc] init];
    //[self presentViewController:textVC animated:YES completion:nil];
    [self.navigationController pushViewController:textVC animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
