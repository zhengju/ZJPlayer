//
//  ZJTopView.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//顶部空间

#import <UIKit/UIKit.h>
#import "ZJCommonHeader.h"
@protocol ZJTopViewDelegate <NSObject>

/**
 返回事件
 */
- (void)back;
- (void)setRate:(float)rate;
- (void)fetchScreen;

@end
@interface ZJTopView : UIView
@property(weak,nonatomic) id<ZJTopViewDelegate> delegate;
@property(assign,nonatomic) float  rate;
/**
 标题
 */
@property(copy,nonatomic) NSString * title;
/**
 倍速归1.0X
 */
- (void)resetRate;
@end
