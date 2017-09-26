//
//  VideoController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "VideoController.h"
#import "ZJPlayer.h"
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
    
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(64);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(260);
    }];
}
#pragma mark -- ZJPlayerDelegate
- (void)playFinishedPlayer:(ZJPlayer *)player{

}
@end
