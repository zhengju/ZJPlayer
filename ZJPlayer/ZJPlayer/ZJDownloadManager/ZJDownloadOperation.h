//
//  ZJDownloadOperation.h
//  ZJPlayer
//
//  Created by leeco on 2019/3/13.
//  Copyright © 2019年 郑俱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJDownloaderItem.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ZJDownloadOperationDelegate <NSObject>

@optional
- (void)zjDownloadOperationStartDownloading:(ZJDownloaderItem *)dItem;
- (void)zjDownloadOperationFinishDownload:(ZJDownloaderItem *)dItem;
- (void)zjDownloadOperationDownloading:(ZJDownloaderItem *)dItem downloadPercentage:(float)percentage velocity:(float)velocity;

@end


@interface ZJDownloadOperation : NSOperation

@property (nonatomic, weak) id<ZJDownloadOperationDelegate> delegate;
- (id)initWithItem:(ZJDownloaderItem *)item;
- (ZJDownloaderItem *)downloadItem;
- (void)cancelDownload;


@end

NS_ASSUME_NONNULL_END
