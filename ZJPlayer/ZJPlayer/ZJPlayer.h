//
//  ZJPlayer.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//

/**
 任务：
 1.视屏截屏---已完成，有偶尔闪退的bug
 2.GIF动画截屏
 3.视频流的录屏(转成GIF)
 2.视频缓冲
 3.视屏下载---借鉴他人已完成功能，差在ZJplayer中添加下载功能--下载还有些问题
 4.上下滑动调节屏幕亮度，写调节亮度的视图---已完成
 5.上下滑动调节声音大小，写调节声音的视图---已完成
 6.上下，左半部分是调整亮度，右半部分是调整声音的---已完成
 7.监听插入耳机/耳机线控 --- 已完成
 8.弹幕
 9.播放本地视频---已完成
 10.加载缓存环形加载指示器待优化...
 11.视频第一帧缓存到本地
 12.更新屏幕选中方式--已经更新，但是zjplayer添加到cell上有问题
 13.缓存视频第一张截图的图片--已完成
 */
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZJCommonHeader.h"

@class ZJControlView;
@class ZJTopView;
@class ZJPlayer;

@protocol ZJPlayerDelegate <NSObject>

- (void)playFinishedPlayer:(ZJPlayer *)player;


@end

extern NSString *const ZJViewControllerWillAppear;// 一个控制器即将出现
extern NSString *const ZJViewControllerWillDisappear; // 一个控制器即将消失
extern NSString *const ZJContinuousVideoPlayback; // 连续播放视频通知
extern NSString *const ZJEventSubtypeRemoteControlTogglePlayPause; // 暂停键

@interface ZJPlayer : UIView <UIApplicationDelegate>

@property(weak,nonatomic) id<ZJPlayerDelegate> delegate;

@property(strong,nonatomic) AVPlayer * player;

@property(strong,nonatomic) AVPlayerLayer * playerLayer;

@property(strong,nonatomic) AVPlayerItem * playerItem;

@property(strong,nonatomic) ZJTopView * topView;

@property(strong,nonatomic) ZJControlView * bottomView;

@property(assign,nonatomic) BOOL  isDragSlider;
/**
 tableView中player显示的位置
 */
@property(strong,nonatomic) NSIndexPath *indexPath;
/**
 当前播放视频的标题
 */
@property(copy,nonatomic) NSString * title;
/**
 当前播放url
 */
@property (nonatomic,strong) NSURL *url;

@property (nonatomic,strong) AVURLAsset *asset;

/**
 定时器 自动消失View
 */
@property(strong,nonatomic) NSTimer * autoDismissTimer;
/**
 是否自动播放,默认是NO
 */
@property(assign,nonatomic) BOOL  isAutoPlay;

/**
 是否连续播放,YES:连续播放，NO,不连续播放，默认是NO
 */
@property(assign,nonatomic) BOOL  isPlayContinuously;

/**
 是否隐藏bottomView
 */
@property(assign,nonatomic) BOOL  isBottomViewHidden;

/**
 是否全屏 YES:全屏 ；NO:非全屏
 */
@property (nonatomic,assign) BOOL isFullScreen;
/**
 当大屏时，播放完视频是否自动旋转至小屏幕 YES:自动 ；NO:不自动
 */
@property (nonatomic,assign) BOOL isRotatingSmallScreen;
/**
 跳转之后是否播放 YES:播放 ；NO:不播放，默认是NO
 */
@property (nonatomic,assign) BOOL isPushOrPopPlpay;

/**
 父视图
 */
@property(strong,nonatomic) UIView * fatherView;

/**
 单例生成player
 */
+ (id)sharePlayer;
/**
 与url初始化
 */
-(instancetype)initWithUrl:(NSURL *)url withSuperView:(UIView *)superView;
/**
 视频播放
 */
- (void)play;
/**
 视频暂停
 */
- (void)pause;

- (void)deallocSelf;

@end
