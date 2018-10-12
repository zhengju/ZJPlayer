//
//  ZJScreenCaptureToolBox.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/11.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJScreenCaptureToolBox.h"
#import "ZJCommonHeader.h"


@interface ZJScreenCaptureToolBox()
{
    CGFloat _verticalPlateX;
    CGFloat _squareX;
    CGFloat _verticalPlateW;
    CGFloat _squareW;
}
@property(nonatomic, strong) UIView * dragView;

@property(nonatomic, assign) ZJSelectFrameType  selectedFrameType;

@end


@implementation ZJScreenCaptureToolBox
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor=[UIColor clearColor];
        
        [self configureUI];
        
    }
    return self;
}

- (void)configureUI{

    self.selectedFrameType = ZJSelectFrameViewOriginal;//默认是原始视频
    _squareX = self.frameH;
    _verticalPlateW = (self.frameH/3.0)*2.0;
    _squareW = self.frameH;
    _verticalPlateX = (self.frameW - _verticalPlateW)/2.0;
    _squareX = (self.frameW - _squareW)/2.0;
    
    self.dragView = [[UIView alloc]initWithFrame:CGRectMake((self.frameW-self.frameH)/2.0, 0, self.frameH, self.frameH)];
    self.dragView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.dragView];
    
    //临时边框
    self.dragView.layer.borderWidth = 1.5;
    self.dragView.layer.borderColor = [UIColor redColor].CGColor;
    
    UIPanGestureRecognizer *handlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    [self.dragView addGestureRecognizer:handlePan];
    
    
    self.hidden  = YES;
    
}

- (void)setCaptureDragViewFrame:(CGRect)frame type:(ZJSelectFrameType)type{
    if (type == ZJSelectFrameViewOriginal) {
        self.hidden = YES;
    }else if(type == ZJSelectFrameViewVerticalPlate){
        self.hidden = NO;
        self.dragView.frameW = _verticalPlateW;
        self.dragView.frameX = _verticalPlateX;
    }else if(type == ZJSelectFrameViewFilm){
        self.hidden = NO;
        self.dragView.frame = frame;
    }else if(type == ZJSelectFrameViewSquare){
        self.hidden = NO;
        self.dragView.frameX = _squareX;
        self.dragView.frameW = frame.size.width;
    }
    self.selectedFrameType = type;
    [self setNeedsDisplay];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
    }else if (gesture.state == UIGestureRecognizerStateChanged) {

        CGPoint translation = [gesture translationInView:gesture.view];
        
        CGFloat sliderX = self.dragView.frameX + translation.x/50.0;

        CGFloat maxX = self.frameW - self.dragView.frameW;
        CGFloat minX = 0;
        
        if (translation.x <0) {//小于0是左滑
            
            if (sliderX >=0) {
                self.dragView.frameX = sliderX;
            }else{
                self.dragView.frameX = minX;
            }
        }else{//右滑
            
            if (sliderX <= self.frameW - self.dragView.frameW) {
                self.dragView.frameX = sliderX;
            }else{
                self.dragView.frameX = maxX;
            }
        }

        if (self.selectedFrameType == ZJSelectFrameViewVerticalPlate) {
            _verticalPlateX = self.dragView.frameX;
        }
        if (self.selectedFrameType == ZJSelectFrameViewSquare) {
            _squareX = self.dragView.frameX;
        }
        
        [self setNeedsDisplay];
        
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(screenCaptureFrame:)]) {
            [self.delegate screenCaptureFrame:self.dragView.frame];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return;
    }
    
    [[[UIColor blackColor] colorWithAlphaComponent:0.3f] setFill];
    
    UIRectFill(rect);
    
    [[UIColor clearColor] setFill];
    
    //设置透明部分位置和圆角
    CGRect alphaRect = self.dragView.frame;
    
    CGFloat cornerRadius = 10;
    UIBezierPath *bezierPath=[UIBezierPath bezierPathWithRoundedRect:alphaRect
                                                        cornerRadius:cornerRadius];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor clearColor] CGColor]);
    CGContextAddPath(UIGraphicsGetCurrentContext(), bezierPath.CGPath);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    CGContextFillPath(UIGraphicsGetCurrentContext());
    
}
@end
