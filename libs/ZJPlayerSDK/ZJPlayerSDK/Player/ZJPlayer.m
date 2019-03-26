//
//  ZJPlayer.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJPlayer.h"
#import "ZJControlView.h"
#import "ZJTopView.h"
#import "ZJProgress.h"
#import "ZJLoadingIndicator.h"
#import "ZJBrightness.h"
#import "ZJResourceLoaderManager.h"
#import "ZJPlayerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZJPlayerSDK.h"
#import <MediaPlayer/MPVolumeView.h>
#import "UIView+Player.h"
// 缓存主目录
#define ZJCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache"]

// 保存文件名
#define ZJFileName(url)  [self md5String:url]

// 文件的存放路径（caches）
#define ZJFileFullpath(url) [ZJCachesDirectory stringByAppendingPathComponent:ZJFileName(url)]

NSString *const ZJViewControllerWillDisappear = @"ZJViewControllerWillDisappear";
NSString *const ZJViewControllerWillAppear = @"ZJViewControllerWillAppear";
NSString *const ZJContinuousVideoPlayback = @"ZJContinuousVideoPlayback";
NSString *const ZJEventSubtypeRemoteControlTogglePlayPause = @"ZJEventSubtypeRemoteControlTogglePlayPause";

#define MINDISTANCE 0.5
#define kCustomVideoScheme @"http"

//枚举
typedef NS_ENUM(NSInteger, ZJPlayerSliding) {
    slidingDefault,//当前没有滑动
    slidingVolume,//声音滑动
    slidingBrightness,//亮度滑动
    slidingProgress//进度滑动
};

@interface ZJPlayer()<ZJControlViewDelegate,ZJTopViewDelegate>//,InterceptViewDelegate>

@property(strong,nonatomic) UIViewController * controller;

@property(nonatomic) CGRect  currentFrame;//遗弃
/**
 在父类上的frame
 */
@property(nonatomic) CGRect  frameOnFatherView;
/**
 是否自动横屏 YES:自动横屏 NO:手动横屏
 */
@property(assign,nonatomic) BOOL  isAutomaticHorizontal;
/**
 是否是暂停之后的播放 YES:暂停后播放 NO:首次播放或被动暂停播放
 */
@property(assign,nonatomic) BOOL  isPlayAfterPause;

/**
 是否隐藏底航栏和导航栏 YES:自动横屏 NO:手动横屏
 */
@property(assign,nonatomic) BOOL  isTabNavigationHidden;

/**
 当前player是否消失 YES:消失 NO:不消失 ，默认是NO
 */
@property(assign,nonatomic) BOOL  isDisappear;
/**
 是否是本地视频 YES:本地视频 NO:网络视频 ，默认是NO网络视频
 */
@property(assign,nonatomic) BOOL  isLocalVideo;
/**
 当前点击屏幕是否有滑动 YES:滑动 NO:没有滑动，只是点击 ，默认是NO
 */
@property(assign,nonatomic) BOOL  isTouchesMoved;

/**
 横屏状态 YES:电池栏在右 NO:电池栏在左 ，在全屏有效
 */
@property(assign,nonatomic) BOOL  isLandscapeLeft;

/**
 加载指示器
 */
@property(strong,nonatomic) ZJLoadingIndicator * loadingIndicator;
/**
 滑动进度展示器
 */
@property(strong,nonatomic) ZJProgress * progress;
/**
 滑动亮度展示器
 */
@property(strong,nonatomic) ZJBrightness * brightness;

/**
 系统声音指示器
 */
@property(strong,nonatomic) UISlider * volumeViewSlider;


/**
 开始活动的点
 */
@property(assign,nonatomic) CGPoint  gestureStartPoint;
/**
 开始滑动时的播放时间
 */
@property(assign,nonatomic) NSTimeInterval  progressTime;

@property(strong,nonatomic) ZJResourceLoaderManager *  resourceManager;
@property(assign,nonatomic) ZJPlayerSliding  slidingStyle;

@end

@implementation ZJPlayer

- (UISlider *)volumeViewSlider{
    if (_volumeViewSlider == nil) {
        MPVolumeView * volumeView   = [[MPVolumeView alloc] init];
            UISlider *volumeViewSlider = nil;
            for (UIView *view in [volumeView subviews]) {
                if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
                    volumeViewSlider = (UISlider *)view;
                    [self addSubview:_volumeViewSlider];
                    break;
                }
            }
        self.volumeViewSlider = volumeViewSlider;

    }
    return _volumeViewSlider;
}

+ (id)sharePlayer
{
    static ZJPlayer *player = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        player = [[ZJPlayer alloc]initWithUrl:[NSURL URLWithString:@""]  withSuperView:nil frame:CGRectZero controller:nil];
        
    });
    return player;
}

