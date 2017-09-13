//
//  ZJPlayer.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZJCommonHeader.h"

@class ZJControlView;

@interface ZJPlayer : UIView

@property(strong,nonatomic) AVPlayer * player;

@property(strong,nonatomic) AVPlayerLayer * playerLayer;

@property(strong,nonatomic) AVPlayerItem * playerItem;

@property(strong,nonatomic) UIView * topView;

@property(strong,nonatomic) ZJControlView * bottomView;

@property(strong,nonatomic) UILabel * titleLabel;

@property(assign,nonatomic) BOOL  isDragSlider;
/**
 当前播放视频的标题
 */
@property(copy,nonatomic) NSString * title;
/**
 当前播放url
 */
@property (nonatomic,strong) NSURL *url;
/**
 定时器 自动消失View
 */
@property(strong,nonatomic) NSTimer * autoDismissTimer;
/**
 是否隐藏bottomView
 */
@property(assign,nonatomic) BOOL  isBottomViewHidden;
/**
 左上角关闭按钮
 */
@property(strong,nonatomic) UIButton * closeButton;

// 是否全屏
@property (nonatomic,assign) BOOL isFullScreen;

//与url初始化
-(instancetype)initWithUrl:(NSURL *)url;
/**
 视频播放
 */
- (void)play;
/**
 视频暂停
 */
- (void)pause;

@end
