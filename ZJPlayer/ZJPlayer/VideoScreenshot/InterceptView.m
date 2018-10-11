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
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZJInterceptTopView.h"
#define kLeftWidth   50 //scrollview的左边距
#define kCoverImageScrollTag 10
#define kClipTimeScrollTag  20
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kColorWithRGBA(_R,_G,_B,_A)    ((UIColor *)[UIColor colorWithRed:_R/255.0 green:_G/255.0 blue:_B/255.0 alpha:_A])
//#define kScreenWidth   200
#define ZJHeight 150
@interface InterceptView()<UIScrollViewDelegate,ZJInterceptTopViewDelegate>

@property (nonatomic, strong) UIImage *cover;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) ZJInterceptTopView * topView;
@property (nonatomic, strong) UIImageView *BGView;
@property (nonatomic, strong) UIScrollView *scrollView;         //视频封面的滚动
@property (nonatomic, strong) UIImageView *coverImgView;        //封面imgview
@property (nonatomic, strong) UIImageView *leftSliderImgView;   //左滑块
@property (nonatomic, strong) UIImageView *rightSliderImgView;  //右滑块
@property (nonatomic, strong) UIImageView *leftOpacityImgView;  //左边黑色遮罩
@property (nonatomic, strong) UIImageView *rightOpacityImgView; //右边黑色遮罩
@property (nonatomic, strong) UIImageView *upOpacityImgView;    //上边白色
@property (nonatomic, strong) UIImageView *downOpacityImgView;  //下班白色
@property (nonatomic, strong) UILabel *selDurationLabel;        //显示时间label
@property (nonatomic, strong) UIButton *playBtn;                //播放按钮
@property (nonatomic, strong) NSArray *coverImgs;               //封面图片

@property (nonatomic, strong) UIView *rangeView;   //裁剪范围的rang
@property (nonatomic, assign) CGFloat imgWidth;   //指示器图片宽
@property (nonatomic, assign) CGFloat minWidth;   //两个指示器间隔距离最短
@property (nonatomic, assign) CGFloat maxWidth;   //两个指示器间隔距离最长
@property (nonatomic, assign) CGFloat timeScale;  //每个像素占多少秒

@property (nonatomic, assign) unsigned long videoDuration;  //截取的时间长度
@property (nonatomic, assign) CGFloat startTime;            //开始截取的时间
@property (nonatomic, assign) CGFloat endTime;              //结束截取的时间
@property (nonatomic, assign) CGFloat tempStartTime;    //滚动的偏移量的开始时间
@property (nonatomic, assign) CGFloat tempEndTime;      //滚动的偏移量的结束时间
@property (nonatomic, assign) CGFloat contentOffsetX;

@property (nonatomic, assign) CGPoint clipPoint;        //开始截取的点
@property (nonatomic, assign) float m_ftp;              //视频的ftp
@property (nonatomic, strong) NSTimer *m_timer;         //
@property (nonatomic, strong) UIView *m_tapView; //拖动层
@property (nonatomic, strong) UIView *guideBg;       //新手引导界面
@property (nonatomic, strong) UIView *pullGuideBg;  //拖动提示
@property (nonatomic, strong) UIScrollView *clipView;   //视频截取的滚动

@property (nonatomic, strong) AVPlayer     *player;
@end

