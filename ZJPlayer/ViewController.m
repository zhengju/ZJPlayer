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
#import "ZJVideoPlayerView.h"
#import "Masonry.h"
#import "ZJDownloadManager.h"
#import "ZJInterceptSDK.h"
#import "MainViewController.h"
#import <BlocksKit/BlocksKit.h>

#import "ZJPlayerController.h"
#import "ZJPlayerControl.h"


#define ZJCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache"]

@interface ViewController ()

@end

@implementation ViewController
//https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4
///Users/leeco/Documents/童话侠.mp4
//http://img.house.china.com.cn/voice/rongch.mp4
//http://gslb.miaopai.com/stream/QgZbuZjY70~LOyicMJz9NQ__.mp4?yx=&KID=unistore,video&Expires=1488340984&ssig=9xbm%2BqHngF
//http://www.ytmp3.cn/down/53969.mp3
- (void)viewDidLoad {
    [super viewDidLoad];
    self.backBtn.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIWebView * web = [[UIWebView alloc]initWithFrame:self.view.bounds];
//    [self.view addSubview:web];
//
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345"]];
//    [web loadRequest:request];
//    [web loadRequest:request];
//
//
//
//    return;
    //NSString * urlStr = @"http://img.house.china.com.cn/voice/hdzxjh.mp4";

    
//    InterceptView<ZJPlayerProtocolDelegate> * interceptView = [[InterceptView alloc]init];

    
    ZJPlayerControl * control = [[ZJPlayerControl alloc]initWithView:self.view andFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300) url:@"http://img.house.china.com.cn/voice/rongch.mp4"];
    
    
    
    
//    ZJVideoPlayerView * player =  [[ZJVideoPlayerView alloc]initWithUrl:[NSURL URLWithString:@"http://localhost:12345/35011f625548a53b13919c825b022aaa.mp4"] withSuperView:self.view frame:CGRectMake(0, 0, self.view.bounds.size.width, 300) controller:self];
    
//    player.interceptView  = interceptView;
    
//    player.isRotatingSmallScreen = YES;
//
//    [self.view addSubview:player];

    
    
    
    UIButton * liveBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, kScreenHeight-300, kScreenWidth-100, 40)];
    
    [liveBtn setTitle:@"看直播" forState:UIControlStateNormal];

    [liveBtn setBackgroundColor:[UIColor blueColor]];
    
    [liveBtn addTarget:self action:@selector(liveVideo) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:liveBtn];
    
    
    
//    ZJPlayerController * vc = [ZJPlayerController sharePlayerController];
    
//    player.orientationWillChange = ^(ZJVideoPlayerView *player, BOOL isFullScreen) {
//
////        [self setNeedsStatusBarAppearanceUpdate];
//    };
    
}
- (void)liveVideo{
    MainViewController * vc = [[MainViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"原始controller消失");
}
//Interface的方向是否会跟随设备方向自动旋转，如果返回NO,后两个方法不会再调用
- (BOOL)shouldAutorotate {
    return NO;
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
