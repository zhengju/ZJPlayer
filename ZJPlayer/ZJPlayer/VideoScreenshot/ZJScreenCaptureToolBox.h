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

- (void)setCaptureDragViewFrame:(CGRect)frame type:(ZJSelectFrameType)type;

@property(nonatomic, weak)  id<ZJScreenCaptureToolBoxDelegate> delegate;

@end


