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

NSString *const ZJViewControllerWillDisappear = @"ZJViewControllerWillDisappear";
NSString *const ZJViewControllerWillAppear = @"ZJViewControllerWillAppear";
NSString *const ZJContinuousVideoPlayback = @"ZJContinuousVideoPlayback";
#define MINDISTANCE 0.5

@interface ZJPlayer()<ZJControlViewDelegate,ZJTopViewDelegate>

/**
 父视图
 */
@property(weak,nonatomic) UIView * fatherView;

@property(nonatomic) CGRect  currentFrame;
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
 当前点击屏幕是否有滑动 YES:滑动 NO:没有滑动，只是点击 ，默认是NO
 */
@property(assign,nonatomic) BOOL  isTouchesMoved;

/**
 横屏状态 YES:电池栏在右 NO:电池栏在左 ，在全屏有效
 */
@property(assign,nonatomic) BOOL  isLandscapeLeft;

/**
 是否添加过监听 YES:已经监听 NO:无监听
 */
@property(assign,nonatomic) BOOL  isAddObserverToPlayerItem;
/**
 加载指示器
 */
@property(strong,nonatomic) ZJLoadingIndicator * loadingIndicator;
/**
 滑动进度展示器
 */
@property(strong,nonatomic) ZJProgress * progress;
/**
 开始活动的点
 */
@property(assign,nonatomic) CGPoint  gestureStartPoint;
/**
 开始滑动时的播放时间
 */
@property(assign,nonatomic) NSTimeInterval  progressTime;

@end

@implementation ZJPlayer

+ (id)sharePlayer
{
    static ZJPlayer *player = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        player = [[ZJPlayer alloc]initWithUrl:[NSURL URLWithString:@""]];
        
    });
    return player;
}

- (void)setIsTabNavigationHidden:(BOOL)isTabNavigationHidden{
    
    _isTabNavigationHidden = isTabNavigationHidden;
    
    UIViewController * currentController = [self getCurrentViewController];
    //隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:_isTabNavigationHidden withAnimation:UIStatusBarAnimationNone];
    //隐藏底航栏
    currentController.tabBarController.tabBar.hidden = _isTabNavigationHidden;
    //隐藏状态栏
    currentController.navigationController.navigationBar.hidden = _isTabNavigationHidden;
    
}
/**
 因复用，移除监听，重新监听
 */
#pragma 设置当前url
- (void)setUrl:(NSURL *)url{
    
    _url = url;

    self.isPlayAfterPause = NO;
    
    if (self.isAddObserverToPlayerItem) {
        
        self.isAddObserverToPlayerItem = NO;
        
        [self removeObserverFromPlayerItem:self.playerItem];
  
    }
    
    self.playerItem = nil;
    
//    self.asset=[[AVURLAsset alloc]initWithURL:_url options:nil];
//    
//    
//    self.playerItem=[AVPlayerItem playerItemWithAsset:self.asset];
    
    self.playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    if (self.isAddObserverToPlayerItem == NO) {
        self.isAddObserverToPlayerItem = YES;
        [self addObserverToPlayerItem:self.playerItem];
    }
}
#pragma  当前播放视频的标题
- (void)setTitle:(NSString *)title{
    _title = title;
    self.topView.title = _title;
    
}

- (void)layoutSubviews{
    [super layoutSubviews];

    self.isTabNavigationHidden = self.isFullScreen;
    
    if (self.isFullScreen) {
        
        self.frame = self.currentFrame;

        
        self.playerLayer.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
      
 
    }else{
        
        
        self.playerLayer.frame = self.bounds;
        [self.progress resetFrameisFullScreen:NO];
    }
}
#pragma 实例化
-(instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        _url = url;
        
        [self configureUI];
        
        [self setupObservers];//监听应用状态
    }
    return self;
}
- (instancetype)init{

    return [self initWithUrl:[NSURL URLWithString:@""]];
}

- (void)dealloc{
    NSLog(@"销毁......");
}

