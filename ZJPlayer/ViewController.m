//
//  ViewController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/6.
//  Copyright © 2017年 郑俱. All rights reserved.
//
//http://localhost:8080/hls/room.m3u8
//http://img.house.china.com.cn/voice/hdzxjh.mp4

#import "ViewController.h"
#import "ZJPlayer.h"
#import "Masonry.h"
#import "ZJDownloadManager.h"
@interface ViewController ()

@end

@implementation ViewController
///Users/leeco/Documents/童话侠.mp4
//http://img.house.china.com.cn/voice/rongch.mp4
//http://gslb.miaopai.com/stream/QgZbuZjY70~LOyicMJz9NQ__.mp4?yx=&KID=unistore,video&Expires=1488340984&ssig=9xbm%2BqHngF
- (void)viewDidLoad {
    [super viewDidLoad];
    self.backBtn.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    ZJPlayer * player =  [[ZJPlayer alloc]initWithUrl:[NSURL URLWithString:@"http://img.house.china.com.cn/voice/rongch.mp4"] withSuperView:self.view frame:CGRectMake(0, 0, self.view.bounds.size.width, 300) controller:self];
    player.isRotatingSmallScreen = YES;

    [self.view addSubview:player];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"原始controller消失");
}
//Interface的方向是否会跟随设备方向自动旋转，如果返回NO,后两个方法不会再调用
- (BOOL)shouldAutorotate {
    return YES;
}
////返回直接支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end
