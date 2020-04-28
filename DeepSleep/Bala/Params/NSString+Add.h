//
//  NSString+Add.h
//  DeviceParamTest
//
//  Created by xinguang hu on 2019/8/28.
//  Copyright © 2019 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Add)

+ (NSString *)stringWithUUID;

+ (NSString *)getRandom16String;

+ (NSDictionary *)dictionaryFromUrlQueryString:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
