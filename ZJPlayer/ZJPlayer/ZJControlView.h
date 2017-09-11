//
//  ZJControlView.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCommonHeader.h"

@protocol ZJControlViewDelegate <NSObject>

/**
 点击全屏的事件
 */
- (void)clickFullScreen;
- (void)play;
- (void)sliderDragValueChange:(UISlider *)slider;
- (void)sliderTapValueChange:(UISlider *)slider;
// 点击事件的Slider
- (void)touchSlider:(UITapGestureRecognizer *)tap;

@end



@interface ZJControlView : UIView
@property(strong,nonatomic) UISlider * slider;
@property (nonatomic,strong) UIProgressView *progressView;
/**
 播放暂停按钮
 */
@property(strong,nonatomic) UIButton * playBtn;
/**
 右下角放缩按钮
 */
@property(strong,nonatomic) UIButton * scalingBtn;

@property(strong,nonatomic) UILabel * nowLabel;

@property(strong,nonatomic) UILabel * remainLabel;

@property(weak,nonatomic) id<ZJControlViewDelegate> delegate;

@end
