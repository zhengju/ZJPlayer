//
//  AppDelegate+Player.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/22.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "AppDelegate+Player.h"
/** 导入头文件 */
#import <objc/runtime.h>
@implementation AppDelegate (Player)

+(void)load{

    Method originalM = class_getInstanceMethod([self class], @selector(application: didFinishLaunchingWithOptions:));
    Method exchangeM = class_getInstanceMethod([self class], @selector(zj_application: didFinishLaunchingWithOptions:));
    method_exchangeImplementations(originalM, exchangeM);
    
  
}

- (BOOL)zj_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self zj_application:application didFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}
//received remote event
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    NSLog(@"event tyipe:::%ld   subtype:::%ld",(long)event.type,(long)event.subtype);    //type==2  subtype==单击暂停键：103，双击暂停键104
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:{
                NSLog(@"play---------");
            }break;
            case UIEventSubtypeRemoteControlPause:{
                NSLog(@"Pause---------");
            }break;
            case UIEventSubtypeRemoteControlStop:{
                NSLog(@"Stop---------");
            }break;
            case UIEventSubtypeRemoteControlTogglePlayPause:{
                
                //单击暂停键：103
                NSLog(@"单击暂停键：103");
                //发送通知
                [[NSNotificationCenter defaultCenter]postNotificationName:ZJEventSubtypeRemoteControlTogglePlayPause object:nil];
            }break;
            case UIEventSubtypeRemoteControlNextTrack:{                //双击暂停键：104
                NSLog(@"双击暂停键：104");
            }break;
            case UIEventSubtypeRemoteControlPreviousTrack:{
                NSLog(@"三击暂停键：105");
            }break;
            case UIEventSubtypeRemoteControlBeginSeekingForward:{
                NSLog(@"单击，再按下不放：108");
            }break;
                
            case UIEventSubtypeRemoteControlEndSeekingForward:{
                NSLog(@"单击，再按下不放，松开时：109");                 }break;
            default:
                break;
        }
    }
}

@end
