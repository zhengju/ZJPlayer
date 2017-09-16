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
@class ZJTopView;
@class ZJPlayer;

@protocol ZJPlayerDelegate <NSObject>

- (void)playFinishedPlayer:(ZJPlayer *)player;


@end

extern NSString *const ZJViewControllerWillAppear;// 一个控制器即将出现
extern NSString *const ZJViewControllerWillDisappear; // 一个控制器即将消失
extern NSString *const ZJContinuousVideoPlayback; // 连续播放视频通知


@interface ZJPlayer : UIView

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
 单例生成player
 */
+ (id)sharePlayer;
/**
 与url初始化
 */
-(instancetype)initWithUrl:(NSURL *)url;
/**
 视频播放
 */
- (void)play;
/**
 视频暂停
 */
- (void)pause;
/**
 获取视频第一帧 返回图片
 */
- (UIImage*) getVideoPreViewImage:(NSURL *)path;

@end
