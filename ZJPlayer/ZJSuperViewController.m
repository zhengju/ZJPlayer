//
//  SuperViewController.m
//  BigHome
//
//  Created by zhengju on 16/4/29.
//  Copyright © 2016年 shengmei. All rights reserved.
//

#import "ZJSuperViewController.h"

@interface ZJSuperViewController ()

@property(nonatomic,strong)NSMutableArray * rightBarButtonItems;



@end

@implementation ZJSuperViewController

- (UIImageView *)backImage{
    
    if (_backImage == nil) {
        
        _backImage = [ [UIImageView alloc]initWithFrame:CGRectMake(120, 200, kScreenWidth - 120 *2 , (kScreenWidth - 120 *2)*11/9)];

        _backImage.image = [UIImage imageNamed:@"no_data"];
        
        _backImage.hidden = YES;
        
        [self.view addSubview:_backImage];
        
    }
    return _backImage;
}

- (NSMutableArray *)rightBarButtonItems{
    if (_rightBarButtonItems == nil) {
        _rightBarButtonItems = [NSMutableArray array];
    }
    return _rightBarButtonItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];

    //返回按钮
    [self.backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];

   // self.view.backgroundColor = COLORSting(@"#F0EFF4");

    self.automaticallyAdjustsScrollViewInsets =  NO;
/**
 设置statusBar和navigationbar为一体naBg
 */
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarMetrics:UIBarMetricsDefault];
    
   // [self.navigationController.navigationBar setBackgroundColor:[UIColor blueColor]];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
   
   
}

- (UIButton *)leftBtn{
    if (_leftBtn == nil) {
        _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];

      // [_leftBtn setTitle:@"返回" forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:_leftBtn];
        self.navigationItem.leftBarButtonItem = leftBarBtn;
    }
    return _leftBtn;
}
- (UIButton *)backBtn{
    if (_backBtn == nil) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];

        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _backBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        UIBarButtonItem *leftBackBarBtn = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
        self.navigationItem.leftBarButtonItem = leftBackBarBtn;
    }
    return _backBtn;
}
- (UIView *)midddleView{
    if (_midddleView == nil) {
        _midddleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
        //_midddleView.userInteractionEnabled = YES;
        self.navigationItem.titleView = _midddleView;
        
    }
    return _midddleView;
}
- (UIButton *)rightBtn1{

    if (_rightBtn1 == nil) {
        
        CGFloat Width = 40;
        
        _rightBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, Width, Width)];

        [_rightBtn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn1];
        [self.rightBarButtonItems addObject:rightBarBtn];

        self.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
    }
    return _rightBtn1;
}

- (UIButton *)rightBtn2{
    if (_rightBtn2 == nil) {
        _rightBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [_rightBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn2];
        [self.rightBarButtonItems addObject:rightBarBtn];
      self.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
    }
    return _rightBtn2;
}

#pragma mark - backAction返回
- (void)backAction
{
    if ((self.navigationController.presentedViewController || self.navigationController.presentingViewController)&&self.childViewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
     [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

@end
