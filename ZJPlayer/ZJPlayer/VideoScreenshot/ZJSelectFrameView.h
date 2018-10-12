//
//  ZJSelectFrameView.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/11.
//  Copyright © 2018年 郑俱. All rights reserved.
//选取画幅

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ZJSelectFrameType) {
    ZJSelectFrameViewOriginal = 1,
    ZJSelectFrameViewVerticalPlate,
    ZJSelectFrameViewFilm,
    ZJSelectFrameViewSquare
};

@protocol ZJSelectFrameViewDelegate <NSObject>

- (void)selectedFrameType:(ZJSelectFrameType)type;

@end


@interface ZJSelectFrameView : UIView

@property(weak,nonatomic)id<ZJSelectFrameViewDelegate> delegate;

@end


