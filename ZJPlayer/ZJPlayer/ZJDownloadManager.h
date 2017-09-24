//
//  ZJDownloadManager.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/22.
//  Copyright © 2017年 郑俱. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZJCommonHeader.h"
typedef enum {
    ZJDownloadStateRunning = 0,     /** 下载中 */
    ZJDownloadStateSuspended,     /** 下载暂停 */
    ZJDownloadStateCompleted,     /** 下载完成 */
    ZJDownloadStateCanceled,     /** 取消下载 */
    ZJDownloadStateFailed         /** 下载失败 */
}ZJDownloadState;
@interface ZJDownload : NSObject<NSCopying>
@property (nonatomic, strong) NSOutputStream *stream;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) long long allLength;

@property(strong,nonatomic) NSMutableData * fileData;
/**
 *  文件的总长度
 */
@property (nonatomic, assign) long long totalLength;
/**
 *  文件的实时长度
 */
@property (nonatomic, assign) long long currentLength;

/**
 *  文件的实时长度
 */
@property (nonatomic, assign) long long downloadLength;

/**
 保存上次的下载信息
 */
@property(strong,nonatomic) NSData *resumeData;

@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, copy) void(^progressBlock)( CGFloat progress);
@property (nonatomic, copy) void(^stateBlock)(ZJDownloadState state);

@end

@interface ZJDownloadManager : NSObject

/**
 *  初始化
 *
 */
+ (ZJDownloadManager *)sharedInstance;

/**
 *  添加下载任务
 *
 *  @param url           url
 *  @param tag           唯一标识
 *  @param resume        是否下载
 *  @param progressBlock 下载进度回调
 *  @param stateBlack    下载状态回调
 */
- (void)downloadDataWithURL:(NSString *)url tag:(NSUInteger)tag resume:(BOOL)resume progress: (void(^)( CGFloat progress)) progressBlock state:(void(^)(ZJDownloadState state))stateBlack;

//- (void)download;
/**
 继续下载
 */
- (void)continueDownloading;
/**
 取消或暂停
 */
- (void)cancel;
/**
 *  进度
 *
 *  @param tag 唯一标识
 */
- (float)progressWithTag:(NSUInteger)tag;

/**
 *  开始
 *
 *  @param tag 唯一标识
 */
- (void)resumeWithTag:(NSUInteger)tag;

/**
 *  暂停
 *
 *  @param tag 唯一标识
 */
- (void)suspendWithTag:(NSUInteger)tag;

/**
 *  取消
 *
 *  @param tag 唯一标识
 */
- (void)cancelWithTag:(NSUInteger)tag;

- (void)continueDownloadingWithTag:(NSUInteger)tag;
@end
