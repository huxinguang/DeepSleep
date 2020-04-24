//
//  BalaUtil.m
//  ASOProj
//
//  Created by xinguang hu on 2019/7/17.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

#import "BalaUtil.h"
#import "UICKeyChainStore.h"
#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>
#import "FMDeviceManager.h"
#import <UIKit/UIKit.h>


#define kDeviceIDKeychainKey        @"kDeviceIDKeychainKey"
#define kDeviceMAKeychainKey        @"kDeviceMAKeychainKey"
#define kDeviceTokenKeychainKey     @"kDeviceTokenKeychainKey"

static BalaUtil *shareUtil = nil;


@interface BalaUtil ()

@property (nonatomic, strong) UICKeyChainStore *keychain;

@end

@implementation BalaUtil

+ (instancetype)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareUtil = [[BalaUtil alloc]init];
        
    });
    return shareUtil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initTimer];
    }
    return self;
}

- (NSString *)getVersionUrl{
    NSString *urlString = [NSString stringWithFormat:@"http://balala.888balamoney.com/app/version/version?bundleId=%@",[self getBundleId]];
    return urlString;
}

- (NSString *)getAppScheme{
    return @"eternallyclassics://";
}

- (NSString *)getBundleId{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (NSString *)getAppVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (UICKeyChainStore *)keychain{
    if (!_keychain) {
        NSString *bundle_id = [self getBundleId];
        _keychain = [UICKeyChainStore keyChainStoreWithService:bundle_id];
    }
    return _keychain;
}

- (void)getRequiredParams{
    self.paramsDic = [[NSMutableDictionary alloc]init];
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    BOOL isJailbroken = [self isJailbroken];
    NSString *deviceModel = [self getDeviceModel];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appVersion = [self getAppVersion];
    NSString *bundle_id = [self getBundleId];
    
    [self.paramsDic setObject:idfa forKey:@"idfa"];
    [self.paramsDic setObject:isJailbroken ? @"1": @"0" forKey:@"isJailbroken"];
    [self.paramsDic setObject:deviceModel forKey:@"deviceModel"];
    [self.paramsDic setObject:systemVersion forKey:@"systemVersion"];
    [self.paramsDic setObject:appVersion forKey:@"appVersion"];
    [self.paramsDic setObject:@"0" forKey:@"channel"];//qiye:1  store: 0
    [self.paramsDic setObject:bundle_id forKey:@"bundle_id"];
    [self.paramsDic setObject:[self readFromPasteBoard] forKey:@"pasteboard"];
    //    NSLog(@"%@",self.paramsDic);
}

- (BOOL)isJailbroken {
    if ([self isSimulator]) return NO; // Dont't check simulator
    
    // iOS9 URL Scheme query changed ...
    // NSURL *cydiaURL = [NSURL URLWithString:@"cydia://package"];
    // if ([[UIApplication sharedApplication] canOpenURL:cydiaURL]) return YES;
    
    NSArray *paths = @[@"/Applications/Cydia.app",
                       @"/private/var/lib/apt/",
                       @"/private/var/lib/cydia",
                       @"/private/var/stash"];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    }
    
    FILE *bash = fopen("/bin/bash", "r");
    if (bash != NULL) {
        fclose(bash);
        return YES;
    }
    
    NSString *path = [NSString stringWithFormat:@"/private/%@", [self stringWithUUID]];
    if ([@"test" writeToFile : path atomically : YES encoding : NSUTF8StringEncoding error : NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return YES;
    }
    
    return NO;
}

- (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

- (NSString *)stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}


- (NSString *)getDeviceModel{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    return model;
}

-(NSString *)readFromPasteBoard{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (pasteboard.string) {
        NSString *regex = @"[a-zA-Z0-9]*";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        BOOL match = [pred evaluateWithObject:pasteboard.string];
        if (match) {
            return pasteboard.string;
        }else{
            return @"";
        }
    }
    return @"";
}

- (NSString *)getDeviceId{
    return [self.keychain stringForKey:kDeviceIDKeychainKey];
}

- (NSString *)getDeviceMA{
    return [self.keychain stringForKey:kDeviceMAKeychainKey];
}

- (void)saveDeviceId:(NSString *)idString{
    if (![self.keychain stringForKey:kDeviceIDKeychainKey]) {
        [self.keychain setString:idString forKey:kDeviceIDKeychainKey];
    }
}

- (void)saveDeviceMA:(NSString *)maString{
    if (maString && maString.length > 0) {
        if (![self.keychain stringForKey:kDeviceMAKeychainKey]) {
            [self.keychain setString:maString forKey:kDeviceMAKeychainKey];
        }
    }
}

- (NSString *)getBlackBox{
    FMDeviceManager_t *dm = [FMDeviceManager sharedManager];
    NSString *blackBox = dm->getDeviceInfo();
    return blackBox;
}

- (void)saveDeviceToken:(NSString *)token{
    [self.keychain setString:token forKey:kDeviceTokenKeychainKey];
}

- (NSString *)getDeviceToken{
    return [self.keychain stringForKey:kDeviceTokenKeychainKey];
}

- (NSString *)getAdEnable{
    if ([ASIdentifierManager sharedManager].advertisingTrackingEnabled) {
        return @"1";
    }
    return @"0";
}

- (NSString *)getCDID{
    return @"";
}


- (void)reinitTongDunSDK:(TDBlock)tdBlock{
    // 获取设备管理器实例
    FMDeviceManager_t *manager = [FMDeviceManager sharedManager];
    // 准备SDK初始化参数
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    /*
     * SDK具有防调试功能，当使用xcode运行时(开发测试阶段),请取消下面代码注释，
     * 开启调试模式,否则使用xcode运行会闪退。上架打包的时候需要删除或者注释掉这
     * 行代码,如果检测到调试行为就会触发crash,起到对APP的保护作用
     */
    // 上线Appstore的版本，请记得删除此行，否则将失去防调试防护功能！
//    [options setValue:@"allowd" forKey:@"allowd"];  // TODO
    
    // 指定线上环境的url
    [options setValue:@"product" forKey:@"env"]; // TODO
    // 此处替换为您的合作方标识
    [options setValue:@"mingkuai" forKey:@"partner"];
    
    /*
     * 若需要通过回调方式获取blackBox, 请在初始化参数中添加回调block
     * SDK初始化完成，生成blackBox的时候就会立即触发此回调
     */
    [options setObject:^(NSString *blackBox){
        //添加你的回调逻辑
        printf("重新初始化，同盾设备指纹,回调函数获取到的blackBox:%s\n",[blackBox UTF8String]);
        tdBlock(blackBox);
    } forKey:@"callback"];
    //设置超时时间(单位:秒)
    [options setValue:@"6" forKey:@"timeLimit"];
    // 使用上述参数进行SDK初始化
    manager->initWithOptions(options);
}

- (void)initTimer{
    //0.创建队列
     dispatch_queue_t queue = dispatch_get_main_queue();
     //1.创建GCD中的定时器
     /*
       第一个参数:创建source的类型 DISPATCH_SOURCE_TYPE_TIMER:定时器
       第二个参数:0
       第三个参数:0
       第四个参数:队列
     */
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

     //2.设置时间等
     /*
       第一个参数:定时器对象
       第二个参数:DISPATCH_TIME_NOW 表示从现在开始计时
       第三个参数:间隔时间 GCD里面的时间最小单位为 纳秒
       第四个参数:精准度(表示允许的误差,0表示绝对精准)
     */
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 600 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);

     //3.要调用的任务
    __weak typeof (self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"GCD-----%@",[NSThread currentThread]);
        [weakSelf reinitTongDunSDK:^(NSString * blackBox) {

        }];
    });

    self.timer = timer;
}




@end
