//
//  ZJSelectFrameView.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/11.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJSelectFrameView.h"
#import "ZJInterceptSDK.h"
@interface ZJSelectFrameView()
@property(nonatomic, strong) UIButton * originalBtn;
@property(nonatomic, strong) UIButton * verticalPlateBtn;
@property(nonatomic, strong) UIButton * filmBtn;
@property(nonatomic, strong) UIButton * squareBtn;
@property(nonatomic, strong) UIButton * selectedBtn;
@end


@implementation ZJSelectFrameView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self configureUI];
    }
    return self;
}

- (void)configureUI{
    self.backgroundColor = [UIColor clearColor];
    
    //
    self.originalBtn = [[UIButton alloc]init];
    [self.originalBtn setTitle:@"原始" forState:UIControlStateNormal];
    [self.originalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.originalBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.selectedBtn = self.originalBtn;
    self.selectedBtn.selected = YES;
    
    
    
    [self.originalBtn bk_addEventHandler:^(id sender) {
        
        [self setSelectedBtnWithBtn:self.originalBtn];
        
        if ([self.delegate respondsToSelector:@selector(selectedFrameType:)]) {
            
            [self.delegate selectedFrameType:ZJSelectFrameViewOriginal];
            
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.originalBtn];
    
    self.originalBtn.frame = CGRectMake(5, 10, 50, 35);
    
    //
    self.verticalPlateBtn = [[UIButton alloc]init];
    [self.verticalPlateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.verticalPlateBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.verticalPlateBtn setTitle:@"竖版" forState:UIControlStateNormal];
    [self.verticalPlateBtn bk_addEventHandler:^(id sender) {
        [self setSelectedBtnWithBtn:self.verticalPlateBtn];
        if ([self.delegate respondsToSelector:@selector(selectedFrameType:)]) {
            
            [self.delegate selectedFrameType:ZJSelectFrameViewVerticalPlate];
            
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.verticalPlateBtn];
    
    self.verticalPlateBtn.frame = CGRectMake(self.frameW-50-5, 10, 50, 35);

    //
    self.filmBtn = [[UIButton alloc]init];
    [self.filmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.filmBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.filmBtn setTitle:@"电影" forState:UIControlStateNormal];
    [self.filmBtn bk_addEventHandler:^(id sender) {
        [self setSelectedBtnWithBtn:self.filmBtn];
        if ([self.delegate respondsToSelector:@selector(selectedFrameType:)]) {
            
            [self.delegate selectedFrameType:ZJSelectFrameViewFilm];
            
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.filmBtn];
    
    self.filmBtn.frame = CGRectMake(5, self.frameH-35-10, 50, 35);

    self.squareBtn = [[UIButton alloc]init];
    [self.squareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.squareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.squareBtn setTitle:@"方形" forState:UIControlStateNormal];
    [self.squareBtn bk_addEventHandler:^(id sender) {
        [self setSelectedBtnWithBtn:self.squareBtn];
        if ([self.delegate respondsToSelector:@selector(selectedFrameType:)]) {
            
            [self.delegate selectedFrameType:ZJSelectFrameViewSquare];
            
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.squareBtn];
    
    self.squareBtn.frame = CGRectMake(self.frameW-50-5, self.frameH-10-35, 50, 35);

}
- (void)setSelectedBtnWithBtn:(UIButton *)btn{
    if (self.selectedBtn != btn) {
        self.selectedBtn.selected = NO;
        self.selectedBtn = btn;
        self.selectedBtn.selected = YES;
    }
}

@end
