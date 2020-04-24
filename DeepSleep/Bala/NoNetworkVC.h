//
//  NoNetworkVC.h
//  JqTechnology
//
//  Created by xinguang hu on 2019/8/1.
//  Copyright © 2019 yanlei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NetRefreshBlock)(void);

@interface NoNetworkVC : UIViewController

@property (nonatomic, copy) NetRefreshBlock block;

- (instancetype)initWithBlock:(NetRefreshBlock)block;

@end

NS_ASSUME_NONNULL_END
