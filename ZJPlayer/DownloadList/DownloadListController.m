//
//  DownloadListController.m
//  ZJPlayer
//
//  Created by zhengju on 2017/9/23.
//  Copyright © 2017年 郑俱. All rights reserved.
//

#import "DownloadListController.h"
#import "PlayerVideoController.h"
#import "DownloadListCell.h"
#import "ZJDownloadManager.h"
#import "DownloadList.h"
#import "ZJCustomTools.h"
@interface DownloadListController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic) UITableView * tableView;
@property(strong,nonatomic) ZJDownloadManager * downloadManager;
@property(strong,nonatomic) NSMutableArray * datas;
@end

@implementation DownloadListController
- (NSMutableArray *)datas{
    if (_datas == nil) {
        
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    return _datas;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载";
    self.backBtn.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.downloadManager = [ZJDownloadManager sharedInstance];
    [self configDatas];
    [self configureTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]bk_initWithTitle:@"clean" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [self.downloadManager deleteAllFile];
        [self.tableView reloadData];
    }];
    
    
}
- (void)configDatas{
    
    NSArray * titles = @[
                         @"许家印讲话",
                         @"许家印讲话",
                         @"许家印讲话",
                         @"许家印讲话",
                         @"许家印讲话",
                         @"许家印讲话",
                         @"许家印讲话"
                         ];
    
    NSArray * urls = @[
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4",
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4",
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4",
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4",
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4",
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4",
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4"
                       ];
    
    for (int i = 0; i < urls.count; i++) {
        DownloadList * list = [[DownloadList alloc]init];
        list.name = titles[i];
        list.urlString = urls[i];
        list.progress = [self.downloadManager progress:urls[i]];
        list.ratio = [NSString stringWithFormat:@"%.1fM/%.1fM",[self.downloadManager downloadLength:urls[i]],[self.downloadManager totalLength:urls[i]]];
        [self.datas addObject:list];
    }
}

- (void)configureTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,kScreenWidth , kScreenHeight - 49 - 64) style:UITableViewStylePlain];
    [self.tableView registerNib:[UINib nibWithNibName:@"DownloadListCell" bundle:nil] forCellReuseIdentifier:@"DownloadListCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
}
#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DownloadListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadListCell" forIndexPath:indexPath];
    cell.model = self.datas[indexPath.row];
    cell.suspendBlock = ^(BOOL isSuspend){
        DownloadList * model = self.datas[indexPath.row];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self.downloadManager downloadDataWithURL:model.urlString resume:YES progress:^(CGFloat progress) {
            NSLog(@"controller:%ld->%f",(long)indexPath.row,progress);
            model.progress = progress;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
            
        } state:^(ZJDownloadState state) {
            NSLog(@"controller:%u",state);
        }];
            
        });
                       
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

        DownloadList *  model = self.datas[indexPath.row];
    
    if (![self.downloadManager isCompletion:model.urlString]) {
        HUDNormal(@"该资源还未完成，请下载后观看");
        return;
    }

    PlayerVideoController * controller = [[PlayerVideoController alloc]init];
    controller.path = [self.downloadManager path:model.urlString];
    
    [self.navigationController pushViewController:controller animated:YES];
    //[self.navigationController presentViewController:controller animated:YES completion:nil];
    
    
}
@end

