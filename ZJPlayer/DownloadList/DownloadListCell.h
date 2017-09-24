//
//  DownloadListCell.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/23.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DownloadList;
@interface DownloadListCell : UITableViewCell
@property (nonatomic, copy) void(^suspendBlock)( BOOL isSuspend);
@property(strong,nonatomic) DownloadList * model;
@end
