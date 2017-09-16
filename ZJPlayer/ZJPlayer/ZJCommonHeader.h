//
//  ZJCommonHeader.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#ifndef ZJCommonHeader_h
#define ZJCommonHeader_h

#import "ZJPlayer.h"
#import "UIView+Player.h"
#import "ZJCacheTask.h"
#import "ZJLoadingIndicator.h"
#import "ZJProgress.h"
#import "UIViewController+Player.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+UIKit.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define WeakObj(o) __weak typeof(o) o##Weak = o;
//LOG日志
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stdout,"\n==========================START===========================\n😄😃😄 Class:%s\n🔴❤️😃 Line:%d\n😄😃😄 TimeStampe:%s\n===========================LOG============================\n%s\n===========================END============================\n",[[[[NSString stringWithUTF8String:__FILE__] lastPathComponent]componentsSeparatedByString:@"."].firstObject UTF8String], __LINE__, __TIMESTAMP__ ,[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#else
#define NSLog(format, ...)
#endif

#endif /* ZJCommonHeader_h */
