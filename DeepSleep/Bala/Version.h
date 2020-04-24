//
//  Version.h
//  meishijia
//
//  Created by xinguang hu on 2019/5/29.
//  Copyright © 2019 hxg. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Version : NSObject

@property (nonatomic,assign) int forceUpdate;
@property (nonatomic,copy  ) NSString *latestVersion;
@property (nonatomic,copy  ) NSString *updateDesc;

- (instancetype)initFromDictionary:(NSDictionary *)dic;


@end

NS_ASSUME_NONNULL_END
