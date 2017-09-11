//
//  ZJPlayer.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/10.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "ZJPlayer.h"
#import "ZJControlView.h"

@interface ZJPlayer()<ZJControlViewDelegate>
//当前播放url
@property (nonatomic,strong) NSURL *url;

@end


@implementation ZJPlayer


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

- (void)configureUI{
    self.isFullScreen = NO;

    // 初始化播放器item
    self.playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    // 初始化播放器的Layer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    // layer的frame
    self.playerLayer.frame = CGRectMake(0, 0, kScreenWidth, 300);
    /*
     * layer的填充属性 和UIImageView的填充属性类似
     * AVLayerVideoGravityResizeAspect 等比例拉伸，会留白
     * AVLayerVideoGravityResizeAspectFill // 等比例拉伸，会裁剪
     * AVLayerVideoGravityResize // 保持原有大小拉伸
     */
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 把Layer加到底部View上
    [self.layer insertSublayer:self.playerLayer atIndex:0];
//    [self.layer addSublayer:self.playerLayer];
    //顶部栏
    self.topView = [[UIView alloc]init];
    
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.top.equalTo(self).with.offset(0);
        make.height.mas_equalTo(50);
    }];
    //顶部删除按钮
    self.closeButton = [[UIButton alloc]init];
    self.closeButton.showsTouchWhenHighlighted = YES;
    [self.closeButton setImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
    [self.closeButton bk_addEventHandler:^(id sender) {
        //关闭
        if (self.isFullScreen)
        {
            [self clickFullScreen:nil];
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.topView addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.topView).with.offset(5);
        make.centerY.equalTo(self.topView);
        make.size.mas_equalTo(CGSizeMake(35, 35));
        
        
    }];
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.text = @"奥特曼爱打小怪兽";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.left.mas_equalTo(self.closeButton.mas_right).offset(5);
        make.right.mas_equalTo(self.topView.mas_right).offset(-5);
        
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

    // 监听播放器状态变化
   // [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓存进去，就是大家所看到的一开始进去底部灰色的View会迅速加载
   // [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserverToPlayerItem:self.playerItem];
    
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    //给playView加手势
    [self bk_whenTapped:^{
        [self singleTap];
        
    }];

}
/**
 *  给AVPlayerItem添加监控
 *  @param playerItem AVPlayerItem对象
 */
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
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
    if (self.player.rate == 0) {
        [self.player play];
       
        [self.bottomView.playBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (self.player.rate == 1){
        [self.player pause];
        
        [self.bottomView.playBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
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
            
            //[self toCell];
            
            
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在右");
            
            
            [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在左");
            
            
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
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        [self.bottomView.scalingBtn setImage:[UIImage imageNamed:@"放大"] forState:UIControlStateNormal];
    }
    else
    {
        [self toCell];
        [self.bottomView.scalingBtn setImage:[UIImage imageNamed:@"缩小"] forState:UIControlStateNormal];
    }
    self.isFullScreen = !self.isFullScreen;
    
}
// 缩小到cell
-(void)toCell{
    // 先移除
    [self removeFromSuperview];
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5f animations:^{
        weakSelf.transform = CGAffineTransformIdentity;
        weakSelf.frame = CGRectMake(0, 80, kScreenWidth, kScreenHeight / 2.5);
        weakSelf.playerLayer.frame =  weakSelf.bounds;
        // 再添加到View上
        // [weakSelf addSubview:weakSelf.playerView];
        // remark约束
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf).with.offset(0);
            make.right.equalTo(weakSelf).with.offset(0);
            make.height.mas_equalTo(50);
            make.bottom.equalTo(weakSelf).with.offset(0);
        }];
        [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf).with.offset(0);
            make.right.equalTo(weakSelf).with.offset(0);
            make.height.mas_equalTo(50);
            make.top.equalTo(weakSelf).with.offset(0);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf).with.offset(5);
            make.centerY.equalTo(weakSelf.topView);
            make.size.mas_equalTo(CGSizeMake(30, 30));
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
                [self initTimer];
                //                // 启动定时器 5秒自动隐藏
                if (!self.autoDismissTimer)
                {
                    self.autoDismissTimer = [NSTimer timerWithTimeInterval:8.0 target:self selector:@selector(autoDismissView:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
                }
                
                [self.player play];
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
// 全屏显示
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    // 先移除之前的
    [self removeFromSuperview];
   
    // 初始化
    self.transform = CGAffineTransformIdentity;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    // BackView的frame能全屏
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    // layer的方向宽和高对调
    self.playerLayer.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
    [self.layer addSublayer:self.playerLayer];
    // remark 约束
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(kScreenWidth-50);
        make.left.equalTo(self).with.offset(0);
        make.width.mas_equalTo(kScreenHeight);
    }];
    
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.left.equalTo(self).with.offset(0);
        make.width.mas_equalTo(kScreenHeight);
    }];
    
    [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(5);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
        make.top.equalTo(self).with.offset(10);
        
    }];
    //
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(45);
        make.right.equalTo(self.topView).with.offset(-45);
        make.center.equalTo(self.topView);
        make.top.equalTo(self.topView).with.offset(0);
    }];
    
    [self.bottomView.nowLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView.slider.mas_left).with.offset(0);
        make.top.equalTo(self.bottomView.slider.mas_bottom).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
    [self.bottomView.remainLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView.slider.mas_right).with.offset(0);
        make.top.equalTo(self.bottomView.slider.mas_bottom).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    // 加到window上面
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
#pragma ZJControlViewDelegate
- (void)clickFullScreen{
    [self clickFullScreen:nil];
}
- (void)play{
    if (self.player.rate != 1.0f)
    {
        [self.bottomView.playBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        
        [self.player play];
    }
    else
    {
        [self.bottomView.playBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
        [self.player pause];
    }
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
        [self.bottomView.playBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        [self.player play];
    }
}
@end
