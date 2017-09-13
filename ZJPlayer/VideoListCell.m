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
@interface VideoListCell()
@property(strong,nonatomic) ZJPlayer* player;
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
   
    self.player = [[ZJPlayer alloc]initWithUrl:[NSURL URLWithString:@""]];
    
    self.player.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.player];
    
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-10);

    }];
}

- (void)setModel:(VideoList *)model{
    _model = model;
    self.player.url = [NSURL URLWithString:model.url];
    self.player.title = _model.title;
}
@end
