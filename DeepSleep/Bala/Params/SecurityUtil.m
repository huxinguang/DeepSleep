//
//  SecurityUtil.h
//  Smile
//
//  Created by apple on 15/8/25.
//  Copyright (c) 2015年 Weconex. All rights reserved.
//

#import "SecurityUtil.h"
#import "GTMBase64.h"
#import "NSData+AES.h"
#import <CommonCrypto/CommonDigest.h>

#define Iv   @"0102030405060708" //偏移量,可自行修改  //
#define KEY  @"t9pqg2z3gk597j26" //key，可自行修改

@implementation SecurityUtil

#pragma mark - base64
+ (NSString *)encodeBase64String:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [GTMBase64 encodeData:data]; 
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
    
}

+ (NSString *)decodeBase64String:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [GTMBase64 decodeData:data]; 
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
} 

+ (NSString *)encodeBase64Data:(NSData *)data {
	data = [GTMBase64 encodeData:data]; 
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}

+ (NSString *)decodeBase64Data:(NSData *)data {
	data = [GTMBase64 decodeData:data]; 
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return base64String;
}

#pragma mark - AES加密

+ (NSString *)encryptStringUsingAES:(NSString*)string aesKey:(NSString *)key{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用aes秘钥对NSData进行加密
    NSData *encryptedData = [data AES128EncryptWithKey:key gIv:Iv];
    //加密后使用BASE64做转码功能，同时能起到2次加密的作用。解密也要先用base64解密。
    return [self encodeBase64Data:encryptedData];
}

#pragma mark - AES解密
+ (NSString *)decryptStringUsingAES:(NSString*)string aesKey:(NSString *)key{
    NSData *decodeBase64Data=[GTMBase64 decodeString:string];
    NSData *decryData = [decodeBase64Data AES128DecryptWithKey:key gIv:Iv];
    NSString *str = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return str;
}

@end
