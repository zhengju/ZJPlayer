//
//  ZJTopView.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/15.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJTopView.h"

@interface ZJTopView()
/**
 左上角关闭按钮
 */
@property(strong,nonatomic) UIButton * closeButton;
@property(strong,nonatomic) UILabel * titleLabel;
@end


@implementation ZJTopView

- (instancetype)init{
    if (self = [super init]) {
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
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
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.closeButton.mas_right).offset(5);
        make.right.mas_equalTo(self.mas_right).offset(-5);
    }];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = _title;
    
}
@end
