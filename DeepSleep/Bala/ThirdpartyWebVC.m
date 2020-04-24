//
//  ThirdpartyWebVC.m
//  guitar
//
//  Created by xinguang hu on 2019/8/13.
//  Copyright © 2019 hxg. All rights reserved.
//

#import "ThirdpartyWebVC.h"
#import <WebKit/WebKit.h>
#import "BLProgressHUD+Util.h"

@interface ThirdpartyWebVC ()<WKNavigationDelegate>

@property (nonatomic, strong) NavRightButton *refreshBtn;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation ThirdpartyWebVC

- (void)configLeftItem{
    NavLeftButton *backBtn = [[NavLeftButton alloc]initWithFrame:CGRectMake(0, 0, 32, 44) imageName:@"navi_back_black" title:nil font:nil color:nil];
    [backBtn addTarget:self action:@selector(webviewGoBack) forControlEvents:UIControlEventTouchUpInside];
    NavLeftButton *closeBtn = [[NavLeftButton alloc]initWithFrame:CGRectMake(0, 0, 40, 44) imageName:@"navi_close" title:nil font:nil color:nil];
    [closeBtn addTarget:self action:@selector(popVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc]initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItems = @[item1,item2];
}

- (void)configTitleView{
    CGFloat lw = [UIScreen mainScreen].bounds.size.width-20-32-8-40-8-8-24-20-10;
    CGFloat fontSize = (12*[UIScreen mainScreen].bounds.size.width/375) > 15 ? 15 : (12*[UIScreen mainScreen].bounds.size.width/375);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, lw, 22)];
    label.text = [NSString stringWithFormat:@" 来自 %@",self.url.host];
    label.font = [UIFont boldSystemFontOfSize:fontSize];
    label.textColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1];
    label.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
    label.layer.cornerRadius = 3;
    label.layer.masksToBounds = YES;
    label.layer.borderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1].CGColor;
    label.layer.borderWidth = 1;
    self.navigationItem.titleView = label;
}

- (void)configRightItem{
    NavRightButton *rightBtn = [[NavRightButton alloc]initWithFrame:CGRectMake(0, 0, 24, 44) imageName:@"nav_refresh" title:nil font:nil color:nil];
    [rightBtn addTarget:self action:@selector(onRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.refreshBtn = rightBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
    self.progressView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTitleView];
    
    // progress
    UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 44-2, [UIScreen mainScreen].bounds.size.width, 2)];
    progressView.tintColor = [UIColor colorWithRed:250.0/255.0 green:99.0/255.0 blue:85.0/255.0 alpha:1];
    progressView.backgroundColor = [UIColor whiteColor];
    progressView.trackTintColor = [UIColor whiteColor];
    progressView.transform = CGAffineTransformMakeScale(1.0f, 1.25f);
    [self.navigationController.navigationBar addSubview:progressView];
    
    self.progressView = progressView;
    
    
    // webview
    WKWebViewConfiguration *configuration  = [[WKWebViewConfiguration alloc]init];
    configuration.allowsInlineMediaPlayback = YES;
    WKWebView *webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:configuration];
    webView.backgroundColor = [UIColor whiteColor];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [webView loadRequest:request];
    self.webView = webView;
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

- (void)webviewGoBack{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self popVC];
    }
}

- (void)popVC{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onRightBtnClick{
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    [self.webView reload];

    [self.refreshBtn.layer removeAllAnimations];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat: M_PI *2];
    animation.duration = 0.6;
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT;
    [self.refreshBtn.layer addAnimation:animation forKey:@"refreshAnimation"];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.1f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 0.5f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    self.progressView.hidden = NO;
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.25f);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.refreshBtn.layer removeAllAnimations];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self.refreshBtn.layer removeAllAnimations];
    [BLProgressHUD showTipInViewWithMessage:@"加载失败" hideDelay:1.5];
    self.progressView.hidden = YES;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return NO;
    }
    return YES;
    
}

- (void)dealloc{
    [self.refreshBtn.layer removeAllAnimations];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
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
