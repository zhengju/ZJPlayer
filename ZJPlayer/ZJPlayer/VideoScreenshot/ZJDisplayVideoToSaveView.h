//
//  ZJDisplayVideoToSaveView.h
//  ZJPlayer
//
//  Created by zhengju on 2018/10/14.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ZJDisplayVideoToSaveViewDelegate <NSObject>

- (void)displayVideoToSaveViewToback;

@end


@interface ZJDisplayVideoToSaveView : UIView

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

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)videoUrl playerItem:(AVPlayerItem *)playerItem currentTime:(CMTime )currentTime;

@end
