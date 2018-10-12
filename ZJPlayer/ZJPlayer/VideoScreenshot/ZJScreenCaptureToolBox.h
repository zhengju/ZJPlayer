//
//  ZJScreenCaptureToolBox.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/11.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJSelectFrameView.h"
@protocol ZJScreenCaptureToolBoxDelegate <NSObject>

- (void)screenCaptureFrame:(CGRect)frame;


@end

@interface ZJScreenCaptureToolBox : UIView

@property(nonatomic, weak)  id<ZJScreenCaptureToolBoxDelegate> delegate;

@property(nonatomic) CGRect  originVideoFrame;


- (void)setCaptureDragViewFrame:(CGRect)frame type:(ZJSelectFrameType)type;

- (CGRect)captureDragViewFrameWithType:(ZJSelectFrameType)type;

@end


