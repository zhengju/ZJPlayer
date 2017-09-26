//
//  BigSuperViewController.h
//  BigHome
//
//  Created by zhengju on 16/2/15.
//  Copyright © 2016年 shengmei. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ZJSuperViewController : UIViewController

@property (strong ,nonatomic) UIImageView * backImage;

@property (strong, nonatomic) UIButton *backBtn;
@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *rightBtn1;
@property (strong, nonatomic) UIButton *rightBtn2;
@property (strong, nonatomic) UIView *midddleView;

- (void)backAction;


@end
