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

/**
工作目录：
 
 1.截视频视频--已完成
 2.GIF生成--已完成
 3.删除截视频产生的沙盒视频
 4.选取画幅面板界面--已完成
 5.基础视频裁剪--已完成
 6.优化视频截帧
 7.实现裁剪之后的视频压缩
 8.把耗时操作放在子线程中
 9.重新架构
 10.
 **/
