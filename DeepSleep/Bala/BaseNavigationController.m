//
//  BaseNavigationController.m
//  meishijia
//
//  Created by xinguang hu on 2019/5/7.
//  Copyright © 2019 hxg. All rights reserved.
//

#import "BaseNavigationController.h"
#import "BalaUtil.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    if ([BalaUtil share].vm.forceUpdate == 1) {
        return UIStatusBarStyleDefault;
    }else{
        return UIStatusBarStyleLightContent;
    }
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
