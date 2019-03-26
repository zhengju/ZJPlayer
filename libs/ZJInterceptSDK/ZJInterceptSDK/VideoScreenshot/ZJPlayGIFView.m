//
//  ZJPlayGIFView.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/17.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJPlayGIFView.h"


@interface ZJPlayGIFView()
@property(nonatomic, strong) UIWebView * webView;

@property(nonatomic, strong) UIImageView * imgView;

@end

@implementation ZJPlayGIFView

- (void)setUrl:(NSURL *)url{
    _url = url;
    
     NSString *path = [[NSBundle mainBundle] pathForResource:@"NSGIF-15397710983" ofType:@"gif"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 72, 300, 200)];
    [self addSubview:self.webView];
    self.webView.backgroundColor = [UIColor redColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"NSGIF-15397710983" ofType:@"gif"];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 300, 300, 200)];
    self.imgView.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.imgView];
    
    self.imgView.image = [UIImage imageNamed:@"NSGIF-15397710983.gif"];//只能播放一帧
}

@end
