//
//  Version.m
//  meishijia
//
//  Created by xinguang hu on 2019/5/29.
//  Copyright © 2019 hxg. All rights reserved.
//

#import "Version.h"

@implementation Version

- (instancetype)initFromDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.forceUpdate = [[dic objectForKey:@"forceUpdate"] intValue];
        self.latestVersion = [dic objectForKey:@"latestVersion"];
        self.updateDesc = [dic objectForKey:@"updateDesc"];
    }
    return self;
}

@end
