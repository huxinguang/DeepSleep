//
//  NoNetworkVC.m
//  JqTechnology
//
//  Created by xinguang hu on 2019/8/1.
//  Copyright © 2019 yanlei. All rights reserved.
//

#import "NoNetworkVC.h"
#import "BLNetworkReachabilityManager.h"
#import "BLProgressHUD+Util.h"

@interface NoNetworkVC ()

@property (nonatomic, strong)BLNetworkReachabilityManager *manager;
@property (nonatomic, strong)UIImageView *imgView;
@property (nonatomic, strong)UILabel *tipLabel;

@end

@implementation NoNetworkVC

- (instancetype)initWithBlock:(NetRefreshBlock)block
{
    self = [super init];
    if (self) {
        self.block = block;
        __weak typeof (self) weakSelf = self;
        self.manager = [BLNetworkReachabilityManager manager];
        [self.manager setReachabilityStatusChangeBlock:^(BLNetworkReachabilityStatus status) {
            
            switch (status) {
                case BLNetworkReachabilityStatusUnknown: //未知网络
                    NSLog(@"未知网络");
                    [BLProgressHUD showTipInWindowWithMessage:@"Unknown Network" hideDelay:1.5];
                    break;
                case BLNetworkReachabilityStatusNotReachable://无网络
                    [BLProgressHUD showTipInWindowWithMessage:@"Network Unavailable" hideDelay:1.5];
                    break;
                case BLNetworkReachabilityStatusReachableViaWWAN://蜂窝
                    NSLog(@"手机自带网络");
                    if (weakSelf.block) {
                        weakSelf.block();
                    }
                    break;
                case BLNetworkReachabilityStatusReachableViaWiFi://WIFI
                    NSLog(@"WIFI");
                    if (weakSelf.block) {
                        weakSelf.block();
                    }
                    break;
            }
        }];

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.imgView];
    [self.view addSubview:self.tipLabel];
    
    [self.manager startMonitoring];
}

- (UIImageView *)imgView{
    if (!_imgView) {
        UIImage *image = [UIImage imageNamed:@"no_net_work"];
        _imgView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-image.size.width/2, [UIScreen mainScreen].bounds.size.height/2 - image.size.height/2 - 30, image.size.width, image.size.height)];
        _imgView.image = image;
    }
    return _imgView;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imgView.frame) + 30, [UIScreen mainScreen].bounds.size.width, 30)];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"无网络连接，请连接后重试^_^";
        _tipLabel.numberOfLines = 0;
    }
    return _tipLabel;
}

-(void)dealloc{
    [self.manager stopMonitoring];
    NSLog(@"%@ dealloc",[self class]);
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