@implementation InterceptView
- (void)setCurrentTtime:(CMTime)currentTtime{
    _currentTtime = currentTtime;
    UIImage * bgImage = [self getVideoPreViewImageFromVideoPath:self.videoUrl withAtTime:CMTimeGetSeconds(_currentTtime)+0.01];

    self.BGView.image = bgImage;
    
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(_currentTtime), self.m_ftp);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self.player pause];
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
//    AVAsset *asset = [AVAsset assetWithURL:self.videoUrl];
    AVAsset *asset = self.playerItem.asset;
    self.m_ftp = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
    CMTimeShow(self.currentTtime);
    CMTimeShow(asset.duration);
    self.startTime = 0.0f + CMTimeGetSeconds(self.currentTtime);//
    self.endTime = self.startTime + 10.0f;
    self.imgWidth = [UIImage imageNamed:@"resume_btn_control_r"].size.width;
    CGFloat totalWidth = kScreenWidth - 2*kLeftWidth;
    self.timeScale = 10.0f/totalWidth;
    self.minWidth = 0.6*totalWidth - self.imgWidth;
    if (self.videoDuration >=10.0) {
        self.maxWidth = totalWidth - self.imgWidth;
    }
    else{
        self.maxWidth = totalWidth * self.videoDuration/10.0 - self.imgWidth;
    }
    [self createUI];
    
    [self.player pause];
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
    [self.player pause];
}
//截帧逻辑可以优化，比较多时可以放在子线程中去完成
- (void)getCoverImgs {
    NSMutableArray *imageArrays = [NSMutableArray array];
    self.videoDuration = [self durationWithVideo:self.videoUrl.absoluteString];
    self.videoDuration = 20;
    
    
    float second = CMTimeGetSeconds(self.currentTtime);
    
    //要判断seconds是否会超出总的时间区间

    //大于11s
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    if (self.videoDuration>11.0) {
        //每隔1s截取一张图片
        for (int i = 0; i <  self.videoDuration-1; i++) {
            UIImage *image = [self getVideoPreViewImageFromVideoPath:self.videoUrl withAtTime: second + i +0.01];
            if (image) {
                [imageArrays addObject:image];
            }
        }
    }
    else{
        //截取11张
        for (int i = 0; i < 11; i++) {
            UIImage *image = [self getVideoPreViewImageFromVideoPath:self.videoUrl withAtTime:self.videoDuration*i/12.0+0.01];
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
    
    
    UIImage * bgImage =  [self getVideoPreViewImageFromVideoPath:self.videoUrl withAtTime:5+0.01];
    
    self.BGView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.BGView.backgroundColor = [UIColor redColor];
    self.BGView.image = bgImage;
    [self addSubview:self.BGView];
    
    //头部确定和取消按钮
    self.topView = [[ZJInterceptTopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 72)];
    self.topView.delegate = self;
    [self addSubview:self.topView];
    
//    UILabel *titleLabel = [[UILabel alloc] init];
//    [titleLabel setText:NSLocalizedString(@"裁剪", nil)];
//    [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
//    [titleLabel sizeToFit];
//    [titleLabel setTextColor:[UIColor whiteColor]];
//    [topView addSubview:titleLabel];
//
//    //取消
//    UIButton *cancelButton = [[UIButton alloc]init];
//    [cancelButton setImage:[UIImage imageNamed:@"resume_icon_return"] forState:UIControlStateNormal];
//    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:cancelButton];
//
//    //确定
//    UIButton *confirmButton = [[UIButton alloc]init];
//    [confirmButton setImage:[UIImage imageNamed:@"resume_btn_complete"] forState:UIControlStateNormal];
//    [confirmButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:confirmButton];
//
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
    CGFloat imgRate = image.size.height / image.size.width;
    CGFloat originRate = ZJHeight /kScreenWidth;
    CGFloat min = MIN(imgRate, originRate);
    
    if (min == imgRate) {

        imgW = kScreenWidth;
        imgH = imgW * imgRate;//H不会超过originH

    }else{
        imgH = ZJHeight;
        imgW = imgH / imgRate;
    }

    self.coverImgView = [[UIImageView alloc] initWithImage:image];
    self.coverImgView.userInteractionEnabled = YES;
    [clipView addSubview:self.coverImgView];
    self.coverImgView.frame = CGRectMake((kScreenWidth - imgW)/2.0, (ZJHeight-imgH)/2.0, imgW, imgH);
    clipView.contentSize = CGSizeMake(imgW, imgH);
    
    self.playBtn = [[UIButton alloc] init];
    UIImage *playImg = [UIImage imageNamed:@"resume_icon_play"];
    [self.playBtn setImage:playImg forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playBtn];
    
    //下面的小图
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kLeftWidth, kScreenHeight - 50 - 20, kScreenWidth-2*kLeftWidth, 50)];
    [self.scrollView setTag:kClipTimeScrollTag];
    self.scrollView.delegate = self;
    [self.scrollView setAlwaysBounceHorizontal:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self addSubview:self.scrollView];
    self.scrollView.backgroundColor = [UIColor clearColor];
    //图片宽
    float imgWidth = self.maxWidth/10.0;
    for (int i = 0; i< self.coverImgs.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self.coverImgs objectAtIndex:i]];
        [imageView setFrame:CGRectMake(i*imgWidth, 0, imgWidth, 50)];
        [self.scrollView addSubview:imageView];
    }
    [self.scrollView setContentSize:CGSizeMake(imgWidth*self.coverImgs.count, 50)];
    
    //滑块
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    UIImage *leftSliderImg = [UIImage imageNamed:@"resume_btn_control_l"];
    UIImage *rightSliderImg = [UIImage imageNamed:@"resume_btn_control_r"];
    
    self.leftSliderImgView = [[UIImageView alloc] initWithImage:leftSliderImg];
    self.leftSliderImgView.userInteractionEnabled = YES;
    self.leftSliderImgView.frame = CGRectMake(kLeftWidth, self.scrollView.frame.origin.y, leftSliderImg.size.width, leftSliderImg.size.height);
    [self.leftSliderImgView addGestureRecognizer:leftPan];
    [self addSubview:self.leftSliderImgView];
    
    self.rightSliderImgView = [[UIImageView alloc] initWithImage:rightSliderImg];
    self.rightSliderImgView.userInteractionEnabled = YES;
    //最大的长度裁剪
    self.rightSliderImgView.frame = CGRectMake(self.leftSliderImgView.frameX + _maxWidth, self.scrollView.frameY, rightSliderImg.size.width, rightSliderImg.size.height);
    
    [self.rightSliderImgView addGestureRecognizer:rightPan];
    [self addSubview:self.rightSliderImgView];
    
    //透明度
    self.leftOpacityImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftWidth, self.scrollView.frame.origin.y, 0, leftSliderImg.size.height)];
    [self addSubview:self.leftOpacityImgView];
    self.leftOpacityImgView.backgroundColor = kColorWithRGBA(0, 0, 0, 0.6);
    
    self.rightOpacityImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftSliderImgView.frame.origin.x + _maxWidth+self.imgWidth, self.scrollView.frame.origin.y, kScreenWidth - self.rightSliderImgView.frameX-self.imgWidth - kLeftWidth, self.scrollView.frame.size.height)];
    [self addSubview:self.rightOpacityImgView];
    self.rightOpacityImgView.backgroundColor = kColorWithRGBA(0, 0, 0, 0.6);
    
    //指示器范围
    self.rangeView = [[UIView alloc] initWithFrame:CGRectMake(kLeftWidth, self.scrollView.frame.origin.y, kScreenWidth - 2*kLeftWidth, self.scrollView.frameH)];
    [self.rangeView.layer setMasksToBounds:YES];
    [self.rangeView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.rangeView.layer setBorderWidth:1.0f];
    [self addSubview:self.rangeView];
    [self.rangeView setHidden:YES];
    
    //上边的白色横条
    self.upOpacityImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftSliderImgView.frameX, self.scrollView.frameY, self.rightSliderImgView.frameX-self.leftSliderImgView.frameX+self.leftSliderImgView.frameW, 2.0)];
    [self.upOpacityImgView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.upOpacityImgView];
    
    self.downOpacityImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftSliderImgView.frameX, self.scrollView.frameY+48, self.rightSliderImgView.frameX-self.leftSliderImgView.frameX+self.leftSliderImgView.frameW, 2.0)];
    [self.downOpacityImgView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.downOpacityImgView];
    
    //选中片段时长
    self.selDurationLabel = [[UILabel alloc] init];
    self.selDurationLabel.textColor = [UIColor whiteColor];
    self.selDurationLabel.font = [UIFont systemFontOfSize:12];
    if (self.videoDuration >= 10.) {
        self.selDurationLabel.text = @"10.0s";
    }else if (self.videoDuration > 6.) {
        self.selDurationLabel.text = [NSString stringWithFormat:@"%.lds", self.videoDuration];
    }else {
        self.selDurationLabel.text = @"6.0s";
    }
    [self.selDurationLabel sizeToFit];
    [self addSubview:self.selDurationLabel];
    
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
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(playImg.size.width));
        make.height.equalTo(@(playImg.size.height));
        make.centerX.equalTo(self);
        make.top.equalTo(self).with.offset(72+ZJHeight/2-playImg.size.height/2);
    }];
    
    [self.selDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-14);
        make.top.equalTo(self.scrollView.mas_bottom).with.offset(8);
    }];
    
