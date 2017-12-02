//
//  DownloadList.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/24.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DownloadList : NSObject
/**
 下载程度
 */
@property(nonatomic,assign) float progress;

@property(copy,nonatomic) NSString * name;
@property(copy,nonatomic) NSString * urlString;
@property(copy,nonatomic) NSString * ratio;
@property(copy,nonatomic) NSString * cacheRatio;
@property(strong,nonatomic) UIImage * img;
@property(assign,nonatomic) BOOL isDownloading;
@end
