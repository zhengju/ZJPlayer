//
//  VideoListController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/13.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "VideoListController.h"
#import "ZJCommonHeader.h"
#import "VideoListCell.h"
#import "VideoList.h"
@interface VideoListController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic) UITableView * tableView;
@property(strong,nonatomic) NSMutableArray * datas;
@property(strong,nonatomic) ZJPlayer * player;
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

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureTableView];
    
    [self configDatas];
    
    [self.tableView reloadData];
    
    self.player = [ZJPlayer sharePlayer];
    self.player.isPlayContinuously = YES;
    //添加自动播放的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(continuousVideoPlayback) name:ZJContinuousVideoPlayback object:self.player];
}
- (void)continuousVideoPlayback{

    if (self.player.indexPath.row < self.datas.count - 1 ) {

        self.player.indexPath = [NSIndexPath indexPathForRow:self.player.indexPath.row + 1 inSection:self.player.indexPath.section];
        
        [self.tableView scrollToRowAtIndexPath:self.player.indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        VideoListCell * cell =  [self.tableView cellForRowAtIndexPath:self.player.indexPath];
        
        [cell initPlayer];
    }
}

- (void)configDatas{
    
    NSArray * titles = @[
                         @"为什么和我看的爱情公寓一点儿都不一样……",
                         @"人狗大战来了啊，目测主人已被逼疯…",
                         @"《选择》琼瑶女郎陈德容翩然而至，患失忆症情感何去何从！",
                         @"动作片里都是骗人的，一个视频告诉你真实的啪啪啪是什么样子的",
                         @"他用亲身经历告诉你——原来“老婆能吃才是福”！",
                         @"涂磊告诉女人不要太省！否则会失去魅力又亏待自己！要爱自己！"
                         ];

    NSArray * urls = @[
                       @"http://mvideo.spriteapp.cn/video/2017/0912/84cd46ac-97d0-11e7-89c6-1866daeb0df1_wpcco.mp4",
                       @"http://mvideo.spriteapp.cn/video/2017/0912/59b77f1327619_wpcco.mp4",
                       @"http://mvideo.spriteapp.cn/video/2017/0911/59b5675ca92ee_wpcco.mp4",
                       @"http://mvideo.spriteapp.cn/video/2017/0907/b3143e38-93d6-11e7-a4ca-1866daeb0df1_wpcco.mp4",
                       @"http://mvideo.spriteapp.cn/video/2017/0526/812bd8ee41bb11e7b007842b2b4c75ab_wpcco.mp4",
                       @"http://mvideo.spriteapp.cn/video/2017/0912/59b7d62d323e2_wpcco.mp4"
                       ];
    
    for (int i = 0; i < urls.count; i++) {
        VideoList * list = [[VideoList alloc]init];
        list.title = titles[i];
        list.url = urls[i];
        [self.datas addObject:list];
    }
}

- (void)configureTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight ) style:UITableViewStylePlain];

    [self.tableView registerClass:[VideoListCell class] forCellReuseIdentifier:@"VideoListCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray * cells = [self.tableView visibleCells];
    
    
    if (cells.count == 3) {
        
        VideoListCell * cell = cells[1];
        if (cell.indexPath != self.player.indexPath) {//
            self.player.indexPath = cell.indexPath;
            [cell initPlayer];
        }
    }else if (cells.count == 2) {
        VideoListCell * cell = cells[0];
        if (cell.indexPath.row == 0 && cell.indexPath != self.player.indexPath) {
            self.player.indexPath = cell.indexPath;
            [cell initPlayer];
        }
    }
    
    //NSLog(@"tabelView在滚... %@",cells);
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
    
    cell.indexPath = indexPath;
    
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
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
@end
