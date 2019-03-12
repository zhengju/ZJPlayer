//
//  VideoController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "VideoController.h"
#import "ZJPlayer.h"
#import "VideoList.h"
@interface VideoController ()<ZJPlayerDelegate>
@property(strong,nonatomic) ZJPlayer* player;
@end

@implementation VideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [ZJPlayer sharePlayer];
    self.player.isPushOrPopPlpay = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    [self.player removeFromSuperview];
    
    self.player.delegate = nil;
    
    self.player.delegate = self;
    
    [self.view addSubview:self.player];
    
    self.player.fatherView = self.view;
    
//    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.view).offset(0);
//        make.left.mas_equalTo(self.view);
//        make.right.mas_equalTo(self.view);
//        make.height.mas_equalTo(260);
//    }];
    
    self.player.frame = CGRectMake(0, 0, kScreenWidth, 300);
    
    NSLog(@"%@",self.player);
    
}

#pragma mark -- ZJPlayerDelegate
- (void)playFinishedPlayer:(ZJPlayer *)player{

}
- (BOOL)shouldAutorotate//是否支持旋转屏幕
{
    NSLog(@":YES");
    return YES;
    
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations//支持哪些方向
{
    return UIInterfaceOrientationMaskAll;
    
}
//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation//默认显示的方向
{
    
    return UIInterfaceOrientationPortrait;
    
}
@end
