//
//  ZJCacheTask.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/14.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJCacheTask.h"
#import "NSString+Hash.h"
@interface ZJCacheTask()

@end

@implementation ZJCacheTask

+ (instancetype)shareTask
{
    static ZJCacheTask *cachetask = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        cachetask = [[ZJCacheTask alloc]init];
        
        [cachetask clearCache];//默认删除上次记录
    });
    return cachetask;
}
- (NSString *)path{
    // 1.获得沙盒根路径
    NSString *home = NSHomeDirectory();
    
    // 2.document路径
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    
    // 3.文件路径
    NSString *filepath = [docPath stringByAppendingPathComponent:@"videoTask.plist"];
    
    return filepath;
}
- (NSString *)cacheImagePath{
    // 1.获得沙盒根路径
    NSString *home = NSHomeDirectory();
    
    // 2.document路径
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    
    // 3.文件路径
    NSString *filepath = [docPath stringByAppendingPathComponent:@"cacheImage.plist"];
    
    return filepath;
}
- (void)writeToFileUrl:(NSString *)url time: (NSTimeInterval) currentTime{
    
    
    NSString * filepath = [self path];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithContentsOfFile:filepath];

    
    if (tasks == nil) {
        tasks = [NSMutableArray arrayWithCapacity:0];
    }
    
    BOOL isHave = NO;
    
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:currentTime];
    
    for (NSMutableDictionary * dic in tasks) {

        if ([dic[@"url"] isEqualToString:url]) {

            [dic setObject:date forKey:@"time"];
            
            isHave = YES;
        }
    }
    
    if (isHave == NO) {
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];

        [dic setObject:date forKey:@"time"];
        
        [dic setObject:url forKey:@"url"];
            
        [tasks addObject:dic];
    }
    
    [tasks writeToFile:filepath atomically:YES];
    
}
- (NSTimeInterval)queryToFileUrl:(NSString *)url{
   
    
    NSTimeInterval time = 0;

    NSString * filepath = [self path];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithContentsOfFile:filepath];
    
    for (NSMutableDictionary * dic in tasks) {
        
        if ([dic[@"url"] isEqualToString:url]) {
            
            NSDate * date = [dic objectForKey:@"time"];
            
           time = [date timeIntervalSince1970];

        }
    }
    return time;
}
- (void)clearCacheToFileUrl:(NSString *)url{
    [self writeToFileUrl:url time:0];
}
- (void)clearCache{
 
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    NSString * filepath = [self path];
      BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filepath];
    if (!blHave) {
        NSLog(@"no  have");
        return ;
    }else {
        NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:filepath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
    }
}

- (void)cacheImageWith:(NSString *)url image:(UIImage *)image{
    
     NSString * md5Str = [url md5String];
    
    NSString * filepath = [self cacheImagePath];
    
    self.cacheImageDic = [[NSMutableDictionary alloc] initWithContentsOfFile:filepath];

    if (self.cacheImageDic == nil) {
        self.cacheImageDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
   
    [self.cacheImageDic setObject:imageData forKey:md5Str];

 
    [self.cacheImageDic writeToFile:filepath atomically:YES];
  
}
/**
 缓存图片
 */
- (UIImage *)imageWith:(NSString *)url{
    
    NSString * md5Str = [url md5String];
    
    NSData * data = [self.cacheImageDic valueForKey:md5Str];
    
    UIImage * image = [UIImage imageWithData:data];
    
    if (!image){
        
         self.cacheImageDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[self cacheImagePath]];

        data = [self.cacheImageDic valueForKey:md5Str];

        image = [UIImage imageWithData:data];
    }
    return image;
}
@end
