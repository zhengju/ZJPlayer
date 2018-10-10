//
//  InterceptView.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/9.
//  Copyright © 2018年 郑俱. All rights reserved.
//视频、gif截屏View

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
@interface InterceptView : UIView

@property(strong,nonatomic) AVPlayerItem * playerItem;

/**
 当前观看时间
 */
@property(assign,nonatomic) CMTime  currentTtime;
/**
 视频链接资源
 */
@property (nonatomic,strong) NSURL * videoUrl;

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)videoUrl playerItem:(AVPlayerItem *)playerItem currentTime:(CMTime )currentTime;

@end


