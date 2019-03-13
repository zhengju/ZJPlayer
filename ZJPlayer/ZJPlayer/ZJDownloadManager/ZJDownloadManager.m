//
//  ZJDownloaderItemManager.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/22.
//  Copyright © 2017年 郑俱. All rights reserved.
//实现方法是借鉴他人

#import "ZJDownloadManager.h"
#import "NSString+Hash.h"

#import "ZJDownloadOperation.h"

#define kMaxDownloadOperation    5

// 缓存主目录
#define ZJCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache"]

// 保存文件名
#define ZJFileName(url)  [self md5String:url]

// 文件的存放路径（caches）
#define ZJFileFullpath(url) [ZJCachesDirectory stringByAppendingPathComponent:ZJFileName(url)]

// 文件的已下载长度
#define ZJDownloaderItemLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:ZJFileFullpath(url) error:nil][NSFileSize] integerValue]

// 存储文件总长度的文件路径（caches）
#define ZJTotalLengthFullpath [ZJCachesDirectory stringByAppendingPathComponent:@"totalLength.plist"]

@interface ZJDownloadManager()<NSURLSessionDelegate,ZJDownloadOperationDelegate>
{
    NSConditionLock * _sliderLock;
}

/** 保存所有任务(注：用下载地址md5后作为key) */
@property (nonatomic, strong) NSMutableDictionary *tasks;
/** 保存所有下载相关信息 */
@property (nonatomic, strong) NSMutableDictionary *sessionModels;

@property (nonatomic, strong) NSOperationQueue * downloadOperationQueue;

@property (nonatomic, copy) void(^progressBlock)( CGFloat progress);
@property (nonatomic, copy) void(^totalLengthBlock)( CGFloat totalLength);
@property (nonatomic, copy) void(^stateBlock)(ZJDownloadState state);

@end

@implementation ZJDownloadManager
- (NSMutableDictionary *)tasks
{
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

- (NSMutableDictionary *)sessionModels
{
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}

- (NSString *)md5String:(NSString *)url
{
   
    NSArray * arr = [url componentsSeparatedByString:@"."];

    return   [NSString stringWithFormat:@"%@.%@",url.md5String,arr.lastObject];
}

static ZJDownloadManager *manager = nil;
+ (ZJDownloadManager *)sharedInstance{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[ZJDownloadManager alloc]init];
        
    });
    return manager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [super allocWithZone:zone];
        
    });
    return manager;
}
- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return manager;
}
- (instancetype)init{
    if (self = [super init]) {
        _downloadOperationQueue = [[NSOperationQueue alloc] init];
        _downloadOperationQueue.maxConcurrentOperationCount = kMaxDownloadOperation;
    }
    return self;
}


/**
 *  创建缓存目录文件
 */
- (void)createCacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:ZJCachesDirectory]) {
        [fileManager createDirectoryAtPath:ZJCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}
/**
 *  开启任务下载资源
 */
- (void)downloadDataWithURL:(NSString *)url resume:(BOOL)resume totalLength:(void (^)(CGFloat))totalLengthBlock progress:(void (^)(CGFloat))progressBlock state:(void (^)(ZJDownloadState))stateBlack{

    if (!url) {
        return;
    }

    if ([self isCompletion:url]) {
        stateBlack(ZJDownloadStateCompleted);
        NSLog(@"----该资源已下载完成");
        return;
    }
    
    // 暂停
    if ([self.tasks valueForKey:ZJFileName(url)]) {
        [self handle:url];
        
        return;
    }
    
    
    
    self.progressBlock = progressBlock;
    self.totalLengthBlock = totalLengthBlock;
    self.stateBlock = stateBlack;

    ZJDownloaderItem * dItem = [[ZJDownloaderItem alloc] init];
    dItem.downloadUrl = url;

//
//    // 创建缓存目录文件
    [self createCacheDirectory];
//
    dItem.downloadPath = ZJFileFullpath(url);
    [self startOperationWithRequestItem:dItem];

    return;
    
#warning --

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:ZJFileFullpath(url) append:YES];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%ld-", ZJDownloaderItemLength(url)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
    [task setValue:@(taskIdentifier) forKeyPath:@"taskIdentifier"];
    
    // 保存任务
    [self.tasks setValue:task forKey:ZJFileName(url)];
    
    ZJDownloaderItem *sessionModel = [[ZJDownloaderItem alloc] init];
    sessionModel.downloadUrl = url;
    sessionModel.totalLengthBlock = totalLengthBlock;
    sessionModel.progressBlock = progressBlock;
    sessionModel.stateBlock = stateBlack;
    sessionModel.stream = stream;
    [self.sessionModels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
    
    [self start:url];
}

#pragma mark - 队列管理
- (void)startOperationWithRequestItem:(ZJDownloaderItem *)dItem
{
    ZJDownloadOperation *  operation = [[ZJDownloadOperation alloc] initWithItem:dItem];
    operation.delegate = self;
    [_downloadOperationQueue addOperation:operation];
}

- (void)handle:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    if (task.state == NSURLSessionTaskStateRunning) {
        [self pause:url];
    } else {
        [self start:url];
    }
}

