//
//  UINavigationController+Player.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "UINavigationController+Player.h"
/** 导入头文件 */
#import <objc/runtime.h>

@implementation UINavigationController (Player)

+(void)load{

    Method originalpushM = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
    Method exchangepushM = class_getInstanceMethod([self class], @selector(zj_pushViewController:animated:));
    method_exchangeImplementations(originalpushM, exchangepushM);
    
    Method originalPopM = class_getInstanceMethod([self class], @selector(popViewControllerAnimated:));
    Method exchangePopM = class_getInstanceMethod([self class], @selector(zj_popViewControllerAnimated:));
    method_exchangeImplementations(originalPopM, exchangePopM);
    
}


- (void)zj_pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
   
    [self zj_pushViewController:viewController animated:animated];
}
- (UIViewController *)zj_popViewControllerAnimated:(BOOL)animated{
  
    
    UIViewController * controller = self.viewControllers.lastObject;
    
    [self zj_popViewControllerAnimated:animated];
    
    return controller;
}
- (BOOL)shouldAutorotate{//是否支持旋转自动屏幕
    return [[self.viewControllers lastObject] shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    //支持哪些方向
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}
//放开之后不支持其他横屏
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation//默认显示的方向
{
    NSLog(@"Nav+preferredInterfaceOrientationForPresentation:%ld",(long)[[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation]);
    

    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];

}
@end
