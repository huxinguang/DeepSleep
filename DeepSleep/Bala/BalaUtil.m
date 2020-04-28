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

//************

#import "DeviceModel.h"

#import <AdSupport/AdSupport.h>
#import <sys/utsname.h>//获取设备型号、内核版本

#import <CoreTelephony/CTTelephonyNetworkInfo.h> //运营商
#import <CoreTelephony/CTCarrier.h>

#import <SystemConfiguration/CaptiveNetwork.h>//wifi信息

#import "Reachability.h"//获取网络类型

#import "UIDevice+Add.h"
#import "NSString+Add.h"

#import <sys/stat.h>
#import <dlfcn.h>  //是否越狱

#include <arpa/inet.h> //DNS
#include <ifaddrs.h>
#include <resolv.h>
#include <dns.h>


#import <sys/sockio.h>
#import <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#include <string.h>//检测dylib（动态链接库）的内容
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>


#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLError.h>


#include <dlfcn.h> // 蜂窝基站 cellInfo
#include <stdio.h>
#include <stdlib.h>


#import "ParamUtil.h"//参数加密
#import "NSString+Add.h"
#import "RSA.h"
#import "SecurityUtil.h"

#define kRSA_PublicKey  @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDGW4I/1il5JvpZ8rkEfBX6n8Ak4uXlF+LkYF0SiewTg2jAQr4AEVMbVPzgdlo/72ykgJ6m/celMtDRIcSVEtuDXkJzeILHseV/pq0kg9+BdXs0xxsi9xLNNOSiDZe5m99AWe1495zhr9qpsnHqNyTP53rH/V/Xvujhz6zqrl5lxQIDAQAB"

//************


#define kDeviceIDKeychainKey        @"kDeviceIDKeychainKey"
#define kDeviceMAKeychainKey        @"kDeviceMAKeychainKey"
#define kDeviceTokenKeychainKey     @"kDeviceTokenKeychainKey"

static BalaUtil *shareUtil = nil;


@interface BalaUtil ()

@property (nonatomic, strong) UICKeyChainStore *keychain;
@property (nonatomic, strong) DeviceModel *dm;

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
    NSString *urlString = [NSString stringWithFormat:@"http://balala.bala888money.com/app/version/version?bundleId=%@",[self getBundleId]];
    return urlString;
}

- (NSString *)getAppScheme{
    return @"sleeptunes://";
}

