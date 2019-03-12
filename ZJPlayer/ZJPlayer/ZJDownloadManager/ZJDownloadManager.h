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
@interface ZJDownload : NSObject
/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;
/** 下载地址 */
@property (nonatomic, copy) NSString *url;
/**
 *  文件的总长度
 */
@property (nonatomic, assign) long long totalLength;

@property (nonatomic, copy) void(^progressBlock)( CGFloat progress);
@property (nonatomic, copy) void(^totalLengthBlock)( CGFloat totalLength);
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
 *  @param resume        是否下载
 *  @param progressBlock 下载进度回调
 *  @param stateBlack    下载状态回调
 */
- (void)downloadDataWithURL:(NSString *)url resume:(BOOL)resume totalLength:(void(^)( CGFloat totalLength)) totalLengthBlock progress: (void(^)( CGFloat progress)) progressBlock state:(void(^)(ZJDownloadState state))stateBlack;
/**
 *  查询该资源的下载进度值
 *
 *  @param url 下载地址
 *
 *  @return 返回下载进度值
 */
- (CGFloat)progress:(NSString *)url;
/**
 *  获取该资源总大小
 *
 *  @param url 下载地址
 *
 *  @return 资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;

/**
 *  判断该资源是否下载完成
 *
 *  @param url 下载地址
 *
 *  @return YES: 完成
 */
- (BOOL)isCompletion:(NSString *)url;

/**
 *  删除该资源
 *
 *  @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile;
/**
 *  本地路径
 */
- (NSString *)path:(NSString *)url;
/**
 *总大小，单位是M
 */
- (float)totalLength:(NSString *)url;
/**
 *已经下载的大小，单位是M
 */
- (float)downloadLength:(NSString *)url;
@end
