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

    // http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4
    ZJPlayer * player = [[ZJPlayer alloc]initWithUrl:[NSURL URLWithString:@"http://baobab.wdjcdn.com/14564977406580.mp4"]];

    [self.view addSubview:player];
    
    [player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(64);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(300);
    }];
    
}
@end