- (NSString *)getBundleId{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

- (NSString *)getAppVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)getBalaToken{
    self.balaParamsDic = [[NSMutableDictionary alloc]init];
    
    NSString *version = @"1";
    [self.balaParamsDic setObject:version forKey:@"version"];
    
    NSString *os = [[UIDevice currentDevice] systemVersion];
    [self.balaParamsDic setObject:os forKey:@"os"];
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [self.balaParamsDic setObject:idfa forKey:@"idfa"];
    
    
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [self.balaParamsDic setObject:idfv forKey:@"idfv"];
    
    NSString *uuid = [NSString stringWithUUID];
    [self.balaParamsDic setObject:uuid forKey:@"uuid"];
    
    [self getUptime];
    
    int64_t totalSpace = [UIDevice currentDevice].diskSpace;
    [self.balaParamsDic setObject:[NSNumber numberWithLongLong:totalSpace] forKey:@"totalSpace"];
    
    
    int64_t freeSpace = [UIDevice currentDevice].diskSpaceFree;
    [self.balaParamsDic setObject:[NSNumber numberWithLongLong:freeSpace] forKey:@"freeSpace"];
    
    
    int64_t memo = [NSProcessInfo processInfo].physicalMemory;
    [self.balaParamsDic setObject:[NSNumber numberWithLongLong:memo] forKey:@"memory"];
    
    
    CGFloat b = [UIScreen mainScreen].brightness;
    [self.balaParamsDic setObject:[NSNumber numberWithDouble:b] forKey:@"brightness"];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    UIDeviceBatteryState state = [[UIDevice currentDevice] batteryState];
    NSString *status = @"";
    switch (state) {
        case UIDeviceBatteryStateUnknown:
            status = @"Unknown";
            break;
        case UIDeviceBatteryStateUnplugged:
            status = @"Unplugged";
            break;
        case UIDeviceBatteryStateCharging:
            status = @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            status = @"Full";
            break;
        default:
            break;
    }
    [self.balaParamsDic setObject:status forKey:@"batteryStatus"];
    
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float level = [[UIDevice currentDevice] batteryLevel];
    [self.balaParamsDic setObject:[NSNumber numberWithFloat:level] forKey:@"batteryLevel"];
    
    
    [self getCurentLocalIP];
    
    NSString *networkType = [self getNetworkType];
    [self.balaParamsDic setObject:networkType forKey:@"networkType"];
    
    [self getWifiInfo];
    
    BOOL jailBreak = [UIDevice currentDevice].isJailBreak;
    [self.balaParamsDic setObject:[NSNumber numberWithBool:jailBreak] forKey:@"jailBreak"];
    
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    [self.balaParamsDic setObject:model forKey:@"platform"];
    
    
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    [self.balaParamsDic setObject:osVersion forKey:@"osVersion"];
    
    NSString *deviceName = [UIDevice currentDevice].name;
    [self.balaParamsDic setObject:deviceName forKey:@"deviceName"];
    
    
    [self getCarrierInfo];
    
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [self.balaParamsDic setObject:bundleId forKey:@"bundleId"];
    
    
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    [self.balaParamsDic setObject:language forKey:@"languages"];
    
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [self.balaParamsDic setObject:appVersion forKey:@"appVersion"];
    
    NSString *timeZone = [NSTimeZone localTimeZone].name;
    [self.balaParamsDic setObject:timeZone forKey:@"timeZone"];
    
    NSString *kernelVersion = [self getKernelVersion];
    [self.balaParamsDic setObject:kernelVersion forKey:@"kernelVersion"];
    
    
    NSString *gpsSwitch = [CLLocationManager locationServicesEnabled] ? @"ON" : @"OFF";
    [self.balaParamsDic setObject:gpsSwitch forKey:@"gpsSwitch"];
    
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    NSString *authString = @"";
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined:
            authString = @"NotDetermined";
            break;
        case kCLAuthorizationStatusRestricted:
            authString = @"Restricted";
            break;
        case kCLAuthorizationStatusDenied:
            authString = @"Denied";
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            authString = @"Always";
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            authString = @"WhenInUse";
            break;
        default:
            break;
    }
    [self.balaParamsDic setObject:authString forKey:@"gpsAuthStatus"];
    

    NSString *trueIp = [self getTrueIPAddress];
    [self.balaParamsDic setObject:trueIp forKey:@"trueIp"];
    
    
    NSString *mac = [self getMacAddress];
    [self.balaParamsDic setObject:mac forKey:@"mac"];
    
    NSMutableArray *dnsArray = [self getDNSServers];
    NSString *dnsAddress = [dnsArray componentsJoinedByString:@","];
    [self.balaParamsDic setObject:dnsAddress forKey:@"dnsAddress"];
    
    NSString *env = [self getEnv];
    [self.balaParamsDic setObject:env forKey:@"env"];
    
    NSDictionary *dic = [self getProxyInfo];
    NSString *proxyType = [dic objectForKey:(NSString *)kCFProxyTypeKey];
    BOOL useProxy = ![proxyType isEqualToString:@"kCFProxyTypeNone"];
    [self.balaParamsDic setObject:proxyType forKey:@"proxyType"];
    [self.balaParamsDic setObject:[NSNumber numberWithBool:useProxy] forKey:@"useProxy"];
    
    
    NSString *proxyHost = [dic objectForKey:(NSString *)kCFProxyHostNameKey];
    NSString *proxyPort = [dic objectForKey:(NSString *)kCFProxyPortNumberKey];
    NSString *proxyUrl = @"";
    if ([proxyType isEqualToString:@"kCFProxyTypeHTTP"]) {
        proxyUrl = [NSString stringWithFormat:@"http://%@:%@",proxyHost,proxyPort];
    }else if ([proxyType isEqualToString:@"kCFProxyTypeHTTPS"]){
        proxyUrl = [NSString stringWithFormat:@"https://%@:%@",proxyHost,proxyPort];
    }else if ([proxyType isEqualToString:@"kCFProxyTypeSOCKS"]){
        proxyUrl = [NSString stringWithFormat:@"socks://%@:%@",proxyHost,proxyPort];
    }else if ([proxyType isEqualToString:@"kCFProxyTypeFTP"]){
        proxyUrl = [NSString stringWithFormat:@"ftp://%@:%@",proxyHost,proxyPort];
    }
    
    [self.balaParamsDic setObject:proxyUrl forKey:@"proxyUrl"];
    
    BOOL hasSim = [self isSimInserted];
    [self.balaParamsDic setObject:[NSNumber numberWithBool:hasSim] forKey:@"hasSim"];
    
    BOOL wx = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"weixin://"]];
    [self.balaParamsDic setObject:[NSNumber numberWithBool:wx] forKey:@"weixin"];
    
    BOOL qq = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"mqq://"]];
    [self.balaParamsDic setObject:[NSNumber numberWithBool:qq] forKey:@"qq"];
    
    BOOL taobao = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"taobao://"]];
    [self.balaParamsDic setObject:[NSNumber numberWithBool:taobao] forKey:@"taobao"];
    
    BOOL jingdong = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"openApp.jdMobile://"]];
    [self.balaParamsDic setObject:[NSNumber numberWithBool:jingdong] forKey:@"jingdong"];
    
    if ([NSJSONSerialization isValidJSONObject:self.balaParamsDic]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.balaParamsDic options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",json);
        if (!error){
            NSString *jsonEncrypt = [RSA encryptString:json publicKey:kRSA_PublicKey];
            return jsonEncrypt;
        }
    }
    return @"";
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
    [options setValue:@"allowd" forKey:@"allowd"];  // TODO
    
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

