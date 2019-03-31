//
//  DownloadListCell.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/23.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "DownloadListCell.h"
#import "DownloadList.h"
#import "ZJCustomTools.h"
@interface DownloadListCell()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *cacheL;
@property (weak, nonatomic) IBOutlet UIProgressView *cacheProgress;
@property (weak, nonatomic) IBOutlet UILabel *rightCacheL;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

@end


@implementation DownloadListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)downloadClick:(UIButton *)sender {
    if (self.suspendBlock) {
        
        _model.isDownloading = !_model.isDownloading;
        
        self.suspendBlock(sender);
        
    }
}
- (void)setModel:(DownloadList *)model{
    _model = model;
    
    if (_model.progress == 1.0) {
        [_downloadBtn setTitle:@"下载完成" forState:UIControlStateNormal];
    }else{
        if (_model.isDownloading) {
            [_downloadBtn setTitle:@"取消" forState:UIControlStateNormal];
        }else{
            [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        }
    }
    
    _nameL.text = _model.name;
    _cacheProgress.progress = _model.progress;
    _rightCacheL.text = _model.ratio;
    _cacheL.text = [NSString stringWithFormat:@"已缓存%.0f%%",_model.progress * 100];
   
    
    if (_model.image == nil) {
     
        [ZJCustomTools thumbnailImageRequest:1.0 url:_model.urlString success:^(UIImage *image) {
            self.icon.image = image;
            _model.image = image;
        }];

    }else{
        self.icon.image = _model.image;
    }
}


@end