- (void)setIsTabNavigationHidden:(BOOL)isTabNavigationHidden{
    
    _isTabNavigationHidden = isTabNavigationHidden;
   
    UIViewController * currentController = [self getCurrentViewController];
    //隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:_isTabNavigationHidden withAnimation:UIStatusBarAnimationNone];
   
    //隐藏状态栏
    currentController.navigationController.navigationBar.hidden = _isTabNavigationHidden;
   
    //当前controller是否是nav第一个
    if ([currentController isEqual:currentController.navigationController.viewControllers.firstObject]) {
        //隐藏底航栏
        if (currentController.navigationController.viewControllers.count == 1) {
            currentController.tabBarController.tabBar.hidden = _isTabNavigationHidden;
        }else{
            currentController.tabBarController.tabBar.hidden = _isTabNavigationHidden;
        }
    }
}
/**
 因复用，移除监听，重新监听
 */
#pragma 设置当前url
- (void)setUrl:(NSURL *)url{
    
    //初始化

    _url = url;
    
    self.isPlayAfterPause = NO;
    
    if (![_url.absoluteString hasPrefix:@"http"])
    {
        
        self.isLocalVideo = YES;

        self.asset = [AVURLAsset URLAssetWithURL:url options:nil];
           
        self.playerItem=[AVPlayerItem playerItemWithAsset:self.asset];
           
           if (!self.player) {
               self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
           } else {
               [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
           }

       }else{
           self.isLocalVideo = NO;
           self.playerItem = nil;
           NSURLComponents *components = [[NSURLComponents alloc]initWithURL:_url resolvingAgainstBaseURL:NO];
           ////注意，不加这一句不能执行到回调操作
           components.scheme = kCustomVideoScheme;
           
           self.asset=[[AVURLAsset alloc]initWithURL:components.URL options:nil];
           
           _resourceManager = [[ZJResourceLoaderManager alloc]init];
           
           [self.asset.resourceLoader setDelegate:_resourceManager queue:dispatch_get_main_queue()];
           
           self.playerItem=[AVPlayerItem playerItemWithAsset:self.asset];
           
           if (!self.player) {
               self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
           } else {
               [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
           } self.playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;

       }

        [self addObserverToPlayerItem:self.playerItem];
}
#pragma  当前播放视频的标题
- (void)setTitle:(NSString *)title{
    _title = title;
    self.topView.title = _title;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationMaskPortrait) {
        //竖屏布局
        NSLog(@"------------竖屏布局");
    } else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft){
        //横屏布局
        NSLog(@"-----------=右横屏布局");
        self.isFullScreen = YES;
    }else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        //横屏布局
        NSLog(@"-----------=左横屏布局");
        self.isFullScreen = YES;
        
    }else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationMaskPortraitUpsideDown){
        //横屏布局
        NSLog(@"-----------=下竖屏");
        return;
    } else{
        NSLog(@"默认");
        self.isFullScreen = NO;
    }
    
    
    if (self.isFullScreen) {
        self.isTabNavigationHidden = YES;
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        NSLog(@"进啦了大的");
    }else{
        self.isTabNavigationHidden = NO;
        self.frame = CGRectMake(0, 0, kScreenWidth, self.frameOnFatherView.size.height);
        [self.progress resetFrameisFullScreen:NO];
        [self.brightness resetFrameisFullScreen:NO];
    }
    self.playerLayer.frame = self.bounds;

}
#pragma 实例化
-(instancetype)initWithUrl:(NSURL *)url  withSuperView:(UIView *)superView frame:(CGRect)frame controller:(UIViewController *)controller{
    self = [super init];
    if (self) {
        _url = url;
        self.controller = controller;
        self.fatherView = superView;
        
        if (!CGRectEqualToRect(frame, CGRectZero)) {
            self.frameOnFatherView = frame;
            [self configureUI];
        }

        [self setupObservers];//监听应用状态
        [self addNotificationCenter];
        
        //  [self addSwipeGesture];
        
        //给playView加手势
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap)];
        [self addGestureRecognizer:tapGes];
    }
    return self;
}
- (instancetype)init{

    return [self initWithUrl:[NSURL URLWithString:@""] withSuperView:nil frame:CGRectZero controller:nil];
}

