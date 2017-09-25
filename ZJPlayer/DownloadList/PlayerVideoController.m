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
    self.view.backgroundColor = [UIColor  whiteColor];
    ZJPlayer * player =  [[ZJPlayer alloc]initWithUrl:[NSURL fileURLWithPath:self.path]];
    
    player.isRotatingSmallScreen = YES;
    
    [self.view addSubview:player];
    
    [player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(64);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(300);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
