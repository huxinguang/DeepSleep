//
//  UIDevice+Add.h
//  DeviceParamTest
//
//  Created by xinguang hu on 2019/8/28.
//  Copyright © 2019 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Add)

- (BOOL)isJailBreak;

- (int64_t)diskSpace;

- (int64_t)diskSpaceFree;

- (int64_t)diskSpaceUsed;

- (int64_t)memoryTotal;

- (int64_t)memoryUsed;

- (int64_t)memoryFree;




@end

NS_ASSUME_NONNULL_END
