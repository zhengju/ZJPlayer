//
//  ZJNetWorkUtils.h
//  ZJHTTPNetWorking
//
//  Created by zhengju on 2019/4/7.
//  Copyright © 2019年 zhengju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, ZJNetworkReachabilityStatus) {
    ZJNetworkReachabilityStatusUnknown          = -1,
    ZJNetworkReachabilityStatusNotReachable     = 0,
    ZJNetworkReachabilityStatusReachableViaWWAN2G = 1,
    ZJNetworkReachabilityStatusReachableViaWWAN3G = 2,
    ZJNetworkReachabilityStatusReachableViaWWAN4G = 3,
    ZJNetworkReachabilityStatusReachableViaWWAN5G = 4,
    ZJNetworkReachabilityStatusReachableViaWiFi = 5,
};

typedef void(^netStateBlock)(NSInteger netState);

@interface ZJNetWorkUtils : NSObject

@property(assign) ZJNetworkReachabilityStatus  networkStatus;


/**
 *  网络监测
 *
 *  @param block 判断结果回调
 *
 *  
 */
+(void)netWorkState:(netStateBlock)block;

@end

NS_ASSUME_NONNULL_END
