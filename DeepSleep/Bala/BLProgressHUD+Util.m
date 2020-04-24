//
//  BLProgressHUD+YbsUtil.m
//  ASOProj
//
//  Created by xinguang hu on 2019/4/15.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

#import "BLProgressHUD+Util.h"
#import "BLProgressHUD.h"

@implementation BLProgressHUD (Util)

+ (BLProgressHUD *)createHUD:(NSString *)message isWindow:(BOOL)isWindow{
    UIView *hudSuperView = isWindow ? [UIApplication sharedApplication].keyWindow : [self currentViewController].view;
    BLProgressHUD *hud = [BLProgressHUD showHUDAddedTo:hudSuperView animated:YES];
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:15];
    hud.bezelView.style = BLProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    hud.contentColor = [UIColor whiteColor];
    hud.margin = 15.0;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+ (UIViewController*)findBestViewController:(UIViewController*)vc {
    
    if (vc.presentedViewController) {
        
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
        
    } else {
        
        // Unknown view controller type, return last child view controller
        return vc;
        
    }
    
}

+ (UIViewController*) currentViewController {
    // Find best view controller
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
    
}


// ####################### Text #########################

+ (void)showTipInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    [self showTipMessage:message isWindow:NO hideDelay:hideDelay];
}

+ (void)showTipInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    [self showTipMessage:message isWindow:YES hideDelay:hideDelay];
}

+ (void)showTipMessage:(NSString *)message isWindow:(BOOL)isWindow hideDelay:(NSTimeInterval)hideDelay{
    BLProgressHUD *hud = [self createHUD:message isWindow:isWindow];
    hud.mode = BLProgressHUDModeText;
    [hud hideAnimated:YES afterDelay:hideDelay];
}

// ####################### Activity #######################

+ (void)showLoadingInView{
    [self showActivityInViewWithMessage:@"加载中..."];
}
+ (void)showLoadingInWindow{
    [self showActivityInWindowWithMessage:@"加载中..."];
}

+ (void)showActivityInViewWithMessage:(NSString *)message{
    [self showActivityWithMessage:message isWindow:NO];
}

+ (void)showActivityInWindowWithMessage:(NSString *)message{
    [self showActivityWithMessage:message isWindow:YES];
}

+ (void)showActivityWithMessage:(NSString *)message isWindow:(BOOL)isWindow{
    BLProgressHUD *hud = [self createHUD:message isWindow:isWindow];
    hud.mode = BLProgressHUDModeIndeterminate;
}

// ####################### Image #######################

+ (void)showSuccessInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    
    [self showImageInViewWithImage:@"BLHUD_Success" message:message hideDelay:hideDelay];
}

+ (void)showErrorInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    
    [self showImageInViewWithImage:@"BLHUD_Error" message:message hideDelay:hideDelay];
}

+ (void)showInfoInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    [self showImageInViewWithImage:@"BLHUD_Info" message:message hideDelay:hideDelay];
}

+ (void)showWarningInViewWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    
    [self showImageInViewWithImage:@"BLHUD_Warn" message:message hideDelay:hideDelay];
}

+ (void)showSuccessInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    [self showImageInWindowWithImage:@"BLHUD_Success" message:message hideDelay:hideDelay];
}

+ (void)showErrorInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    [self showImageInWindowWithImage:@"BLHUD_Error" message:message hideDelay:hideDelay];
}

+ (void)showInfoInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    [self showImageInWindowWithImage:@"BLHUD_Info" message:message hideDelay:hideDelay];
}

+ (void)showWarningInWindowWithMessage:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    [self showImageInWindowWithImage:@"BLHUD_Warn" message:message hideDelay:hideDelay];
}

+ (void)showImageInViewWithImage:(NSString *)imageName message:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    [self showImage:imageName message:message isWindow:NO hideDelay:hideDelay];
}

+ (void)showImageInWindowWithImage:(NSString *)imageName message:(NSString *)message hideDelay:(NSTimeInterval)hideDelay{
    [self showImage:imageName message:message isWindow:YES hideDelay:hideDelay];
}

+ (void)showImage:(NSString *)imageName message: (NSString *)message isWindow:(BOOL)isWindow hideDelay:(NSTimeInterval)hideDelay{
    BLProgressHUD *hud = [self createHUD:message isWindow:isWindow];
    hud.mode = BLProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    [hud hideAnimated:YES afterDelay:hideDelay];
}

// ####################### hide #######################

+ (void)hideHUD{
    UIView *view = [UIApplication sharedApplication].keyWindow;
    [self hideHUDForView:view animated:YES];
    [self hideHUDForView:[self currentViewController].view animated:YES];
}




@end
