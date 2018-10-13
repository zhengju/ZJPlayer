//
//  ZJInterceptBottomTools.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/13.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJInterceptBottomTools.h"
#import "ZJCommonHeader.h"

#define kClipTimeScrollTag  20


@interface ZJInterceptBottomTools()

@property(nonatomic, strong) UIView * sliderView;

@property (nonatomic, strong) UIScrollView *scrollView;         //视频封面的滚动

@property (nonatomic, strong) UIImageView *leftSliderImgView;   //左滑块
@property (nonatomic, strong) UIImageView *rightSliderImgView;  //右滑块

@property (nonatomic, strong) UIImageView *upOpacityImgView;    //上边白色
@property (nonatomic, strong) UIImageView *downOpacityImgView;  //下班白色

@property (nonatomic, strong) UILabel *selDurationLabel;        //显示时间label

@property (nonatomic, assign) unsigned long videoDuration;  //截取的时间长度

@property (nonatomic, assign) CGFloat imgWidth;   //指示器图片宽
@property (nonatomic, assign) CGFloat minWidth;   //两个指示器间隔距离最短 对应时间是5秒
@property (nonatomic, assign) CGFloat maxWidth;   //两个指示器间隔距离最长(屏幕宽) 对应时间是30秒
@property (nonatomic, assign) CGFloat timeScale;  //每个像素占多少秒

@property (nonatomic, strong) NSArray *coverImgs;               //封面图片

@property (nonatomic, assign) CGFloat tempStartTime;    //滚动的偏移量的开始时间
@property (nonatomic, assign) CGFloat tempEndTime;      //滚动的偏移量的结束时间
@property (nonatomic, assign) CGFloat contentOffsetX;


@end


@implementation ZJInterceptBottomTools
- (instancetype)initWithFrame:(CGRect)frame  coverImgs:(NSArray *)coverImgs{
    if (self = [super initWithFrame:frame]) {
        self.coverImgs = coverImgs;
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    self.timeScale = 30.0f/kScreenWidth;
    
    self.minWidth = 5.0f/self.timeScale;//5秒钟占的宽

    //下面的小图
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    [self.scrollView setTag:kClipTimeScrollTag];
    [self.scrollView setAlwaysBounceHorizontal:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self addSubview:self.scrollView];
    self.scrollView.backgroundColor = [UIColor clearColor];
    //图片宽
    float imgWidth = kScreenWidth/20.0;//20张图
    for (int i = 0; i< self.coverImgs.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self.coverImgs objectAtIndex:i]];
        [imageView setFrame:CGRectMake(i*imgWidth, 0, imgWidth, 50)];
        [self.scrollView addSubview:imageView];
    }
    [self.scrollView setContentSize:CGSizeMake(kScreenWidth, 50)];
    
    self.sliderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    [self addSubview:self.sliderView];
    
    self.sliderView.backgroundColor = [UIColor blueColor];
    
    //滑块
    UIPanGestureRecognizer *handlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.sliderView addGestureRecognizer:handlePan];
    
    
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    UIImage *leftSliderImg = [UIImage imageNamed:@"resume_btn_control_l"];
    UIImage *rightSliderImg = [UIImage imageNamed:@"resume_btn_control_r"];
    
    self.leftSliderImgView = [[UIImageView alloc] initWithImage:leftSliderImg];
    self.leftSliderImgView.userInteractionEnabled = YES;
    self.leftSliderImgView.frame = CGRectMake(0, 0, leftSliderImg.size.width, 50);
    [self.leftSliderImgView addGestureRecognizer:leftPan];
    [self addSubview:self.leftSliderImgView];
    
    self.leftSliderImgView.backgroundColor = [UIColor redColor];
    
    self.rightSliderImgView = [[UIImageView alloc] initWithImage:rightSliderImg];
    self.rightSliderImgView.userInteractionEnabled = YES;
    
    self.sliderView.frameX = CGRectGetMaxX(self.leftSliderImgView.frame);
    self.rightSliderImgView.backgroundColor = [UIColor redColor];
    
    //最大的长度裁剪
    self.rightSliderImgView.frame = CGRectMake(CGRectGetMaxX(self.sliderView.frame), 0, rightSliderImg.size.width, 50);
    
    [self.rightSliderImgView addGestureRecognizer:rightPan];
    [self addSubview:self.rightSliderImgView];
    
    //上边的白色横条
    self.upOpacityImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftSliderImgView.frameX, 0, self.sliderView.frameW, 2.0)];
    [self.upOpacityImgView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.upOpacityImgView];
    //下边的白色横条
    self.downOpacityImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftSliderImgView.frameX, 48, self.sliderView.frameW, 2.0)];
    [self.downOpacityImgView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.downOpacityImgView];
    
    //选中片段时长
    self.selDurationLabel = [[UILabel alloc] init];
    self.selDurationLabel.textColor = [UIColor whiteColor];
    self.selDurationLabel.font = [UIFont systemFontOfSize:12];
    if (self.videoDuration >= 30.) {
        self.selDurationLabel.text = @"30.0s";
    }else if (self.videoDuration > 5.) {
        self.selDurationLabel.text = [NSString stringWithFormat:@"%.lds", self.videoDuration];
    }else {
        self.selDurationLabel.text = @"5.0s";
    }
    [self.selDurationLabel sizeToFit];
    [self addSubview:self.selDurationLabel];
    
    [self.selDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-14);
        make.top.equalTo(self.scrollView.mas_bottom).with.offset(8);
    }];
    
}
#pragma mark -
#pragma mark - Handele Gesture

