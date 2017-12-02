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
#import "ZJDownloadManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backBtn.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];

//    ZJPlayer * player =  [[ZJPlayer alloc]initWithUrl:[NSURL URLWithString:@"http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4"]];
//
//    player.isRotatingSmallScreen = YES;
//
//    [self.view addSubview:player];
//
//    [player mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.view.mas_top).offset(64);
//        make.left.mas_equalTo(self.view);
//        make.right.mas_equalTo(self.view);
//        make.height.mas_equalTo(300);
//    }];


    UIButton * button = [[UIButton alloc]init];

    [button setBackgroundColor:[UIColor redColor]];

    [button bk_addEventHandler:^(id sender) {
        

    } forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button];

    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(64);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.width.mas_equalTo(30);
    }];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"原始controller消失");
}
//Interface的方向是否会跟随设备方向自动旋转，如果返回NO,后两个方法不会再调用
- (BOOL)shouldAutorotate {
    return YES;
}
//返回直接支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end
