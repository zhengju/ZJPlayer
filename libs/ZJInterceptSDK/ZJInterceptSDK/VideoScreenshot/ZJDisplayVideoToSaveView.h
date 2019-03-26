//
//  ZJDisplayVideoToSaveView.h
//  ZJPlayer
//
//  Created by zhengju on 2018/10/14.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZJInterceptTopView.h"


@protocol ZJDisplayVideoToSaveViewDelegate <NSObject>

- (void)displayVideoToSaveViewToback;
- (void)displayVideoToSaveViewExit;
@end


@interface ZJDisplayVideoToSaveView : UIView


@property(nonatomic, weak) id<ZJDisplayVideoToSaveViewDelegate > delegate;

@property(strong,nonatomic) AVPlayerItem * playerItem;

/**
 当前观看时间
 */
@property(assign,nonatomic) CMTime  currentTtime;
/**
 视频链接资源
 */
@property (nonatomic,strong) NSURL * videoUrl;

@property (nonatomic, assign) CGFloat startTime;            //开始截取的时间

@property (nonatomic, assign) CGFloat endTime;    

@property(nonatomic, assign) CGRect videoCroppingFrame ;

@property (nonatomic, strong) UIImageView *BGView;

@property(nonatomic, assign) ZJInterceptTopViewType type ;


- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)videoUrl playerItem:(AVPlayerItem *)playerItem currentTime:(CMTime )currentTime withAsset:(AVAsset*)asset videoCroppingFrame:(CGRect )videoCroppingFrame playeFrame:(CGRect)playFrame videoOutPut:(AVPlayerItemVideoOutput *)videoOutPut type: (ZJInterceptTopViewType)type;

@end
