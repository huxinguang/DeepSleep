//
//  NSString+Add.m
//  DeviceParamTest
//
//  Created by xinguang hu on 2019/8/28.
//  Copyright © 2019 huxinguang. All rights reserved.
//

#import "NSString+Add.h"

@implementation NSString (Add)

+ (NSString *)stringWithUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

+ (NSString *)getRandom16String{
    NSString * result = @"";
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstufwsyz";
    // Get the characters into a C array for efficient shuffling
    uint32_t numberOfCharacters = 16;//[alphabet length];
    unichar *characters = calloc(numberOfCharacters, sizeof(unichar));
    [alphabet getCharacters:characters range:NSMakeRange(0, numberOfCharacters)];
    
    // Perform a Fisher-Yates shuffle
    for (uint32_t i = 0; i < 16; ++i) {
        uint32_t j = (arc4random_uniform(numberOfCharacters - i) + i);
        unichar c = characters[i];
        characters[i] = characters[j];
        characters[j] = c;
    }
    
    // Turn the result back into a string
    result = [NSString stringWithCharacters:characters length:numberOfCharacters];
    
    return result;
}

+ (NSDictionary *)dictionaryFromUrlQueryString:(NSString *)query{
    NSArray *strArr = [query componentsSeparatedByString:@"&"];
    //把strArr转换为字典
    //tempDic中存放一个URL中转换的键值对
    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
    for (int j=0;j<strArr.count; j++){
        //在通过=拆分键和值
        NSArray *dicArray = [strArr[j] componentsSeparatedByString:@"="];
        //给字典加入元素
        [result setObject:dicArray[1] forKey:dicArray[0]];
    }
    
    return result;
}

@end
