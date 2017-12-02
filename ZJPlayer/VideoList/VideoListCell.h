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
@property(copy,nonatomic) dispatch_block_t playBlock;
@property(strong,nonatomic) UIView * topView;
@property(strong,nonatomic) UIView * bottomView;
@property(strong,nonatomic) UIImageView * bgView;
@property(strong,nonatomic) UIView * playerView;
@end
