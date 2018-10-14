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


@interface ZJDisplayVideoToSaveView()

@property (nonatomic, strong) AVPlayer     *player;

@property (nonatomic, strong) NSTimer *m_timer;         //



@end


@implementation ZJDisplayVideoToSaveView
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
    
 
    CGFloat   imgW = ZJHeight*originRate;
    
 
    CGFloat  imgH = ZJHeight;
    
    CGRectMake((kScreenWidth - imgW)/2.0, (ZJHeight-imgH)/2.0, imgW, imgH);

    //通过playerItem创建AVPlayer
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.playerItem.asset];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    //或者直接使用URL创建AVPlayer
    //self.playss = [AVPlayer playerWithURL:sourceMovieUrl];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = CGRectMake((kScreenWidth - imgW)/2.0, (ZJHeight-imgH)/2.0, imgW, imgH);
    layer.videoGravity =AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:layer];
    [self.player play];
    
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
@end
