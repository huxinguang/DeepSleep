//
//  TestViewController.m
//  ASOProj
//
//  Created by xinguang hu on 2019/4/17.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

#import "BalaViewController.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "BalaUtil.h"
#import "LoadingView.h"
#import "BLProgressHUD+Util.h"
#import "ThirdpartyWebVC.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface BalaViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate,LoadingViewDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, copy  ) NSString *entranceUrl;
@property (nonatomic, assign) BOOL finishNavigation;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) NSArray *strArr;
@property (nonatomic, assign) BOOL canRefresh;
@property (nonatomic, strong) NavRightButton *refreshBtn;
@property (nonatomic, strong) NSString *jsCallbackFuncStr;

@end

@implementation BalaViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.progressView.hidden = YES;
}

- (void)configRightItem{
    NavRightButton *rightBtn = [[NavRightButton alloc]initWithFrame:CGRectMake(0, 0, 24, 44) imageName:@"nav_refresh" title:nil font:nil color:nil];
    [rightBtn addTarget:self action:@selector(onRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.refreshBtn = rightBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_resume([BalaUtil share].timer);
    
    self.strArr = [[BalaUtil share].vm.updateDesc componentsSeparatedByString:@"####"];
    self.title = self.strArr[0];

    if (self.strArr.count >= 8 && [self.strArr[7] isEqualToString:@"canRefresh=Yes"]) {
        self.canRefresh = YES;
        self.refreshBtn.hidden = NO;
    }else{
        self.canRefresh = NO;
        self.refreshBtn.hidden = YES;
    }
    
    [self.navigationController.navigationBar addSubview:self.progressView];
    [self.view addSubview:self.webView];
    
    LoadingView *loadingView = [[LoadingView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    loadingView.delegate = self;
    [self.navigationController.view addSubview:loadingView];
    self.loadingView = loadingView;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToPushPage) name:@"JumpToPushPageNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveWxAuthResp:) name:@"kWxAuthRespNotification" object:nil];

    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    if ([[BalaUtil share].paramsDic[self.strArr[1]] isEqualToString:self.strArr[2]]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:self.strArr[5] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [self loadData];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

- (void) onRightBtnClick{
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

- (void)appEnterForeground{
    dispatch_resume([BalaUtil share].timer);
    if ([[BalaUtil share].paramsDic[self.strArr[1]] isEqualToString:self.strArr[2]]) {
        [[BalaUtil share] getRequiredParams];
        [self loadData];
    }
}

- (void)appEnterBackground{
    dispatch_suspend([BalaUtil share].timer);
}

- (void)didReceiveWxAuthResp:(NSNotification *)notification{
    SendAuthResp *resp = [notification.userInfo objectForKey:@"resp"];
    NSString *jsonString = [self jsonStringFromDictionary:@{@"data":resp.errCode == 0 ? resp.code : @"0"}];
    [self jsCallBack:self.jsCallbackFuncStr paramStr:jsonString];
    self.jsCallbackFuncStr = nil;
}

- (void)loadData{
    NSString *address = self.strArr[3];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:address]];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError *parseErr = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&parseErr];
            if (!parseErr && [dic[@"result"] isEqualToString:@"success"]) {
                NSString *urlStr = dic[@"url"];
                NSString *url = [self keyValueJointedFromDic:[BalaUtil share].paramsDic withPrefix:urlStr];
                self.entranceUrl = url;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.entranceUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
                    [self.webView loadRequest:request];
                });
            }else{
                [BLProgressHUD showTipInViewWithMessage:@"服务器异常" hideDelay:1.5];
            }
        }
    }];
    
    [task resume];
}

- (WKWebView *)webView{
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [WKUserContentController new];
        [configuration.userContentController addScriptMessageHandler:self name:@"openApp"];
        [configuration.userContentController addScriptMessageHandler:self name:@"share"];
        [configuration.userContentController addScriptMessageHandler:self name:@"openSafari"];
        [configuration.userContentController addScriptMessageHandler:self name:@"getParameter"];
        [configuration.userContentController addScriptMessageHandler:self name:@"goToThirdparty"];
        [configuration.userContentController addScriptMessageHandler:self name:@"getWxCode"];
        [configuration.userContentController addScriptMessageHandler:self name:@"canOpenApp"];
        [configuration.userContentController addScriptMessageHandler:self name:@"checkInstallation"];
        [configuration.userContentController addScriptMessageHandler:self name:@"getBalaToken"];
        
        _webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:configuration];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    
    return _webView;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 44-2, [UIScreen mainScreen].bounds.size.width, 2)];
        _progressView.tintColor = [UIColor colorWithRed:250.0/255.0 green:99.0/255.0 blue:85.0/255.0 alpha:1];
        _progressView.backgroundColor = [UIColor whiteColor];
        _progressView.trackTintColor = [UIColor whiteColor];
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 1.25f);
        _progressView.hidden = YES;
    }
    return _progressView;
}