- (NSDictionary *)dictionaryFromUrlQueryString:(NSString *)query{
    NSArray *strArr = [query componentsSeparatedByString:@"&"];
    //把strArr转换为字典
    //tempDic中存放一个URL中转换的键值对
    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
    for (int j=0;j<strArr.count; j++){
        //在通过=拆分键和值
        NSArray *dicArray = [strArr[j] componentsSeparatedByString:@"="];
        //给字典加入元素
        [result setObject:dicArray[1] forKey:dicArray[0]];
    }
    
    return result;
}

- (time_t)getUptime{
//    http://www.itkeyword.com/doc/0334439811584752378/getting-ios-system-uptime-that-doesnt-pause-when-asleep
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;
    (void)time(&now);
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0){
        uptime = now - boottime.tv_sec;
    }
    
    self.dm.bootTime = boottime.tv_sec;
    self.dm.currentTime = now;
    self.dm.upTime = uptime;
    
    [self.balaParamsDic setObject:[NSNumber numberWithLong:boottime.tv_sec] forKey:@"bootTime"];
    [self.balaParamsDic setObject:[NSNumber numberWithLong:now] forKey:@"currentTime"];
    [self.balaParamsDic setObject:[NSNumber numberWithLong:uptime] forKey:@"uptime"];

    return uptime;
}

