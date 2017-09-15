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
    
    _playBtn = [[UIButton alloc]init];
    [_playBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    [_playBtn bk_addEventHandler:^(id sender) {


        [self initPlayer];

        [self.player play];
        
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
    self.player.tag = 1002;
    self.player.indexPath = _indexPath;
    
    [self.player removeFromSuperview];
    self.player.delegate = nil;

    self.player.delegate = self;
    [self addSubview:self.player];

    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-10);
    }];
    
    self.player.url = [NSURL URLWithString:self.model.url];
    
    self.player.title = self.model.title;

}
- (void)setModel:(VideoList *)model{
    _model = model;

    self.player = [ZJPlayer sharePlayer];
    self.player.tag = 1002;
    
    self.player.isAutoPlay = YES;
    _bgView.image = [self.player getVideoPreViewImage:[NSURL URLWithString:_model.url]];
    
    [self initPlayer];
    [self.player pause];
}
- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    
    self.player = [ZJPlayer sharePlayer];

    self.player.tag = 1002;
    if (self.player.indexPath == _indexPath) {//当前播放的cell
        
        [self initPlayer];
        [self.player pause];
    }

}
#pragma ZJPlayerDelegate
- (void)playFinishedPlayer:(ZJPlayer *)player{
    NSLog(@"播放完毕");
    
}

@end
