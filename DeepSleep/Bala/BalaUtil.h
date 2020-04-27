//
//  BalaUtil.h
//  ASOProj
//
//  Created by xinguang hu on 2019/7/17.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Version.h"

NS_ASSUME_NONNULL_BEGIN

//typedef void(^PushJumpBlock)(NSString *);
typedef void(^TDBlock)(NSString *);

@interface BalaUtil : NSObject

@property (strong, nonatomic) NSMutableDictionary *paramsDic;
@property (copy, nonatomic) NSString *pushUrl;
@property (assign, nonatomic) BOOL needJump;
@property (assign, nonatomic) BOOL isLaunch;
@property (strong, nonatomic) Version *vm;
@property (nonatomic ,strong) dispatch_source_t timer;//  注意:此处应该使用强引用 strong


+ (instancetype)share;

- (NSString *)getVersionUrl;

- (NSString *)getAppScheme;

- (NSString *)getBundleId;

- (NSString *)getAppVersion;

- (void)getRequiredParams;

- (NSString *)getDeviceId;

- (NSString *)getDeviceMA;

- (void)saveDeviceId:(NSString *)idString;

- (void)saveDeviceMA:(NSString *)maString;

- (NSString *)getBlackBox;

- (void)saveDeviceToken:(NSString *)token;

- (NSString *)getDeviceToken;

- (NSString *)getAdEnable;

- (NSString *)getCDID;

- (void)reinitTongDunSDK:(TDBlock)tdBlock;

- (NSDictionary *)dictionaryFromUrlQueryString:(NSString *)query;



@end

NS_ASSUME_NONNULL_END