- (void)configureUI{
    self.isFullScreen = NO;
    self.isPlayAfterPause = NO;
    
   
    // 初始化播放器item
   // self.playerItem = [[AVPlayerItem alloc] initWithURL:_url];
//    self.asset=[[AVURLAsset alloc]initWithURL:_url options:nil];
//    self.playerItem=[AVPlayerItem playerItemWithAsset:self.asset];
    
    self.player = [[AVPlayer alloc] init];
    
    self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    // 初始化播放器的Layer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    /*
     * layer的填充属性 和UIImageView的填充属性类似
     * AVLayerVideoGravityResizeAspect 等比例拉伸，会留白
     * AVLayerVideoGravityResizeAspectFill // 等比例拉伸，会裁剪
     * AVLayerVideoGravityResize // 保持原有大小拉伸
     */
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 把Layer加到底部View上 //放到最下面，防止遮挡
    [self.layer insertSublayer:self.playerLayer atIndex:1];
    
    self.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    if (_url.absoluteString.length > 0) {
        self.url = _url;
    }
    
    //顶部栏
    self.topView = [[ZJTopView alloc]init];
    self.topView.delegate = self;
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.topView.hidden = YES;
    [self addSubview:self.topView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.top.equalTo(self).with.offset(0);
        make.height.mas_equalTo(50);
    }];

    //底部
    
    self.bottomView = [[ZJControlView alloc]init];
    self.bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.bottomView.delegate = self;
    [self addSubview:self.bottomView];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(50);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        
    }];

    
    
    self.loadingIndicator = [[ZJLoadingIndicator alloc]init];
    self.loadingIndicator.backgroundColor = [UIColor redColor];
    [self addSubview:self.loadingIndicator];
    
    [self.loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.width.mas_equalTo(35);
    }];

    
    self.progress = [[ZJProgress alloc]initWithSuperView:self];

   

    [self addNotificationCenter];
    
    [self addSwipeGesture];
    
    //给playView加手势
    [self bk_whenTapped:^{
        [self singleTap];
        
    }];
}
#pragma  mark -- 加滑动手势
- (void)addSwipeGesture{

    //增加音量的手势
    UISwipeGestureRecognizer *increaseGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(increaseVolume:)];
    increaseGesture.direction=UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:increaseGesture];
    //减小音量的手势
    UISwipeGestureRecognizer *decreaseGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(decreaseVolume:)];
    decreaseGesture.direction=UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:decreaseGesture];
    
 
}

#pragma mark -- 向上滑动增加音量
-(void)increaseVolume:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction==UISwipeGestureRecognizerDirectionUp)
    {
        if(_player.volume>=1.0)
            return;
        _player.volume+=0.1;
        
        NSLog(@"+++++音量:%f++++++",10*_player.volume);
//        weak PlayViewController *weakSelf=self;
//        _volumeLabel.text=[NSString stringWithFormat:@"音量:%d",(int)ceilf(_player.volume*10)];
//        [UIView animateWithDuration:0.2 animations:^{
//            weakSelf.volumeLabel.alpha=1.0;
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.2 animations:^{
//                weakSelf.volumeLabel.alpha=0.0;
//            }];
//        }];
    }
}

#pragma mark -- 向下滑动减小音量
-(void)decreaseVolume:(UISwipeGestureRecognizer *)sender
{
    if(sender.direction==UISwipeGestureRecognizerDirectionDown)
    {
        if(_player.volume<=0.0)
            return;
        _player.volume-=0.1;
        
        NSLog(@"------音量:%f------",10*_player.volume);
        
//        weak PlayViewController *weakSelf=self;
//        _volumeLabel.text=[NSString stringWithFormat:@"音量:%d",(int)ceilf(_player.volume*10)];
//        [UIView animateWithDuration:0.3 animations:^{
//            weakSelf.volumeLabel.alpha=1.0;
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.3 animations:^{
//                weakSelf.volumeLabel.alpha=0.0;
//            }];
//        }];
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
    //NSLog(@"x=%f y=%f",fabs(pointX),fabs(pointY));
    self.isTouchesMoved = YES;
    BOOL isPlusTime = YES;
    
     if (self.isFullScreen) {//大屏，x和y互换
     
         pointY=(self.gestureStartPoint.x-currentPoint.x);
         pointX=(self.gestureStartPoint.y-currentPoint.y);
         isPlusTime = NO;
         if (!self.isLandscapeLeft) {
             isPlusTime = YES;
         }
     }
        //上下滑动
        if (fabs(pointY)>fabs(pointX)) {
            //向上滑动
            if (pointY>MINDISTANCE) {
                // NSLog(@"第二种方式：向上滑动");
            }else if(pointY<-MINDISTANCE){
                // NSLog(@"第二种方式：向下滑动");
            }
        }else if(fabs(pointX)>fabs(pointY)){//左右滑动
            //向右滑动
            if (pointX<-MINDISTANCE) {
                
              //  NSLog(@"第二种方式：向右滑动");
                [self swipeToPlusTime:isPlusTime];
            }else if(pointX>MINDISTANCE){
                [self swipeToPlusTime:!isPlusTime];
               // NSLog(@"第二种方式：向左滑动");
            }
        }
    [self.progress show];
    self.gestureStartPoint = currentPoint;
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.progress dismiss];
    if (self.isTouchesMoved) {
        self.isTouchesMoved = NO;
        [self.loadingIndicator show];
        [self.player seekToTime:CMTimeMakeWithSeconds(self.progressTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
  
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.progress dismiss];
    
    //判断是单击还是滑动
    if (self.isTouchesMoved) {
        self.isTouchesMoved = NO;
        [self.loadingIndicator show];
        [self.player seekToTime:CMTimeMakeWithSeconds(self.progressTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    
    
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
}
#pragma  mark -- 监听有控制器即将消失
- (void)viewControllerWillDisappear{

    if ([self windowVisible] == YES) {//当前player即将不显示
        
        self.isDisappear = YES;
        //player暂停
        if (self.player.rate != 0){
            [self.player pause];
            self.bottomView.isPlay  = NO;
        }
    }
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
    {
        
        self.isAutomaticHorizontal = NO;
        self.isLandscapeLeft = YES;
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        [self.bottomView.scalingBtn setImage:[UIImage imageNamed:@"放大"] forState:UIControlStateNormal];
    }
    else
    {
        


        [self toCell];
        [self.bottomView.scalingBtn setImage:[UIImage imageNamed:@"缩小"] forState:UIControlStateNormal];
    }
   
}
// 缩小到cell
-(void)toCell{

    self.isFullScreen = NO;
    
    
    if (self.fatherView == nil) {
        
        return;
    }
    //小屏幕是隐藏top
    self.topView.hidden = YES;
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        weakSelf.transform = CGAffineTransformIdentity;

        // 再添加到View上
        [weakSelf.fatherView addSubview:weakSelf];
       
        [weakSelf mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.fatherView).offset(self.frameOnFatherView.origin.y);
            make.left.mas_equalTo(weakSelf.fatherView).offset(self.frameOnFatherView.origin.x);
            make.width.mas_equalTo(self.frameOnFatherView.size.width);
            make.height.mas_equalTo(self.frameOnFatherView.size.height);
        }];
        
        // remark 约束
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(50);
            make.bottom.mas_equalTo(self);
            make.left.mas_equalTo(self);
            make.width.mas_equalTo(kScreenWidth);
        }];
        
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(0);
            make.width.mas_equalTo(kScreenWidth);
            make.top.equalTo(self).with.offset(0);
            make.height.mas_equalTo(50);
        }];


    }completion:^(BOOL finished) {
        
    }];
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
                self.bottomView.slider.maximumValue = CMTimeGetSeconds(self.playerItem.duration);
                
                [self.loadingIndicator dismiss];
               
                [self initTimer];
                
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
        //        // 计算缓存进度
        NSTimeInterval timeInterval = [self availableDuration];
        //        // 获取总长度
        CMTime duration = self.playerItem.duration;
        //
        CGFloat durationTime = CMTimeGetSeconds(duration);
        //        // 监听到了给进度条赋值
        
        self.bottomView.progress = timeInterval / durationTime;
        
       
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        NSLog(@"playbackBufferEmpty");
       // [self.viewLogin setHidden:YES];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        //[self.viewLogin setHidden:NO];
        NSLog(@"playbackLikelyToKeepUp");
        
        [self.loadingIndicator dismiss];
        
        
    }
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

