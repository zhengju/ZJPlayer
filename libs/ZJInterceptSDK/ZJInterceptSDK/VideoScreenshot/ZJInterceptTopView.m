//
//  ZJInterceptTopView.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/11.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJInterceptTopView.h"
#import "ZJInterceptSDK.h"
@interface ZJInterceptTopView()
{
    ZJInterceptTopViewType _actionType;
    UIButton * _selectedBtn;
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

    self.cancelButton = [UIButton buttonWithTitle:@"取消" normalTitleColor:nil selectedTitleColor:nil];
    
    [self.cancelButton bk_addEventHandler:^(id sender) {

        if ([self.delegate respondsToSelector:@selector(back)]) {
            [self.delegate back];

        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
//    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.left.equalTo(self.mas_left).with.offset(5);
//        make.centerY.equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(50, 35));
//
//    }];
    
    //截屏
    self.captureBtn = [UIButton buttonWithTitle:@"截视频" normalTitleColor:[UIColor whiteColor] selectedTitleColor:[UIColor grayColor]];
    [self.captureBtn bk_addEventHandler:^(id sender) {
        _actionType = ZJInterceptTopViewVideo;
        
        if (self.captureBtn != _selectedBtn) {
            _selectedBtn.selected = NO;
            _selectedBtn = self.captureBtn;
            _selectedBtn.selected = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(action:)]) {
            [self.delegate action:ZJInterceptTopViewVideo];
        }
        
    } forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.captureBtn];

//    [self.captureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.right.equalTo(self.mas_centerX).offset(-2.5);
//        make.centerY.equalTo(self);
//        make.height.mas_equalTo(35);
//        make.width.mas_equalTo(70);
//
//    }];
 
    _selectedBtn = self.captureBtn;
    _selectedBtn.selected = YES;

    //GIF截屏
    self.gifScreenshotBtn = [UIButton buttonWithTitle:@"截GIF" normalTitleColor:[UIColor whiteColor] selectedTitleColor:[UIColor grayColor]];
    [self.gifScreenshotBtn bk_addEventHandler:^(id sender) {
        
        _actionType = ZJInterceptTopViewGIF;
        
        if (self.gifScreenshotBtn != _selectedBtn) {
            _selectedBtn.selected = NO;
            _selectedBtn = self.gifScreenshotBtn;
            _selectedBtn.selected = YES;
        }
        if ([self.delegate respondsToSelector:@selector(action:)]) {
            [self.delegate action:ZJInterceptTopViewGIF];
        }
    } forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.gifScreenshotBtn];

//    [self.gifScreenshotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.left.equalTo(self.mas_centerX).offset(2.5);
//        make.centerY.equalTo(self);
//        make.height.mas_equalTo(35);
//        make.width.mas_equalTo(70);
//
//    }];
    //完成
    self.finishBtn = [[UIButton alloc]init];
    [self.finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    
    [self.finishBtn bk_addEventHandler:^(id sender) {
      
        if ([self.delegate respondsToSelector:@selector(finishWithAction:)]) {
            
            [self.delegate finishWithAction:_actionType];
            
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.finishBtn];
    
//    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.right.equalTo(self.mas_right).offset(-10);
//        make.centerY.equalTo(self);
//        make.height.mas_equalTo(35);
//        make.width.mas_equalTo(50);
//
//    }];
}



@end
