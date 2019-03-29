//
//  VideoList.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/13.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface VideoList : NSObject
@property(copy,nonatomic) NSString * title;
@property(copy,nonatomic) NSString * url;
@property(nonatomic, strong) UIImage * image;
@end
