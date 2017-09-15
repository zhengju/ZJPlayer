//
//  ViewController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/6.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ViewController.h"
#import "ZJPlayer.h"
#import "Masonry.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    ZJPlayer * player = [[ZJPlayer alloc]initWithUrl:[NSURL URLWithString:@"http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4"]];
    player.tag = 1001;
    [self.view addSubview:player];
    
    [player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(64);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(300);
    }];

    UIButton * button = [[UIButton alloc]init];
    
    [button setBackgroundColor:[UIColor redColor]];
    
    [button bk_addEventHandler:^(id sender) {
    
        [player play];
        
    } forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(player.mas_bottom).offset(64);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.width.mas_equalTo(30);
    }];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"原始controller消失");
}
@end