//    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self).with.offset(35);
//        make.left.equalTo(self).with.offset(8);
//    }];
//
//    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(cancelButton);
//        make.right.equalTo(self).with.offset(-14);
//    }];
//
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self);
//        make.centerY.equalTo(cancelButton);
//    }];
}



- (void)playVideo {
    self.playBtn.hidden = YES;
    if (!self.m_timer) {
        self.m_timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(stopPlay) userInfo:nil repeats:YES];
    }
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        [self.player play];
    }
}

-(void)tapVideo{
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        [self.player play];
    }
    else if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
        [self.player pause];
    }
}

- (void)stopPlay {
    if (CMTimeCompare(self.player.currentTime, CMTimeMakeWithSeconds(self.endTime, self.m_ftp)) >= 0) {
        [self.player pause];
        CMTime time = CMTimeMakeWithSeconds(self.startTime, self.m_ftp);
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
            }
        }];
        if (self.m_timer) {
            [self.m_timer invalidate];
            self.m_timer = nil;
        }
    }
}

#pragma mark -
#pragma mark - Handele Gesture
- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.rangeView setHidden:NO];
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat sliderW = self.leftSliderImgView.frame.size.width;
        CGFloat sliderH = self.leftSliderImgView.frame.size.height;
        CGFloat sliderY = self.leftSliderImgView.frame.origin.y;
        
        CGPoint translation = [gesture translationInView:gesture.view];
        CGFloat rightX = self.rightSliderImgView.frame.origin.x;
        CGFloat leftX = self.leftSliderImgView.frame.origin.x + translation.x;
        
        if (leftX <= kLeftWidth) {
            leftX = kLeftWidth;
        }
        if (leftX <= rightX - _maxWidth) {
            leftX = rightX - _maxWidth;
        }
        else if (leftX >= rightX - _minWidth) {
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
        self.leftSliderImgView.frame = CGRectMake(leftX, sliderY, sliderW, sliderH);
        self.leftOpacityImgView.frame = CGRectMake(kLeftWidth, sliderY, leftX-self.leftSliderImgView.frameW/2.0, self.scrollView.frame.size.height);
        
        self.upOpacityImgView.frame = CGRectMake(self.leftSliderImgView.frameX, self.scrollView.frameY, self.rightSliderImgView.frameX-self.leftSliderImgView.frameX+self.leftSliderImgView.frameW, 2.0);
        self.downOpacityImgView.frame = CGRectMake(self.leftSliderImgView.frameX, self.scrollView.frameY+48, self.rightSliderImgView.frameX-self.leftSliderImgView.frameX+self.leftSliderImgView.frameW, 2.0);
        
        [gesture setTranslation:CGPointZero inView:gesture.view];
        CMTime time = CMTimeMakeWithSeconds(self.startTime, self.m_ftp);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                    if (finished) {
                        [self.player pause];
                        self.playBtn.hidden = NO;
                    }
                }];
            });
            
        });
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.rangeView setHidden:YES];
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.rangeView setHidden:NO];
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat sliderY = self.rightSliderImgView.frame.origin.y;
        CGFloat sliderW = self.rightSliderImgView.frame.size.width;
        CGFloat sliderH = self.rightSliderImgView.frame.size.height;
        
        CGPoint translation = [gesture locationInView:gesture.view];
        CGFloat leftX = self.leftSliderImgView.frame.origin.x;
        CGFloat rightX = self.rightSliderImgView.frame.origin.x + translation.x;
        
        if (rightX >= kScreenWidth - kLeftWidth - self.imgWidth) {
            rightX = kScreenWidth - kLeftWidth - self.imgWidth;
        }
        
        if (rightX <= leftX + _minWidth) {
            rightX = leftX + _minWidth;
        }
        if (rightX >= leftX + _maxWidth) {
            rightX = leftX + _maxWidth;
        }
        
        CGFloat width = rightX - leftX + self.imgWidth;
        CGFloat selDuration = width * self.timeScale;
        self.endTime = self.startTime + selDuration;
        self.selDurationLabel.text = [NSString stringWithFormat:@"%.1fs", selDuration];
        
        self.rightSliderImgView.frame = CGRectMake(rightX, sliderY, sliderW, sliderH);
        self.rightOpacityImgView.frame = CGRectMake(rightX+self.leftSliderImgView.frameW, sliderY, kScreenWidth - rightX-self.leftSliderImgView.frameW -kLeftWidth, self.scrollView.frame.size.height);
        
        self.upOpacityImgView.frame = CGRectMake(self.leftSliderImgView.frameX, self.scrollView.frameY, self.rightSliderImgView.frameX-self.leftSliderImgView.frameX+self.leftSliderImgView.frameW, 2.0);
        self.downOpacityImgView.frame = CGRectMake(self.leftSliderImgView.frameX, self.scrollView.frameY+48, self.rightSliderImgView.frameX-self.leftSliderImgView.frameX+self.leftSliderImgView.frameW, 2.0);
        
        [gesture setTranslation:CGPointZero inView:gesture.view];
        CMTime time = CMTimeMakeWithSeconds(self.endTime, self.m_ftp);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                    if (finished) {
                        [self.player pause];
                        self.playBtn.hidden = NO;
                    }
                }];
            });
        });
    }
    else if (gesture.state == UIGestureRecognizerStateEnded){
        [self.rangeView setHidden:YES];
        CMTime startTime = CMTimeMakeWithSeconds(self.startTime, self.m_ftp);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                    if (finished) {
                        [self.player pause];
                        self.playBtn.hidden = NO;
                    }
                }];
            });
        });
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

