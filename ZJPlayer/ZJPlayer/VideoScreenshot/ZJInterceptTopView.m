//
//  ZJInterceptTopView.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/11.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJInterceptTopView.h"

@interface ZJInterceptTopView()
{
    float _action;
}
/**
 左上角返回按钮
 */
@property(strong,nonatomic) UIButton * cancelButton;
/**
 截视频
 */
@property(strong,nonatomic) UIButton * captureBtn;
/**
 截GIF
 */
@property(strong,nonatomic) UIButton * gifScreenshotBtn;

/**
 完成
 */
@property(strong,nonatomic) UIButton * finishBtn;

@end


@implementation ZJInterceptTopView


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureUI];
    }
    return self;
}
- (void)configureUI{

    self.backgroundColor = [UIColor clearColor];

    //顶部关闭按钮
    self.cancelButton = [[UIButton alloc]init];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton bk_addEventHandler:^(id sender) {

        if ([self.delegate respondsToSelector:@selector(back)]) {
            [self.delegate back];

        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(self.mas_left).with.offset(5);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(50, 35));

    }];
    
    //截屏
    self.captureBtn = [[UIButton alloc]init];
    [self.captureBtn setTitle:@"截视频" forState:UIControlStateNormal];
    [self.captureBtn bk_addEventHandler:^(id sender) {
        _action = 0;
        if ([self.delegate respondsToSelector:@selector(setAction:)]) {
            [self.delegate setAction:0];

        }

    } forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.captureBtn];

    [self.captureBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(self.cancelButton.mas_right).offset(-5);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(70);

    }];
 
    //GIF截屏
    self.gifScreenshotBtn = [[UIButton alloc]init];
    self.gifScreenshotBtn.showsTouchWhenHighlighted = YES;

    [self.gifScreenshotBtn setTitle:@"截GIF" forState:UIControlStateNormal];
    [self.gifScreenshotBtn bk_addEventHandler:^(id sender) {
        _action = 1;
        if ([self.delegate respondsToSelector:@selector(setAction:)]) {
            [self.delegate setAction:1];

        }

    } forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.gifScreenshotBtn];

    [self.gifScreenshotBtn mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.equalTo(self.captureBtn.mas_right).offset(5);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(70);


    }];
    //完成
    self.finishBtn = [[UIButton alloc]init];
    [self.finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    
    [self.finishBtn bk_addEventHandler:^(id sender) {
        
        if ([self.delegate respondsToSelector:@selector(finishWithAction:)]) {
            [self.delegate finishWithAction:_action];
            
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.finishBtn];
    
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.mas_right).offset(-10);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(50);
        
    }];
}
@end
