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

@property(nonatomic, strong) UILabel * titleLabel;
@property(nonatomic, strong) UILabel * bottomDesL;

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
    self.topView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.topView];
   
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.numberOfLines = 0;
    [self.topView addSubview:self.titleLabel];
    
    
    
    
    self.playerView = [[UIView alloc]init];
    self.playerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.playerView];
    
    _bgView = [[UIImageView alloc]init];
    [self addSubview:_bgView];
    _bgView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomView];

    self.bottomDesL = [[UILabel alloc]init];
    self.bottomDesL.textColor = [UIColor blueColor];
    self.bottomDesL.textAlignment = NSTextAlignmentCenter;
    [self.bottomView addSubview:self.bottomDesL];
    self.bottomDesL.layer.masksToBounds = YES;
    self.bottomDesL.layer.cornerRadius = 5;
    self.bottomDesL.font = [UIFont systemFontOfSize:14];
    self.bottomDesL.layer.borderColor = [UIColor blueColor].CGColor;
    self.bottomDesL.layer.borderWidth = 2;
    
    
    //frame
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.height.mas_equalTo(50);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView);
        make.left.mas_equalTo(self.topView);
        make.right.mas_equalTo(self.topView);
        make.height.mas_equalTo(self.topView.mas_height);
    }];

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(0);
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.height.mas_equalTo(40);
    }];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.bottom.mas_equalTo(self.bottomView.mas_top).offset(0);
    }];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.bottom.mas_equalTo(self.bottomView.mas_top).offset(0);
    }];

    [self.bottomDesL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomView.mas_bottom).offset(-5);
        make.left.mas_equalTo(self.bottomView.mas_left);
        make.width.mas_equalTo(60);
        make.top.mas_equalTo(self.bottomView.mas_top).offset(5);
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
    
    self.titleLabel.text = _model.title;
    self.bottomDesL.text = @"短视频";
    
    if (_model.image) {
        self.bgView.image = _model.image;
    }else{
        //放入异步线程中
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage * image = [ZJCustomTools thumbnailImageRequest:5.0 url:_model.url];
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                self.bgView.image = image;
                _model.image = image;
            });
        });
    }
}
- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;

}


@end
