//
//  ZJDisplayVideoToSaveView.m
//  ZJPlayer
//
//  Created by zhengju on 2018/10/14.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJDisplayVideoToSaveView.h"
#import "ZJInterceptSDK.h"
#import "ZJDisplayVideoToSaveTopView.h"
#import "ZJOpenGLView.h"
#import "ZJGlKImageView.h"
#import "ZJPlayGIFView.h"

#import "ZJInterceptSDK.h"


#define ZJHeight kScreenHeight/2.0

#define originRate 16.0/9.0


@interface ZJDisplayVideoToSaveView()<ZJDisplayVideoToSaveTopViewDelegate,AVPlayerItemOutputPullDelegate>
{
  
    CGRect   _videoCroppingFrame;

    dispatch_queue_t _renderQueue;
    
    dispatch_queue_t _videoCroppingQueue;
    
    CGSize _videoSize;
    
    CGRect _playFrame;
    
}

@property(nonatomic, strong) AVPlayerItemVideoOutput * videoOutPut;

@property (nonatomic, strong) AVPlayer     *player;

@property (nonatomic, strong) NSTimer *m_timer;         //

@property(nonatomic, strong) UILabel * desLabel;//正在生成视频

@property(nonatomic, strong) UIProgressView * slider;

@property(nonatomic, strong) ZJDisplayVideoToSaveTopView * topView;

@property(nonatomic, strong) UIButton * saveBtn;

@property(nonatomic, strong) UIButton * playGIFBtn;//玩GIF按钮

@property(nonatomic, strong) NSURL * videoUrlPath;
@property(nonatomic, strong) NSURL * GIFUrlPath;
@property(nonatomic, strong) AVAsset * asset;

@property(nonatomic, strong) UIView * layerBGView;

@property(nonatomic,strong) CADisplayLink *playLink;

@property(nonatomic,strong) ZJGlKImageView *glkImgView;

@property(nonatomic,strong) UIVisualEffectView *effectView;

@property (nonatomic , strong) ZJOpenGLView *mOpenGLView;

@end


@implementation ZJDisplayVideoToSaveView

-(void)setVideoCroppingFrame:(CGRect)videoCroppingFrame{
    _videoCroppingFrame = videoCroppingFrame;

    if (_type == ZJInterceptTopViewVideo) {//截视频
        [self videoCropping];
    }else{//截GIF
        [self gifScreenshot];
    }
}
- (void)setType:(ZJInterceptTopViewType)type{
    _type = type;
    if (type == ZJInterceptTopViewVideo) {
        self.player.volume = 0.5;
    }else{
        self.player.volume = 0.0;
    }
}
- (void)setCurrentTtime:(CMTime)currentTtime{

    _currentTtime = currentTtime;

    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(_currentTtime), 25);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self playVideo];
        }
    }];
}
- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)videoUrl playerItem:(AVPlayerItem *)playerItem currentTime:(CMTime)currentTime withAsset:(AVAsset*)asset videoCroppingFrame:(CGRect )videoCroppingFrame  playeFrame:(CGRect)playFrame videoOutPut:(AVPlayerItemVideoOutput *)videoOutPut  type: (ZJInterceptTopViewType)type{
    self.type = type;
    self.videoUrl = videoUrl;
//    self.playerItem = playerItem;
    self.currentTtime = currentTime;
    self.asset = asset;
    _playFrame= playFrame;
    self.videoOutPut = videoOutPut;
//    _videoCroppingFrame = videoCroppingFrame;
    if (self = [super initWithFrame:frame]) {
        self.videoUrl = videoUrl;
        self.playerItem = playerItem;
        self.currentTtime = currentTime;
        [self configureUI];
        self.type = type;
    }
    return self;
}
- (void)configureUI{
    
    self.backgroundColor = [UIColor blackColor];
    
    [self initPlayerView];

}

- (void)layoutSubviews{
    [super layoutSubviews];

    self.glkImgView.frame = CGRectMake((kScreenWidth - _playFrame.size.width)/2.0, CGRectGetMaxY(self.topView.frame), _playFrame.size.width, _playFrame.size.height);

}

