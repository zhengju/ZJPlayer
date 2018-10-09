//
//  VideoListCell.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/13.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "VideoListCell.h"
#import "ZJCommonHeader.h"
#import "ZJCustomTools.h"
#import "VideoList.h"
@interface VideoListCell()



@property(strong,nonatomic) UIButton * playBtn;




@end


@implementation VideoListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.userInteractionEnabled = YES;
        
        [self configure];
    
    }
    return self;
    
}

- (void)configure{
   
    

    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.topView];
   
    self.playerView = [[UIView alloc]init];
    self.playerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.playerView];
    
    _bgView = [[UIImageView alloc]init];
    [self addSubview:_bgView];
    
    
    
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.bottomView];

    //frame
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(0);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(30);
    }];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.bottomView.mas_top).offset(0);
    }];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.bottomView.mas_top).offset(0);
    }];
    
    _playBtn = [[UIButton alloc]init];
    [_playBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    [_playBtn bk_addEventHandler:^(id sender) {

        if (self.playBlock) {
            self.playBlock();
        }

    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_playBtn];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.with.mas_equalTo(40);
        
    }];
}


- (void)setModel:(VideoList *)model{
    _model = model;
    //放入异步线程中
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage * image = [ZJCustomTools thumbnailImageRequest:5.0 url:_model.url];
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            self.bgView.image = image;
           
        });
    });
}
- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;

}


@end
