//
//  ZJBrightness.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/18.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJBrightness.h"


@interface ZJBrightness()
@property(strong,nonatomic) UIImageView * brightnessImg;
@property(strong,nonatomic) UILabel * brightL;
@property(strong,nonatomic) UIView * superView;
@end

@implementation ZJBrightness
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
    
    
    
    self.brightL = [[UILabel alloc]init];
    self.brightL.text = @"亮度";
    self.brightL.textColor = RGBACOLOR(90, 90, 90, 1.0);
    [self addSubview:self.brightL];
    
    
    self.brightnessImg = [[UIImageView alloc]init];
    self.brightnessImg.image = [UIImage imageNamed:@"亮度"];
    [self addSubview:self.brightnessImg];
    self.frame = CGRectMake(0, 0, 150, 150);
    //frame
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.superView);
        make.centerY.mas_equalTo(self.superView);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(150);
        
    }];
    [self.brightL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(25);
        
    }];
    
    [self.brightnessImg mas_makeConstraints:^(MASConstraintMaker *make) {
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
        lattice.layer.borderColor = RGBACOLOR(90, 90, 90, 1.0).CGColor;
        lattice.layer.borderWidth = 1;
        
        [self addSubview:lattice];
    }
}

- (void)show{
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
         
            lattice.backgroundColor =RGBACOLOR(90, 90, 90, 1.0);
        }

    }
}
@end