- (void)deallocSelf{
    self.fatherView = nil;
    [self.player pause];
    self.player = nil;
    self.playerLayer  = nil;
    self.playerItem = nil;
    self.asset = nil;

    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setPlayerFrame:(CGRect)frame{

    self.frameOnFatherView = frame;

    [self configureUI];

}

- (AVPlayer *)player{
    if (_player == nil) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}
- (AVPlayerLayer *)playerLayer{
    if (_playerLayer == nil) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        // 把Layer加到底部View上 //放到最下面，防止遮挡
        [self.layer insertSublayer:_playerLayer atIndex:1];
    }
    return _playerLayer;
}
- (UIImageView *)BGImgView{
    if (_BGImgView == nil) {
        _BGImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frameOnFatherView.size.width, self.frameOnFatherView.size.height)];
        [self addSubview:_BGImgView];
    }
    return _BGImgView;
}
- (ZJTopView *)topView{
    if (_topView == nil) {
        _topView = [[ZJTopView alloc]initWithFrame:CGRectMake(0, 0, self.frameOnFatherView.size.width, 50)];
        _topView.delegate = self;
        _topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self addSubview:_topView];
    }
    return _topView;
}
- (ZJControlView *)bottomView{
    if (_bottomView == nil) {
        _bottomView =[[ZJControlView alloc]initWithFrame:CGRectMake(0, self.frameOnFatherView.size.height-50, self.frameOnFatherView.size.width, 50)];
        _bottomView.delegate = self;
        [self addSubview:_bottomView];
    }
    return _bottomView;
}
- (ZJLoadingIndicator *)loadingIndicator{
    if (_loadingIndicator == nil) {
        _loadingIndicator = [[ZJLoadingIndicator alloc]init];
        [self addSubview:_loadingIndicator];
    }
    return _loadingIndicator;
}

- (void)configureUI{
    self.isFullScreen = NO;
    self.isPlayAfterPause = NO;
    self.slidingStyle = slidingDefault;
   
    // 初始化播放器item
//    self.asset=[[AVURLAsset alloc]initWithURL:_url options:nil];
//    self.playerItem=[AVPlayerItem playerItemWithAsset:self.asset];
    
    self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    /*
     * layer的填充属性 和UIImageView的填充属性类似
     * AVLayerVideoGravityResizeAspect 等比例拉伸，会留白
     * AVLayerVideoGravityResizeAspectFill // 等比例拉伸，会裁剪
     * AVLayerVideoGravityResize // 保持原有大小拉伸
     */
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;

  
    self.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    if (_url.absoluteString.length > 0) {
        self.url = _url;
    }

    self.BGImgView.image = [ZJCustomTools thumbnailImageRequest:10.5 url:self.url.absoluteString];
    
    
    //顶部栏

     self.topView.hidden = YES;
    
    //底部
    self.bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

    self.loadingIndicator.frame = CGRectMake((self.frameOnFatherView.size.width-35)/2.0, (self.frameOnFatherView.size.height-35)/2.0, 35, 35);

    self.loadingIndicator.progress = 0.5;
    
    if (self.progress == nil) {
         self.progress = [[ZJProgress alloc]initWithSuperView:self];
    }
    if (self.brightness == nil) {
        self.brightness = [[ZJBrightness alloc]initWithSuperView:self];

    }

    self.volumeViewSlider.frame = CGRectMake(-1000, -1000, 100, 100);

    
}
#pragma  mark -- 加滑动手势
- (void)addSwipeGesture{

    UISwipeGestureRecognizer * swipeGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:swipeGestureLeft];
    UISwipeGestureRecognizer * swipeGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:swipeGestureRight];
    
    //增加音量的手势
    UISwipeGestureRecognizer *increaseGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(increaseVolume:)];
    increaseGesture.direction=UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:increaseGesture];
    //减小音量的手势
    UISwipeGestureRecognizer *decreaseGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(decreaseVolume:)];
    decreaseGesture.direction=UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:decreaseGesture];
    
}
- (void)swipeAction:(UISwipeGestureRecognizer *)swipeGesture{
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {//左滑
        [self swipeToPlusTime:NO];
    }else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight){//右滑
        [self swipeToPlusTime:YES];
    }
}
#pragma mark -- 向上滑动增加屏幕亮度
-(void)increaseVolume:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction==UISwipeGestureRecognizerDirectionUp)
    {
        
        CGFloat  currentLight = [[UIScreen mainScreen] brightness];
        if(currentLight>=1.0)
            return;
        currentLight+=0.1;
        [[UIScreen mainScreen] setBrightness: currentLight];
    }
}

