//
//  ZJTopView.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJTopView.h"

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




@property(strong,nonatomic) NSArray * rates;
@end


@implementation ZJTopView

- (NSArray *)rates{
    if (_rates == nil) {
        _rates = @[@"1.0",@"1.25",@"1.5",@"2.0"];
    }
    return _rates;
}
- (instancetype)init{
    if (self = [super init]) {
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    _rateIndex = 0;
    
    
    //顶部删除按钮
    self.closeButton = [[UIButton alloc]init];
    self.closeButton.showsTouchWhenHighlighted = YES;
    [self.closeButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    [self.closeButton bk_addEventHandler:^(id sender) {

        if ([self.delegate respondsToSelector:@selector(back)]) {
            [self.delegate back];
            
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self).with.offset(5);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(35, 35));
        
        
    }];
    
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
    [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.mas_right).offset(-5);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(25);
        make.width.mas_equalTo(50);
    }];
    //截屏
    self.captureBtn = [[UIButton alloc]init];
    [self.captureBtn setTitle:@"截屏" forState:UIControlStateNormal];
    [self.captureBtn bk_addEventHandler:^(id sender) {
        
        if ([self.delegate respondsToSelector:@selector(fetchScreen)]) {
            [self.delegate fetchScreen];
            
        }
        
        
       
       
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.captureBtn];

    [self.captureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.rateBtn.mas_left).offset(-5);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(25);
        make.width.mas_equalTo(50);
        
        
    }];
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.closeButton.mas_right).offset(5);
        make.right.mas_equalTo(self.captureBtn.mas_left).offset(-5);
    }];

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



@end
