//
//  BaseViewController.h
//  guitar
//
//  Created by xinguang hu on 2019/7/1.
//  Copyright © 2019 hxg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavLeftButton.h"
#import "NavRightButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

- (void)configLeftItem;
- (void)configRightItem;

@end

NS_ASSUME_NONNULL_END
