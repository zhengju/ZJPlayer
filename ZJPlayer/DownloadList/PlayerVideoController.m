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

@end

@implementation PlayerVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频播放";
    self.view.backgroundColor = [UIColor  whiteColor];
    ZJPlayer * player =  [[ZJPlayer alloc]initWithUrl:[NSURL fileURLWithPath:self.path]];
    
    player.isRotatingSmallScreen = YES;
    
    [self.view addSubview:player];
    
    [player mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(300);
    }];
}


@end
