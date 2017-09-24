//
//  ZJDownloadManager.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/22.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJDownloadManager.h"

#define AllLengthKey(tag)  [NSString stringWithFormat:@"%lud",tag]

@implementation ZJDownload : NSObject
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.totalLength forKey:@"totalLength"];
    [aCoder encodeDouble:self.currentLength forKey:@"currentLength"];
    [aCoder encodeDouble:self.downloadLength forKey:@"downloadLength"];
    [aCoder encodeDataObject:self.resumeData];
    [aCoder encodeObject:self.task forKey:@"task"];
    //[aCoder encodeInteger:self. forKey:<#(nonnull NSString *)#>]
   // [aCoder encodeBool:self.isVideo forKey:@""];
    //[aCoder encodeObject:self.date forKey:@""];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.resumeData = [aDecoder decodeDataObject];
        self.task = [aDecoder decodeObjectForKey:@"task"];
        self.totalLength = [aDecoder decodeDoubleForKey:@"totalLength"];
        self.currentLength = [aDecoder decodeDoubleForKey:@"currentLength"];
        self.downloadLength = [aDecoder decodeDoubleForKey:@"downloadLength"];
    }
    
    return self;
}
@end

@interface ZJDownloadManager()<NSURLSessionDownloadDelegate>

@property(strong,nonatomic) NSMutableData * fileData;
/**
 *  文件的总长度
 */
@property (nonatomic, assign) long long totalLength;
/**
 *  文件的实时长度
 */
@property (nonatomic, assign) long long currentLength;

@property(strong,nonatomic) NSFileHandle * writeHandle;
/**
 *  下载
 */
@property(strong,nonatomic) NSURLSession * urlSession;
/**
 下载任务
 */
@property(strong,nonatomic) NSURLSessionDownloadTask * downloadTask;
/**
 保存上次的下载信息
 */
@property(strong,nonatomic) NSData *resumeData;
/**写文件的流对象 */
@property (nonatomic, strong) NSOutputStream *stream;

@property (nonatomic, strong) NSMutableDictionary *downloadDic;

@end

@implementation ZJDownloadManager

- (NSMutableDictionary *)downloadDic {
    if (!_downloadDic) {
        _downloadDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[self getCachDirectory]];
        
        if (_downloadDic == nil || _downloadDic.allKeys.count == 0) {
            _downloadDic = [NSMutableDictionary dictionaryWithCapacity:0];
        }
    }
    return _downloadDic;
}

+ (ZJDownloadManager *)sharedInstance{
    static ZJDownloadManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[ZJDownloadManager alloc]init];
        
    });
    return manager;
}

- (void)downloadDataWithURL:(NSString *)url tag:(NSUInteger)tag resume:(BOOL)resume progress: (void(^)( CGFloat progress)) progressBlock state:(void(^)(ZJDownloadState state))stateBlack{
    NSLog(@"%@",[self getCachDirectory]);
    if (!url && !tag) {
        return;
    }
    //判断是否是已经下载过得了
    if ([self getAllLength:tag] == [self getFileDownloadedLength:tag] && [self getFileDownloadedLength:tag] > 0) {
        if (stateBlack) {
            stateBlack(ZJDownloadStateCompleted);
        }
        if (progressBlock) {
            progressBlock(1.0);
        }
        return;
    }
    //是否下载一部分
    if ([self.downloadDic valueForKey:@(tag).stringValue]) {
        ZJDownload *zj_D = [self.downloadDic valueForKey:@(tag).stringValue];
        if (resume) {
            [zj_D.task resume];//开始
        }else {
            [zj_D.task suspend];//暂停
            if (zj_D.stateBlock) {
                zj_D.stateBlock(ZJDownloadStateSuspended);
            }
            
        }
        
        return;
    }
    
    //新的下载任务哈...
    self.urlSession= [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self getFileDownloadedLength:tag]];//有下载
    
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request];
    
    [task setValue:@(tag) forKeyPath:@"taskIdentifier"];
    
    ZJDownload *lc_download = [[ZJDownload alloc]init];
    lc_download.task = task;
    lc_download.progressBlock = progressBlock;
    lc_download.stateBlock = stateBlack;
    
    [self.downloadDic setValue:lc_download forKey:@(tag).stringValue];
    //[self archiver];
    //写文件
 BOOL success =    [self.downloadDic writeToFile:[self getCachDirectory] atomically:YES];
    if (success) {
        NSLog(@"写入OK");
    }else{

        NSLog(@"写入失败");
    }
    if (resume) {
        [task resume];
    }
}

// 获取本地已经下载的大小
- (NSUInteger)getFileDownloadedLength:(NSUInteger)tag {

        ZJDownload * download = [self.downloadDic valueForKey:@(tag).stringValue];
    if (download) {
        return download.currentLength;
    }

    return 0;

}

- (NSUInteger)getAllLength:(NSUInteger)tag {

        ZJDownload * download = [self.downloadDic valueForKey:@(tag).stringValue];
    
    if (download) {
        return download.totalLength;
    }

    return 0;

}
- (NSString *)getCachDirectory {

    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache"];
}

