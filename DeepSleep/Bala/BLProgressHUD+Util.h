//
//  BLProgressHUD+YbsUtil.h
//  ASOProj
//
//  Created by xinguang hu on 2019/4/15.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

#import "BLProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLProgressHUD (YbsUtil)

+ (void)showTipInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)showTipInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)showLoadingInView;
+ (void)showLoadingInWindow;
+ (void)showActivityInViewWithMessage:(NSString *)message;
+ (void)showActivityInWindowWithMessage:(NSString *)message;
+ (void)showSuccessInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)showErrorInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)showInfoInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)showWarningInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)showSuccessInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)showErrorInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)showInfoInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)showWarningInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay;
+ (void)hideHUD;

@end

NS_ASSUME_NONNULL_END
