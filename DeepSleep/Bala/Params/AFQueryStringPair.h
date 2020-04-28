//
//  AFQueryStringPair.h
//  DeviceParamTest
//
//  Created by xinguang hu on 2019/9/2.
//  Copyright © 2019 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFQueryStringPair : NSObject

@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

//- (NSString *)URLEncodedStringValueWithSecurity;
- (NSString *)URLEncodedStringValueEncryptWithAesKey:(NSString *)aeskey;

@end

NS_ASSUME_NONNULL_END
