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
    
    /** 获取原始setBackgroundColor方法 */
    Method originalM = class_getInstanceMethod([self class], @selector(viewWillDisappear:));
    
    /** 获取自定义的pb_setBackgroundColor方法 */
    Method exchangeM = class_getInstanceMethod([self class], @selector(zj_viewWillDisappear:));
    
    /** 交换方法 */
    method_exchangeImplementations(originalM, exchangeM);
}
- (void)zj_viewWillDisappear:(BOOL)animated{

    NSLog(@"%s",__FUNCTION__);

    //发送通知
    [[NSNotificationCenter defaultCenter]postNotificationName:ZJViewControllerWillDisappear object:nil];
    
    [self zj_viewWillDisappear:animated];
}
@end
