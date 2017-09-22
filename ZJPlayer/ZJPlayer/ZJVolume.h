//
//  ZJVolume.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//调整音量大小的视图

#import <UIKit/UIKit.h>
#import "ZJCommonHeader.h"
@interface ZJVolume : UIView
/**
 声音大小
 */
@property(nonatomic,assign) float progress;

- (instancetype)initWithSuperView:(UIView *)superView;
/**
 显示
 */
- (void)show;
/**
 隐藏
 */
- (void)dismiss;
/**
 旋转之后重新调整约束
 */
- (void)resetFrameisFullScreen:(BOOL)isFullScreen;
@end