- (NSString *)getCurentLocalIP {
    struct ifaddrs *ifa, *ifa_tmp;
    char addr[50];
    int success = getifaddrs(&ifa);
    if (success != 0) {
        return @"0.0.0.0";
    }
    NSString *wifiIp = @"";
    NSString *wifiNetmask = @"";
    NSString *cellIp = @"";
    NSString *vpnIp = @"";
    NSString *vpnNetmask = @"";
    NSMutableArray *netNames = @[].mutableCopy;
    ifa_tmp = ifa;
    while (ifa_tmp) {
        if ((ifa_tmp->ifa_addr) && ((ifa_tmp->ifa_addr->sa_family == AF_INET) ||
                                    (ifa_tmp->ifa_addr->sa_family == AF_INET6))) {
            if (ifa_tmp->ifa_addr->sa_family == AF_INET) {
                // create IPv4 string
                struct sockaddr_in *in = (struct sockaddr_in*) ifa_tmp->ifa_addr;
                inet_ntop(AF_INET, &in->sin_addr, addr, sizeof(addr));
            } else { // AF_INET6
                // create IPv6 string
                struct sockaddr_in6 *in6 = (struct sockaddr_in6*) ifa_tmp->ifa_addr;
                inet_ntop(AF_INET6, &in6->sin6_addr, addr, sizeof(addr));
            }
            NSString *name = [NSString stringWithFormat:@"%s",ifa_tmp->ifa_name];
            NSLog(@"%@",name);
            NSString *address = [NSString stringWithFormat:@"%s",addr];

            // en0 WIFI, pdp_ip0 蜂窝网, utun0 VPN
            if (address.length <= 15) { // 排除 fe80::10fb:284:1d52:9ef6
                if (![netNames containsObject:name]) {
                    [netNames addObject:name];
                }
                if ([name isEqualToString:@"en0"]) { // WIFI
                    wifiIp = address;
                    self.dm.wifiIp = wifiIp;
                    wifiNetmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)ifa_tmp->ifa_netmask)->sin_addr)];
                    self.dm.wifiNetmask = wifiNetmask;
//                    break;
                }
                if ([name isEqualToString:@"pdp_ip0"]) { // 蜂窝移动数据
                    cellIp = address;
                    self.dm.cellIp = cellIp;
                }
                
                if ([name isEqualToString:@"utun0"] || [name isEqualToString:@"utun1"]) { // VPN
                    vpnIp = address;
                    self.dm.vpnIp = vpnIp;
                    vpnNetmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)ifa_tmp->ifa_netmask)->sin_addr)];
                    self.dm.vpnNetmask = vpnNetmask;
                }
                
                
            }
            
        }
        ifa_tmp = ifa_tmp->ifa_next;
    }
    freeifaddrs(ifa);
    
    NSString *networkNames = [netNames componentsJoinedByString:@","];
    self.dm.networkNames = networkNames;
    
    [self.balaParamsDic setObject:wifiIp forKey:@"wifiIp"];
    [self.balaParamsDic setObject:wifiNetmask forKey:@"wifiNetmask"];
    [self.balaParamsDic setObject:cellIp forKey:@"cellIp"];
    [self.balaParamsDic setObject:vpnIp forKey:@"vpnIp"];
    [self.balaParamsDic setObject:vpnNetmask forKey:@"vpnNetmask"];
    [self.balaParamsDic setObject:networkNames forKey:@"networkNames"];

    return wifiIp ?: cellIp;
}

- (NSString *)getNetworkType{
    
    NSString *netType = @"";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {
            netType = @"None";
        }
            break;
        case ReachableViaWiFi:// Wifi
        {
            netType = @"Wifi";
        }
            break;
        case ReachableViaWWAN:// 手机自带网络
        {
            netType = @"WWAN";
        }
            break;
        default:
            break;
    }
    
    return netType;
}

- (void)getWifiInfo{
    NSString *ssid = @"";
    NSString *bssid = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            ssid = [dict valueForKey:@"SSID"];
            bssid = [dict valueForKey:@"BSSID"];
        }
    }
    
    self.dm.ssid = ssid;
    self.dm.bssid = bssid;
    
    [self.balaParamsDic setObject:ssid forKey:@"ssid"];
    [self.balaParamsDic setObject:bssid forKey:@"bssid"];
    
}

