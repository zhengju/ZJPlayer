//
//  ZJDisplayVideoToSaveTopView.h
//  ZJPlayer
//
//  Created by zhengju on 2018/10/14.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCommonHeader.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ZJDisplayVideoToSaveTopViewDelegate <NSObject>

- (void)displayVideoToSaveTopViewBack;
- (void)displayVideoToSaveTopViewExit;

@end


@interface ZJDisplayVideoToSaveTopView : UIView
@property(weak,nonatomic) id<ZJDisplayVideoToSaveTopViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
