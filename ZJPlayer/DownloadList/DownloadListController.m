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
#import "ZJDownloaderItem.h"

@interface DownloadListController ()<UITableViewDelegate,UITableViewDataSource,ZJDownloadManagerDelegate>
@property(strong,nonatomic) UITableView * tableView;
@property(strong,nonatomic) ZJDownloadManager * downloadManager;
@property(strong,nonatomic) NSMutableArray * datas;
@property(nonatomic, strong) NSMutableDictionary * downLists;
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
//    self.title = @"下载";
    self.backBtn.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.downloadManager = [ZJDownloadManager sharedInstance];
    self.downloadManager.delegate = self;
    [self configDatas];
    [self configureTableView];
    
    self.downLists = [NSMutableDictionary dictionaryWithCapacity:0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]bk_initWithTitle:@"clean" style:UIBarButtonItemStylePlain handler:^(id sender) {
        
        [self.downloadManager deleteAllFile];
        
        for (int i = 0; i<self.datas.count; i++) {
            DownloadList * list = self.datas[i];
            list.progress = [self.downloadManager progress:list.urlString];
            list.ratio = [NSString stringWithFormat:@"%.1fM/%.1fM",[self.downloadManager downloadLength:list.urlString],[self.downloadManager totalLength:list.urlString]];
        }

        [self.tableView reloadData];
    }];
    
}
- (void)configDatas{
    
    NSArray * titles = @[
                         @"许家印讲话",
                         @"融创中国宣传片"
                         ];
    
    NSArray * urls = @[
                       @"http://img.house.china.com.cn/voice/hdzxjh.mp4",
                       @"http://img.house.china.com.cn/voice/rongch.mp4"
                       ];
    
    for (int i = 0; i < urls.count; i++) {
        DownloadList * list = [[DownloadList alloc]init];
        list.name = titles[i];
        list.urlString = urls[i];
        list.progress = [self.downloadManager progress:urls[i]];
        list.ratio = [NSString stringWithFormat:@"%.1fM/%.1fM",[self.downloadManager downloadLength:urls[i]],[self.downloadManager totalLength:urls[i]]];
        
        ZJDownloaderItem * item = [[ZJDownloaderItem alloc]init];
        item.downloadUrl = list.urlString;
        
        list.downloaderItem = item;
        
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
    cell.model.indexPath = indexPath;
    cell.suspendBlock = ^(BOOL isSuspend){
        
        DownloadList * model = self.datas[indexPath.row];
        
        [self.downLists setObject:model forKey:model.downloaderItem.downloadUrl];

        [self.downloadManager downloadWithItem:model.downloaderItem];

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

    NSLog(@"didSelectRowAtIndexPath");
    
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

#pragma mark - ZJDownloadManagerDelegate
- (void)zjDownloadOperationStartDownloading:(ZJDownloaderItem *)dItem{
    
}
- (void)zjDownloadOperationFinishDownload:(ZJDownloaderItem *)dItem{
    
    [self.downLists removeObjectForKey:dItem.downloadUrl];
    
}
- (void)zjDownloadOperationDownloading:(ZJDownloaderItem *)dItem downloadPercentage:(float)percentage velocity:(float)velocity{
    
    CGFloat progress = 1.0 * dItem.downloadedFileSize / dItem.totalFileSize;
    NSLog(@"%f",progress);
    
    DownloadList * model = [self.downLists valueForKey:dItem.downloadUrl];
    model.progress = progress;
    
    model.ratio = [NSString stringWithFormat:@"%.1fM/%.1fM",[self.downloadManager downloadLength:model.urlString],dItem.totalFileSize/1024.0/1024.0];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.tableView reloadRowsAtIndexPaths:@[model.indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

@end