- (void)getCarrierInfo{
    NSMutableArray *carriers = [NSMutableArray array];
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    if (@available(iOS 12.0, *)) {
        NSDictionary *dic = [telephonyInfo serviceSubscriberCellularProviders];
        NSDictionary *dic2 = [telephonyInfo serviceCurrentRadioAccessTechnology];
        [dic.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CTCarrier *carr = [dic objectForKey:obj];
            NSMutableDictionary *carrierDic = [self getInfoWithCarrier:carr];
            NSString *radioType = [dic2 objectForKey:obj];
            [carrierDic setObject:radioType == nil ? @"" : radioType forKey:@"radioType"];
            [carriers addObject:carrierDic];
        }];
    } else {
        // Fallback on earlier versions
        CTCarrier *carrier = telephonyInfo.subscriberCellularProvider;
        NSMutableDictionary *carrierDic = [self getInfoWithCarrier:carrier];
        [carrierDic setObject:telephonyInfo.currentRadioAccessTechnology == nil ? @"" : telephonyInfo.currentRadioAccessTechnology forKey:@"radioType"];
    }
    
    [self.balaParamsDic setObject:carriers forKey:@"carriers"];
    
}

- (NSMutableDictionary *)getInfoWithCarrier:(CTCarrier *)carrier{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:carrier.carrierName == nil ? @"" : carrier.carrierName forKey:@"carrier"];
    [dic setObject:carrier.isoCountryCode == nil ? @"" : carrier.isoCountryCode forKey:@"countryIso"];
    [dic setObject:carrier.mobileCountryCode == nil ? @"" : carrier.mobileCountryCode forKey:@"mcc"];
    [dic setObject:carrier.mobileNetworkCode == nil ? @"" : carrier.mobileNetworkCode forKey:@"mnc"];
    NSString *imsi = [NSString stringWithFormat:@"%@%@",carrier.mobileCountryCode == nil ? @"" :carrier.mobileCountryCode ,carrier.mobileNetworkCode == nil ? @"" : carrier.mobileNetworkCode];
    [dic setObject:imsi forKey:@"imsi"];
    return dic;
}

- (NSString *)getKernelVersion{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *version = [NSString stringWithCString:systemInfo.version encoding:NSASCIIStringEncoding];
    return version;
}

- (NSString *)getTrueIPAddress{
    //需要禁用ATS,否则返回data为空
    NSURL *ipURL = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
    NSData *data = [NSData dataWithContentsOfURL:ipURL];
    NSString *ipStr = @"";
    if (data) {
        NSDictionary *ipDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (ipDic && [ipDic[@"code"] integerValue] == 0) {
            ipStr = ipDic[@"data"][@"ip"];
        }
    }
    self.dm.trueIp = ipStr;
    return ipStr;
}

- (NSString *)getMacAddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    NSLog(@"outString:%@", outstring);
    
    free(buf);
    
    return [outstring uppercaseString];
}

// 获取本机DNS服务器
- (NSMutableArray *)getDNSServers
{
    res_state res = malloc(sizeof(struct __res_state));
    
    int result = res_ninit(res);
    
    NSMutableArray *dnsArray = @[].mutableCopy;
    
    if ( result == 0 )
    {
        for ( int i = 0; i < res->nscount; i++ )
        {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res->nsaddr_list[i].sin_addr)];
            
            [dnsArray addObject:s];
        }
    }
    else{
        NSLog(@"%@",@" res_init result != 0");
    }
    
    res_nclose(res);
    
    return dnsArray;
}

- (NSString *)getEnv{
    /* 通常，越狱机的输出结果会包含字符串：Library/MobileSubstrate/MobileSubstrate.dylib。 攻击者给MobileSubstrate改名，原理都是通过DYLD_INSERT_LIBRARIES注入动态库。那么可以检测当前程序运行的环境变量
     */
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env != NULL) {
        return [NSString stringWithUTF8String:env];
    }
    return @"";
}

- (NSDictionary *)getProxyInfo{
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com/"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSDictionary *settings = proxies[0];
    return settings;
}

- (BOOL)isSimInserted{
    BOOL hasSim = NO;
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    if (@available(iOS 12.0, *)) {
        NSDictionary *dic = [networkInfo serviceSubscriberCellularProviders];
        if (dic.allKeys.count) {
            CTCarrier *carrier = [dic objectForKey:dic.allKeys[0]];
            if (carrier.isoCountryCode) {
                hasSim = YES;
            }
        }
    } else {
        CTCarrier *carrier = networkInfo.subscriberCellularProvider;
        hasSim = carrier.isoCountryCode != nil;
    }
    return hasSim;
}



@end
