//
//  DGToast.m
//  DGImagePicker
//
//  Created by david on 2018/12/18.
//  Copyright © 2018 david. All rights reserved.
//


#import "DGToast.h"
#import "DGIP_Header.h"

#define kToastBottomMetric 60    //与底部的默认距离
#define kToastMarginWidth 20     //文字和黑框左右最下间距
#define kToastMarginHeigh 25     //文字和黑框上下间距和
#define kToastWidth 200          //黑框宽度

#define kDefaultDuration 3.0     //默认显示时间

@implementation DGToast

+ (instancetype)sharedToast {
    static dispatch_once_t onceToken;
    static DGToast *sharedToast;
    dispatch_once(&onceToken, ^{
        sharedToast = [[DGToast alloc] init];
    });
    return sharedToast;
}

+ (instancetype)makeText:(NSString *)text {
    DGToast *sharedToast = [self sharedToast];
    [sharedToast makeText:text color:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    return sharedToast;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
        [self addSubview:self.textLabel];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    }
    return self;
}

- (void)tap {
    [self dismiss];
}

- (void)_initialize {
    _textLabel = [[UILabel alloc] init];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont systemFontOfSize:12];
    _textLabel.numberOfLines = 0;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.preferredMaxLayoutWidth = kToastWidth - 2 * kToastMarginWidth;

    self.layer.cornerRadius = 3;
}

- (void)layoutSubviews {
    CGSize labelSize = self.textLabel.intrinsicContentSize;

    self.textLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - labelSize.width) / 2, (CGRectGetHeight(self.frame) - labelSize.height) / 2, labelSize.width, labelSize.height);
}

- (CGSize)intrinsicContentSize {
    CGSize labelSize = self.textLabel.intrinsicContentSize;
    return CGSizeMake(kToastWidth, labelSize.height + kToastMarginHeigh);
}


- (void)show {
    [self showWithOffset:0 duration:kDefaultDuration];
}

- (void)showWithOffset:(CGFloat)offsetY {
    [self showWithOffset:offsetY duration:kDefaultDuration];
}
- (void)showWithOffset:(CGFloat)offsetY duration:(CGFloat)duration{
    if (self.textLabel.text.length == 0) {
        return ;
    }

    CGFloat off = MIN(offsetY, DGIP_SCREEN_H - self.intrinsicContentSize.height - kToastBottomMetric);

    [self setFrame:CGRectMake((DGIP_SCREEN_W - self.intrinsicContentSize.width) / 2, off, self.intrinsicContentSize.width, self.intrinsicContentSize.height)];

    [self setNeedsLayout];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        [self setAlpha:1];
    }];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:duration inModes:@[ NSRunLoopCommonModes ]];
}

- (void)makeText:(NSString *)text color:(UIColor *)color {
    self.textLabel.text = text;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];

    [self invalidateIntrinsicContentSize];
}

- (void)dismiss {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self setAlpha:0];
    }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - convenience
+ (void)showMsg:(NSString *)msg{
    [self showMsg:msg duration:kDefaultDuration];
}

+ (void)showMsg:(NSString *)msg duration:(CGFloat)duration {
    [[DGToast makeText:msg] showWithOffset:DGIP_SCREEN_H/2 duration:duration];
}
@end