#pragma mark - Private method
-(void)initPlayerView{
    
    self.BGView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self addSubview:self.BGView];

    self.topView = [[ZJDisplayVideoToSaveTopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 72)];
    self.topView.delegate = self;
    [self addSubview:self.topView];
    
    

    _renderQueue = dispatch_queue_create("com.render", DISPATCH_QUEUE_SERIAL);
    
    _videoCroppingQueue = dispatch_queue_create("com.videoCropping", DISPATCH_QUEUE_SERIAL);
    
    CGFloat  imgW = ZJHeight*originRate;
    
    
    //通过playerItem创建AVPlayer
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.playerItem.asset];
    self.playerItem = playerItem;
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    
    
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    
    self.videoOutPut = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];

    [self.player.currentItem addOutput:_videoOutPut];

    [self.player play];

    _playLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(playerRender)];
    [_playLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _playLink.frameInterval = 1;
    
    self.mOpenGLView =
    [[ZJOpenGLView alloc]initWithFrame:CGRectMake((kScreenWidth - _playFrame.size.width)/2.0, CGRectGetMaxY(self.topView.frame), _playFrame.size.width, _playFrame.size.height)];
    self.mOpenGLView.backgroundColor = [UIColor redColor];
    
    [self.mOpenGLView setupGL];

    [self addSubview:self.mOpenGLView];
    
    
    _glkImgView = [[ZJGlKImageView alloc] init];
    [self addSubview:_glkImgView];
    
    
    
    self.slider = [[UIProgressView alloc]initWithFrame:CGRectMake((kScreenWidth - imgW)/2.0, ZJHeight+72, imgW, 2)];
    self.slider.progressTintColor = [UIColor blueColor];
    self.slider.trackTintColor = [UIColor whiteColor];
    [self addSubview:self.slider];
    
    self.desLabel = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth - imgW)/2.0, CGRectGetMaxY(self.slider.frame), imgW, 30)];
    self.desLabel.textColor = [UIColor whiteColor];
    self.desLabel.textAlignment = NSTextAlignmentCenter;
   
    
    [self addSubview:self.desLabel];
    
    self.saveBtn = [[UIButton alloc]initWithFrame:CGRectMake((kScreenWidth - imgW)/2.0, CGRectGetMaxY(self.desLabel.frame), imgW, 30)];
    [self.saveBtn setTitle:@"保存本地" forState:UIControlStateNormal];
    
    [self.saveBtn bk_addEventHandler:^(id sender) {
        
        if (self.type == ZJInterceptTopViewVideo) {
            [self saveVideo];
        }else{
            [self saveGIF];
        }

    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.saveBtn];
    
    
    
    self.playGIFBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 100, (kScreenHeight - 30)/2.0, 100, 30)];

    [self.playGIFBtn setTitle:@"玩GIF" forState:UIControlStateNormal];
    [self.playGIFBtn setBackgroundColor:[UIColor yellowColor]];
    [self.playGIFBtn bk_addEventHandler:^(id sender) {
        
        ZJPlayGIFView * playGIFView = [[ZJPlayGIFView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        playGIFView.backgroundColor = [UIColor blackColor];
        playGIFView.url = self.GIFUrlPath;
        [self addSubview:playGIFView];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.playGIFBtn];
    
    if (self.type == ZJInterceptTopViewVideo) {
        self.desLabel.text = @"正在生成视频";
        self.playGIFBtn.hidden = YES;
    }else{
        self.desLabel.text = @"正在生成GIF";
        self.playGIFBtn.hidden = NO;
    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        if ([keyPath isEqualToString:@"status"]) {
            switch (_playerItem.status) {
                case AVPlayerItemStatusReadyToPlay:
                    //推荐将视频播放放在这里
//                    [self play];
                     NSLog(@"AVPlayerItemStatusReadyToPlay");
                    break;
                    
                case AVPlayerItemStatusUnknown:
                    NSLog(@"AVPlayerItemStatusUnknown");
                    break;
                    
                case AVPlayerItemStatusFailed:
                    NSLog(@"AVPlayerItemStatusFailed");
                    break;
                    
                default:
                    break;
        }
        }
    }
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
        
        if (progress != 0) {
            NSLog(@" 视频 打印信息:%f",progress);
            
            self.slider.progress = progress;
            
            if (progress == 1) {
                self.desLabel.text = @"视频生成ok,可以保存和分享了..";
                self.slider.hidden = YES;
            }
        }

    }  withCompletionBlock:^(NSError *error) {
        
        if (error == nil) {

        }else{
            NSLog(@"error is :%@",error.userInfo);
        }
        
    }];
}
- (void)gifScreenshot{
    //裁剪视频可以看这篇文章：http://www.hudongdong.com/ios/550.html
//    NSLog(@"开始裁剪:开始时间:%f,结束时间:%f,裁剪区域W:%f,H:%f",self.startTime,self.endTime,self.clipPoint.x,self.clipPoint.y);
    NSString * url1 = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache.mov"];
    NSRange range = NSMakeRange(self.startTime, self.endTime - self.startTime);
    CFAbsoluteTime start= CFAbsoluteTimeGetCurrent();
    // dosomething

    [[ZJCustomTools shareCustomTools]interceptVideoAndVideoUrl:self.videoUrl withOutPath:url1 outputFileType:AVFileTypeQuickTimeMovie range:range compositionProgressBlock:^(CGFloat progress) {
        if (progress != 0) {
            NSLog(@" GIF 打印信息:%f",progress);
            
            self.slider.progress = progress;
            
            if (progress == 1) {
                self.desLabel.text = @"GIF生成ok,可以保存和分享了..";
                self.slider.hidden = YES;
            }
        }
    } intercept:^(NSError *error, NSURL *url) {
        if (error) {
            NSLog(@"error:%@",error);
            return ;
        }
        CFAbsoluteTime end= CFAbsoluteTimeGetCurrent();
        NSLog(@"%f", end- start);
        NSLog(@"----++%@",url);//本地视频记得删除

        [NSGIF optimalGIFfromURL:url loopCount:0 completion:^(NSURL *GifURL) {
            
            self.slider.progress = 1.0;
            
            
            self.desLabel.text = @"GIF生成ok,可以保存和分享了..";
            self.slider.hidden = YES;

            NSLog(@"Finished generating GIF: %@", GifURL);
            
            self.GIFUrlPath = GifURL;
            
        }];
    }];
}

