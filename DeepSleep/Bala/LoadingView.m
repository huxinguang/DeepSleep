//
//  LoadingView.m
//  ASOProj
//
//  Created by xinguang hu on 2019/7/18.
//  Copyright © 2019 Yunbangshou. All rights reserved.
//

#import "LoadingView.h"
#import "FLAnimatedImage.h"

#define kGifWidth   ([UIScreen mainScreen].bounds.size.width*0.6)
#define kGifHeight  (kGifWidth*397/432)
#define kDistanceY  20
#define kProgressWidth  kGifWidth*0.8
#define kProgressHeight  20
#define kRefreshBtnWidth  80
#define kRefreshBtnHeight  30


@interface LoadingView ()

@property (nonatomic, strong)FLAnimatedImageView *gifView;

@end

@implementation LoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.gifView];
        [self addSubview:self.msgLabel];
        [self addSubview:self.progressBar];
        self.progressBar.progress = 0;
        [self addSubview:self.refreshBtn];
        self.refreshBtn.hidden = YES;
        self.msgLabel.hidden = YES;
        
        
    }
    return self;
}

- (FLAnimatedImageView *)gifView{
    if (!_gifView) {
        NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:gifPath]];
        _gifView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - kGifWidth/2 , [UIScreen mainScreen].bounds.size.height/2 - (kGifHeight+kDistanceY+kProgressHeight)/2 - 20, kGifWidth , kGifHeight)];
        _gifView.animatedImage = image;
    }
    return _gifView;
}

- (THProgressView *)progressBar{
    if (!_progressBar) {
        _progressBar = [[THProgressView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 -kProgressWidth/2, CGRectGetMaxY(self.gifView.frame) + kDistanceY, kProgressWidth, kProgressHeight)];
        _progressBar.borderTintColor = [UIColor colorWithRed:221.0/255.0 green:87.0/255.0 blue:75.0/255.0 alpha:1];
        _progressBar.progressTintColor = [UIColor colorWithRed:221.0/255.0 green:87.0/255.0 blue:75.0/255.0 alpha:1];
        
    }
    return _progressBar;
}

- (UIButton *)refreshBtn{
    if (!_refreshBtn) {
        _refreshBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 -kRefreshBtnWidth/2, CGRectGetMaxY(self.progressBar.frame) + 40, kRefreshBtnWidth, kRefreshBtnHeight)];
        _refreshBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:87.0/255.0 blue:75.0/255.0 alpha:1];
        [_refreshBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        _refreshBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _refreshBtn.layer.cornerRadius = 3;
        _refreshBtn.layer.masksToBounds = YES;
        [_refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.gifView.frame) + kDistanceY, [UIScreen mainScreen].bounds.size.width, 20)];
        _msgLabel.text = @"加载失败，请重试~";
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = [UIFont systemFontOfSize:15];
        _msgLabel.textColor = [UIColor colorWithRed:221.0/255.0 green:87.0/255.0 blue:75.0/255.0 alpha:1];
    }
    return _msgLabel;
}

- (void)refresh{
    
    if ([self.delegate respondsToSelector:@selector(refreshDidClick)]) {
        [self.delegate refreshDidClick];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
