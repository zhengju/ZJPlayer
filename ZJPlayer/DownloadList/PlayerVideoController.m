//
//  PlayerVideoController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/25.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "PlayerVideoController.h"
#import "ZJPlayer.h"
@interface PlayerVideoController ()
@property(strong,nonatomic) ZJPlayer * player;
@end

@implementation PlayerVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频播放";
   
    self.view.backgroundColor = [UIColor  whiteColor];
   
    self.player =   [[ZJPlayer alloc]initWithUrl:[NSURL fileURLWithPath:self.path]  withSuperView:self.view];
   
    self.player.isRotatingSmallScreen = YES;

    [self.view addSubview:self.player];

    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {

        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(300);
    }];
}
- (BOOL)shouldAutorotate//是否支持旋转屏幕
{
    NSLog(@"PlayerVideoController:YES");
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
- (void)dealloc{
    
    [self.player deallocSelf];
    
    NSLog(@"%@",self.view);
    
    NSLog(@"销毁......");
    
}

@end
