//
//  ZJNetWorkUtils.m
//  ZJHTTPNetWorking
//
//  Created by zhengju on 2019/4/7.
//  Copyright © 2019年 zhengju. All rights reserved.
//

#import "ZJNetWorkUtils.h"
#import "ZJNetworkReachabilityManager.h"
@implementation ZJNetWorkUtils
#pragma mark----网络检测
+(void)netWorkState:(netStateBlock)block;
{
    ZJNetworkReachabilityManager *manager = [ZJNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    
   __block ZJNetworkReachabilityStatus networkStatus;
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status==0||status==-1) {
            networkStatus = ZJNetworkReachabilityStatusUnknown;
            block(networkStatus);
        }else{
            if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                networkStatus = ZJNetworkReachabilityStatusReachableViaWiFi;
            }else if(status == AFNetworkReachabilityStatusReachableViaWWAN){
                networkStatus = [ZJNetWorkUtils networkingStatesFromStatebar];
            }
            
            block(networkStatus);
        }
    }];
}
#pragma mark - 获取当前网络状态
+ (ZJNetworkReachabilityStatus )networkingStatesFromStatebar {

    
    NSArray *subviews = nil;
    id statusBar = [[UIApplication sharedApplication] valueForKeyPath:@"statusBar"];
    if ([statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        subviews = [[[statusBar valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    } else {
        subviews = [[statusBar valueForKey:@"foregroundView"] subviews];
    }

    int type = 0;
    ZJNetworkReachabilityStatus status = ZJNetworkReachabilityStatusReachableViaWWAN4G;

    for (id child in subviews) {
        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
        }
    }
    
    NSString *stateString = @"4G";
    
    switch (type) {
        case 0:
            status = ZJNetworkReachabilityStatusNotReachable;
            stateString = @"notReachable";
            break;
            
        case 1:
            status = ZJNetworkReachabilityStatusReachableViaWWAN2G;
            stateString = @"2G";
            break;
            
        case 2:
            status = ZJNetworkReachabilityStatusReachableViaWWAN3G;
            stateString = @"3G";
            break;
            
        case 3:
            status = ZJNetworkReachabilityStatusReachableViaWWAN4G;
            stateString = @"4G";
            break;
            
        case 4:
            status = ZJNetworkReachabilityStatusReachableViaWWAN4G;
            stateString = @"LTE";
            break;
            
//        case 5:  检查不准确，去掉这个选项
//            status = ZJNetworkReachabilityStatusReachableViaWiFi;
//            stateString = @"wifi";
//            break;
            
        default:
            status = ZJNetworkReachabilityStatusReachableViaWWAN4G;
            break;
    }
    NSLog(@"----当前状态%@",stateString);
    return status;
}
@end
