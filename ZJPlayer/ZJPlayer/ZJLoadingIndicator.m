//
//  ZJLoadingIndicator.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//
#warning 待完善.....
#import "ZJLoadingIndicator.h"

@implementation ZJLoadingIndicator

- (instancetype)init{
    if (self = [super init]) {
        self.hidden = YES;
    }
    return self;
}

- (void)show{
    self.hidden = NO;
}


- (void)dismiss{
    self.hidden = YES;
}

@end
