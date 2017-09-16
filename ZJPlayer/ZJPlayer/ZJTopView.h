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
 返回时间
 */
- (void)back;

@end
@interface ZJTopView : UIView
@property(weak,nonatomic) id<ZJTopViewDelegate> delegate;
/**
 标题
 */
@property(copy,nonatomic) NSString * title;
@end