- (void)saveGIF{
    [self.GIFUrlPath saveGIFToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
        if (error) {
            NSLog(@"-----error :%@",error.userInfo);
            return ;
        }
        HUDNormal(@"保存成功");
        NSLog(@"Success at %@", path );
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

- (void)playerRender{
    
    CMTime itemTime = [_videoOutPut itemTimeForHostTime:CACurrentMediaTime()];
    
    if ([_videoOutPut hasNewPixelBufferForItemTime:itemTime]) {
        
        dispatch_async(_renderQueue, ^{
            
            CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
            
            
            if ([_videoOutPut hasNewPixelBufferForItemTime:itemTime]) {
                CVPixelBufferRef pixelBuffer = [_videoOutPut copyPixelBufferForItemTime:itemTime itemTimeForDisplay:nil];
                CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
//                CIImage *outPutImg = [ciImage imageByCroppingToRect:_videoCroppingFrame];//有些吃性能
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //self.glkImgView.renderImg = outPutImg;
                    
                    self.mOpenGLView.isFullYUVRange = YES;
                    [self.mOpenGLView displayPixelBuffer:pixelBuffer];
                    
                    CVBufferRelease(pixelBuffer);
                    
                });
                
                
            }else{
                NSLog(@"没有。。。");
            }
            
            
            CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
            
//            NSLog(@"像素耗时：-----%f", end - start);
            
        });
    }else{
        
    }
}

#pragma mark -ZJDisplayVideoToSaveTopViewDelegate
- (void)displayVideoToSaveTopViewBack{
    [self.player pause];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    if ([self.delegate respondsToSelector:@selector(displayVideoToSaveViewToback)]) {
        [self.delegate displayVideoToSaveViewToback];
    }
}
- (void)displayVideoToSaveTopViewExit{
    [self.player pause];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    if ([self.delegate respondsToSelector:@selector(displayVideoToSaveViewExit)]) {
        [self.delegate displayVideoToSaveViewExit];
    }
}
@end
