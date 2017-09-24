//
//  DownloadListCell.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/23.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "DownloadListCell.h"
#import "DownloadList.h"
@interface DownloadListCell()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *cacheL;
@property (weak, nonatomic) IBOutlet UIProgressView *cacheProgress;
@property (weak, nonatomic) IBOutlet UILabel *rightCacheL;

@end


@implementation DownloadListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)downloadClick:(UIButton *)sender {
    if (self.suspendBlock) {
        sender.selected = !sender.selected;
        self.suspendBlock(sender);
    }
}
- (void)setModel:(DownloadList *)model{
    _model = model;
    _nameL.text = _model.name;
    _cacheProgress.progress = _model.progress;
}


@end
