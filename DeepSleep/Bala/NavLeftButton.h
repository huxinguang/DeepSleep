//
//  NavLeftButton.h
//  guitar
//
//  Created by xinguang hu on 2019/7/1.
//  Copyright © 2019 hxg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavLeftButton : UIButton

@property(nonatomic, copy) NSString *image_name;

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName title:(NSString *)title font:(UIFont *)font color:(UIColor *)color;

@end