#pragma mark -- NSURLSessionDownloadDelegate
//didResumeAtOffset重新恢复下载时调用的代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    NSLog(@"断点续传哈;;;;%s",__func__);
}

//1.当接收到下载数据的时候调用,可以在该方法中监听文件下载的进度,该方法会被调用多次
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

     ZJDownload *lc_D = [self.downloadDic valueForKey:@(downloadTask.taskIdentifier).stringValue];
    if (lc_D.stateBlock) {
        lc_D.stateBlock(ZJDownloadStateRunning);
    }
    lc_D.downloadLength = lc_D.currentLength +totalBytesWritten;

    if (lc_D.totalLength <  totalBytesExpectedToWrite) {
        lc_D.totalLength = totalBytesExpectedToWrite;
    }
    
    // 可在这里通过已写入的长度和总长度算出下载进度
    float progress = 1.0 * lc_D.downloadLength / lc_D.totalLength;
    
    if (lc_D.progressBlock) {
        lc_D.progressBlock(progress);
    }
  //  NSLog(@"%f",progress);

    [self.downloadDic writeToFile:[self getCachDirectory] atomically:YES];
   // [self archiver];
}
//下载完成调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
   
    NSString* ceches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//文件存放的真实路径
    NSString* filepath = [ceches stringByAppendingPathComponent:downloadTask.response.suggestedFilename]; // 创
            NSLog(@"%@",filepath);
//
    NSFileManager* fileManager = [NSFileManager defaultManager];
//剪切location的临时文件到真实路径
    [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:filepath] error:nil];

    NSLog(@"下载完成");
    
}

// 3.请求成功或者失败（如果失败，error有值）
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{

    ZJDownload *lc_D = [self.downloadDic valueForKey:@(task.taskIdentifier).stringValue];
    
    lc_D.resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
//[self archiver];
   [self.downloadDic writeToFile:[self getCachDirectory] atomically:YES];
}
#pragma mark -- 继续下载
- (void)continueDownloadingWithTag:(NSUInteger)tag{
    
    ZJDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
    if (lc_D && lc_D.resumeData != nil) {
        
        lc_D.task = [self.urlSession downloadTaskWithResumeData:lc_D.resumeData];
        [lc_D.task resume];
        self.resumeData = nil;
        
    }else{
        
        HUDNormal(@"还未开始过下载呢");
    }

}

- (void)resumeWithTag:(NSUInteger)tag {
    ZJDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
    if (lc_D) {
        [lc_D.task resume];
    }
}

- (void)suspendWithTag:(NSUInteger)tag {
   ZJDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
    if (lc_D) {
        [lc_D.task suspend];//暂停
        lc_D.stateBlock(ZJDownloadStateSuspended);
    }
}

- (void)cancelWithTag:(NSUInteger)tag {
    ZJDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
    if (lc_D) {
        WeakObj(lc_D);
        WeakObj(self);
        // 一旦这个task被取消了，就无法再恢复

        [lc_D.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
            lc_DWeak.resumeData = resumeData;
            lc_DWeak.task = nil;
            [selfWeak.downloadDic writeToFile:[selfWeak getCachDirectory] atomically:YES];
            //[selfWeak archiver];
        }];

        lc_D.stateBlock(ZJDownloadStateCanceled);
    }
   
}
/**
 *  进度
 *
 *  @param tag 唯一标识
 */
- (float)progressWithTag:(NSUInteger)tag{
    ZJDownload *lc_D = [self.downloadDic valueForKey:@(tag).stringValue];
    if (lc_D) {
        if (lc_D.totalLength == 0) {
            return 0;
        }
        return lc_D.currentLength / lc_D.totalLength;
    }
    return 0;
}
- (void)archiver{
    
    // 要归档的对象.
   // ModelForWeather *model = self.arrayForChoosePlace[indexPath.row]; // 创建归档时所需的data 对象.
    NSMutableData *data = [NSMutableData data]; // 归档类.
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data]; // 开始归档（@"model" 是key值，也就是通过这个标识来找到写入的对象）.
    [archiver encodeObject:self.downloadDic forKey:@"model"]; // 归档结束.
    [archiver finishEncoding]; // 写入本地（@"weather" 是写入的文件名）.
   // NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"weather"];
    
    [data writeToFile:[self getCachDirectory] atomically:YES];
   
}
- (NSMutableDictionary *)unarchiver{
    // 从本地（@"weather" 文件中）获取.
  //  NSString *file = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"weather"]; // data.
    NSData *data = [NSData dataWithContentsOfFile:[self getCachDirectory]]; // 反归档.
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data]; // 获取@"model" 所对应的数据
    _downloadDic = [unarchiver decodeObjectForKey:@"model"]; // 反归档结束.
//    if(self.downloadDic.allKeys.count == 0){
//        self.downloadDic = [NSMutableDictionary dictionaryWithCapacity:0];
//    }
    
    [unarchiver finishDecoding];
    
    return _downloadDic;
}
@end
