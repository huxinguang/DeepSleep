//
//  SecurityUtil.h
//  Smile
//
//  Created by apple on 15/8/25.
//  Copyright (c) 2015年 Weconex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityUtil : NSObject

#pragma mark - base64
+ (NSString *)encodeBase64String:(NSString *)input;
+ (NSString *)decodeBase64String:(NSString *)input;

+ (NSString *)encodeBase64Data:(NSData *)data;
+ (NSString *)decodeBase64Data:(NSData *)data;

#pragma mark - AES加密

+ (NSString *)encryptStringUsingAES:(NSString*)string aesKey:(NSString *)key;

+ (NSString *)decryptStringUsingAES:(NSString*)string aesKey:(NSString *)key;

@end
