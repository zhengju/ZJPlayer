//
//  VideoListCell.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/13.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "VideoListCell.h"
#import "ZJPlayer.h"
#import "VideoList.h"
@interface VideoListCell()<ZJPlayerDelegate>
@property(strong,nonatomic) ZJPlayer* player;

@property(strong,nonatomic) UIImageView * bgView;
@property(strong,nonatomic) UIButton * playBtn;


@property(strong,nonatomic) UIView * topView;
@property(strong,nonatomic) UIView * bottomView;

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
   
    _bgView = [[UIImageView alloc]init];
    [self addSubview:_bgView];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-10);
        
    }];
    
    
    
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.topView];
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
        make.bottom.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    
    _playBtn = [[UIButton alloc]init];
    [_playBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    [_playBtn bk_addEventHandler:^(id sender) {


        [self initPlayer];

        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_playBtn];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.with.mas_equalTo(40);
        
    }];
}

#pragma 加载视频player
- (void)initPlayer{

  
    self.player = [ZJPlayer sharePlayer];

    self.player.indexPath = _indexPath;
    
    self.player.url = [NSURL URLWithString:self.model.url];
    
    self.player.title = self.model.title;
    
    [self.player removeFromSuperview];
    self.player.delegate = nil;

    self.player.delegate = self;
    [self addSubview:self.player];

    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.bottomView.mas_top).offset(0);
    }];
  
    
    [self.player play];
    
}
- (void)setModel:(VideoList *)model{
    _model = model;

    self.player = [ZJPlayer sharePlayer];
  
    
    //放入异步线程中
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage * image = [self.player getVideoPreViewImage:[NSURL URLWithString:_model.url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            self.bgView.image = image;
        });
    });
    
}
- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;

}
#pragma ZJPlayerDelegate
- (void)playFinishedPlayer:(ZJPlayer *)player{
    NSLog(@"播放完毕");
    
}

@end
