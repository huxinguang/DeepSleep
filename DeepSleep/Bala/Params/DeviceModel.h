//
//  DeviceModel.h
//  DeviceParamTest
//
//  Created by xinguang hu on 2019/8/28.
//  Copyright © 2019 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceModel : NSObject

@property (nonatomic, copy) NSString *os;
@property (nonatomic, copy) NSString *idfa;
@property (nonatomic, copy) NSString *idfv;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) long bootTime;
@property (nonatomic, assign) long currentTime;
@property (nonatomic, assign) long upTime;
@property (nonatomic, assign) long totalSpace;
@property (nonatomic, assign) long freeSpace;
@property (nonatomic, assign) long memory;
@property (nonatomic, assign) float brightness;
@property (nonatomic, copy) NSString *batteryStatus;
@property (nonatomic, assign) float batteryLevel;
@property (nonatomic, copy) NSString *cellIp;
@property (nonatomic, copy) NSString *wifiIp;
@property (nonatomic, copy) NSString *wifiNetmask;
@property (nonatomic, copy) NSString *networkType;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *bssid;
@property (nonatomic, assign) BOOL jailBreak;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *carrier;
@property (nonatomic, copy) NSString *countryIso;
@property (nonatomic, copy) NSString *mcc;
@property (nonatomic, copy) NSString *mnc;
@property (nonatomic, copy) NSString *imsi;
@property (nonatomic, copy) NSString *radioType;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *bundleId;
@property (nonatomic, copy) NSString *languages;
@property (nonatomic, copy) NSString *networkNames;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *timeZone;
@property (nonatomic, copy) NSString *kernelVersion;
@property (nonatomic, copy) NSString *gpsSwitch;
@property (nonatomic, copy) NSString *gpsAuthStatus;
@property (nonatomic, copy) NSString *trueIp;
@property (nonatomic, copy) NSString *vpnIp;
@property (nonatomic, copy) NSString *vpnNetmask;
@property (nonatomic, copy) NSString *mac;
@property (nonatomic, copy) NSString *proxyUrl;
@property (nonatomic, copy) NSString *dnsAddress;
@property (nonatomic, copy) NSString *signMd5;
@property (nonatomic, copy) NSString *gpsLocation;
@property (nonatomic, copy) NSString *env;
@property (nonatomic, copy) NSString *attached;
@property (nonatomic, assign) BOOL useProxy;
@property (nonatomic, copy) NSString *proxyType;
@property (nonatomic, assign) BOOL containCheatingApps;
@property (nonatomic, copy) NSString *hookInline;
@property (nonatomic, copy) NSString *hookIMP;
@property (nonatomic, assign) BOOL hasSim;



@end

NS_ASSUME_NONNULL_END