#pragma mark -- 向下滑动减小屏幕亮度
-(void)decreaseVolume:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction==UISwipeGestureRecognizerDirectionDown)
    {
        CGFloat  currentLight = [[UIScreen mainScreen] brightness];
        if(currentLight<=0.0)
            return;
        currentLight-=0.1;
        [[UIScreen mainScreen] setBrightness: currentLight];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch=[[event allTouches] anyObject];
    
    self.gestureStartPoint=[touch locationInView:self.superview];
    
    // 获取当前播放的时间
    self.progressTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
    
    CGFloat duration = CMTimeGetSeconds(self.playerItem.duration);
    
    self.isTouchesMoved = NO;
    
    self.progress.allTime = [self convertToTime:duration];
    
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* touch=[[event allTouches] anyObject];
    CGPoint currentPoint=[touch locationInView:self.superview];
    CGFloat pointX=(self.gestureStartPoint.x-currentPoint.x);
    CGFloat pointY=(self.gestureStartPoint.y-currentPoint.y);
    self.isTouchesMoved = YES;
    BOOL isPlusTime = YES;
    
    CGFloat width = kScreenWidth;
    CGFloat x = self.gestureStartPoint.x;
    
//     if (self.isFullScreen) {//大屏，x和y互换
//
//         pointY=(self.gestureStartPoint.x-currentPoint.x);
//         pointX=(self.gestureStartPoint.y-currentPoint.y);
//         isPlusTime = NO;
//         width = kScreenHeight;
//         x = self.gestureStartPoint.y;
//         if (!self.isLandscapeLeft) {
//             isPlusTime = YES;
//             x = width - x;
//         }
//     }
    
    switch (self.slidingStyle) {
        case slidingDefault:
            [self slidingDefaultIsPlusTime:isPlusTime pointY:pointY pointX:pointX x:x width:width];
            break;
        case slidingVolume:
            [self slidingVolumeIsPlusTime:isPlusTime pointY:pointY pointX:pointX x:x width:width];
            break;
        case slidingProgress:
            [self slidingProgressIsPlusTime:isPlusTime pointY:pointY pointX:pointX x:x width:width];
            break;
        case slidingBrightness:
            [self slidingBrightnessIsPlusTime:isPlusTime pointY:pointY pointX:pointX x:x width:width];
            break;
        default:
            break;
    }

    self.gestureStartPoint = currentPoint;
    
}
#pragma mark -- 默认滑动
- (void)slidingDefaultIsPlusTime:(BOOL)isPlusTime pointY:(CGFloat)pointY pointX:(CGFloat)pointX x:(CGFloat)x width:(CGFloat)width{
    //上下滑动
    if (fabs(pointY)>fabs(pointX)) {
        if (self.isFullScreen == NO) {
            return ;
        }
        //向上滑动
        if (pointY>MINDISTANCE) {
            if (x < width / 2.0 ) {//右边
                self.slidingStyle = slidingVolume;
                [self swipeToPlusVolume:!isPlusTime];
            }else{
                self.slidingStyle = slidingBrightness;
                [self.brightness show];
                [self swipeToPlusbrightness:!isPlusTime];
            }
            
        }else if(pointY<-MINDISTANCE){
            
            if (x < width / 2.0 ) {//右边
                 self.slidingStyle = slidingVolume;
                [self swipeToPlusVolume:isPlusTime];
            }else{
                 self.slidingStyle = slidingBrightness;
                [self.brightness show];
                [self swipeToPlusbrightness:isPlusTime];
            }
        }
    }else if(fabs(pointX)>fabs(pointY)){//左右滑动
         self.slidingStyle = slidingProgress;
        [self.progress show];
        //向右滑动
        if (pointX<-MINDISTANCE) {
            [self swipeToPlusTime:isPlusTime];
        }else if(pointX>MINDISTANCE){
            [self swipeToPlusTime:!isPlusTime];
        }
    }
}
#pragma mark -- 声音滑动
- (void)slidingVolumeIsPlusTime:(BOOL)isPlusTime pointY:(CGFloat)pointY pointX:(CGFloat)pointX x:(CGFloat)x width:(CGFloat)width{

        if (pointY>MINDISTANCE) {

                [self swipeToPlusVolume:!isPlusTime];

        }else if(pointY<-MINDISTANCE){

                [self swipeToPlusVolume:isPlusTime];

        }

}
#pragma mark -- 进度滑动
- (void)slidingProgressIsPlusTime:(BOOL)isPlusTime pointY:(CGFloat)pointY pointX:(CGFloat)pointX x:(CGFloat)x width:(CGFloat)width{

        [self.progress show];
        //向右滑动
        if (pointX<-MINDISTANCE) {
 
            [self swipeToPlusTime:isPlusTime];
        }else if(pointX>MINDISTANCE){
            [self swipeToPlusTime:!isPlusTime];
          
        }

}
#pragma mark -- 亮度滑动
- (void)slidingBrightnessIsPlusTime:(BOOL)isPlusTime pointY:(CGFloat)pointY pointX:(CGFloat)pointX x:(CGFloat)x width:(CGFloat)width{

        //向上滑动
        if (pointY>MINDISTANCE) {

        [self.brightness show];
        [self swipeToPlusbrightness:!isPlusTime];

        }else if(pointY<-MINDISTANCE){

        [self.brightness show];
        [self swipeToPlusbrightness:isPlusTime];
       
        }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.brightness dismiss];
    [self.progress dismiss];
    if (self.isTouchesMoved && self.slidingStyle == slidingProgress) {
        self.isTouchesMoved = NO;
        [self.loadingIndicator show];
        [self.player seekToTime:CMTimeMakeWithSeconds(self.progressTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
  self.slidingStyle = slidingDefault;
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.progress dismiss];
    [self.brightness dismiss];
    //判断是单击还是滑动
    if (self.isTouchesMoved && self.slidingStyle == slidingProgress) {
        self.isTouchesMoved = NO;
        [self.loadingIndicator show];
        [self.player seekToTime:CMTimeMakeWithSeconds(self.progressTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    self.slidingStyle = slidingDefault;
}
#pragma mark -- 滑动调整播放时间
- (void)swipeToPlusTime:(BOOL)isPlus{

    if (isPlus) {
        self.progressTime += 1;
       
    }else{
        
        self.progressTime -= 1;
    }
    self.progress.isForward = isPlus;
    
    if (self.progressTime >= CMTimeGetSeconds(self.player.currentItem.duration)) {
        
        self.progressTime = CMTimeGetSeconds(self.player.currentItem.duration) - 1;
        
    } else if (self.progressTime <= 0) {
        
        self.progressTime = 0;
        
    }
    
    CGFloat duration = CMTimeGetSeconds(self.playerItem.duration);
    
    self.progress.progress = self.progressTime / duration;
    
    
    self.progress.currentTime = [self convertToTime:self.progressTime];
    
}
#pragma mark -- 滑动调整亮度
- (void)swipeToPlusbrightness:(BOOL)isPlus{
    
    CGFloat  currentLight = [[UIScreen mainScreen] brightness];
    
    if (isPlus) {
        
        currentLight += 1/100.0;
        
    }else{
        
        currentLight -= 1/100.0;
    }
    
    if (currentLight <= 0.0) {
        currentLight = 0.0;
    }
    if (currentLight >= 1.0) {
        currentLight = 1.0;
    }
    
//    self.brightness.progress = currentLight;
    
    [[UIScreen mainScreen] setBrightness: currentLight];

}
#pragma mark -- 滑动调整声音
- (void)swipeToPlusVolume:(BOOL)isPlus{
    
    CGFloat  currentLolume = self.player.volume;
    
    if (isPlus) {
        
        currentLolume += 1/100.0;
        
    }else{
        
        currentLolume -= 1/100.0;
    }
    
    if (currentLolume <= 0.0) {
        currentLolume = 0.0;
    }
    if (currentLolume >= 1.0) {
        currentLolume = 1.0;
    }
    
    self.volumeViewSlider.value = currentLolume;
    
    
    self.player.volume = currentLolume;
    
}
#pragma 添加通知
- (void)addNotificationCenter{
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
    //监听AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //监听有控制器消失
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerWillDisappear) name:ZJViewControllerWillDisappear object:nil];
    //监听有控制器即将出现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewControllerWillAppear) name:ZJViewControllerWillAppear object:nil];
    
     //添加耳机状态监听
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventSubtypeRemoteControlTogglePlayPause) name:ZJEventSubtypeRemoteControlTogglePlayPause object:nil];

     [[AVAudioSession sharedInstance] setActive:YES error:nil];//创建单例对象并且使其设置为活跃状态.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

#pragma mark -- 音频输出改变触发事件OK
- (void)routeChange:(NSNotification *)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            NSLog(@"耳机插入");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            //NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            NSLog(@"耳机拔出，停止播放操作");
            //暂停播放
           
                [self pause];
          
           
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:  // called at start - also when other audio wants to play
            //NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
    
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma  mark -- 监听有控制器即将消失
- (void)viewControllerWillDisappear{

    if ([self windowVisible] == YES) {//当前player即将不显示
        
        self.isDisappear = YES;
        //player暂停
        if (self.player.rate != 0 && self.isPushOrPopPlpay == NO){
            [self.player pause];
            self.bottomView.isPlay  = NO;
        }
    }
}
- (void)eventSubtypeRemoteControlTogglePlayPause{
    [self pause];
}


#pragma mark -- 监听有控制器即将出现
- (void)viewControllerWillAppear{
    
    if (self.isDisappear) {
        
        self.isDisappear = NO;
        
        return;
    }

    if ([self windowVisible] == NO) {//当前player即将显示,此时还不显示
        //player暂停
        if (self.player.rate == 0 &&self.isAutoPlay){
            
            [UIView animateWithDuration:1 animations:^{
                [self.player play];
                self.BGImgView.hidden = YES;
                self.bottomView.isPlay  = YES;
            }];

        }
    }
}

#pragma 监听AVPlayer播放完成通知
- (void)playerItemDidReachEnd:(NSNotification *)notification{
   //播放完毕
    
    __weak typeof(self) weakSelf = self;

    if ([self.delegate respondsToSelector:@selector(playFinishedPlayer:)]) {
        
        [self.delegate playFinishedPlayer:self];
       
    }
    
    //连续播放视频
    if (self.isPlayContinuously) {
        [[NSNotificationCenter defaultCenter]postNotificationName:ZJContinuousVideoPlayback object:self];
    }else{
        
        //缓存清零
        ZJCacheTask * task =  [ZJCacheTask shareTask];
        [task clearCacheToFileUrl:self.url.absoluteString];
      
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf initTimer];
            
        }];
        
        self.bottomView.isPlay = NO;
    }

    //如果是大屏播放完毕，播放完毕自动回小平
    if (self.isRotatingSmallScreen ) {
        [self toCell];
        [self.bottomView.scalingBtn setImage:[UIImage imageNamed:@"缩小"] forState:UIControlStateNormal];
    }
}
/**
 *  给AVPlayerItem添加监控
 *  @param playerItem AVPlayerItem对象
 */
