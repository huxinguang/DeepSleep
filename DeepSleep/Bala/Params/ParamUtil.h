//
//  ParamUtil.h
//  DeviceParamTest
//
//  Created by xinguang hu on 2019/9/2.
//  Copyright © 2019 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParamUtil : NSObject

+ (NSString *)encryptParamsUsingAES:(NSDictionary *)paramsDic aesKey:(NSString *)aesKey;


@end

NS_ASSUME_NONNULL_END