- (BOOL)oawb:(NSString *)bd cls:(NSString *)cls_string seld:(NSString *)seld_string  selo:(NSString *)selo_string{
    
    const char *cls_char = [cls_string UTF8String];
    Class cls = objc_getClass(cls_char);
    SEL sel_d = NSSelectorFromString(seld_string);
    NSObject *ws = [cls performSelector:sel_d];
    SEL sel_o = NSSelectorFromString(selo_string);
    BOOL ooppeenneedd = [ws performSelector:sel_o withObject:bd];
    return ooppeenneedd;
    
}

- (void)openThirdpartyVC:(NSString *)url{
    self.progressView.hidden = YES;
    ThirdpartyWebVC *vc = [[ThirdpartyWebVC alloc]init];
    vc.url = [NSURL URLWithString:url];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)jsonStringFromDictionary:(NSDictionary *)dic {
    if ([NSJSONSerialization isValidJSONObject:dic]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

- (NSString *)keyValueJointedFromDic:(NSDictionary *)dic withPrefix:(NSString *)prefixString{
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@",prefixString];
    NSArray * keys = [dic allKeys];
    for (int j = 0; j < keys.count; j ++){
        NSString *string;
        if (j == 0){
            string = [NSString stringWithFormat:@"?%@=%@", keys[j], dic[keys[j]]];
        }else{
            string = [NSString stringWithFormat:@"&%@=%@", keys[j], dic[keys[j]]];
        }
        [urlStr appendString:string];
    }
    return urlStr;
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        self.loadingView.progressBar.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            if (self.loadingView) {
                self.progressView.hidden = YES;
            }else{
                [UIView animateWithDuration:0.1f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 0.5f);
                } completion:^(BOOL finished) {
                    self.progressView.hidden = YES;
                }];
            }
            
            [self.loadingView removeFromSuperview];
            self.loadingView = nil;
            NSLog(@"self.progressView.progress = 1");
            
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

- (void)refreshDidClick{
    [self loadData];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didStartProvisionalNavigation");
    if (self.canRefresh) {
        self.progressView.hidden = NO;
        self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.25f);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"didFinishNavigation");
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    [self.refreshBtn.layer removeAllAnimations];
    self.finishNavigation = YES;
    [self jumpToPushPage];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation");
    self.progressView.hidden = YES;
    [self.refreshBtn.layer removeAllAnimations];
    self.loadingView.progressBar.hidden = YES;
    self.loadingView.msgLabel.hidden = NO;
    self.loadingView.refreshBtn.hidden = NO;
    [BLProgressHUD showTipInViewWithMessage:@"页面加载失败" hideDelay:1.5];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    if ([message.name isEqualToString:@"openApp"]) {
        NSDictionary *jsData = message.body;
        NSString *jsFunctionString = jsData[@"result"];
        
        NSString *b_id = jsData[@"bundle_id"];
        NSString *cls = jsData[@"cls"];
        NSString *sel_d = jsData[@"sel_d"];
        NSString *sel_o = jsData[@"sel_o"];
        
        NSString *jsonString;
        
        if ([self oawb:b_id cls:cls seld:sel_d selo:sel_o]) {
            jsonString = [self jsonStringFromDictionary:@{@"data":@"1"}];
        }else{
            jsonString = [self jsonStringFromDictionary:@{@"data":@"0"}];
    
        }
        [self jsCallBack:jsFunctionString paramStr:jsonString];

    }else if ([message.name isEqualToString:@"share"]){
        NSDictionary *jsData = message.body;
        NSString *jsFunctionString = jsData[@"result"];
        NSString *platformType = jsData[@"platformType"];
        NSString *title = jsData[@"title"];
        NSString *description = jsData[@"description"];
        //NSString *thumbUrl = jsData[@"thumbUrl"];
        NSString *webpageUrl = jsData[@"webpageUrl"];
        NSString *jsonString;
        if ([platformType intValue] == 1 || [platformType intValue] == 2) {
            if ([WXApi isWXAppInstalled]) {
                WXMediaMessage *message = [WXMediaMessage message];
                message.title = title;
                message.description = description;
                [message setThumbImage:[UIImage imageNamed:@"thumb_share"]];
                WXWebpageObject *ext = [WXWebpageObject object];
                ext.webpageUrl = webpageUrl;
                message.mediaObject = ext;
                SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = 0;
                __weak typeof (self) weakSelf = self;
                [WXApi sendReq:req completion:^(BOOL success) {
                    NSString *jsonString = [weakSelf jsonStringFromDictionary:@{@"data":success ? @"1" : @"0"}];
                    [weakSelf jsCallBack:jsFunctionString paramStr:jsonString];
                }];
            
            }else{
                NSString *jsonString = [self jsonStringFromDictionary:@{@"data":@"0"}];
                [self jsCallBack:jsFunctionString paramStr:jsonString];
            }
        }else if ([platformType intValue] == 4){
            if ([QQApiInterface isQQInstalled]) {
                UIImage *image = [UIImage imageNamed:@"thumb_share"];
                NSData *data = UIImagePNGRepresentation(image);
                QQApiNewsObject *newsObj = [[QQApiNewsObject alloc]initWithURL:[NSURL URLWithString:webpageUrl] title:title description:description previewImageData:data targetContentType:QQApiURLTargetTypeNews];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
                QQApiSendResultCode result = [QQApiInterface sendReq:req];
                NSString *jStr = [self jsonStringFromDictionary:@{@"data":result == EQQAPISENDSUCESS ? @"1" : @"0" }];
                [self jsCallBack:jsFunctionString paramStr:jStr];
            }
            
        }else{
            jsonString = [self jsonStringFromDictionary:@{@"data":@"0"}];
            [self jsCallBack:jsFunctionString paramStr:jsonString];
        }
            
    }else if ([message.name isEqualToString:@"openSafari"]){
        NSDictionary *jsData = message.body;
        NSString *jsFunctionString = jsData[@"result"];
        NSString *urlString = jsData[@"url"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
            NSString *jsonString = [self jsonStringFromDictionary:@{@"data":success ? @"1" : @"0"}];
            [self jsCallBack:jsFunctionString paramStr:jsonString];
        }];
        
        
    }else if ([message.name isEqualToString:@"getParameter"]){
        NSDictionary *jsData = message.body;
        NSString *jsFunctionString = jsData[@"result"];
        NSString *paramType = jsData[@"paramType"];
        NSString *jsonString;
        
        if ([paramType isEqualToString:@"deviceId"]) {
            NSString *deviceId = [[BalaUtil share] getDeviceId];
            if (deviceId && deviceId.length > 0) {
                jsonString = [self jsonStringFromDictionary:@{@"data":deviceId}];
            }else{
                jsonString = [self jsonStringFromDictionary:@{@"data":@"0"}];
            }
        }else if ([paramType isEqualToString:@"deviceMa"]){
            NSString *deviceMa = [[BalaUtil share] getDeviceMA];
            if (deviceMa && deviceMa.length > 0) {
                jsonString = [self jsonStringFromDictionary:@{@"data":deviceMa}];
            }else{
                jsonString = [self jsonStringFromDictionary:@{@"data":@"0"}];
            }
        }else if ([paramType isEqualToString:@"blackBox"]){
            
            NSString *blackBox = [[BalaUtil share] getBlackBox];
            if (blackBox && blackBox.length > 0) {
                jsonString = [self jsonStringFromDictionary:@{@"data":blackBox}];
            }else{
                jsonString = [self jsonStringFromDictionary:@{@"data":@"0"}];
            }
        }else if ([paramType isEqualToString:@"blackBox_new"]){
            __weak typeof (self) weakSelf = self;
            [[BalaUtil share] reinitTongDunSDK:^(NSString * blackBox) {
                NSString *jStr = @"";
                if (blackBox && blackBox.length > 0) {
                    jStr = [self jsonStringFromDictionary:@{@"data":blackBox}];
                }else{
                    jStr = [self jsonStringFromDictionary:@{@"data":@"0"}];
                }
                [weakSelf jsCallBack:jsFunctionString paramStr:jStr];
            }];
            
            return;
            
        }else if ([paramType isEqualToString:@"deviceToken"]){
            NSString *deviceToken = [[BalaUtil share] getDeviceToken];
            if (deviceToken && deviceToken.length > 0) {
                jsonString = [self jsonStringFromDictionary:@{@"data":deviceToken}];
            }else{
                jsonString = [self jsonStringFromDictionary:@{@"data":@"0"}];
            }
        }else if ([paramType isEqualToString:@"adEnable"]){
            NSString *enable = [[BalaUtil share] getAdEnable];
            jsonString = [self jsonStringFromDictionary:@{@"data":enable}];
        }else if ([paramType isEqualToString:@"cdid"]){
            NSString *cdid = [[BalaUtil share] getCDID];
            jsonString = [self jsonStringFromDictionary:@{@"data":cdid}];
        }
        
        [self jsCallBack:jsFunctionString paramStr:jsonString];
        
    }else if ([message.name isEqualToString:@"goToThirdparty"]){
        NSDictionary *jsData = message.body;
        NSString *jsFunctionString = jsData[@"result"];
        NSString *url = jsData[@"url"];
        [self openThirdpartyVC:url];
        NSString *jsonString = [self jsonStringFromDictionary:@{@"data":@"1"}];
        [self jsCallBack:jsFunctionString paramStr:jsonString];
    }else if ([message.name isEqualToString:@"getWxCode"]){
        NSDictionary *jsData = message.body;
        NSString *jsFunctionString = jsData[@"result"];
        if ([WXApi isWXAppInstalled]) {
            self.jsCallbackFuncStr = jsFunctionString;
            //构造SendAuthReq结构体
            SendAuthReq *req = [[SendAuthReq alloc]init];
            req.scope = @"snsapi_userinfo";
            req.state = @"2020";
            //第三方向微信终端发送一个SendAuthReq消息结构
            [WXApi sendReq:req completion:^(BOOL success) {
            }];
        }else{
            NSString *jsonString = [self jsonStringFromDictionary:@{@"data":@"-1"} ];
            [self jsCallBack:jsFunctionString paramStr:jsonString];
        }
    }else if ([message.name isEqualToString:@"canOpenApp"]){
        NSDictionary *jsData = message.body;
        NSString *jsFunctionString = jsData[@"result"];
        NSString *scheme = jsData[@"scheme"];
        NSString *jsonString = [self jsonStringFromDictionary:@{@"data":[[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:scheme]] ? @"1" : @"0"} ];
        [self jsCallBack:jsFunctionString paramStr:jsonString];
    }else if ([message.name isEqualToString:@"checkInstallation"]){
        NSDictionary *jsData = message.body;
        NSString *jsFunctionString = jsData[@"result"];
        NSMutableDictionary *dic = @{}.mutableCopy;
        [dic setObject:[[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"weixin://"]] ? @"1" : @"0" forKey:@"weixin"];
        [dic setObject:[[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"mqq://"]] ? @"1" : @"0" forKey:@"qq"];
        [dic setObject:[[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"taobao://"]] ? @"1" : @"0" forKey:@"taobao"];
        NSString *jsonString = [self jsonStringFromDictionary:dic];
        [self jsCallBack:jsFunctionString paramStr:jsonString];
    }else if ([message.name isEqualToString:@"getBalaToken"]){
        NSDictionary *jsData = message.body;
        NSString *jsFunctionString = jsData[@"result"];
        NSString *jsonString = [self jsonStringFromDictionary:@{@"data":[[BalaUtil share] getBalaToken]}];
        [self jsCallBack:jsFunctionString paramStr:jsonString];
    }
    
}

- (void)jsCallBack:(NSString *)funcStr paramStr: (NSString *)paramStr{
    NSString *jsCallBack = [NSString stringWithFormat:@"(%@)(%@);", funcStr, paramStr];
    //执行回调
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:jsCallBack completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"err is %@", error.domain);
            }
        }];
    });
    
}


#pragma mark - WKUIDelegate
//解决js alert不显示问题
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];


    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)jumpToPushPage{
    if ([BalaUtil share].needJump && self.finishNavigation) {
        if ([BalaUtil share].pushUrl && [BalaUtil share].pushUrl.length > 0) {
            self.entranceUrl = [BalaUtil share].pushUrl;
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[BalaUtil share].pushUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
            [self.webView loadRequest:request];
        }
        [BalaUtil share].needJump = NO;
    }
}


-(void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
