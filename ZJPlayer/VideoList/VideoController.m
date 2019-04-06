//
//  VideoController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "VideoController.h"
#import "ZJVideoPlayerView.h"
#import "VideoList.h"
@interface VideoController ()<ZJPlayerDelegate>
@property(strong,nonatomic) ZJVideoPlayerView* player;
@end

@implementation VideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"视频详情";
    
    self.player = [ZJVideoPlayerView sharePlayer];
    
    self.player.isPushOrPopPlpay = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.player.delegate = self;

    self.player.fatherView = self.view;

    
    self.player.url = [NSURL URLWithString:self.model.url];
    
    [self.player setPlayerFrame:CGRectMake(0, 0, kScreenWidth, 300)];

    NSLog(@"%@",self.player);
    
}

#pragma mark -- ZJPlayerDelegate
- (void)playFinishedPlayer:(ZJVideoPlayerView *)player{

}
- (BOOL)shouldAutorotate//是否支持旋转屏幕
{
    return NO;
    
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
