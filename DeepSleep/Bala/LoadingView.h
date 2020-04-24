//
//  LoadingView.h
//  ASOProj
//
//  Created by xinguang hu on 2019/7/18.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LoadingViewDelegate <NSObject>

- (void)refreshDidClick;

@end


@interface LoadingView : UIView

@property (nonatomic, strong)THProgressView *progressBar;
@property (nonatomic, strong)UIButton *refreshBtn;
@property (nonatomic, strong)UILabel *msgLabel;
@property (nonatomic, weak) id<LoadingViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
