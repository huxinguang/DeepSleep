//
//  BaseViewController.m
//  guitar
//
//  Created by xinguang hu on 2019/7/1.
//  Copyright © 2019 hxg. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    //启用滑动返回
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self configLeftItem];
    [self configRightItem];
}

- (void)configLeftItem{
    if (self.navigationController.viewControllers.count > 1) {
        NavLeftButton *backBtn = [[NavLeftButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44) imageName:@"navigation_back" title:nil font:nil color:nil];
        [backBtn addTarget:self action:@selector(onBackClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    
}

- (void)configRightItem{
    
}

- (void)onBackClick{
    [self.navigationController popViewControllerAnimated:YES];
}

// 是否允许侧滑返回
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return self.navigationController.viewControllers.count > 1;
    }
    return YES;
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