// 调用plaer的对象进行UI更新
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
#pragma 全屏显示
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{

    
    if ([self windowVisible] == NO) {//判断当前player是否显示在window上
        
        return;
        
    }
    
    self.topView.hidden = NO;
    
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenHeight;
    
    self.currentFrame = CGRectMake(0, 0, width, height);

    if (!self.isFullScreen) {//如果是第二次横屏就不执行此代码
        _fatherView = self.superview;
        self.frameOnFatherView = self.frame;
    }
    
    self.isFullScreen = YES;

    UIViewController * controller = [self getCurrentViewController];
    [controller.view addSubview:self];
    self.frame = CGRectMake(0, 0, width, height);
    
    [self.progress resetFrameisFullScreen:YES];
    
    // remark 约束
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self).offset(width - 50);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(height);
    }];
    
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.width.mas_equalTo(height);
        make.top.equalTo(self).with.offset(0);
        make.height.mas_equalTo(50);
    }];

    //获取到当前状态条的方向
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    //判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (currentOrientation == interfaceOrientation) {
        return;
    }

//    // 初始化
    self.transform = CGAffineTransformIdentity;
    //UIInterfaceOrientationLandscapeLeft 横屏 Home键在左侧
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);

    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        //UIInterfaceOrientationLandscapeRight 横屏 Home键在右侧
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
    }

}

#pragma 其它App播放声音
- (void)otherAudioPlay{
    //判断还有没有其它业务的声音在播放。
    if ([AVAudioSession sharedInstance].otherAudioPlaying) {
        NSLog(@"有其他声音在播放");
        
    }
}
#pragma 获取视频第一帧 返回图片
- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}
#pragma mark -- ZJControlViewDelegate
- (void)clickFullScreen{

    [self clickFullScreen:nil];
    
}
#pragma 视频播放
- (void)play{

    
    self.bottomView.isPlay  = YES;
    
    [self.player play];
   
    ZJCacheTask * task =  [ZJCacheTask shareTask];
    
    NSTimeInterval time = [task queryToFileUrl:_url.absoluteString];
    
    //判断是开始播放，还是暂停之后的播放
    if (time > 0 &&self.isPlayAfterPause == NO) {
        
        [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
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

#pragma mark -- 视频暂停
- (void)pause{

    self.bottomView.isPlay  = NO;
    self.isPlayAfterPause = YES;
    [self.player pause];
   
}
- (void)sliderDragValueChange:(UISlider *)slider
{
    self.isDragSlider = YES;
    
}

- (void)sliderTapValueChange:(UISlider *)slider
{
    self.isDragSlider = NO;
    // CMTimeMake(帧数（slider.value * timeScale）, 帧/sec)
    // 直接用秒来获取CMTime
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, self.playerItem.currentTime.timescale)];
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
    if (self.player.rate != 1)
    {
        self.bottomView.isPlay  = YES;
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


@end
