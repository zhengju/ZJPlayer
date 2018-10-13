//
//  InterceptView.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/9.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "InterceptView.h"
#import "UIView+Frame.h"
#import "UIImage+Crop.h"
#import "Masonry.h"
#import <Photos/Photos.h>
#import "ZJCommonHeader.h"

#import "ZJInterceptTopView.h"
#import "ZJSelectFrameView.h"
#import "ZJScreenCaptureToolBox.h"
#import "ZJVideoTools.h"
#import "ZJInterceptBottomTools.h"

#define kLeftWidth   0 
#define kCoverImageScrollTag 10
#define kClipTimeScrollTag  20

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kColorWithRGBA(_R,_G,_B,_A)    ((UIColor *)[UIColor colorWithRed:_R/255.0 green:_G/255.0 blue:_B/255.0 alpha:_A])

#define ZJHeight kScreenHeight/2.0

#define originRate 16.0/9.0

@interface InterceptView()<UIScrollViewDelegate,ZJInterceptTopViewDelegate,ZJScreenCaptureToolBoxDelegate,ZJSelectFrameViewDelegate,ZJInterceptBottomToolsDelegate>
{
    CGRect _videoCroppingFrame;
}
@property (nonatomic, strong) UIImage *cover;
@property (nonatomic, strong) PHAsset *asset;
@property(nonatomic, strong) ZJSelectFrameView * selectFrameView;
@property (nonatomic, strong) ZJInterceptTopView * topView;
@property (nonatomic, strong) UIImageView *BGView;
@property (nonatomic, strong) UIImageView *coverImgView;        //封面imgview

@property(nonatomic, strong) ZJInterceptBottomTools * bottomToolView;
@property (nonatomic, strong) NSArray *coverImgs;               //封面图片
@property(nonatomic, strong) ZJScreenCaptureToolBox * screenCaptureToolBox;

@property (nonatomic, assign) unsigned long videoDuration;  //截取的时间长度
@property (nonatomic, assign) CGFloat startTime;            //开始截取的时间
@property (nonatomic, assign) CGFloat endTime;              //结束截取的时间

@property (nonatomic, assign) CGPoint clipPoint;        //开始截取的点
@property (nonatomic, assign) float m_ftp;              //视频的ftp
@property (nonatomic, strong) NSTimer *m_timer;         //
@property (nonatomic, strong) UIView *guideBg;       //新手引导界面
@property (nonatomic, strong) UIView *pullGuideBg;  //拖动提示
@property (nonatomic, strong) UIScrollView *clipView;   //视频截取的滚动

@property (nonatomic, strong) AVPlayer     *player;
@end

@implementation InterceptView
- (void)setCurrentTtime:(CMTime)currentTtime{
    _currentTtime = currentTtime;
    
     AVURLAsset *asset = (AVURLAsset *)self.playerItem.asset;
    
    UIImage * bgImage = [ZJVideoTools getVideoPreViewImageFromVideo:asset atTime:CMTimeGetSeconds(_currentTtime)+0.01];

    self.BGView.image = bgImage;
    
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(_currentTtime), self.m_ftp);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self playVideo];
        }
    }];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem{
    _playerItem = playerItem;
    
}
- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)videoUrl playerItem:(AVPlayerItem *)playerItem currentTime:(CMTime)currentTime{
    
    if (self = [super initWithFrame:frame]) {
        self.videoUrl = videoUrl;
        self.playerItem = playerItem;
        self.currentTtime = currentTime;
        [self loadData];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self loadData];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadData];
    }
    return self;
}
- (void)loadData{
    //获取截图和视频时长
    if (self.videoUrl == nil) {
        return;
    }
    [self getCoverImgs];
    AVAsset *asset = self.playerItem.asset;
    self.m_ftp = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
    CMTimeShow(self.currentTtime);
    CMTimeShow(asset.duration);
    self.startTime = 0.0f + CMTimeGetSeconds(self.currentTtime);//
    self.endTime = self.startTime + 10.0f;
    
    [self createUI];
    
    [self.player play];
    //设置视频视图
    [self initPlayerView];
    
}