#pragma mark -
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == kCoverImageScrollTag) {
        self.clipPoint = CGPointMake(scrollView.contentOffset.x*720.0/kScreenWidth, scrollView.contentOffset.y*720.0/kScreenWidth);
    }
    else if (scrollView.tag == kClipTimeScrollTag){
        if (scrollView.contentOffset.x>=0) {
            CGFloat addTime = scrollView.contentOffset.x*self.timeScale;
            self.tempStartTime = self.startTime + addTime - self.contentOffsetX*self.timeScale;
            self.tempEndTime = self.endTime + addTime - self.contentOffsetX*self.timeScale;
            CMTime time = CMTimeMakeWithSeconds(self.tempStartTime, self.m_ftp);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                        if (finished) {
                            [self.player pause];
                            self.playBtn.hidden = NO;
                        }
                    }];
                });
                
            });
        }
    }
    NSLog(@"offset:%@", NSStringFromCGPoint(scrollView.contentOffset));
    NSLog(@"%f",self.startTime);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == kClipTimeScrollTag){
        self.contentOffsetX = scrollView.contentOffset.x;
        self.startTime = self.tempStartTime;
        self.endTime = self.tempEndTime;
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.tag == kClipTimeScrollTag){
        self.contentOffsetX = scrollView.contentOffset.x;
        self.startTime = self.tempStartTime;
        self.endTime = self.tempEndTime;
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.tag == kClipTimeScrollTag){
        self.contentOffsetX = scrollView.contentOffset.x;
        self.startTime = self.tempStartTime;
        self.endTime = self.tempEndTime;
    }
}
///获取本地视频的时长
- (NSUInteger)durationWithVideo:(NSString *)videoPath {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:opts];     //初始化视频媒体文件
    NSUInteger second = 0;
    second = ceilf((double)urlAsset.duration.value / (double)urlAsset.duration.timescale); // 获取视频总时长,单位秒
    return second;
}

