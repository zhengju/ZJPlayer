//
//  ZJDisplayVideoToSaveTopView.m
//  ZJPlayer
//
//  Created by zhengju on 2018/10/14.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJDisplayVideoToSaveTopView.h"


@interface ZJDisplayVideoToSaveTopView()
{
   
}
/**
 左上角返回按钮
 */
@property(strong,nonatomic) UIButton * cancelButton;

/**
 完成
 */
@property(strong,nonatomic) UIButton * exitBtn;

@end


@implementation ZJDisplayVideoToSaveTopView


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
        
        if ([self.delegate respondsToSelector:@selector(displayVideoToSaveTopViewBack)]) {
            [self.delegate displayVideoToSaveTopViewBack];
            
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
    
    //完成
    self.exitBtn = [[UIButton alloc]init];
    [self.exitBtn setTitle:@"退出" forState:UIControlStateNormal];
    
    [self.exitBtn bk_addEventHandler:^(id sender) {
        
        if ([self.delegate respondsToSelector:@selector(displayVideoToSaveTopViewExit)]) {
            
            [self.delegate displayVideoToSaveTopViewExit];
            
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.exitBtn];
    
//    [self.exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        make.right.equalTo(self.mas_right).offset(-10);
//        make.centerY.equalTo(self);
//        make.height.mas_equalTo(35);
//        make.width.mas_equalTo(50);
//        
//    }];
}



@end