#pragma mark -
#pragma mark - Private method
-(void)initPlayerView{
    
    //AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
    //通过playerItem创建AVPlayer
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.playerItem.asset];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    //或者直接使用URL创建AVPlayer
    //self.playss = [AVPlayer playerWithURL:sourceMovieUrl];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = CGRectMake(0, 0, self.coverImgView.frameW, self.coverImgView.frameH);
    layer.videoGravity =AVLayerVideoGravityResizeAspect;
    [self.coverImgView.layer addSublayer:layer];
    [self.player play];
}
//截帧逻辑可以优化，比较多时可以放在子线程中去完成
- (void)getCoverImgs {
    NSMutableArray *imageArrays = [NSMutableArray array];
    self.videoDuration = [self durationWithVideo:self.videoUrl.absoluteString];
    self.videoDuration = 20;
    
    
    float second = CMTimeGetSeconds(self.currentTtime);
    
    //要判断seconds是否会超出总的时间区间
 
    AVURLAsset *asset = (AVURLAsset *)self.playerItem.asset;
    //大于11s
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    if (self.videoDuration>11.0) {
        //每隔1s截取一张图片
        for (int i = 0; i <  self.videoDuration; i++) {
           
            
            UIImage * image = [ZJVideoTools getVideoPreViewImageFromVideo:asset atTime:second + i +0.01];
           
            if (image) {
                [imageArrays addObject:image];
            }
        }
    }
    else{
        //截取11张
        for (int i = 0; i < 11; i++) {

            UIImage *image =  [ZJVideoTools getVideoPreViewImageFromVideo:asset atTime:self.videoDuration*i/12.0+0.01];

            if (image) {
                [imageArrays addObject:image];
            }
            
        }
    }
    
    self.coverImgs = [NSArray arrayWithArray:imageArrays];
    self.cover = [imageArrays objectAtIndex:0];
    
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"截屏耗时：-----%f", end - start);
    
}

