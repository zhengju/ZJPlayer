//
//  ZJVolume.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJVolume.h"

@interface ZJVolume()
@property(strong,nonatomic) UIImageView * volumeImg;
@property(strong,nonatomic) UILabel * volumeL;
@property(strong,nonatomic) UIView * superView;
@end



@implementation ZJVolume

- (instancetype)initWithSuperView:(UIView *)superView{
    if (self = [super init]) {
        self.alpha = 0;
        
        self.superView = superView;
        [self.superView addSubview:self];
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
    
    

    
    self.volumeL = [[UILabel alloc]init];
    self.volumeL.text = @"耳机";
    self.volumeL.textColor = RGBACOLOR(37, 17, 9, 1.0);
    [self addSubview:self.volumeL];
    
    
    self.volumeImg = [[UIImageView alloc]init];
    self.volumeImg.image = [UIImage imageNamed:@"声音"];
    [self addSubview:self.volumeImg];
    self.frame = CGRectMake(0, 0, 150, 150);
    //frame
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.superView);
        make.centerY.mas_equalTo(self.superView);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(150);
        
    }];
    [self.volumeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(25);
        
    }];
    
    [self.volumeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(75);
        make.height.mas_equalTo(75);
        
    }];
    
    for (int i = 0; i < 16; i++) {
        CGFloat width = 9;
        
        CGFloat height = 6;
        
        UIView * lattice = [[UIView alloc]initWithFrame:CGRectMake(10 + i*(width-1), self.frame.size.height - height -10, width, height)];
        lattice.tag = 1001 + i;
        lattice.backgroundColor = [UIColor whiteColor];
        lattice.layer.borderColor = RGBACOLOR(37, 17, 9, 1.0).CGColor;
        lattice.layer.borderWidth = 1;
        
        [self addSubview:lattice];
    }
}

- (void)show{
    if ([self isHeadsetPluggedIn]) {
       self.volumeL.text =  @"耳机";
    }else{
    
        self.volumeL.text =  @"声音";
    }
    self.alpha = 1;
}
- (void)dismiss{
    
    
    self.alpha = 0;
    
}
- (void)resetFrameisFullScreen:(BOOL)isFullScreen;{
    
    CGFloat height = self.superView.bounds.size.height;
    CGFloat width = self.superView.bounds.size.width;
    if (isFullScreen) {
        
        height = kScreenWidth;
        
        width = kScreenHeight;
    }
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.superView).offset((height -160)/2.0);
        make.left.mas_equalTo(self.superView).offset((width -200)/2.0);
        
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(150);
        
    }];
}
- (void)setProgress:(float)progress{
    _progress = progress;
    
    
    for (int i = 0; i < 16; i++) {
        
        
        UIView * lattice = [self viewWithTag:1001 + i];
        if (i <= _progress*16) {
            lattice.backgroundColor = [UIColor whiteColor];
            
        }else{
            
            lattice.backgroundColor =RGBACOLOR(37, 17, 9, 1.0);
        }
        
    }
}
#pragma mark -- 检测耳机是否插入
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

@end