//截图
- (UIImage*)getVideoPreViewImageFromVideoPath:(NSURL *)videoPath withAtTime:(float)atTime {
    
   // AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
    AVURLAsset *asset = (AVURLAsset *)self.playerItem.asset;
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
        return nil;
    }

    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    gen.appliesPreferredTrackTransform = YES;
    
    //防止时间出现偏差 当你指定要获取time时刻的帧，如果不设置这两个属性，系统会默认如果在指定time段内有缓存，就从缓存中直接返回结果，但并不准确，这是为了优化性能
//    gen.requestedTimeToleranceAfter = kCMTimeZero;
//    gen.requestedTimeToleranceBefore = kCMTimeZero;
    
    CMTime time = CMTimeMakeWithSeconds(atTime, 600);//atTime  第几秒的截图,是当前视频播放到的帧数的具体时间; 600 首选的时间尺度 "每秒的帧数"
    
    NSError *error = nil;
    CMTime actualTime;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];//线上视频比较耗时(新创建的AVURLAsset比较耗时)，用上一个AVURLAsset,或等player缓冲可以看了的时候，再截屏耗时短
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"一张图片耗时：====--%f", end - start);
    
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    UIGraphicsBeginImageContext(CGSizeMake([[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width, [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height));//asset.naturalSize.width, asset.naturalSize.height)
    [img drawInRect:CGRectMake(0, 0, [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width, [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(image);
   
    return scaledImage;
}
#pragma mark - ZJInterceptTopViewDelegate
- (void)back{
    [self.player pause];
    self.player  = nil;
    [self removeFromSuperview];
}
- (void)finishWithAction:(float)action{
    
    if (action == 0) {//截视频
        [self videoCapture];
    }else{//截GIF
        [self gifScreenshot];
    }
}
- (void)setAction:(float)action{
    if (action == 0) {//截视频
        NSLog(@"视频");
    }else{//截GIF
        NSLog(@"GIF");
    }
}

- (void)videoCapture{
    NSString * url1 = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZJCache.mov"];
    NSRange range = NSMakeRange(self.startTime, self.endTime - self.startTime);
    CFAbsoluteTime start= CFAbsoluteTimeGetCurrent();
    [[ZJCustomTools shareCustomTools]interceptVideoAndVideoUrl:self.videoUrl withOutPath:url1 outputFileType:AVFileTypeQuickTimeMovie range:range intercept:^(NSError *error, NSURL *url) {
        if (error) {
            NSLog(@"error:%@",error);
            return ;
        }
        CFAbsoluteTime end= CFAbsoluteTimeGetCurrent();
        NSLog(@"%f", end- start);
        NSLog(@"----++%@",url);//本地视频记得删除
        
        NSString * urlpath = url.absoluteString;
        if ([url.absoluteString hasPrefix:@"file://"]) {
            urlpath = [url.absoluteString substringFromIndex:7];
        }

        BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlpath);
        if(compatible)
        {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum(urlpath,self,@selector(savedVideoPhotoImage:didFinishSavingWithError:contextInfo:),nil);
        }else{
            HUDNormal(@"路径失败");
        }
    }];
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
            //保存到相册
            NSData *data = [NSData dataWithContentsOfURL:GifURL];
             
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL,
                                                                                          NSError *error) {
                HUDNormal(@"保存成功");
                NSLog(@"Success at %@", [assetURL path] );
                
            }] ;
            
        }];
    }];
}
- (void)savedVideoPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError*)error contextInfo: (void*)contextInfo {
    if(error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }else{
        HUDNormal(@"保存视频成功");
    }
}

@end

