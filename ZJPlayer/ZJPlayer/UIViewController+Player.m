//
//  UIViewController+Player.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "UIViewController+Player.h"

/** 导入头文件 */
#import <objc/runtime.h>

@implementation UIViewController (Player)

+(void)load{
    

    Method originalViewWillDisappearM = class_getInstanceMethod([self class], @selector(viewWillDisappear:));
    Method exchangeViewWillDisappearM = class_getInstanceMethod([self class], @selector(zj_viewWillDisappear:));
    method_exchangeImplementations(originalViewWillDisappearM, exchangeViewWillDisappearM);
 
    Method originalViewWillAppearM = class_getInstanceMethod([self class], @selector(viewWillAppear:));
    Method exchangeViewWillAppearM = class_getInstanceMethod([self class], @selector(zj_viewWillAppear:));
    method_exchangeImplementations(originalViewWillAppearM, exchangeViewWillAppearM);

}
- (void)zj_viewWillDisappear:(BOOL)animated{

    //发送通知
    [[NSNotificationCenter defaultCenter]postNotificationName:ZJViewControllerWillDisappear object:nil];
    
    [self zj_viewWillDisappear:animated];
}
- (void)zj_viewWillAppear:(BOOL)animated{
    //发送通知
    [[NSNotificationCenter defaultCenter]postNotificationName:ZJViewControllerWillAppear object:nil];
    
    [self zj_viewWillAppear:animated];
}
@end
