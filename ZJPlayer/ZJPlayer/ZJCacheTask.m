//
//  ZJCacheTask.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/14.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJCacheTask.h"

@interface ZJCacheTask()

@end

@implementation ZJCacheTask

+ (instancetype)shareTask
{
    static ZJCacheTask *cachetask = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        cachetask = [[ZJCacheTask alloc]init];
        
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
- (void)writeToFileUrl:(NSString *)url time: (NSTimeInterval) currentTime{
    
    
    NSString * filepath = [self path];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithContentsOfFile:filepath];

    
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
@end
