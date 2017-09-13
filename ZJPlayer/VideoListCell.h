//
//  VideoListCell.h
//  ZJPlayer
//
//  Created by zhengju on 2017/9/13.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoList;
@interface VideoListCell : UITableViewCell
@property(strong,nonatomic) VideoList * model;
@property(strong,nonatomic) NSIndexPath *indexPath ;
@end
