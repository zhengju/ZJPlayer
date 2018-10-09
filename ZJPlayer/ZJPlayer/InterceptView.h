//
//  InterceptView.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/9.
//  Copyright © 2018年 郑俱. All rights reserved.
//视频、gif截屏View

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
@interface InterceptView : UIView
/**
 当前观看时间
 */
@property(assign) CMTime  currentTtime;

@end