/**
 *  开始下载
 */
- (void)start:(NSString *)url
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
 
    
    NSURLSessionDataTask *task = [self getTask:url];
    [task resume];
    
    [self getSessionModel:task.taskIdentifier].stateBlock(ZJDownloadStateRunning);
        
        
    });
}

/**
 *  暂停下载
 */
- (void)pause:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    [task suspend];
    
    [self getSessionModel:task.taskIdentifier].stateBlock(ZJDownloadStateSuspended);
}

/**
 *  根据url获得对应的下载任务
 */
- (NSURLSessionDataTask *)getTask:(NSString *)url
{
    return (NSURLSessionDataTask *)[self.tasks valueForKey:ZJFileName(url)];
}

/**
 *  根据url获取对应的下载信息模型
 */
- (ZJDownloaderItem *)getSessionModel:(NSUInteger)taskIdentifier
{
    return (ZJDownloaderItem *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

/**
 *  判断该文件是否下载完成
 */
- (BOOL)isCompletion:(NSString *)url
{
    if ([self fileTotalLength:url] && ZJDownloaderItemLength(url) == [self fileTotalLength:url]) {
        return YES;
    }
    return NO;
}

/**
 *  查询该资源的下载进度值
 */
- (CGFloat)progress:(NSString *)url
{

    return [self fileTotalLength:url] == 0 ? 0.0 : 1.0 * ZJDownloaderItemLength(url) /  [self fileTotalLength:url];
}

/**
 *  获取该资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url
{
    return [[NSDictionary dictionaryWithContentsOfFile:ZJTotalLengthFullpath][ZJFileName(url)] integerValue];
}

#pragma mark - 删除
/**
 *  删除该资源
 */
- (void)deleteFile:(NSString *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:ZJFileFullpath(url)]) {
        
        // 删除沙盒中的资源
        [fileManager removeItemAtPath:ZJFileFullpath(url) error:nil];
        // 删除任务
        [self.tasks removeObjectForKey:ZJFileName(url)];
        [self.sessionModels removeObjectForKey:@([self getTask:url].taskIdentifier).stringValue];
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:ZJTotalLengthFullpath]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:ZJTotalLengthFullpath];
            [dict removeObjectForKey:ZJFileName(url)];
            [dict writeToFile:ZJTotalLengthFullpath atomically:YES];
            
        }
    }
}

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:ZJCachesDirectory]) {
        // 删除沙盒中所有资源
        [fileManager removeItemAtPath:ZJCachesDirectory error:nil];
        // 删除任务
        [[self.tasks allValues] makeObjectsPerformSelector:@selector(cancel)];
        [self.tasks removeAllObjects];
        
        for (ZJDownloaderItem *sessionModel in [self.sessionModels allValues]) {
            [sessionModel.stream close];
        }
        [self.sessionModels removeAllObjects];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:ZJTotalLengthFullpath]) {
            [fileManager removeItemAtPath:ZJTotalLengthFullpath error:nil];
        }
    }
}


#pragma mark -- NSURLSessionDownloadDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    
    
    ZJDownloaderItem *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 打开流
    [sessionModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + ZJDownloaderItemLength(sessionModel.downloadUrl);
    sessionModel.totalLength = totalLength;//
    
    sessionModel.totalLengthBlock(totalLength/1024.0/1024.0);
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:ZJTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[ZJFileName(sessionModel.downloadUrl)] = @(totalLength);
    [dict writeToFile:ZJTotalLengthFullpath atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}
/**
 <NSHTTPURLResponse: 0x2807ee880> { URL: http://house.china.com.cn/img/voice/hdzxjh.mp4 } { Status Code: 206, Headers {
 CACHE =     (
 "TCP_HIT"
 );
 "CC_CACHE" =     (
 "TCP_MISS"
 );
 "Cache-Control" =     (
 "max-age=86400"
 );
 Connection =     (
 "keep-alive"
 );
 "Content-Length" =     (
 22072560
 );
 "Content-Range" =     (
 "bytes 0-22072559/22072560"
 );
 "Content-Type" =     (
 "video/mp4"
 );
 Date =     (
 "Tue, 12 Mar 2019 08:30:54 GMT"
 );
 Etag =     (
 "\"bf1a74fe8ec9d31:0\""
 );
 Expires =     (
 "Wed, 13 Mar 2019 07:59:51 GMT"
 );
 "Last-Modified" =     (
 "Sun, 01 Apr 2018 07:56:51 GMT"
 );
 "Powered-By-ChinaCache" =     (
 "HIT from CNC-DZ-3-3W7"
 );
 Server =     (
 nginx
 );
 "X-Powered-By" =     (
 "ASP.NET"
 );
 } }
 */

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    ZJDownloaderItem *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 写入数据
    [sessionModel.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = ZJDownloaderItemLength(sessionModel.downloadUrl);
    NSUInteger expectedSize = sessionModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    
    
    if (sessionModel.progressBlock && progress) {
         sessionModel.progressBlock(progress);
    }
  
    NSLog(@"%f",progress);
    
    //(receivedSize, expectedSize, progress);

}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    ZJDownloaderItem *sessionModel = [self getSessionModel:task.taskIdentifier];
    if (!sessionModel) return;
    
    if ([self isCompletion:sessionModel.downloadUrl]) {
        // 下载完成
        sessionModel.stateBlock(ZJDownloadStateCompleted);
    } else if (error){
        // 下载失败
        sessionModel.stateBlock(ZJDownloadStateFailed);
    }
    
    // 关闭流
    [sessionModel.stream close];
    sessionModel.stream = nil;
    
    // 清除任务
    [self.tasks removeObjectForKey:ZJFileName(sessionModel.downloadUrl)];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
    
}

- (NSString *)path:(NSString *)url{
    
    return ZJFileFullpath(url);
}
/**
 *大小，单位是M
 */
- (float)totalLength:(NSString *)url{
    float all =   [self fileTotalLength:url];
    return all/1024.0/1024.0;
}
/**
 *已经下载的大小，单位是M
 */
- (float)downloadLength:(NSString *)url{
    float downloadLength = ZJDownloaderItemLength(url);
    return downloadLength/1024.0/1024.0;
}


#pragma mark - ZJDownloadOperationDelegate
- (void)zjDownloadOperationStartDownloading:(ZJDownloaderItem *)dItem{
    self.totalLengthBlock(dItem.totalFileSize/1024.0/1024.0);
}
- (void)zjDownloadOperationFinishDownload:(ZJDownloaderItem *)dItem{
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:ZJTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[ZJFileName(dItem.downloadUrl)] = @(dItem.totalFileSize);
    [dict writeToFile:ZJTotalLengthFullpath atomically:YES];
    
    
}
- (void)zjDownloadOperationDownloading:(ZJDownloaderItem *)dItem downloadPercentage:(float)percentage velocity:(float)velocity{

    CGFloat progress = 1.0 * dItem.downloadedFileSize / dItem.totalFileSize;

    NSLog(@"%f",progress);
    
    self.progressBlock(progress);
    
}

@end
