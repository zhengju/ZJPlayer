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
   
    self.player =   [[ZJPlayer alloc]initWithUrl:[NSURL fileURLWithPath:self.path]  withSuperView:self.view frame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
   
    self.player.isRotatingSmallScreen = YES;

    [self.view addSubview:self.player];

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
