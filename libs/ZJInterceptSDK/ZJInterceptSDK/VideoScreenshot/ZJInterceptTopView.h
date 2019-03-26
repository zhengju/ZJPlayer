//
//  ZJInterceptTopView.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/11.
//  Copyright © 2018年 郑俱. All rights reserved.
//顶部工具条

#import <UIKit/UIKit.h>
//#import "ZJCommonHeader.h"

typedef NS_ENUM(NSInteger, ZJInterceptTopViewType) {
    ZJInterceptTopViewVideo,
    ZJInterceptTopViewGIF
};

@protocol ZJInterceptTopViewDelegate <NSObject>

/**
 返回事件
 */
- (void)back;
- (void)action:(ZJInterceptTopViewType)actionType;
- (void)finishWithAction:(ZJInterceptTopViewType)actionType;

/**
 GIF视频截屏
 */
- (void)gifScreenshot;
@end


@interface ZJInterceptTopView : UIView

@property(weak,nonatomic) id<ZJInterceptTopViewDelegate> delegate;

@end