#pragma 监听播放器状态变化
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用 // 缓冲区有足够数据可以播放了
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}
//注册通知
- (void)setupObservers
{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    [notification addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    //判断是否是手动暂停，若是手动暂停，不启动
    if (self.player.rate == 0 && self.isPlayAfterPause) {

        [self.player play];
        self.BGImgView.hidden = YES;
        self.bottomView.isPlay  = YES;
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (self.player.rate != 0){
        [self.player pause];
        
        self.bottomView.isPlay  = NO;
        
#warning 暂未调试好，app切换到后台，唤起其他app声音
       // OSStatus ret = AudioSessionSetActiveWithFlags(NO, kAudioSessionSetActiveFlag_NotifyOthersOnDeactivation);
        
      //  [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        
       // [AVAudioSession sharedInstance]
    }
}

- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
// 屏幕旋转
- (void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
            //不做处理
            
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");

            [self toCell];
            
            
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在右");

            self.isAutomaticHorizontal =  YES;
            self.isLandscapeLeft = YES;
            [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在左");

            self.isAutomaticHorizontal =  YES;
            self.isLandscapeLeft = NO;
            [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - 点击全屏
- (void)clickFullScreen:(UIButton *)button
{

    if (!self.isFullScreen)
    {//点击全屏
    
        self.isAutomaticHorizontal = NO;
        self.isLandscapeLeft = YES;
        [self.bottomView.scalingBtn setImage:[UIImage imageNamed:@"放大"] forState:UIControlStateNormal];
    }
    else
    {

        [self.bottomView.scalingBtn setImage:[UIImage imageNamed:@"缩小"] forState:UIControlStateNormal];
    }
    
    self.isFullScreen = !self.isFullScreen;
    
    self.isTabNavigationHidden = !self.isTabNavigationHidden;
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = !self.isFullScreen?UIInterfaceOrientationPortrait: UIInterfaceOrientationLandscapeRight;//这里可以改变旋转的方向
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
        
    }
    
}
#pragma mark -- 缩小到cell
-(void)toCell{

    //小屏幕是隐藏top

    self.topView.hidden = YES;

    self.frame = CGRectMake(0, 0, kScreenWidth, self.frameOnFatherView.size.height);
    if (self.BGImgView.hidden == NO) {
        self.BGImgView.frame = CGRectMake(0, 0, self.frameOnFatherView.size.width, self.frameOnFatherView.size.height);
    }
        // remark 约束
    
    self.loadingIndicator.frame = CGRectMake((self.frameOnFatherView.size.width -35)/2.0, (self.frameOnFatherView.size.height -35)/2.0, 35, 35);

    self.bottomView.frame = CGRectMake(0, self.frameH-50, kScreenWidth, 50);
    [self.bottomView resetFrame];
    self.topView.frame = CGRectMake(0, 0, kScreenWidth, 50);
    [self.topView resetFrame];


}

#pragma mark - 单击手势
- (void)singleTap
{
    // 和即时搜索一样，删除之前未执行的操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissView:) object:nil];
    
    // 这里点击会隐藏对应的View，那么之前的定时还开着，如果不关掉，就会可能重复
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:8.0 target:self selector:@selector(autoDismissView:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
    
    [UIView animateWithDuration:1.0 animations:^{
        if (self.bottomView.alpha == 1)
        {
            self.bottomView.alpha = 0;
            self.topView.alpha = 0;
        }
        else if (self.bottomView.alpha == 0)
        {
            self.bottomView.alpha = 1.0f;
            self.topView.alpha = 1.0f;
        }
        
        
    }];
}


- (void)setIsBottomViewHidden:(BOOL)isBottomViewHidden{
    _isBottomViewHidden = !isBottomViewHidden;
    
    if (_isBottomViewHidden) {
        [UIView animateWithDuration:1.0 animations:^{
            
            self.bottomView.alpha = 0;
            self.topView.alpha = 0;
        }];
    }else{
        self.bottomView.alpha = 1;
        self.topView.alpha = 1;
    }
}

// 监听播放器的变化属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerItemStatus statues = [change[NSKeyValueChangeNewKey] integerValue];
        switch (statues) {
                // 监听到这个属性的时候，理论上视频就可以进行播放了
            case AVPlayerItemStatusReadyToPlay:
                
                // 最大值直接用sec，以前都是
                // CMTimeMake(帧数（slider.value * timeScale）, 帧/sec)
                self.bottomView.sliderMaximumValue = CMTimeGetSeconds(self.playerItem.duration);
                
                [self.loadingIndicator dismiss];
               
                [self initTimer];
                
                self.player.volume = 0.4;
                if (self.isAutoPlay) {
                    [self play];
                }
              // 启动定时器 5秒自动隐藏
                if (!self.autoDismissTimer)
                {
                    self.autoDismissTimer = [NSTimer timerWithTimeInterval:8.0 target:self selector:@selector(autoDismissView:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
                }

                break;
                
            case AVPlayerItemStatusUnknown:
                
                
                
                break;
                // 这个就是不能播放喽，加载失败了
            case AVPlayerItemStatusFailed:
                
                // 这时可以通过`self.player.error.description`属性来找出具体的原因
                
                break;
                
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) // 监听缓存进度的属性
    {
       
        [self loadedTimeRanges];
       
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
       // NSLog(@"playbackBufferEmpty");
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
       // NSLog(@"playbackLikelyToKeepUp");
        
        [self.loadingIndicator dismiss];

    }
}
#pragma mark -- 监听缓存进度
- (void)loadedTimeRanges{
    //        // 计算缓存进度
    NSTimeInterval timeInterval = [self availableDuration];
    //        // 获取总长度
    CMTime duration = self.playerItem.duration;
    //
    CGFloat durationTime = CMTimeGetSeconds(duration);
    //        // 监听到了给进度条赋值
    
    self.bottomView.progress = timeInterval / durationTime;
    
}
/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [self.playerItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start); // 开始的点
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration); // 已缓存的时间点
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark -- 调用plaer的对象进行UI更新
- (void)initTimer
{
    // player的定时器
    __weak typeof(self)weakSelf = self;
    // 每秒更新一次UI Slider
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        // 当前时间
        CGFloat nowTime = CMTimeGetSeconds(weakSelf.playerItem.currentTime);
        // 总时间
        CGFloat duration = CMTimeGetSeconds(weakSelf.playerItem.duration);
        // sec 转换成时间点
        
        weakSelf.bottomView.currentTime = [weakSelf convertToTime:nowTime];
        
        
        weakSelf.bottomView.remainingTime = [weakSelf convertToTime:(duration - nowTime)];
        
        
        //当已经开始播放之后，隐藏指示器
        [weakSelf.loadingIndicator dismiss];
        
        // 获取当前播放的时间
        NSTimeInterval currentTime = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime);
        ZJCacheTask * task =  [ZJCacheTask shareTask];
        [task writeToFileUrl:weakSelf.url.absoluteString time:currentTime];
    
        // 不是拖拽中的话更新UI
        if (!weakSelf.isDragSlider)
        {

            weakSelf.bottomView.sliderValue = CMTimeGetSeconds(weakSelf.playerItem.currentTime);
            
        }

    }];
}

// sec 转换成指定的格式
- (NSString *)convertToTime:(CGFloat)time
{
    // 初始化格式对象
    NSDateFormatter *fotmmatter = [[NSDateFormatter alloc] init];
    // 根据是否大于1H，进行格式赋值
    if (time >= 3600)
    {
        [fotmmatter setDateFormat:@"HH:mm:ss"];
    }
    else
    {
        [fotmmatter setDateFormat:@"mm:ss"];
    }
    // 秒数转换成NSDate类型
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    // date转字符串
    return [fotmmatter stringFromDate:date];
}
#pragma mark - 自动隐藏bottom和top
- (void)autoDismissView:(NSTimer *)timer
{
    // player的属性rate
    /* indicates the current rate of playback; 0.0 means "stopped", 1.0 means "play at the natural rate of the current item" */
    if (self.player.rate == 0)
    {
        // 暂停状态就不隐藏
    }
    else if (self.player.rate == 1)
    {
        if (self.bottomView.alpha == 1)
        {
            [UIView animateWithDuration:1.0 animations:^{
                
                self.bottomView.alpha = 0;
                self.topView.alpha = 0;
                
            }];
        }
    }
}
#pragma mark -- 全屏显示
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{

    
    if ([self windowVisible] == NO) {//判断当前player是否显示在window上

        return;
    }

    self.topView.hidden = NO;
    
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenHeight;

    [self.progress resetFrameisFullScreen:YES];
    [self.brightness resetFrameisFullScreen:YES];

    
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    if (self.BGImgView.hidden == NO) {
        self.BGImgView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    
    self.loadingIndicator.frame = CGRectMake((width -35)/2.0, (height -35)/2.0, 35, 35);

    self.bottomView.frame = CGRectMake(0, self.frameH-50, self.frameW, 50);
    [self.bottomView resetFrame];
    self.topView.frame = CGRectMake(0, 0, self.frameW, 50);
    [self.topView resetFrame];

    //获取到当前状态条的方向
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    //判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (currentOrientation == interfaceOrientation) {
        return;
    }else{

    }
    
}
#pragma 其它App播放声音
- (void)otherAudioPlay{
    //判断还有没有其它业务的声音在播放。
    if ([AVAudioSession sharedInstance].otherAudioPlaying) {
       // NSLog(@"有其他声音在播放");
        
    }
}

#pragma mark -- ZJControlViewDelegate
- (void)clickFullScreen{

    [self clickFullScreen:nil];
}
#pragma 视频播放
- (void)play{

    self.BGImgView.hidden = YES;
    
    self.bottomView.isPlay  = YES;
    
    [self.player play];

    ZJCacheTask * task =  [ZJCacheTask shareTask];
    
    NSTimeInterval time = [task queryToFileUrl:_url.absoluteString];
    
    //判断是开始播放，还是暂停之后的播放
    if (time > 0 &&self.isPlayAfterPause == NO) {
        
        [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    if (self.isPlayAfterPause == NO) {
        [self.topView resetRate];
    }else{//暂停播放，倍速还原为之前的
        self.player.rate = self.topView.rate;
    }
    
    if (self.isPlayAfterPause == NO) {
         [self.loadingIndicator show];//可以播放就隐藏
    }
    if (self.isPlayContinuously && self.isFullScreen) {//连续播放
        //如果上个是全屏，连续播放也是全屏
        
        if (self.isLandscapeLeft) {
            
            [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        }else{
        
            [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
    }
}
- (void)saveImageToPhotos:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
       
        HUDNormal(@"保存成功");
    } else {
        NSLog(@"false");
    }
}

#pragma mark -- 视频暂停
- (void)pause{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bottomView.isPlay  = NO;
        self.isPlayAfterPause = YES;
        [self.player pause];
    });
}
- (void)sliderDragValueChange:(UISlider *)slider
{
    self.isDragSlider = YES;
    
}

- (void)sliderTapValueChange:(UISlider *)slider
{
    self.BGImgView.hidden = YES;
    self.isDragSlider = NO;
    // CMTimeMake(帧数（slider.value * timeScale）, 帧/sec)
    // 直接用秒来获取CMTime
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, self.playerItem.currentTime.timescale)];
    NSLog(@"%d,%lld",self.player.currentItem.asset.duration.timescale,self.player.currentItem.asset.duration.value);
}
// 点击事件的Slider
- (void)touchSlider:(UITapGestureRecognizer *)tap
{
    // 根据点击的坐标计算对应的比例
    CGPoint touch = [tap locationInView:self.bottomView.slider];
    CGFloat scale = touch.x / self.bottomView.slider.bounds.size.width;
    self.bottomView.sliderValue = CMTimeGetSeconds(self.playerItem.duration) * scale;
    [self.player seekToTime:CMTimeMakeWithSeconds(self.bottomView.sliderValue, self.playerItem.currentTime.timescale)];
    /* indicates the current rate of playback; 0.0 means "stopped", 1.0 means "play at the natural rate of the current item" */
    if (self.player.rate == 0)
    {
        self.bottomView.isPlay  = YES;
        self.BGImgView.hidden = YES;
        [self.player play];
    }
}
#pragma mark -- ZJTopViewDelegate
- (void)back{
    if (self.isFullScreen)
     {
        [self clickFullScreen:nil];
    }
}

- (void)setRate:(float)rate{
    self.player.rate = rate;
}

- (void)fetchScreen{
    
    CGFloat nowTime = CMTimeGetSeconds(self.playerItem.currentTime);

    
    UIImage *image = [ZJCustomTools thumbnailImageRequest:nowTime url:_url.absoluteString];
    
    [self saveImageToPhotos:image];
}
- (void)gifScreenshot{

    [self pause];
    
    
    
//
//    InterceptView * view = [[InterceptView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) url:self.url playerItem:self.playerItem currentTime:self.playerItem.currentTime];
//    view.currentTtime = self.playerItem.currentTime;
//    view.playerItem = self.player.currentItem;
//    view.delegate = self;
    
    [self.interceptView setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) url:self.url playerItem:self.playerItem currentTime:self.playerItem.currentTime];
    
    [self addSubview:self.interceptView];
    
}

//#pragma mark -InterceptViewDelegate
//-(void)interceptViewToback{
//    [self play];
//}


@end
