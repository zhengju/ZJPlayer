//
//  ZJInterceptTopView.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/11.
//  Copyright © 2018年 郑俱. All rights reserved.
//顶部工具条

#import <UIKit/UIKit.h>
#import "ZJCommonHeader.h"
@protocol ZJInterceptTopViewDelegate <NSObject>

/**
 返回事件
 */
- (void)back;
- (void)setAction:(float)action;//0截视频 1截GIF
- (void)finishWithAction:(float)action;
/**
 GIF视频截屏
 */
- (void)gifScreenshot;
@end


@interface ZJInterceptTopView : UIView

@property(weak,nonatomic) id<ZJInterceptTopViewDelegate> delegate;

@end

