//
//  ZJTopView.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJTopView.h"
#import "ZJPlayerSDK.h"
@interface ZJTopView()
{
    int _rateIndex;
}
/**
 左上角返回按钮
 */
@property(strong,nonatomic) UIButton * closeButton;
/**
 显示标题
 */
@property(strong,nonatomic) UILabel * titleLabel;
/**
 播放倍速
 */
@property(strong,nonatomic) UIButton * rateBtn;
/**
 截屏
 */
@property(strong,nonatomic) UIButton * captureBtn;

/**
 GIF截屏
 */
@property(strong,nonatomic) UIButton * gifScreenshotBtn;

@property(strong,nonatomic) NSArray * rates;
@end


@implementation ZJTopView
/**
 倍速
 */
- (NSArray *)rates{
    if (_rates == nil) {
        _rates = @[@"1.0",@"1.25",@"1.5",@"2.0"];
    }
    return _rates;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    _rateIndex = 0;
    
    
    //顶部关闭按钮
    self.closeButton = [[UIButton alloc]init];
    self.closeButton.showsTouchWhenHighlighted = YES;
    [self.closeButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [self.closeButton bk_addEventHandler:^(id sender) {

        if ([self.delegate respondsToSelector:@selector(back)]) {
            [self.delegate back];
            
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.closeButton];
    
    self.closeButton.frame = CGRectMake(5, (self.frameH-35)/2.0, 35, 35);

    self.rateBtn = [[UIButton alloc]init];
    [self.rateBtn setTitle:[NSString stringWithFormat:@"%@X",self.rates[_rateIndex]] forState:UIControlStateNormal];
    WeakObj(self);
    [self.rateBtn bk_addEventHandler:^(id sender) {
        
        if ([self.delegate respondsToSelector:@selector(setRate:)]) {
            
           
            _rateIndex += 1;
            
            // 0 1 2 3 4
            
            if (_rateIndex == self.rates.count ) {
                _rateIndex = 0;
            }
            
            NSString * rateStr = selfWeak.rates[_rateIndex];
            
            
            [selfWeak.delegate setRate:rateStr.floatValue];
            
            [selfWeak.rateBtn setTitle:[NSString stringWithFormat:@"%@X",self.rates[_rateIndex]] forState:UIControlStateNormal];
            
            NSLog(@"%@",[NSString stringWithFormat:@"%@X",selfWeak.rates[_rateIndex]]);
            
            
            
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.rateBtn];
    
    self.rateBtn.frame = CGRectMake(self.frameW-50-5, (self.frameH-25)/2.0, 50, 25);

    //截屏
    self.captureBtn = [[UIButton alloc]init];
    self.captureBtn.showsTouchWhenHighlighted = YES;
    [self.captureBtn setImage:[UIImage imageNamed:@"一键截屏"] forState:UIControlStateNormal];
    
    [self.captureBtn bk_addEventHandler:^(id sender) {
        
        if ([self.delegate respondsToSelector:@selector(fetchScreen)]) {
            [self.delegate fetchScreen];
            
        }

    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.captureBtn];

    self.captureBtn.frame = CGRectMake(CGRectGetMinX(self.rateBtn.frame)-5-35, (self.frameH-25)/2.0, 35, 35);

    //GIF截屏
    self.gifScreenshotBtn = [[UIButton alloc]init];
    self.gifScreenshotBtn.showsTouchWhenHighlighted = YES;
    [self.gifScreenshotBtn setImage:[UIImage imageNamed:@"GIF"] forState:UIControlStateNormal];
    
    [self.gifScreenshotBtn bk_addEventHandler:^(id sender) {
        
        if ([self.delegate respondsToSelector:@selector(gifScreenshot)]) {
            [self.delegate gifScreenshot];
            
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.gifScreenshotBtn];
    
    self.gifScreenshotBtn.frame = CGRectMake(CGRectGetMinX(self.captureBtn.frame)-5-35, (self.frameH-25)/2.0, 35, 35);

    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.titleLabel];
    
    
    self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.closeButton.frame)+5, (self.frameH-25)/2.0, self.frameW-CGRectGetMinX(self.closeButton.frame)-5-CGRectGetMinX(self.gifScreenshotBtn.frame)-5, 25);

}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = _title;
    
}
- (float)rate{
    
    NSString * rateStr = self.rates[_rateIndex];
    
    return rateStr.floatValue;
    
}
- (void)resetRate{
    _rateIndex = 0;
    [self.rateBtn setTitle:[NSString stringWithFormat:@"%@X",self.rates[_rateIndex]] forState:UIControlStateNormal];
}

- (void)resetFrame{
      self.closeButton.frame = CGRectMake(5, (self.frameH-35)/2.0, 35, 35);
    self.rateBtn.frame = CGRectMake(self.frameW-50-5, (self.frameH-25)/2.0, 50, 25);
    self.captureBtn.frame = CGRectMake(CGRectGetMinX(self.rateBtn.frame)-5-35, (self.frameH-25)/2.0, 35, 35);
    self.gifScreenshotBtn.frame = CGRectMake(CGRectGetMinX(self.captureBtn.frame)-5-35, (self.frameH-25)/2.0, 35, 35);
    self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.closeButton.frame)+5, (self.frameH-25)/2.0, self.frameW-CGRectGetMinX(self.closeButton.frame)-5-CGRectGetMinX(self.gifScreenshotBtn.frame)-5, 25);

}

@end