- (void)createUI {
    self.backgroundColor = UIColorFromRGB(0x2f2f2f);
    
    
    UIImage * bgImage = [ZJVideoTools getVideoPreViewImageFromVideo:self.playerItem.asset atTime:2+0.01];
    
    self.BGView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.BGView.backgroundColor = [UIColor redColor];
    self.BGView.image = bgImage;
    [self addSubview:self.BGView];
    
    //头部确定和取消按钮
    self.topView = [[ZJInterceptTopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 72)];
    self.topView.delegate = self;
    [self addSubview:self.topView];

    //主预览图
    UIScrollView *clipView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 72, kScreenWidth, ZJHeight)];
    clipView.delegate = self;
    clipView.backgroundColor = [UIColor clearColor];
    clipView.showsVerticalScrollIndicator = NO;
    clipView.showsHorizontalScrollIndicator = NO;
    clipView.bounces = NO;
    clipView.tag = kCoverImageScrollTag;
    [self addSubview:clipView];
    self.clipView = clipView;
    
    UIImage *image = self.cover;
    
    CGFloat imgW = image.size.width;
    CGFloat imgH = image.size.height;
    
    imgW = ZJHeight*originRate;
    
    imgH = ZJHeight;
    
    
    CGFloat imgRate = image.size.width / image.size.height;

    CGFloat min = MIN(imgRate, originRate);

    if (min == imgRate) {

        imgW = originRate*ZJHeight;
        imgH = imgW / imgRate;//H不会超过originH

    }else{
        imgH = ZJHeight;
        imgW = imgH * imgRate;
    }

    self.coverImgView = [[UIImageView alloc] initWithImage:image];
    self.coverImgView.userInteractionEnabled = YES;
    [clipView addSubview:self.coverImgView];
    self.coverImgView.frame = CGRectMake((kScreenWidth - imgW)/2.0, (ZJHeight-imgH)/2.0, imgW, imgH);
    clipView.contentSize = CGSizeMake(imgW, imgH);
    
    
    self.screenCaptureToolBox = [[ZJScreenCaptureToolBox alloc]initWithFrame:CGRectMake((kScreenWidth - imgW)/2.0, 0, imgW, imgH)];
    self.screenCaptureToolBox.originVideoFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.screenCaptureToolBox.delegate = self;
    [clipView addSubview:self.screenCaptureToolBox];
    _videoCroppingFrame = [self.screenCaptureToolBox captureDragViewFrameWithType:ZJSelectFrameViewOriginal];
 
    self.bottomToolView = [[ZJInterceptBottomTools alloc]initWithFrame:CGRectMake(kLeftWidth, kScreenHeight - 50 - 20, kScreenWidth-2*kLeftWidth, 50) coverImgs:self.coverImgs];
    self.bottomToolView.backgroundColor = [UIColor clearColor];
    self.bottomToolView.startTime = self.startTime;
    self.bottomToolView.endTime = self.endTime;
    self.bottomToolView.delegate = self;
    [self addSubview:self.bottomToolView];

    //第一次使用裁剪视频，显示引导
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kYZCropVideoFirstTime"]) {
        UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPullGuide:)];
        _pullGuideBg = [[UIView alloc] init];
        [_pullGuideBg setBackgroundColor:kColorWithRGBA(0, 0, 0, 0.6)];
        [self addSubview:_pullGuideBg];
        [_pullGuideBg addGestureRecognizer:tap3];
        [_pullGuideBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.equalTo(self);
        }];
        UIImageView *pullGuideImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_clip_tips"]];
        [_pullGuideBg addSubview:pullGuideImgView];
        [pullGuideImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_pullGuideBg);
            make.centerY.equalTo(_pullGuideBg).with.offset(-50);
        }];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kYZCropVideoFirstTime"];
    }

    [self configureSelectFrameView];
    
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
    if (CMTimeCompare(self.player.currentTime, CMTimeMakeWithSeconds(self.endTime, self.m_ftp)) >= 0) {
        [self.player pause];
        CMTime time = CMTimeMakeWithSeconds(self.startTime, self.m_ftp);
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


-(void)dismissGuide:(UIPanGestureRecognizer *)gesture{
    [_guideBg removeFromSuperview];
}

-(void)dismissPullGuide:(UIPanGestureRecognizer*)gesture{
    [_pullGuideBg removeFromSuperview];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissGuide:)];
    _guideBg = [[UIView alloc] init];
    [self addSubview:_guideBg];
    [_guideBg addGestureRecognizer:tap];
    [_guideBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(self);
    }];
    
    UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissGuide:)];
    UIImageView *guideImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"resume_pic_guide"]];
    [_guideBg addSubview:guideImgView];
    [guideImgView addGestureRecognizer:tap0];
    
    [guideImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_guideBg);
        make.bottom.equalTo(_guideBg).with.offset(-72);
    }];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissGuide:)];
    UIImageView *imgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_pic_line"]];
    imgview.tag = 10000;
    [_guideBg addSubview:imgview];
    [imgview setUserInteractionEnabled:YES];
    [imgview addGestureRecognizer:tap2];
    [imgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_guideBg);
        make.top.equalTo(self).with.offset(CGRectGetMaxY(_clipView.frame));
    }];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissGuide:)];
    UIView *topBgView = [[UIView alloc] init];
    [topBgView setBackgroundColor:kColorWithRGBA(0, 0, 0, 0.6)];
    [topBgView addGestureRecognizer:tap1];
    [_guideBg addSubview:topBgView];
    [topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.width.left.equalTo(self);
        make.bottom.equalTo(imgview.mas_top);
    }];
}

///获取本地视频的时长
- (NSUInteger)durationWithVideo:(NSString *)videoPath {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:opts];     //初始化视频媒体文件
    NSUInteger second = 0;
    second = ceilf((double)urlAsset.duration.value / (double)urlAsset.duration.timescale); // 获取视频总时长,单位秒
    return second;
}

#pragma mark - ZJInterceptTopViewDelegate
- (void)back{
    [self.player pause];
    self.player  = nil;
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(interceptViewToback)]) {
        [self.delegate interceptViewToback];
    }
}
- (void)action:(ZJInterceptTopViewType)actionType{
    if (actionType == ZJInterceptTopViewVideo) {//截视频
        self.selectFrameView.hidden = NO;
        self.screenCaptureToolBox.hidden = NO;
    }else{//截GIF 隐藏
        self.screenCaptureToolBox.hidden = YES;
        self.selectFrameView.hidden = YES;
    }
}
- (void)finishWithAction:(ZJInterceptTopViewType)actionType{
    
    if (actionType == ZJInterceptTopViewVideo) {//截视频
        [self videoCropping];
    }else{//截GIF
        [self gifScreenshot];
    }
}

- (void)configureSelectFrameView{
    
    self.selectFrameView = [[ZJSelectFrameView alloc]initWithFrame:CGRectMake(kScreenWidth - 150, (kScreenHeight - 180)/2.0, 120, 180)];
    self.selectFrameView.delegate = self;
    [self addSubview:self.selectFrameView];
    
}

