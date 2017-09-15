//
//  ZJControlView.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJControlView.h"


@interface ZJControlView()

@end

@implementation ZJControlView
- (void)setCurrentTime:(NSString *)currentTime{
    _currentTime = currentTime;
    self.nowLabel.text = _currentTime;
    
}
- (void)setRemainingTime:(NSString *)remainingTime{
    _remainingTime = remainingTime;
    self.remainLabel.text = _remainingTime;
}
- (float)sliderValue{
    return self.slider.value;
    
}
- (void)setSliderValue:(float)sliderValue{
    
    self.slider.value = sliderValue;
}

- (void)setProgress:(float)progress{
    _progress = progress;
     [self.progressView setProgress:_progress animated:NO];
}
- (void)setIsPlay:(BOOL)isPlay{
    _isPlay = isPlay;
    if (_isPlay) {
        
        [self.playBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    }else{
     
        [self.playBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    }
}
- (instancetype)init{
    if (self = [super init]) {
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    //播放按钮
    self.playBtn = [[UIButton alloc]init];
    
    self.isPlay = NO;
    
    self.playBtn.showsTouchWhenHighlighted = YES;
    
    [self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.playBtn];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.height.with.mas_equalTo(35);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    //放缩按钮
    self.scalingBtn = [[UIButton alloc]init];
    [self.scalingBtn setImage:[UIImage imageNamed:@"放大"] forState:UIControlStateNormal];
    self.scalingBtn.showsTouchWhenHighlighted = YES;
    [self.scalingBtn bk_addEventHandler:^(id sender) {

        if ([self.delegate respondsToSelector:@selector(clickFullScreen)]) {
            [self.delegate clickFullScreen];
        }

    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.scalingBtn];
    
    [self.scalingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-5);
        make.height.with.mas_equalTo(35);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    // 底部进度条
    
    self.slider = [[UISlider alloc]init];
    self.slider.continuous = YES;
    self.slider.minimumValue = 0.0;
    self.slider.minimumTrackTintColor = [UIColor greenColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.value = 0.0;
    
    [self.slider addTarget:self action:@selector(sliderDragValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.slider addTarget:self action:@selector(sliderTapValueChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderTapValueChange:) forControlEvents:UIControlEventTouchUpOutside];
    [self.slider addTarget:self action:@selector(sliderTapValueChange:) forControlEvents:UIControlEventTouchCancel];
    
    UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchSlider:)];
    [self.slider addGestureRecognizer:tapSlider];
    [self addSubview:self.slider];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.playBtn.mas_right);
        make.right.mas_equalTo(self.scalingBtn.mas_left);
        
    }];
 // 底部缓存进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = [UIColor blueColor];
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    [self addSubview:self.progressView];
    [self.progressView setProgress:0.0 animated:NO];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider).with.offset(0);
        make.right.equalTo(self.slider);
        make.height.mas_equalTo(2);
        make.centerY.equalTo(self.slider).with.offset(1);
    }];
    [self sendSubviewToBack:self.progressView];
    
    // 底部左侧时间轴
    self.nowLabel = [[UILabel alloc] init];
    self.nowLabel.textColor = [UIColor whiteColor];
    self.nowLabel.font = [UIFont systemFontOfSize:13];
    self.nowLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.nowLabel];
    [self.nowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider.mas_left).with.offset(0);
        make.top.equalTo(self.slider.mas_bottom).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    // 底部右侧时间轴
    self.remainLabel = [[UILabel alloc] init];
    self.remainLabel.textColor = [UIColor whiteColor];
    self.remainLabel.font = [UIFont systemFontOfSize:13];
    self.remainLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.remainLabel];
    [self.remainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.slider.mas_right).with.offset(0);
        make.top.equalTo(self.slider.mas_bottom).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];

}
- (void)play:(UIButton *)button{
    
    self.isPlay = !self.isPlay;
    
    if (self.isPlay) {
        if ([self.delegate respondsToSelector:@selector(play)]) {
            [self.delegate play];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(pause)]) {
            [self.delegate pause];
        }
    }
}
// 拖拽的时候调用  这个时候不更新视频进度
- (void)sliderDragValueChange:(UISlider *)slider
{
    if ([self.delegate respondsToSelector:@selector(sliderDragValueChange:)]) {
        [self.delegate sliderDragValueChange:slider];
        
    }
}
// 点击调用  或者 拖拽完毕的时候调用
- (void)sliderTapValueChange:(UISlider *)slider
{
    if ([self.delegate respondsToSelector:@selector(sliderTapValueChange:)]) {
        [self.delegate sliderTapValueChange:slider];
    }
}
// 点击事件的Slider
- (void)touchSlider:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(touchSlider:)]) {
        [self.delegate touchSlider:tap];
        
    }
}
@end
