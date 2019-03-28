//
//  PlayerVideoController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/25.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "PlayerVideoController.h"
#import "ZJVideoPlayerView.h"
@interface PlayerVideoController ()
@property(strong,nonatomic) ZJVideoPlayerView * player;
@end

@implementation PlayerVideoController

- (ZJVideoPlayerView *)player{
    if (_player == nil) {
        _player =   [[ZJVideoPlayerView alloc]initWithUrl:[NSURL fileURLWithPath:self.path]  withSuperView:self.view frame:CGRectMake(0, 0, self.view.frame.size.width, 300) controller:self];
        
        _player.isRotatingSmallScreen = YES;
    }
    return _player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频播放";
   
    self.view.backgroundColor = [UIColor  whiteColor];

    [self.view addSubview:self.player];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}
- (BOOL)shouldAutorotate//是否支持旋转屏幕
{
    NSLog(@"PlayerVideoController:YES");
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
- (void)dealloc{
    
    [self.player deallocSelf];
    
    NSLog(@"%@",self.view);
    
    NSLog(@"销毁......");
    
}

@end