- (void)handlePan:(UIPanGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:gesture.view];
        
        CGFloat rightX = self.rightSliderImgView.frame.origin.x + translation.x;
        
        CGFloat sliderX = self.sliderView.frame.origin.x + translation.x;
        
        CGFloat leftX = self.leftSliderImgView.frame.origin.x + translation.x;
        
        if (leftX <= 0) {
            leftX = 0;
            sliderX = self.leftSliderImgView.frameW;
            rightX =  self.sliderView.frameW  + self.rightSliderImgView.frameW;
        }
        if (rightX >= kScreenWidth - self.rightSliderImgView.frameW) {
            rightX = kScreenWidth - self.rightSliderImgView.frameW;
            sliderX = kScreenWidth - self.rightSliderImgView.frameW - self.sliderView.frameW;
            leftX = kScreenWidth - self.rightSliderImgView.frameW - self.sliderView.frameW - self.leftSliderImgView.frameW;
        }
        
        CGFloat width = rightX - leftX+ self.imgWidth;
        CGFloat selDuration = width * self.timeScale;
        self.startTime = self.contentOffsetX*self.timeScale + leftX *self.timeScale;
        self.endTime = self.startTime + selDuration;
        if (self.startTime < 0.) {
            self.startTime = 0.;
        }
        self.selDurationLabel.text = [NSString stringWithFormat:@"%.1fs", selDuration];
        
        self.leftSliderImgView.frameX = leftX;
        
        self.rightSliderImgView.frameX = rightX;
        
        self.sliderView.frameX = self.downOpacityImgView.frameX = self.upOpacityImgView.frameX = CGRectGetMaxX(self.leftSliderImgView.frame);
        
        [gesture setTranslation:CGPointZero inView:gesture.view];
        
        if ([self.delegate respondsToSelector:@selector(seekToTime:enTime:)]) {
            [self.delegate seekToTime:self.startTime enTime:self.endTime];
        }
        
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
    }
}

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:gesture.view];
        
        CGFloat rightX = self.rightSliderImgView.frame.origin.x;
        
        CGFloat leftX = self.leftSliderImgView.frame.origin.x + translation.x;
        
        if (leftX <= 0) {
            leftX = 0;
        }
        else if (leftX >= rightX - _minWidth) {//设置最小间距
            leftX = rightX - _minWidth;
        }
        
        CGFloat width = rightX - leftX+ self.imgWidth;
        CGFloat selDuration = width * self.timeScale;
        self.startTime = self.contentOffsetX*self.timeScale + leftX *self.timeScale;
        self.endTime = self.startTime + selDuration;
        if (self.startTime < 0.) {
            self.startTime = 0.;
        }
        
        self.selDurationLabel.text = [NSString stringWithFormat:@"%.1fs", selDuration];
        
        self.leftSliderImgView.frameX = leftX;
        
        self.sliderView.frameW  = self.downOpacityImgView.frameW = self.upOpacityImgView.frameW = self.rightSliderImgView.frameX - CGRectGetMaxX(self.leftSliderImgView.frame);
        
        self.sliderView.frameX =   self.downOpacityImgView.frameX = self.upOpacityImgView.frameX = CGRectGetMaxX(self.leftSliderImgView.frame);
        
        [gesture setTranslation:CGPointZero inView:gesture.view];

        if ([self.delegate respondsToSelector:@selector(seekToTime:enTime:)]) {
            [self.delegate seekToTime:self.startTime enTime:self.endTime];
        }
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        //        [self.rangeView setHidden:YES];
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture locationInView:gesture.view];
        CGFloat leftX = self.leftSliderImgView.frame.origin.x;
        CGFloat rightX = self.rightSliderImgView.frame.origin.x + translation.x;
        
        if (rightX >= kScreenWidth - self.rightSliderImgView.frameW) {
            rightX = kScreenWidth - self.rightSliderImgView.frameW;
        }
        
        if (rightX <= leftX + _minWidth) {
            rightX = leftX + _minWidth;
        }
        
        CGFloat width = rightX - leftX + self.imgWidth;
        CGFloat selDuration = width * self.timeScale;
        self.endTime = self.startTime + selDuration;
        self.selDurationLabel.text = [NSString stringWithFormat:@"%.1fs", selDuration];
        
        self.rightSliderImgView.frameX = rightX;
        
        self.sliderView.frameW  =  self.downOpacityImgView.frameW = self.upOpacityImgView.frameW = self.rightSliderImgView.frameX - CGRectGetMaxX(self.leftSliderImgView.frame);
        
        [gesture setTranslation:CGPointZero inView:gesture.view];

        if ([self.delegate respondsToSelector:@selector(seekToTime:enTime:)]) {
            [self.delegate seekToTime:self.startTime enTime:self.endTime];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded){

        if ([self.delegate respondsToSelector:@selector(seekToTime:enTime:)]) {
            [self.delegate seekToTime:self.startTime enTime:self.endTime];
        }
    }
}

@end
