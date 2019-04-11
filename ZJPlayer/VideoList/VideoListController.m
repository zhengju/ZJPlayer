//
//  VideoListController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/13.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "VideoListController.h"
#import "VideoController.h"

#import "ZJCommonHeader.h"
#import "VideoListCell.h"
#import "VideoList.h"

#import "YYFPSLabel.h"


@interface VideoListController ()<UITableViewDelegate,UITableViewDataSource,ZJPlayerDelegate>
@property(strong,nonatomic) UITableView * tableView;
@property(strong,nonatomic) NSMutableArray * datas;
@property(strong,nonatomic) ZJVideoPlayerView * player;
@end

@implementation VideoListController
- (NSMutableArray *)datas{
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    return _datas;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.backBtn.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    
    [self configureTableView];
    
    [self configDatas];
    
    [self.tableView reloadData];
    
    self.player = [ZJVideoPlayerView sharePlayer];
    
    self.player.isPlayContinuously = YES;
    
    //添加自动播放的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(continuousVideoPlayback) name:ZJContinuousVideoPlayback object:self.player];
}
- (void)continuousVideoPlayback{

    if (self.player.indexPath.row < self.datas.count - 1 ) {

        self.player.indexPath = [NSIndexPath indexPathForRow:self.player.indexPath.row + 1 inSection:self.player.indexPath.section];
        
        [self.tableView scrollToRowAtIndexPath:self.player.indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        VideoListCell * cell =  [self.tableView cellForRowAtIndexPath:self.player.indexPath];
        
        [self initPlayer:self.player.indexPath cell:cell];
    }
}
- (void)configDatas{
    
    NSArray * titles = @[
                         @"共享新时代 共赢新发展",
                         @"兴隆。国际城",
                         @"苹果",
                         @"共享新时代 共赢新发展",
                         @"1",
                         @"2",
                         @"3",
                         @"4",
                         @"搞笑视频来啦",
                         ];

    NSArray * urls = @[
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4",
                       @"http://img.house.china.com.cn/voice/rongch.mp4",
                       @"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4",
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4",
                       @"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4",
                       @"https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4",
                       @"http://tb-video.bdstatic.com/tieba-smallvideo/5_6d3243c354755b781f6cc80f60756ee5.mp4",
                       @"http://tb-video.bdstatic.com/tieba-smallvideo/12_cc75b3fb04b8a23546d62e3f56619e85.mp4",
                       
                       @"https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4"
                       
                       ];
    
    for (int i = 0; i < urls.count; i++) {
        VideoList * list = [[VideoList alloc]init];
        list.title = titles[i];
        list.url = urls[i];
        [self.datas addObject:list];
    }
}

#pragma 加载视频player
- (void)initPlayer:(NSIndexPath *)indexPath cell:(VideoListCell*)cell{

    [self.player removeFromSuperview];

    self.player.indexPath = indexPath;
    
    self.player.isPushOrPopPlpay = NO;
    
    [self.player configurePLayerWithUrl:[NSURL URLWithString:cell.model.url]];

    self.player.delegate = self;

    self.player.fatherView  = cell;

    self.player.placeholderImage = cell.model.image;
    
    [self.player setPlayerFrame:cell.playerView.frame];
    
    self.player.title = cell.model.title;
    
    [self.player play];
    
}
- (void)configureTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 49) style:UITableViewStylePlain];

    [self.tableView registerClass:[VideoListCell class] forCellReuseIdentifier:@"VideoListCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    
  YYFPSLabel*  _fpsLabel = [YYFPSLabel new];
    _fpsLabel.frame = CGRectMake(200, 200, 50, 30);
    [_fpsLabel sizeToFit];
    [self.view addSubview:_fpsLabel];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    //判断当前的cell是否在显示
    if (![self.tableView.visibleCells containsObject:(UITableViewCell *)self.player.fatherView]) {
         [self.player pause];
    }else{

    }
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.datas count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    VideoListCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    if (cell == nil) {
        cell = [[VideoListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VideoListCell"];
    }

    cell.model = self.datas[indexPath.row];
    WeakObj(cell);
    WeakObj(self);
    cell.indexPath = indexPath;
    cell.playBlock = ^(){
        
        [selfWeak initPlayer:indexPath cell:cellWeak];
        
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return  cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kScreenHeight / 2.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    VideoList *   model = self.datas[indexPath.row];
    self.player.indexPath = indexPath;
    
    VideoController * controller = [[VideoController alloc]init];
    
    controller.model = model;
    
    [self.navigationController pushViewController:controller animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

#pragma ZJPlayerDelegate
- (void)playFinishedPlayer:(ZJVideoPlayerView *)player{
    NSLog(@"播放完毕");
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    VideoListCell * cell = (VideoListCell *)[self.tableView cellForRowAtIndexPath:self.player.indexPath];
    if (cell) {
        self.player.fatherView = cell;
         [self.player setPlayerFrame:cell.playerView.frame];
    }
    self.player.delegate = self;
}


@end