- (void)gifScreenshot{
    //裁剪视频可以看这篇文章：http://www.hudongdong.com/ios/550.html
    NSLog(@"开始裁剪:开始时间:%f,结束时间:%f,裁剪区域W:%f,H:%f",self.startTime,self.endTime,self.clipPoint.x,self.clipPoint.y);
    NSString * url1 = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache.mov"];
    NSRange range = NSMakeRange(self.startTime, self.endTime - self.startTime);
    CFAbsoluteTime start= CFAbsoluteTimeGetCurrent();
    // dosomething
    
    [[ZJCustomTools shareCustomTools]interceptVideoAndVideoUrl:self.videoUrl withOutPath:url1 outputFileType:AVFileTypeQuickTimeMovie range:range intercept:^(NSError *error, NSURL *url) {
        if (error) {
            NSLog(@"error:%@",error);
            return ;
        }
        CFAbsoluteTime end= CFAbsoluteTimeGetCurrent();
        NSLog(@"%f", end- start);
        NSLog(@"----++%@",url);//本地视频记得删除
        
        [NSGIF optimalGIFfromURL:url loopCount:0 completion:^(NSURL *GifURL) {
            
            NSLog(@"Finished generating GIF: %@", GifURL);

            [GifURL saveGIFToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"error :%@",error.userInfo);
                    return ;
                }
                HUDNormal(@"保存成功");
                NSLog(@"Success at %@", path );
            }];
        }];
    }];
}

#pragma mark - 视频裁剪
- (void)videoCropping{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000]];
    NSURL * videoUrl = [NSURL fileURLWithPath:myPathDocs];

    [ZJVideoTools mixVideo:self.playerItem.asset startTime:CMTimeMakeWithSeconds(self.startTime, self.m_ftp) WithVideoCroppingFrame:_videoCroppingFrame toUrl:videoUrl outputFileType:AVFileTypeQuickTimeMovie withMaxDuration:CMTimeMakeWithSeconds(self.endTime - self.startTime, self.m_ftp) withCompletionBlock:^(NSError *error) {
        
        if (error == nil) {

                NSLog(@"视频剪裁成功：%@",videoUrl);

                [videoUrl saveVideoToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"保存视频出错：%@",error.userInfo);
                        return ;
                    }
                    HUDNormal(@"保存视频至相册成功");
                    NSLog(@"保存视频至相册成功：%@",path);
                }];
                
           
        }else{
            NSLog(@"error is :%@",error.userInfo);
        }
        
    }];
}

#pragma mark - ZJScreenCaptureToolBoxDelegate
- (void)screenCaptureFrame:(CGRect)frame{
    
    _videoCroppingFrame = frame;
}
#pragma mark - ZJSelectFrameViewDelegate
- (void)selectedFrameType:(ZJSelectFrameType)type{
    switch (type) {
        case ZJSelectFrameViewOriginal://原始
        {
            [self.screenCaptureToolBox setCaptureDragViewFrame:CGRectZero type:type];
        }
            break;
        case ZJSelectFrameViewVerticalPlate://竖版
        {
            [self.screenCaptureToolBox setCaptureDragViewFrame:CGRectMake(0, 0, (self.coverImgView.frameH/3.0)*2, self.coverImgView.frameH) type:type];
        }
            break;
        case ZJSelectFrameViewFilm://电影
        {
            [self.screenCaptureToolBox setCaptureDragViewFrame:CGRectMake(0, 0, self.coverImgView.frameW, self.coverImgView.frameH) type:type];
        }
            break;
        case ZJSelectFrameViewSquare://方形
        {
            [self.screenCaptureToolBox setCaptureDragViewFrame:CGRectMake(0, 0, self.coverImgView.frameH, self.coverImgView.frameH) type:type];
        }
            break;
        default:
            break;
    }
    _videoCroppingFrame = [self.screenCaptureToolBox captureDragViewFrameWithType:type];
}
#pragma mark -ZJInterceptBottomToolsDelegate
-(void)seekToTime:(CGFloat)startTime enTime:(CGFloat)endTime{
    
    
    NSLog(@"start:%f,end:%f",startTime,endTime);
    [self.player pause];
    
    self.endTime = endTime;
    CMTime time = CMTimeMakeWithSeconds(startTime, self.m_ftp);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                if (finished) {
                    [self playVideo];
                }
            }];
        });
    });
}
@end

