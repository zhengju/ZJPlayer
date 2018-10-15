//
//  ZJDisplayVideoToSaveView.m
//  ZJPlayer
//
//  Created by zhengju on 2018/10/14.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJDisplayVideoToSaveView.h"
#import "ZJCommonHeader.h"
#import "ZJDisplayVideoToSaveTopView.h"



#define ZJHeight kScreenHeight/2.0

#define originRate 16.0/9.0


@interface ZJDisplayVideoToSaveView()<ZJDisplayVideoToSaveTopViewDelegate>

@property (nonatomic, strong) AVPlayer     *player;

@property (nonatomic, strong) NSTimer *m_timer;         //

@property(nonatomic, strong) UILabel * desLabel;//正在生成视频

@property(nonatomic, strong) UIProgressView * slider;

@property(nonatomic, strong) ZJDisplayVideoToSaveTopView * topView;

@property(nonatomic, strong) UIButton * saveBtn;

@property(nonatomic, strong) NSURL * videoUrlPath;

@end


@implementation ZJDisplayVideoToSaveView

-(void)setVideoCroppingFrame:(CGRect)videoCroppingFrame{
    _videoCroppingFrame = videoCroppingFrame;
    [self videoCropping];
}

- (void)setCurrentTtime:(CMTime)currentTtime{
    
    
    
    _currentTtime = currentTtime;
    
    AVURLAsset *asset = (AVURLAsset *)self.playerItem.asset;

    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(_currentTtime), 25);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self playVideo];
        }
    }];
}
- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)videoUrl playerItem:(AVPlayerItem *)playerItem currentTime:(CMTime)currentTime{
    self.videoUrl = videoUrl;
    self.playerItem = playerItem;
    self.currentTtime = currentTime;
    if (self = [super initWithFrame:frame]) {
        self.videoUrl = videoUrl;
        self.playerItem = playerItem;
        self.currentTtime = currentTime;
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    self.backgroundColor = [UIColor blackColor];
    
    [self initPlayerView];
    
    
    //播放的同时子线程生成本地视频
    
}
#pragma mark - Private method
-(void)initPlayerView{
    
    self.BGView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    [self addSubview:self.BGView];
    
    self.topView = [[ZJDisplayVideoToSaveTopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 72)];
    self.topView.delegate = self;
    [self addSubview:self.topView];
    
    
    
    CGFloat   imgW = ZJHeight*originRate;
    
 
    CGFloat  imgH = ZJHeight;
    
    //CGRectMake((kScreenWidth - imgW)/2.0, (ZJHeight-imgH)/2.0, imgW, imgH);

    //通过playerItem创建AVPlayer
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.playerItem.asset];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    //或者直接使用URL创建AVPlayer
    //self.playss = [AVPlayer playerWithURL:sourceMovieUrl];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = CGRectMake((kScreenWidth - imgW)/2.0, CGRectGetMaxY(self.topView.frame), imgW, imgH);
    layer.videoGravity =AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:layer];
    [self.player play];
    
    self.slider = [[UIProgressView alloc]initWithFrame:CGRectMake((kScreenWidth - imgW)/2.0, CGRectGetMaxY(layer.frame), imgW, 2)];
    self.slider.progressTintColor = [UIColor blueColor];
    self.slider.trackTintColor = [UIColor whiteColor];
    [self addSubview:self.slider];
    
    self.desLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth - imgW)/2.0, CGRectGetMaxY(self.slider.frame), imgW, 30)];
    self.desLabel.textColor = [UIColor whiteColor];
    self.desLabel.textAlignment = NSTextAlignmentCenter;
    self.desLabel.text = @"正在生成视频";
    [self addSubview:self.desLabel];
    
    self.saveBtn = [[UIButton alloc]initWithFrame:CGRectMake((kScreenWidth - imgW)/2.0, CGRectGetMaxY(self.desLabel.frame), imgW, 30)];
    [self.saveBtn setTitle:@"保存本地" forState:UIControlStateNormal];
    
    [self.saveBtn bk_addEventHandler:^(id sender) {
        
        [self saveVideo];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.saveBtn];
    
   
    

}
- (void)playVideo {
    
    if (!self.m_timer) {
        self.m_timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(stopPlay) userInfo:nil repeats:YES];
    }
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        [self.player play];
        NSLog(@"l开始播放了");
    }
}

- (void)stopPlay {
    if (CMTimeCompare(self.player.currentTime, CMTimeMakeWithSeconds(self.endTime, 25)) >= 0) {
        [self.player pause];
        CMTime time = CMTimeMakeWithSeconds(self.startTime, 25);
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                [self playVideo];
            }
        }];
        if (self.m_timer) {
            [self.m_timer invalidate];
            self.m_timer = nil;
        }
    }
}
#pragma mark - 视频裁剪
- (void)videoCropping{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000]];
    self.videoUrlPath = [NSURL fileURLWithPath:myPathDocs];
    
    
    [ZJVideoTools mixVideo:self.playerItem.asset startTime:CMTimeMakeWithSeconds(self.startTime, 25) WithVideoCroppingFrame:_videoCroppingFrame toUrl:self.videoUrlPath outputFileType:AVFileTypeQuickTimeMovie withMaxDuration:CMTimeMakeWithSeconds(self.endTime - self.startTime, 25) compositionProgressBlock:^(CGFloat progress) {
        
        NSLog(@" 视频 打印信息:%f",progress);
        
        self.slider.progress = progress;
        
        if (progress == 1) {
            self.desLabel.text = @"视频生成ok,可以保存和分享了..";
        }
        
    }  withCompletionBlock:^(NSError *error) {
        
        if (error == nil) {
            
            NSLog(@"视频剪裁成功：%@",self.videoUrl);
            

            
        }else{
            NSLog(@"error is :%@",error.userInfo);
        }
        
    }];
}

- (void)saveVideo{
        [self.videoUrlPath saveVideoToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
            if (error) {
                NSLog(@"保存视频出错：%@",error.userInfo);
                return ;
            }
            HUDNormal(@"保存视频至相册成功");
            NSLog(@"保存视频至相册成功：%@",path);
        }];
    
}

#pragma mark -ZJDisplayVideoToSaveTopViewDelegate
- (void)displayVideoToSaveTopViewBack{
    if ([self.delegate respondsToSelector:@selector(displayVideoToSaveViewToback)]) {
        [self.delegate displayVideoToSaveViewToback];
    }
}
- (void)displayVideoToSaveTopViewExit{
    if ([self.delegate respondsToSelector:@selector(displayVideoToSaveViewExit)]) {
        [self.delegate displayVideoToSaveViewExit];
    }
}
@end
